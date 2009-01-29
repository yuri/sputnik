module(..., package.seeall)
NODE = {
   title="Basic Script",
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

$jquery

$(document).ready(function(){

 $("#sidebar ul#menu > li > a ").click(
  function(){
   $(this).siblings("ul").slideToggle();
   return false;
  }
 );
 $("span.ctrigger").click(
  function () {
   var selector = "#" + this.id.substring(8);
   $(selector).slideToggle();
   $(this).toggleClass("closed");
  }
 );
 // Actually hide all the closed elements
 $("span.ctrigger.closed").each(
  function() {
   var selector = "#" + this.id.substring(8);
   $(selector).hide();
  }
 );

});

function addBookmark(title, url) {
        if (window.sidebar) { // firefox
              window.sidebar.addPanel(title, url,"");
        } else if( document.all ) { //MSIE
                window.external.AddFavorite( url, title);
        } else {
               alert("Sorry, your browser doesn't support this");
        }
}
]======]
