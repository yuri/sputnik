module(..., package.seeall)

actions = {}

local PARENT_PATTERN = "(.+)%/([^%/]+)$" -- everything up to the last slash

function actions.show_comment(node, request, sputnik)
    local parent_id, child_anchor = node.id:match(PARENT_PATTERN)
    local url = sputnik:make_url(parent_id, nil, nil, child_anchor)
    request.redirect = url
    return
end
