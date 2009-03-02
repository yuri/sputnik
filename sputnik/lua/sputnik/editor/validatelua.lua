module(..., package.seeall) --sputnik.editor.resizeable

local SNIPPET_TEMPLATE = [[
  $(document).ready(function() {
	// Store the timer id
	var timerId = 0;
	$("textarea.editor_validatelua").keyup(function (e) {
		var field = this;
		var code = $(this).val();
		clearTimeout(timerId);
		timerId = setTimeout(function() {
			$.post("%s"  ,
			{ p: "sputnik/js/editpage.validate_lua", code: code },
			function(data) {
				if (data == "valid")
					$(field).css("background-color", "#D0F8D0");
				else
					$(field).css("background-color", "#F8E0E0");
				});
			}, 500);
		});
	});
]]


function initialize(node, request, sputnik)
	node:add_javascript_snippet(
       SNIPPET_TEMPLATE:format(sputnik.config.BASE_URL)
    )
end
