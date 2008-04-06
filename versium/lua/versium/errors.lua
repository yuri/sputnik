module(..., package.seeall)

function could_not_initialize(reason)
   return "versium failed to initialize: "..(reason or "")
end

function concurrent_write(reason)
   return "versium resource is locked: "..(reason or "")
end

function no_such_node(node)
   return "versium node does not exist: "..(node or "nil")
end

function no_such_version(node, revision)
   return "versium revision does not exist: version "..(revision or "nil").." of "..(node or "nil")
end

function could_not_save(node, reason)
   return "versium could not save node "..node..": "..(reason or "")
end

function could_not_read(node, reason)
   return "versium could not read node "..node..": "..(readon or "")
end

function misc(reason)
   return "versium encountered an unexpected error: "..(reason or "")
end
