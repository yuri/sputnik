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

var sputnik = {};

sputnik.init_page = function() {
  $$(".field input, .field textarea").not(".submit").focus(
    function(){$$(this).addClass("active_input");}
  ).blur(
    function() {$$(this).removeClass("active_input");}
  );
  $$(".autofocus input").focus();
}

sputnik.make_modal_popup = function (id, url) {
   var parent = "body";
   $$(parent).prepend('<div class="popup_background" id="'+id+'"></div>');
   var popup = parent + " div.popup_background";
   $$(popup).append('<div class="popup_frame"><div class="popup_content"/></div>');
   $$("div.popup_content").load(url);
   $$(popup).click(
    function(){ $$(popup).hide(); }
   );
   $$(".popup_frame").click(function(event){
     event.stopPropagation();
   });
   setTimeout(function(){sputnik.init_page()}, 100);
}

$$(document).ready(function(){

 sputnik.init_page();

 $$("#sidebar ul#menu > li > a ").click(
  function(){
   $$(this).siblings("ul").slideToggle();
   return false;
  }
 );

 $$(".ctrigger").click(
  function () {
   var selector = "#" + this.id.substring(8);
   $$(selector).slideToggle();
   $$(this).toggleClass("closed");
  }
 );

 // Actually hide all the closed elements
 $$(".ctrigger.closed").each(
  function() {
   var selector = "#" + this.id.substring(8);
   $$(selector).hide();
  }
 );

 $$("a.login_link").click(
  function(){
   sputnik.make_modal_popup("login_form", "$make_url_without_wrapper{node = '$LOGIN_NODE'}");
   return false;
  }
 );
 $$("a.registration_link").click(
  function(){
   sputnik.make_modal_popup("registration_form", "$make_url_without_wrapper{node = '$REGISTRATION_NODE'}");
   return false;
  }
 ); 

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

$more_javascript

]======]
