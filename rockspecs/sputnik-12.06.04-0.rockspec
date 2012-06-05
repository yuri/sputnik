package = "Sputnik"
version = "12.06.04-0"
source = {
   url = "http://spu.tnik.org/files/sputnik-12.06.04.tar.gz",
}
description = {
   summary    = "A wiki and a framework for wiki-like applications",
   detailed   = [===[     Sputnik is a wiki written in Lua. It is also a platform for building a range of wiki-like 
     applications, drawing on Lua's strengths as an extension language.

     Out of the box Sputnik behaves like a wiki with all the standard wiki features: editable 
     pages, protection against spam bots, history view of pages, diff, preview, per-page-RSS feed 
     for site changes. (See http://sputnik.freewisdom.org/en/Features for more details.)

     At the same time, Sputnik is designed to be used as a platform for a wide range of "social 
     software" applications. A simple change of templates and perhaps a few spoons of Lua code can 
     turn it into a photo album, a blog, a calendar, a mailing list viewer, or almost anything else.
     So, you can think of it as a web framework of sorts. In addition to allowing you to add custom 
     bells and whistles to a wiki, Sputnik provides a good foundation for anything that's kind of 
     like a wiki but not quite. Sputnik stores its data as versioned "pages" that can be editable 
     through the web (just like any wiki). However, it allows those pages to store any data that 
     can be saved as text (prose, comma-separated values, lists of named parameters, Lua tables, 
     mbox-formatted messages, XML, etc.) While by default the page is displayed as if it carried 
     Markdown-formatted text, the way the page is viewed (or edited, or saved, etc.) can be 
     overriden on a per-page basis by over-riding or adding "actions". 
]===],
   license    =  "MIT/X11",
   homepage   = "",
   maintainer = "Yuri Takhteyev (yuri@freewisdom.org)",
}
dependencies = {
  'saci == 12.06.04',
  'cosmo >= 8.04.14',
  'xssfilter >= 8.07.07',
  'markdown >= 0.32',
  'md5 >= 1.1',
  'wsapi >= 1.0',
  'luasocket >= 2.0',
  'coxpcall >= 1.13',
}
build = {
  type = "none",
  install = {
     lua = {        ["sputnik.util"] = "lua/sputnik/util.lua",
        ["sputnik.xavante"] = "lua/sputnik/xavante.lua",
        ["sputnik.cli.encode-binary"] = "lua/sputnik/cli/encode-binary.lua",
        ["sputnik.cli.start-xavante"] = "lua/sputnik/cli/start-xavante.lua",
        ["sputnik.cli.topic"] = "lua/sputnik/cli/topic.lua",
        ["sputnik.cli.help"] = "lua/sputnik/cli/help.lua",
        ["sputnik.cli.version"] = "lua/sputnik/cli/version.lua",
        ["sputnik.cli.make-cgi"] = "lua/sputnik/cli/make-cgi.lua",

        ["sputnik.auth.simple"] = "lua/sputnik/auth/simple.lua",
        ["sputnik.auth.errors"] = "lua/sputnik/auth/errors.lua",
        ["sputnik.auth.luasql"] = "lua/sputnik/auth/luasql.lua",

        ["sputnik.node_defaults.icons.anon"] = "lua/sputnik/node_defaults/icons/anon.lua",
        ["sputnik.node_defaults.icons.edit"] = "lua/sputnik/node_defaults/icons/edit.lua",
        ["sputnik.node_defaults.icons.admin"] = "lua/sputnik/node_defaults/icons/admin.lua",
        ["sputnik.node_defaults.icons.plus"] = "lua/sputnik/node_defaults/icons/plus.lua",
        ["sputnik.node_defaults.icons.rss"] = "lua/sputnik/node_defaults/icons/rss.lua",
        ["sputnik.node_defaults.icons.star"] = "lua/sputnik/node_defaults/icons/star.lua",
        ["sputnik.node_defaults.icons.forum"] = "lua/sputnik/node_defaults/icons/forum.lua",
        ["sputnik.node_defaults.icons.diff"] = "lua/sputnik/node_defaults/icons/diff.lua",
        ["sputnik.node_defaults.icons.basic_node"] = "lua/sputnik/node_defaults/icons/basic_node.lua",
        ["sputnik.node_defaults.icons.lua"] = "lua/sputnik/node_defaults/icons/lua.lua",
        ["sputnik.node_defaults.icons.history"] = "lua/sputnik/node_defaults/icons/history.lua",
        ["sputnik.node_defaults.icons.discussion"] = "lua/sputnik/node_defaults/icons/discussion.lua",
        ["sputnik.node_defaults.icons.picture"] = "lua/sputnik/node_defaults/icons/picture.lua",
        ["sputnik.node_defaults.icons.user"] = "lua/sputnik/node_defaults/icons/user.lua",
        ["sputnik.node_defaults.icons.minus"] = "lua/sputnik/node_defaults/icons/minus.lua",
        ["sputnik.node_defaults.icons.search"] = "lua/sputnik/node_defaults/icons/search.lua",
        ["sputnik.node_defaults.icons.sputnik"] = "lua/sputnik/node_defaults/icons/sputnik.lua",
        ["sputnik.node_defaults.icons.collection"] = "lua/sputnik/node_defaults/icons/collection.lua",
        ["sputnik.node_defaults.icons.system"] = "lua/sputnik/node_defaults/icons/system.lua",
        ["sputnik.node_defaults.icons.attach"] = "lua/sputnik/node_defaults/icons/attach.lua",
        ["sputnik.node_defaults.icons.logout"] = "lua/sputnik/node_defaults/icons/logout.lua",

        ["sputnik.node_defaults.@Root"] = "lua/sputnik/node_defaults/@Root.lua",
        ["sputnik.node_defaults.@Discussion"] = "lua/sputnik/node_defaults/@Discussion.lua",
        ["sputnik.node_defaults.history.edits_by_recent_users"] = "lua/sputnik/node_defaults/history/edits_by_recent_users.lua",
        ["sputnik.node_defaults.history.init"] = "lua/sputnik/node_defaults/history/init.lua",

        ["sputnik.node_defaults.@User_Profile"] = "lua/sputnik/node_defaults/@User_Profile.lua",
        ["sputnik.node_defaults.@Binary_File"] = "lua/sputnik/node_defaults/@Binary_File.lua",
        ["sputnik.node_defaults.@Collection"] = "lua/sputnik/node_defaults/@Collection.lua",
        ["sputnik.node_defaults.index"] = "lua/sputnik/node_defaults/index.lua",
        ["sputnik.node_defaults.@Image"] = "lua/sputnik/node_defaults/@Image.lua",
        ["sputnik.node_defaults.@Lua_Config"] = "lua/sputnik/node_defaults/@Lua_Config.lua",
        ["sputnik.node_defaults.sitemap"] = "lua/sputnik/node_defaults/sitemap.lua",
        ["sputnik.node_defaults.@Comment"] = "lua/sputnik/node_defaults/@Comment.lua",
        ["sputnik.node_defaults.@UID"] = "lua/sputnik/node_defaults/@UID.lua",
        ["sputnik.node_defaults.@JavaScript"] = "lua/sputnik/node_defaults/@JavaScript.lua",
        ["sputnik.node_defaults.@DiscussionForum"] = "lua/sputnik/node_defaults/@DiscussionForum.lua",
        ["sputnik.node_defaults.logo"] = "lua/sputnik/node_defaults/logo.lua",
        ["sputnik.node_defaults.markitup.js.markitup"] = "lua/sputnik/node_defaults/markitup/js/markitup.lua",
        ["sputnik.node_defaults.markitup.js.markdown"] = "lua/sputnik/node_defaults/markitup/js/markdown.lua",

        ["sputnik.node_defaults.markitup.css.simple"] = "lua/sputnik/node_defaults/markitup/css/simple.lua",
        ["sputnik.node_defaults.markitup.css.markdown"] = "lua/sputnik/node_defaults/markitup/css/markdown.lua",

        ["sputnik.node_defaults.markitup.editor_test"] = "lua/sputnik/node_defaults/markitup/editor_test.lua",
        ["sputnik.node_defaults.markitup.images.submenu"] = "lua/sputnik/node_defaults/markitup/images/submenu.lua",
        ["sputnik.node_defaults.markitup.images.h4"] = "lua/sputnik/node_defaults/markitup/images/h4.lua",
        ["sputnik.node_defaults.markitup.images.h6"] = "lua/sputnik/node_defaults/markitup/images/h6.lua",
        ["sputnik.node_defaults.markitup.images.h1"] = "lua/sputnik/node_defaults/markitup/images/h1.lua",
        ["sputnik.node_defaults.markitup.images.h5"] = "lua/sputnik/node_defaults/markitup/images/h5.lua",
        ["sputnik.node_defaults.markitup.images.handle"] = "lua/sputnik/node_defaults/markitup/images/handle.lua",
        ["sputnik.node_defaults.markitup.images.list-bullet"] = "lua/sputnik/node_defaults/markitup/images/list-bullet.lua",
        ["sputnik.node_defaults.markitup.images.h3"] = "lua/sputnik/node_defaults/markitup/images/h3.lua",
        ["sputnik.node_defaults.markitup.images.bold"] = "lua/sputnik/node_defaults/markitup/images/bold.lua",
        ["sputnik.node_defaults.markitup.images.link"] = "lua/sputnik/node_defaults/markitup/images/link.lua",
        ["sputnik.node_defaults.markitup.images.indent_remove"] = "lua/sputnik/node_defaults/markitup/images/indent_remove.lua",
        ["sputnik.node_defaults.markitup.images.picture"] = "lua/sputnik/node_defaults/markitup/images/picture.lua",
        ["sputnik.node_defaults.markitup.images.list-numeric"] = "lua/sputnik/node_defaults/markitup/images/list-numeric.lua",
        ["sputnik.node_defaults.markitup.images.h2"] = "lua/sputnik/node_defaults/markitup/images/h2.lua",
        ["sputnik.node_defaults.markitup.images.italic"] = "lua/sputnik/node_defaults/markitup/images/italic.lua",
        ["sputnik.node_defaults.markitup.images.code"] = "lua/sputnik/node_defaults/markitup/images/code.lua",
        ["sputnik.node_defaults.markitup.images.menu"] = "lua/sputnik/node_defaults/markitup/images/menu.lua",
        ["sputnik.node_defaults.markitup.images.preview"] = "lua/sputnik/node_defaults/markitup/images/preview.lua",
        ["sputnik.node_defaults.markitup.images.indent"] = "lua/sputnik/node_defaults/markitup/images/indent.lua",
        ["sputnik.node_defaults.markitup.images.quotes"] = "lua/sputnik/node_defaults/markitup/images/quotes.lua",


        ["sputnik.node_defaults.sputnik.@Account_Activation_Ticket"] = "lua/sputnik/node_defaults/sputnik/@Account_Activation_Ticket.lua",
        ["sputnik.node_defaults.sputnik.@Password_Reset_Ticket"] = "lua/sputnik/node_defaults/sputnik/@Password_Reset_Ticket.lua",
        ["sputnik.node_defaults.sputnik.scripts"] = "lua/sputnik/node_defaults/sputnik/scripts.lua",
        ["sputnik.node_defaults.sputnik.grippie"] = "lua/sputnik/node_defaults/sputnik/grippie.lua",
        ["sputnik.node_defaults.sputnik.translations.forums"] = "lua/sputnik/node_defaults/sputnik/translations/forums.lua",

        ["sputnik.node_defaults.sputnik.register"] = "lua/sputnik/node_defaults/sputnik/register.lua",
        ["sputnik.node_defaults.sputnik.style"] = "lua/sputnik/node_defaults/sputnik/style.lua",
        ["sputnik.node_defaults.sputnik.edit_scripts"] = "lua/sputnik/node_defaults/sputnik/edit_scripts.lua",
        ["sputnik.node_defaults.sputnik.password_reset"] = "lua/sputnik/node_defaults/sputnik/password_reset.lua",
        ["sputnik.node_defaults.sputnik.version"] = "lua/sputnik/node_defaults/sputnik/version.lua",
        ["sputnik.node_defaults.sputnik.config_defaults"] = "lua/sputnik/node_defaults/sputnik/config_defaults.lua",
        ["sputnik.node_defaults.sputnik.passwords"] = "lua/sputnik/node_defaults/sputnik/passwords.lua",
        ["sputnik.node_defaults.sputnik.login"] = "lua/sputnik/node_defaults/sputnik/login.lua",
        ["sputnik.node_defaults.sputnik.search"] = "lua/sputnik/node_defaults/sputnik/search.lua",
        ["sputnik.node_defaults.sputnik.config"] = "lua/sputnik/node_defaults/sputnik/config.lua",
        ["sputnik.node_defaults.sputnik.templates"] = "lua/sputnik/node_defaults/sputnik/templates.lua",
        ["sputnik.node_defaults.sputnik.logout"] = "lua/sputnik/node_defaults/sputnik/logout.lua",
        ["sputnik.node_defaults.sputnik.navigation"] = "lua/sputnik/node_defaults/sputnik/navigation.lua",
        ["sputnik.node_defaults.sputnik.translations"] = "lua/sputnik/node_defaults/sputnik/translations.lua",
        ["sputnik.node_defaults.sputnik.init"] = "lua/sputnik/node_defaults/sputnik/init.lua",

        ["sputnik.node_defaults.@CSS"] = "lua/sputnik/node_defaults/@CSS.lua",
        ["sputnik.node_defaults.@Text_Config"] = "lua/sputnik/node_defaults/@Text_Config.lua",

        ["sputnik.wsapi_app"] = "lua/sputnik/wsapi_app.lua",
        ["sputnik.actions.register"] = "lua/sputnik/actions/register.lua",
        ["sputnik.actions.javascript"] = "lua/sputnik/actions/javascript.lua",
        ["sputnik.actions.binaryfile"] = "lua/sputnik/actions/binaryfile.lua",
        ["sputnik.actions.wiki"] = "lua/sputnik/actions/wiki.lua",
        ["sputnik.actions.css"] = "lua/sputnik/actions/css.lua",
        ["sputnik.actions.comments"] = "lua/sputnik/actions/comments.lua",
        ["sputnik.actions.search"] = "lua/sputnik/actions/search.lua",
        ["sputnik.actions.collections"] = "lua/sputnik/actions/collections.lua",
        ["sputnik.actions.editor"] = "lua/sputnik/actions/editor.lua",

        ["sputnik.util.calendar"] = "lua/sputnik/util/calendar.lua",
        ["sputnik.util.yui_reset"] = "lua/sputnik/util/yui_reset.lua",
        ["sputnik.util.html_forms"] = "lua/sputnik/util/html_forms.lua",

        ["sputnik.javascript.sorttable"] = "lua/sputnik/javascript/sorttable.lua",
        ["sputnik.javascript.jquery"] = "lua/sputnik/javascript/jquery.lua",

        ["sputnik.doc.version"] = "lua/sputnik/doc/version.lua",
        ["sputnik.doc.params"] = "lua/sputnik/doc/params.lua",

        ["sputnik.i18n"] = "lua/sputnik/i18n.lua",
        ["sputnik.hooks.forums"] = "lua/sputnik/hooks/forums.lua",

        ["sputnik.installer"] = "lua/sputnik/installer.lua",
        ["sputnik.editor.validatelua"] = "lua/sputnik/editor/validatelua.lua",
        ["sputnik.editor.markitup"] = "lua/sputnik/editor/markitup.lua",
        ["sputnik.editor.resizeable"] = "lua/sputnik/editor/resizeable.lua",

        ["sputnik.markup.markdown"] = "lua/sputnik/markup/markdown.lua",
        ["sputnik.markup.init"] = "lua/sputnik/markup/init.lua",

        ["sputnik.init"] = "lua/sputnik/init.lua",

     }
  }
}

