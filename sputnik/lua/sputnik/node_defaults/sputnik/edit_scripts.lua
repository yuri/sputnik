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
        $(".field input, .field textarea").not(".submit").focus(function() {
                $(this).addClass("active_input");
                }).blur(function() {
                $(this).removeClass("active_input");
                });
})

]======]
