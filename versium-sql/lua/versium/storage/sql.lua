---------------------------------------------------------------------------------------------------
-- Provides an implementation of versium storage using the LuaSQL abstraction layer
---------------------------------------------------------------------------------------------------

module(..., package.seeall)

---------------------------------------------------------------------------------------------------
-- Prepares a SQL statement using placeholders.
-- 
-- @param statement      the statement to be prepared
-- @param ...            a list of parameters  
-- @return               the prepared statement.
---------------------------------------------------------------------------------------------------
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

LuaSQLVersiumStorage = {}

---------------------------------------------------------------------------------------------------
-- Instantiates a new LuaSQLVersiumStorage object.
-- 
-- @param impl           the implementation module.
-- @param params         the parameters to pass to the implementation.
-- @return               a new versium object.
---------------------------------------------------------------------------------------------------
function LuaSQLVersiumStorage:new(params, versium)
	-- Try to connect to the given database
	local driver = params.driver
	require("luasql." .. driver)

	local env = luasql[driver]()
	local con = env:connect(unpack(params.connect))

	if not con then
		versium.storage_error("LuaSQL Versium: Could not connect to database %s", tostring(params.db))
	end

	-- Create the new object
	local obj = {con=con, versium=versium}
	setmetatable(obj, self)
	self.__index = self

	return obj 
end

---------------------------------------------------------------------------------------------------
-- Returns a table representing the node with a given id.
--
-- @param id             the node id.
-- @param version        the desired version of the node (defaults to current).
-- @return               the node as table with its content in node.data.
---------------------------------------------------------------------------------------------------
function LuaSQLVersiumStorage:get_node(id, version)
	-- If version wasn't specified, then get the most current version
	if not version then
		local cmd = prepare("SELECT version FROM node_index WHERE node = %s;", id)
		local cur = self.con:execute(cmd)
		local row = cur:fetch({}, "a")
		version = tonumber(row.version)
		cur:close()
	end

	-- If we still don't have a version
	if not version then
		versium.storage_error(version.errors.NODE_DOES_NOT_EXIST, tostring(id))
	end

	-- Get the version and store it
	local cmd = prepare("SELECT data FROM nodes WHERE node = %s AND version = %s;", id, version)
	local cur = self.con:execute(cmd)
	local row = cur:fetch({}, "a")
	cur:close()
	
	assert(row.data)
	local node = {
		id = id,
		data = row.data,
		version = version
	}
   return node
end

---------------------------------------------------------------------------------------------------
-- Returns a table representing a node that doesn't actually exist yet.
--
-- @return               the stub of the node as a table.
---------------------------------------------------------------------------------------------------
function LuaSQLVersiumStorage:get_stub(id)
   return {
      version = "000000",
      data = "",
      id = id,
   }
end

---------------------------------------------------------------------------------------------------
-- Returns true if the node with this id exists and false otherwise.
-- 
-- @param id             an id of an node.
-- @return               true or false.
---------------------------------------------------------------------------------------------------
function LuaSQLVersiumStorage:node_exists(id)
	assert(id)

	-- TODO: This can probably be optimised
	local cmd = prepare("SELECT version FROM node_index WHERE node = %s;", id)
	local cur = self.con:execute(cmd)
	local row = cur:fetch({}, "a")


	cur:close()
	return row and row.version ~= nil
end

