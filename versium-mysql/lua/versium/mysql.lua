-----------------------------------------------------------------------------
-- Implements Versium API using using the LuaSQL driver for MySQL.
--
-- (c) 2008  James Whitehead II (jnwhiteh@gmail.com)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)
local util = require("versium.util")
local errors = require("versium.errors")
require("luasql.mysql")

-----------------------------------------------------------------------------
-- A table that describes what this versium implementation can and cannot do.
-----------------------------------------------------------------------------
capabilities = {
   can_save = true,
   has_history = true,
   is_persistent = true,
   get_nodes_prefix = true,
}

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
   id VARCHAR(255) NOT NULL,
   version INT UNSIGNED NOT NULL AUTO_INCREMENT,
   author VARCHAR(255) NOT NULL,
   comment TEXT,
   timestamp CHAR(19) NOT NULL,
   data MEDIUMBLOB NOT NULL,
   PRIMARY KEY(id, version)
);]]
schemas.node_index = [[
CREATE TABLE IF NOT EXISTS %s (
   id VARCHAR(255) NOT NULL,
   version INT UNSIGNED NOT NULL,
   PRIMARY KEY (id)
);]]

-----------------------------------------------------------------------------
-- A table representing the class.
-----------------------------------------------------------------------------
local MySQLVersium = {}
local MySQLVersium_mt = {__metatable = {}, __index = MySQLVersium}

-----------------------------------------------------------------------------
-- Instantiates a new MySQLVersium object that represents a connection to
-- a storage system.  This is the only function that this module exports.
-- 
-- @param params         a table of parameters
-- @return               a new versium object.
-----------------------------------------------------------------------------
function new(params)
  	-- Params table accepts the following:
	-- prefix - A string that will be prepended to table names
	-- connect - A list that is passed to the luasql connection function

	-- Try to connect to the given database
  	local env = luasql.mysql()
	local con = env:connect(unpack(params))

	if not con then
	   errors.could_not_initialize("Could not connect to MySQL database")
	end

   -- Create the new object
	local obj = {con=con, versium=versium}
	setmetatable(obj, MySQLVersium_mt)

	obj.tables = {}

	-- Create the two data tables, if they don't already exist
	local tables = {"node", "node_index"}

	for idx,tbl in ipairs(tables) do
		obj.tables.node = string.format("%snode", params.prefix or "")
		obj.tables.node_index = string.format("%snode_index", params.prefix or "")

      local cmd = prepare(schemas[tbl]:format(obj.tables[tbl]))
      assert(con:execute(cmd))
	end

	-- Pre-build our queries
	obj.queries = {
		GET_NODE_VERSION = string.format("SELECT id,data,version from %s WHERE id = %%s and version = %%s;", obj.tables.node),
		GET_NODE_LATEST = string.format("SELECT n.id,n.data,n.version FROM %s as n NATURAL JOIN %s WHERE n.id = %%s;", obj.tables.node, obj.tables.node_index),
		GET_VERSION = string.format("SELECT max(version) as version FROM %s WHERE id = %%s;", obj.tables.node),
      GET_NODES_PREFIX = string.format("SELECT n.* FROM %s as n NATURAL JOIN %s WHERE n.id LIKE %%s;", obj.tables.node, obj.tables.node_index),
		GET_NODE_IDS = string.format("SELECT id FROM %s ORDER BY id;", obj.tables.node_index),
		GET_NODE_IDS_PREFIX_LIMIT = string.format("SELECT id FROM %s WHERE id LIKE %%s ORDER BY id LIMIT %%s;", obj.tables.node_index),
      GET_NODE_IDS_PREFIX = string.format("SELECT id FROM %s WHERE id LIKE %%s ORDER BY id;", obj.tables.node_index),
      GET_NODE_IDS_LIMIT = string.format("SELECT id FROM %s ORDER BY id LIMIT %%s;", obj.tables.node_index),
      NODE_EXISTS = string.format("SELECT DISTINCT id FROM %s WHERE id = %%s;", obj.tables.node),
		INSERT_NODE = string.format("INSERT INTO %s (id,author,comment,timestamp,data) VALUES (%%s, %%s, %%s, %%s, %%s);", obj.tables.node),
		INSERT_INDEX = string.format("INSERT INTO %s (id, version) VALUES (%%s, %%s);", obj.tables.node_index),
		UPDATE_INDEX = string.format("UPDATE %s SET version=%%s WHERE id = %%s;", obj.tables.node_index),
      GET_METADATA_ALL = string.format("SELECT id,version,timestamp,author,comment FROM %s WHERE id = %%s ORDER BY timestamp;", obj.tables.node),
		GET_METADATA_VERSION = string.format("SELECT id,version,timestamp,author,comment FROM %s WHERE id = %%s and version = %%s;", obj.tables.node),
		GET_METADATA_LATEST = string.format("SELECT n.id,n.version,timestamp,author,comment FROM %s as n NATURAL JOIN %s WHERE n.id = %%s ORDER BY timestamp;", obj.tables.node, obj.tables.node_index),
	}

	return obj 
end

