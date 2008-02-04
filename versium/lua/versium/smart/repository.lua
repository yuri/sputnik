
module(..., package.seeall)

require("versium")
require("versium.smart.smartnode")

Repository = {}

---------------------------------------------------------------------------------------------------
-- Creates a new instance of Repository.
-- 
-- @param initial_config the bootstrapping config table.
-- @return               an instance of "Repository".
---------------------------------------------------------------------------------------------------
function Repository:new(initial_config)
   local repo = {}
   setmetatable(repo, self)
   self.__index = self

   repo.versium = versium.open{
       storage = initial_config.VERSIUM_STORAGE_MODULE 
                 or "versium.storage.simple",
       params = initial_config.VERSIUM_PARAMS
   }
   setmetatable(self, repo.versium)
   repo.versium.__index = repo.versium
   repo.config = initial_config
   repo.config.__index = repo.config
   return repo
end

---------------------------------------------------------------------------------------------------
-- Retrieves a node transformed it into a "smart node".  This method overrides versium's get_node().
--
-- @param id             the id of the desired node.
-- @param version        the desired version of the node (defaults to latest).
-- @return               a table representing the fields of the node, with the metadata and the 
--                       string representatoin pushed into the metatable.
---------------------------------------------------------------------------------------------------

--require"sputnik.installer.initial_pages"

function Repository:get_node(id, version, mode)
   assert(id)
   if self.logger then 
      self.logger:debug(id)
      self.logger:debug(version)
   end
   local versium_node = self.versium:get_node(id, version) 
   if not versium_node then
      local status, page_module = pcall(require, "sputnik.node_defaults."..id)
      if status then
         local default = self.versium:deflate(page_module.NODE)
         self.versium:save_version(id, default, "Sputnik", "the default version")
         versium_node = self.versium:get_node(id, version)
      else 
         versium_node = self.versium:get_stub(id)
      end
   end
   versium_node = self.versium:inflate(versium_node)
   assert(versium_node._version)
   return versium.smart.smartnode.SmartNode:new(versium_node, self, self.config.ROOT_PROTOTYPE, mode)
end

---------------------------------------------------------------------------------------------------
-- Saves a node.
--
-- @param node           the node to be saved.
-- @param author         the .user name associated with the change (required).
-- @param comment        a comment associated with this change (optional).
-- @param extra          extra params (optional).
-- @return               nothing
---------------------------------------------------------------------------------------------------
function Repository:save_node(node, author, comment, extra)
   assert(node._id)
   self.versium:save_version(node._id, self.versium:deflate(node._vnode), author, comment, extra)
end

---------------------------------------------------------------------------------------------------
-- Returns the history of edits to the node.
--
-- @param id             the id of the node.
-- @param prefix         an optional date prefix (e.g., "2007-12").
-- @return               history as a table.
---------------------------------------------------------------------------------------------------
function Repository:get_node_history(id, prefix)
   assert(id)
   local versium_history = self.versium:get_node_history(id, prefix)
   for i,v in ipairs(versium_history) do
      v.get_node = function() self:get_node(id, v.version) end
   end
   return versium_history
end
