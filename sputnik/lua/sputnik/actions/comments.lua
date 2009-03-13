module(..., package.seeall)

actions = {}

local PARENT_PATTERN = "(.+)%/([^%/]+)$" -- everything up to the last slash

function actions.show_comment(node, request, sputnik)
    local parent_id, child_anchor = node.id:match(PARENT_PATTERN)
    local url = sputnik:make_url(parent_id, nil, nil, child_anchor)
    request.redirect = url
    return
end

local wiki = require("sputnik.actions.wiki")
function actions.edit_comment(node, request, sputnik)
    if request.params.quote then
        local parent_id = request.params.comment_parent
        local parent = sputnik:get_node(parent_id)
        parent = sputnik:decorate_node(parent)
        if node:check_permissions(request.user, "show") then
            -- Quote the text from the node here, using markdown.quote(txt)
            local quoted = parent.markup.quote(parent.content) .. "\n\n"
            request.params.content = tostring(quoted)
        end
    end

    return wiki.actions.edit(node, request, sputnik)
end