--------------------------------------------------------------------------------------------------
-- Returns a list of IDs of all nodes in the repository, in no particular order.
-- 
-- @return               a list of IDs.
---------------------------------------------------------------------------------------------------
function LuaSQLVersiumStorage:get_node_ids()
	local nodes = {}
	local cmd = prepare("SELECT node FROM node_index;")
	local cur = self.con:execute(cmd)
	local row = cur:fetch({}, "a")

	while row do
		nodes[#nodes+1] = row.node
		row = cur:fetch(row, "a")
	end
	
	cur:close()

	return nodes
end

---------------------------------------------------------------------------------------------------
-- Saves a new version of the node.
--
-- @param id             the id of the node (required).
-- @param data           the value to save (required, but "" is ok).
-- @param author         the user name to be associated with the change (required).
-- @param comment        the change comment (optional).
-- @param extra          any extra metadata (optional).
-- @return               the version id of the new node.
---------------------------------------------------------------------------------------------------
function LuaSQLVersiumStorage:save_version(id, data, author, comment, extra, timestamp)
	assert(id)
	assert(data)
	assert(author)

   -- generate and save the new index
   if not timestamp then
	   local t = os.date("*t")
	   timestamp = string.format("%02d-%02d-%02d %02d:%02d:%02d", t.year, t.month, t.day, t.hour, t.min, t.sec)
   end

	-- Determine what the new version number will be
	local cmd = prepare("SELECT version FROM node_index WHERE node = %s;", id)
	local cur = self.con:execute(cmd)
	local row = cur:fetch({}, "a")
	cur:close()

	local new
	local version = row and tonumber(row.version)
	if not version then
		version = 1
		new = true
	else
		version = version + 1
	end

	-- Store the new node in the 'nodes' table
	local cmd = prepare("INSERT INTO nodes (node, version, data) VALUES (%s, %s, %s);", id, version, data)
	local cur,err = self.con:execute(cmd)
	assert(cur, err)
	
	-- Add this version to the 'node_history' table
	local cmd = prepare("INSERT INTO node_history (node, version, timestamp, author, comment) VALUES (%s, %s, %s, %s, %s);", id, version, timestamp, author, comment);
	local cur,err = self.con:execute(cmd)
	assert(cur, err)

	-- Update the index table to the newest revision
	if new then
		local cmd = prepare("INSERT INTO node_index (node, version) VALUES (%s, %s);", id, version)
		local cur,err = self.con:execute(cmd)
		assert(cur, err)
	else
		local cmd = prepare("UPDATE node_index SET version=%s WHERE node = %s;", version, id) 
		local cur,err = self.con:execute(cmd)
		assert(cur, err)
	end

	-- Return the new version number
	return version
end

---------------------------------------------------------------------------------------------------
-- Returns the history of the node as a list of tables, each representing a revision of the node 
-- (with fields like version, author, comment, and extra).  The version can be filtered by a time
-- prefix. Returns an empty table if the node does not exist.
--
-- @param id             the id of the node.
-- @param prefix         time prefix.
-- @return               two values: 
--                           (1) a list of tables representing the versions (the list will be empty
--                               if the node doesn't exist)
--                           (2) the raw prepresentation of nodes history (as lua code).
---------------------------------------------------------------------------------------------------
function LuaSQLVersiumStorage:get_node_history(id, prefix)
	assert(id)

	local history = {}

	-- Pull the history of the given node
	local cmd = prepare("SELECT node,version,timestamp,author,comment FROM node_history WHERE node = %s ORDER by timestamp;", id)
	local cur = self.con:execute(cmd)
	local row = cur:fetch({}, "a")

	while row do
		history[#history+1] = row
		row = cur:fetch({}, "a")
	end

	cur:close()

	-- TODO: This doesn't return the raw representation at the moment
	return history
end

---------------------------------------------------------------------------------------------------
-- Returns a table with the metadata for the latest version of the node. Same as 
-- get_node_history(id)[1] in case of this implementation.
-- 
-- @param id             an id of an node.
-- @return               the metadata for the latest version or nil.
---------------------------------------------------------------------------------------------------
function LuaSQLVersiumStorage:get_node_info(id)
	assert(id)

	-- Fetch the latest version number
	local cmd = prepare("SELECT version FROM node_index WHERE node = %s;", id)
	local cur = self.con:execute(cmd)
	local row = cur:fetch({}, "a")
	local version = row.version
	cur:close()

	-- Get the metadata for that version
	local cmd = prepare("SELECT * FROM node_history WHERE node = %s AND version = %s;", id, version)
	local cur = self.con:execute(cmd)
	local row = cur:fetch({}, "a")
	cur:close()

	return row
end

----------------------------------------------------------------------------------------------------
-- Creates a new LuaSQLVersiumStorage object.
-- 
-- @param params         the parameters to pass to the implementation.
-- @param versium        a generic versium instance.
-- @return               the new versium storage object.
---------------------------------------------------------------------------------------------------

function open(params, versium)
   return LuaSQLVersiumStorage:new(params, versium)
end

