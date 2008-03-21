-----------------------------------------------------------------------------
-- Provides an implementation of versium storage using the LuaSQL abstraction
-- layer.  This provides the lowest common denominator SQL definitions, and
-- it should work on all the provided drivers.
-----------------------------------------------------------------------------

module(..., package.seeall)
require("luasql.sqlite3")

-----------------------------------------------------------------------------
-- Prepares a SQL statement using placeholders.
-- 
-- @param statement      the statement to be prepared
-- @param ...            a list of parameters  
-- @return               the prepared statement.
-----------------------------------------------------------------------------
local function prepare(statement, ...)
    local count = select('#', ...)
    
    if count > 0 then
        local someBindings = {}
        
        for index = 1, count do
            local value = select(index, ...)
            local type = type(value)
            
            if type == 'string' then
                value = '\'' .. value:gsub('\'', '\'\'') .. '\''
            elseif type == 'nil' then
                value = 'null'
            else
                value = tostring(value)
            end 
            
            someBindings[index] = value
        end
        
        statement = statement:format(unpack(someBindings))
    end

    return statement
end

local schemas = {}
schemas.node = [[
CREATE TABLE IF NOT EXISTS %s ( 
  id TEXT,
  version INTEGER,
  author TEXT,
  comment TEXT,
  timestamp TEXT,
  data BLOB,
  PRIMARY KEY(id, version)
);]]
schemas.node_index = [[
CREATE TABLE IF NOT EXISTS %s (
  id TEXT,
  version INTEGER,
  PRIMARY KEY (id)
);]]

Storage = {}

-----------------------------------------------------------------------------
-- Instantiates a new storage object.
-- 
-- @param impl           the implementation module.
-- @param params         the parameters to pass to the implementation.
-- @return               a new versium object.
-----------------------------------------------------------------------------
function Storage:new(params, versium)
  	-- Params table accepts the following:
	-- prefix - A string that will be prepended to table names
	-- connect - A list that is passed to the luasql connection function
	-- Try to connect to the given database

  	local env = luasql.sqlite3()
	local con = env:connect(unpack(params.connect))

	if not con then
		versium.storage_error("SQLite3 Versium: Could not connect to database")
	end

	self.tables = {}

	-- Create the two data tables, if they don't already exist
	local tables = {"node", "node_index"}

	for idx,tbl in ipairs(tables) do
		self.tables.node = string.format("%snode", params.prefix or "")
		self.tables.node_index = string.format("%snode_index", params.prefix or "")

      local cmd = prepare(schemas[tbl]:format(self.tables[tbl]))
      assert(con:execute(cmd))
	end


	-- Pre-build our queries
	self.queries = {
		GET_NODE_VERSION = string.format("SELECT id,data,version from %s WHERE id = %%s and version = %%s;", self.tables.node),
		GET_NODE_LATEST = string.format("SELECT n.id,n.data,n.version FROM %s as n NATURAL JOIN %s WHERE n.id = %%s;", self.tables.node, self.tables.node_index),
		GET_VERSION = string.format("SELECT max(version) as version FROM %s WHERE id = %%s;", self.tables.node),
		GET_NODES = string.format("SELECT id FROM %s ORDER BY id;", self.tables.node_index),
 		NODE_EXISTS = string.format("SELECT DISTINCT id FROM %s WHERE id = %%s;", self.tables.node),
		INSERT_NODE = string.format("INSERT INTO %s (id,version,author,comment,timestamp,data) VALUES (%%s, %%s, %%s, %%s, %%s, %%s);", self.tables.node),
		INSERT_INDEX = string.format("INSERT INTO %s (id, version) VALUES (%%s, %%s);", self.tables.node_index),
		UPDATE_INDEX = string.format("UPDATE %s SET version=%%s WHERE id = %%s;", self.tables.node_index),
		GET_METADATA = string.format("SELECT id,version,timestamp,author,comment FROM %s WHERE id = %%s ORDER BY timestamp;", self.tables.node),
		GET_METADATA_LATEST = string.format("SELECT n.id,n.version,timestamp,author,comment FROM %s as n NATURAL JOIN %s WHERE id = %%s ORDER BY timestamp;", self.tables.node, self.tables.node_index),
	}

	-- Create the new object
	local obj = {con=con, versium=versium}
	setmetatable(obj, self)
	self.__index = self

	return obj 
end

-----------------------------------------------------------------------------
-- Returns a table representing the node with a given id.
--
-- @param id             the node id.
-- @param version        the desired version of the node (defaults to current).
-- @return               the node as table with its content in node.data.
-----------------------------------------------------------------------------
function Storage:get_node(id, version)
	-- Get the most recent version of the node
	local cmd
	if version then
		cmd = prepare(self.queries.GET_NODE_VERSION, id, version)
	else
		cmd = prepare(self.queries.GET_NODE_LATEST, id)
	end

	-- Run the query to get the node
	local cur = assert(self.con:execute(cmd))

	-- If we still don't have a version
   local row = cur:fetch({}, "a")

   if not row then
		versium.storage_error(version.errors.NODE_DOES_NOT_EXIST, tostring(id))
	end

	assert(row.data)

	return row
