module(..., package.seeall)
require"lfs"

function dot(source, format)
    local tempfile = "/tmp/"..math.random()
    local f = io.open(tempfile, "w")
    f:write(source)
    f:close()
    local pipe = io.popen("dot -T"..format.." "..tempfile)
    return pipe:read("*all")
end

actions = {}
actions.dot2svg = function(node, request, sputnik)
    return dot(node.content, "svg"), "image/svg+xml"
end
actions.dot2png = function(node, request, sputnik)
    return dot(node.content, "png"), "image/png"
end
actions.dot2gif = function(node, request, sputnik)
    return dot(node.content, "gif"), "image/gif"
end

actions.show_with_objects = function(node, request, sputnik)
   require"xssfilter"
   sputnik.xssfilter = xssfilter.new()
   sputnik.xssfilter.allowed_tags.object = {type="^image/svg+xml", 
                                 data="^http://sputnik.freewisdom.org/",
                                 width=".", height="."}
   node.inner_html = node.markup.transform(node.content or "")
   return node.wrappers.default(node, request, sputnik)
end
