require("sputnik")
require("versium")

local v
do
	local options = {}
	options.storage = "versium.storage.mysql"
	options.params = {
		connect = {"clad", "clad", "johndoe", "cide.ws"},
	}

	v = assert(versium.Versium:new(options))
end

local nodes = v:get_node_ids()
-- Verify there are no nodes in the blank repo
assert(next(nodes) == nil)

-- Create nodes and verify them after they've been saved
for i=1,5 do
	local name = "node" .. i
	local data = "data" .. i
	local author = "author" .. i
	local comment = "comment" .. i
	v:save_version(name, data, author, comment)
	local node = v:get_node(name)
	assert(node.id == name)
	assert(node.data == data)
	local info = v:get_node_info(name)
	assert(info.author == author)
	assert(info.comment == comment)
end

local name = tostring(os.time() + os.clock())
local stub = v:get_stub(name)
assert(type(stub) == "table")
assert(stub.id == name)
assert(stub.data == "")
assert(stub.version)

assert(v:node_exists(tostring(os.time() + os.clock())) == false)
assert(v:node_exists("node1") == true)

local nodes = {
	node1 = false,
	node2 = false,
	node3 = false,
	node4 = false,
	node5 = false,
}

for idx,id in ipairs(v:get_node_ids()) do
	nodes[id] = true
end

for node,exists in pairs(nodes) do
	assert(exists)
end

-- Test history
for i=1,10 do
	v:save_version("HistoryNode", "HISTORYTEST"..i, "Test", "Comment")
end

local history = v:get_node_history("HistoryNode")
assert(#history == 10)
for idx,entry in ipairs(history) do
	local data = "HISTORYTEST" .. (10 - (idx - 1))
	local node = v:get_node("HistoryNode", entry.version)
	assert(node.data == data)
end