end

-----------------------------------------------------------------------------
-- Returns a table representing a node that doesn't actually exist yet.
--
-- @return               the stub of the node as a table.
-----------------------------------------------------------------------------
function Storage:get_stub(id)
   return {
      version = "000000",
      data = "",
      id = id,
   }
end

-----------------------------------------------------------------------------
-- Returns true if the node with this id exists and false otherwise.
-- 
-- @param id             an id of an node.
-- @return               true or false.
-----------------------------------------------------------------------------
function Storage:node_exists(id)
	assert(id)

	local cmd = prepare(self.queries.NODE_EXISTS, id)
	local cur = assert(self.con:execute(cmd))
   local row = cur:fetch({}, "*a")
	cur:close()

	return row ~= nil
end

-----------------------------------------------------------------------------
-- Returns a list of IDs of all nodes in the repository, in no particular order.
-- 
-- @return               a list of IDs.
-----------------------------------------------------------------------------
function Storage:get_node_ids()
	local nodes = {}
	local cmd = prepare(self.queries.GET_NODES)
	local cur = self.con:execute(cmd)
	local row = cur:fetch({}, "a")

	while row do
		nodes[#nodes+1] = row.id
		row = cur:fetch(row, "a")
	end
	
	cur:close()
	return nodes
end

-----------------------------------------------------------------------------
-- Saves a new version of the node.
--
-- @param id             the id of the node (required).
-- @param data           the value to save (required, but "" is ok).
-- @param author         the user name to be associated with the change (required).
-- @param comment        the change comment (optional).
-- @param extra          any extra metadata (optional).
-- @return               the version id of the new node.
-----------------------------------------------------------------------------
function Storage:save_version(id, data, author, comment, extra, timestamp)
	assert (id)
	assert(data)
	assert(author)

	-- generate and save the new index
	if not timestamp then
		local t = os.date("*t")
		timestamp = string.format("%02d-%02d-%02d %02d:%02d:%02d", t.year, t.month, t.day, t.hour, t.min, t.sec)
	end

	-- Escape all backslashes in the data, since it will be going through a gsub filter
	data = data:gsub("\\", "\\\\")

	-- Determine what the new version number will be
	local cmd = prepare(self.queries.GET_VERSION, id)
	local cur = self.con:execute(cmd)
	local row = cur:fetch({}, "a")
	cur:close()

	local out = ""
	for k,v in pairs(row) do
		out = out .. "key: " .. tostring(k) .. " Value: " .. tostring(v)
	end

	local new
	local version = row and tonumber(row.version)
	if not version then
		version = 1
		new = true
	else
		version = version + 1
	end

	-- Store the new node in the 'nodes' table
	local cmd = prepare(self.queries.INSERT_NODE, id, version, author, comment, timestamp, data)
	local cur,err = assert(self.con:execute(cmd), out)
	
	-- Update the index table to the newest revision
	if new then
		local cmd = prepare(self.queries.INSERT_INDEX, id, version)
		local cur,err = self.con:execute(cmd)
		assert(cur, err)
	else
		local cmd = prepare(self.queries.UPDATE_INDEX, version, id) 
		local cur,err = self.con:execute(cmd)
		assert(cur, err)
	end

	-- Return the new version number
	return version
end

-----------------------------------------------------------------------------
-- Returns the history of the node as a list of tables, each representing a 
-- revision of the node (with fields like version, author, comment, and extra).
-- The version can be filtered by a time prefix. Returns an empty table if 
-- the node does not exist.
--
-- @param id        the id of the node.
-- @param prefix    time prefix.
-- @return history  a list of tables representing the versions (the list will
-- be empty if the node doesn't exist)
-----------------------------------------------------------------------------
function Storage:get_node_history(id, prefix)
	assert(id)

	local history = {}

	-- Pull the history of the given node
	local cmd = prepare(self.queries.GET_METADATA, id)
	local cur = self.con:execute(cmd)
	local row = cur:fetch({}, "a")

	while row do
      table.insert(history, 1, row)
		row = cur:fetch({}, "a")
	end

	cur:close()

	return history
end

-----------------------------------------------------------------------------
-- Returns a table with the metadata for the latest version of the node. Same
-- as get_node_history(id)[1] in case of this implementation.
-- 
-- @param id             an id of an node.
-- @return               the metadata for the latest version or nil.
-----------------------------------------------------------------------------
function Storage:get_node_info(id)
	assert(id)

	-- Fetch the latest version number
	local cmd = prepare(self.queries.GET_METADATA_LATEST, id)
	local cur = assert(self.con:execute(cmd))
	local row = cur:fetch({}, "a")
	cur:close()

	return row
end

-----------------------------------------------------------------------------
-- Creates a new storage object.
-- 
-- @param params         the parameters to pass to the implementation.
-- @param versium        a generic versium instance.
-- @return               the new versium storage object.
-----------------------------------------------------------------------------

function open(params, versium)
   return Storage:new(params, versium)
end

-- vim:ts=3 ss=3 sw=3 expandtab
