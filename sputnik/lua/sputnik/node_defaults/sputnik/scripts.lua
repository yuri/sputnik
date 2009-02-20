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

function sputnik_init_page() {
  $(".field input, .field textarea").not(".submit").focus(
    function(){$(this).addClass("active_input");}
  ).blur(
    function() {$(this).removeClass("active_input");}
  );
  $(".autofocus input").focus();
}

function sputnik_make_modal_popup(id, url) {
   var login_form = document.createElement('div');
   var selector = "#"+id;
   $(selector).fadeIn();
   $(selector).append('<div class="transparency">&nbsp;</div>');
   $(selector).append('<div class="popup_frame"><div class="close_popup">⨯</div><div class="actual_form"/></div>');
   $(selector+" div.actual_form").load(url);
   $(selector+" .close_popup").click(
    function(){ $(selector).hide(); return false; }
   );
   sputnik_init_page();
}

$(document).ready(function(){

 sputnik_init_page();

 $("#sidebar ul#menu > li > a ").click(
  function(){
   $(this).siblings("ul").slideToggle();
   return false;
  }
 );

 $(".ctrigger").click(
  function () {
   var selector = "#" + this.id.substring(8);
   $(selector).slideToggle();
   $(this).toggleClass("closed");
  }
 );

 // Actually hide all the closed elements
 $(".ctrigger.closed").each(
  function() {
   var selector = "#" + this.id.substring(8);
   $(selector).hide();
  }
 );

 /*$("a.login_link").click(
  function(){
   sputnik_make_modal_popup("login_form", "/sputnik2.ws?p=sputnik/login&skip_wrapper=1");
   return false;
  }
 );*/

 function addBookmark(title, url) {
  if (window.sidebar) { // firefox
   window.sidebar.addPanel(title, url,"");
  } else if( document.all ) { //MSIE
   window.external.AddFavorite( url, title);
  } else {
   alert("Sorry, your browser doesn't support this");
  }
 }

});


]======]