-----------------------------------------------------------------------------
-- Returns the data stored in the node as a string and a table representing
-- the node's metadata.  Returns nil if the node doesn't exist.  Throws an
-- error if anything else goes wrong.
--
-- @param id             a node id.
-- @param version        [optional] the desired version of the node (defaults
--                       to current).
-- @return               a byte-string representing the data stored in the
--                       node or nil if the node could not be loaded or nil.
-- @return               a table representing the metadata, including the
--                       following fields (see get_node_history()) or nil.
-- @see get_node_history
-----------------------------------------------------------------------------
function MySQLVersium:get_node(id, version)
   assert(id)

	-- Get the most recent version of the node
	local cmd
	if version then
		cmd = prepare(self.queries.GET_NODE_VERSION, id, version)
	else
		cmd = prepare(self.queries.GET_NODE_LATEST, id)
	end

	-- Run the query to get the node
	local cur = assert(self.con:execute(cmd))
   local row = cur:fetch({}, "a")
   cur:close()

   if not row then
      return nil
   end

   -- Query the metadata
   local cmd
   if version then
      cmd = prepare(self.queries.GET_METADATA_VERSION, id, version)
   else
      cmd = prepare(self.queries.GET_METADATA_LATEST, id)
   end

	local cur = assert(self.con:execute(cmd))
	local metadata = cur:fetch({}, "a")
	cur:close()

	assert(row.data)
	return row.data, metadata
end

-----------------------------------------------------------------------------
-- Returns true if the node with this id exists and false otherwise.
-- 
-- @param id             an id of an node.
-- @return               true or false.
-----------------------------------------------------------------------------
function MySQLVersium:node_exists(id)
	assert(id)

	local cmd = prepare(self.queries.NODE_EXISTS, id)
	local cur = assert(self.con:execute(cmd))
   local row = cur:fetch({}, "*a")
	cur:close()

	return row ~= nil
end

-----------------------------------------------------------------------------
-- Returns a table with the metadata for the latest version of the node. Same
-- as get_node_history(id)[1] in case of this implementation.
-- 
-- @param id             an id of an node.
-- @return               the metadata for the latest version or nil.
-----------------------------------------------------------------------------
function MySQLVersium:get_node_info(id)
	assert(id)

	-- Fetch the latest version number
	local cmd = prepare(self.queries.GET_METADATA_LATEST, id)
	local cur = assert(self.con:execute(cmd))
	local row = cur:fetch({}, "a")
	cur:close()

	return row
end

-----------------------------------------------------------------------------
-- Returns a list of existing node ids, up to a certain limit.  (If no limit
-- is specified, all ids are returned.)  The ids can be optionally filtered
-- by prefix.  (In this case, the limit applies to the number of ids that
-- are being _returned_.)  The ids can be returned in any order.
--
-- @param prefix         [optional] a prefix to filter the ids (defaults to
--                       "").
-- @param limit          [optional] the maximum number of ids to return.
-- @return               a list of node ids.
-- @return               true if there are more ids left.
-----------------------------------------------------------------------------
function MySQLVersium:get_node_ids(prefix, limit)
	local nodes = {}
   local cmd
   if prefix and limit then
      prefix = prefix .. "%"
      cmd = prepare(self.queries.GET_NODE_IDS_PREFIX_LIMIT, prefix, limit)
   elseif prefix then
      prefix = prefix .. "%"
      cmd = prepare(self.queries.GET_NODE_IDS_PREFIX, prefix)
   elseif limit then
      cmd = prepare(self.queries.GET_NODE_IDS_LIMIT, limit)
   else
      cmd = prepare(self.queries.GET_NODE_IDS)
   end

	local cur = assert(self.con:execute(cmd))
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
function MySQLVersium:save_version(id, data, author, comment, extra, timestamp)
	assert (id)
	assert(data)
	assert(author)

	if not timestamp then
		local t = os.date("*t")
		timestamp = string.format("%02d-%02d-%02d %02d:%02d:%02d", t.year, t.month, t.day, t.hour, t.min, t.sec)
	end

   data = data:gsub("\\", "\\\\")

	-- Store the new node in the 'nodes' table
	local cmd = prepare(self.queries.INSERT_NODE, id, author, comment, timestamp, data)
	assert(self.con:execute(cmd), out)

   local cur,err = assert(self.con:execute("SELECT LAST_INSERT_ID();"))
   local version = tonumber(assert(cur:fetch("*a")))
   cur:close()

	-- Update the index table to the newest revision
	if version == 1 then
		local cmd = prepare(self.queries.INSERT_INDEX, id, version)
		local cur = assert(self.con:execute(cmd))
		assert(cur, err)
	else
		local cmd = prepare(self.queries.UPDATE_INDEX, version, id) 
		local cur = assert(self.con:execute(cmd))
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
function MySQLVersium:get_node_history(id, prefix)
	assert(id)

	local history = {}

	-- Pull the history of the given node
	local cmd = prepare(self.queries.GET_METADATA_ALL, id)
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
-- Returns the data and metadata for multiple nodes, using a single database
-- query.  This is used to optimize specific types of pages where the system
-- may need to pull many nodes at once.  Returns an empty table if there are
-- no nodes matching the prefix.
--
-- @param prefix          the prefix to query
-- @return                (1) a table containing the data for each node,
--                        indexed by node name.
--                        (2) a table containing the metadata for each node,
--                        indexed by node name.
-----------------------------------------------------------------------------
function MySQLVersium:get_nodes_prefix(prefix)
   assert(prefix)

   local data,metadata = {}, {}
   
   local cmd = prepare(self.queries.GET_NODES_PREFIX, prefix .. "%")
   local cur = self.con:execute(cmd)
   local row = cur:fetch({}, "a")

   while row do
      data[row.id] = row.data
      row.data = nil
      metadata[row.id] = row
      row = cur:fetch({}, "a")
   end

	cur:close()

	return data, metadata
end

-- vim:ts=3 ss=3 sw=3 expandtab
