module(..., package.seeall)

function initialize(node, request, sputnik)
	node:add_javascript_link(sputnik:make_url("markitup/js/markitup.js"))
	node:add_javascript_link(sputnik:make_url("markitup/js/markdown.js"))

	node:add_css_link(sputnik:make_url("markitup/css/simple.css"), "all")
	node:add_css_link(sputnik:make_url("markitup/css/markdown.css"), "all")
end
