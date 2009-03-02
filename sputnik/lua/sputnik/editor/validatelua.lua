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
         $.post("$url"  ,
                { p: "sputnik/js/editpage.validate_lua", code: code },
                function(data) {
                   if (data == "valid") {
                      $(field).css("background-color", "$valid");
                   }
                   else if (data == "invalid") {
                      $(field).css("background-color", "$invalid");
                   }
                   else {
                      $(field).css("background-color", "$unknown");
                   }
                }
               );
      }, 500);
   });
});
]]

function initialize(node, request, sputnik)
   node:add_javascript_snippet(
      cosmo.f(SNIPPET_TEMPLATE){
         url = sputnik.config.BASE_URL,
         valid = sputnik.config.LUA_VALIDATION_COLOR_VALID or "#D0F8D0",
         invalid = sputnik.config.LUA_VALIDATION_COLOR_INVALID or "#F8E0E0",
         unknown = sputnik.config.LUA_VALIDATION_COLOR_UNKNOWN or "#F8F8F8",
      }
   )
end
