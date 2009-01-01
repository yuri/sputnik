module(..., package.seeall)
NODE = {
   title="Edit Page Script",
   prototype="@JavaScript",
   category="_prototypes",
}

NODE.actions = [[
   validate_lua = "wiki.validate_lua"
   js = "javascript.configured_js"
]]
NODE.permissions = [[
   allow(all_users, "validate_lua")
]]

NODE.content = [======[

$(document).ready(function() {
		// Store the timer id
		var timerId = 0;

		$("div.editlua textarea").keyup(function (e) {
			var field = this;
			var code = $(this).val();
			clearTimeout(timerId);
			timerId = setTimeout(function() {
				$.post("$BASE_URL"  ,
					{ p: "sputnik/js/editpage.validate_lua", code: code },
					function(data) {
					if (data == "valid")
					$(field).css("background-color", "#D0F8D0");
					else
					$(field).css("background-color", "#F8E0E0");
					});
				}, 500);
			});

		$('textarea.resizeable:not(.editor)').TextAreaResizer();

        $(".field input, .field textarea").not(".submit").focus(function() {
                $(this).addClass("active_input");
                }).blur(function() {
                $(this).removeClass("active_input");
                });
})

]======]
