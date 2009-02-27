module(..., package.seeall) --sputnik.editor.resizeable

function initialize(node, request, sputnik)
	node:add_javascript_link(sputnik:make_url("jquery/textarearesizer", "js"))
	node:add_javascript_snippet[[
$(document).ready(function() {
	$('textarea.editor_resizeable').TextAreaResizer();
})]]
end
