package = "Sputnik-Markitup"
version = "9.03.16-0"
source = {
   url = "http://spu.tnik.org/files/sputnik-markitup-9.03.16.tar.gz",
}
description = {
   summary    = "A markitup plugin for Sputnik",
   detailed   = [===[]===],
   license    =  "MIT/X11",
   homepage   = "",
   maintainer = "Yuri Takhteyev (yuri@freewisdom.org)",
}
dependencies = {
}
build = {
  type = "none",
  install = {
    bin = {
    },
    lua = {
        ["sputnik.actions.editor"] = "lua/sputnik/actions/editor.lua",

        ["sputnik.node_defaults.markitup.images.list-bullet"] = "lua/sputnik/node_defaults/markitup/images/list-bullet.lua",
        ["sputnik.node_defaults.markitup.images.code"] = "lua/sputnik/node_defaults/markitup/images/code.lua",
        ["sputnik.node_defaults.markitup.images.h5"] = "lua/sputnik/node_defaults/markitup/images/h5.lua",
        ["sputnik.node_defaults.markitup.images.list-numeric"] = "lua/sputnik/node_defaults/markitup/images/list-numeric.lua",
        ["sputnik.node_defaults.markitup.images.picture"] = "lua/sputnik/node_defaults/markitup/images/picture.lua",
        ["sputnik.node_defaults.markitup.images.indent_remove"] = "lua/sputnik/node_defaults/markitup/images/indent_remove.lua",
        ["sputnik.node_defaults.markitup.images.h1"] = "lua/sputnik/node_defaults/markitup/images/h1.lua",
        ["sputnik.node_defaults.markitup.images.h6"] = "lua/sputnik/node_defaults/markitup/images/h6.lua",
        ["sputnik.node_defaults.markitup.images.submenu"] = "lua/sputnik/node_defaults/markitup/images/submenu.lua",
        ["sputnik.node_defaults.markitup.images.indent"] = "lua/sputnik/node_defaults/markitup/images/indent.lua",
        ["sputnik.node_defaults.markitup.images.menu"] = "lua/sputnik/node_defaults/markitup/images/menu.lua",
        ["sputnik.node_defaults.markitup.images.preview"] = "lua/sputnik/node_defaults/markitup/images/preview.lua",
        ["sputnik.node_defaults.markitup.images.h4"] = "lua/sputnik/node_defaults/markitup/images/h4.lua",
        ["sputnik.node_defaults.markitup.images.handle"] = "lua/sputnik/node_defaults/markitup/images/handle.lua",
        ["sputnik.node_defaults.markitup.images.quotes"] = "lua/sputnik/node_defaults/markitup/images/quotes.lua",
        ["sputnik.node_defaults.markitup.images.h3"] = "lua/sputnik/node_defaults/markitup/images/h3.lua",
        ["sputnik.node_defaults.markitup.images.link"] = "lua/sputnik/node_defaults/markitup/images/link.lua",
        ["sputnik.node_defaults.markitup.images.bold"] = "lua/sputnik/node_defaults/markitup/images/bold.lua",
        ["sputnik.node_defaults.markitup.images.italic"] = "lua/sputnik/node_defaults/markitup/images/italic.lua",
        ["sputnik.node_defaults.markitup.images.h2"] = "lua/sputnik/node_defaults/markitup/images/h2.lua",

        ["sputnik.node_defaults.markitup.editor_test"] = "lua/sputnik/node_defaults/markitup/editor_test.lua",
        ["sputnik.node_defaults.markitup.js.markdown"] = "lua/sputnik/node_defaults/markitup/js/markdown.lua",
        ["sputnik.node_defaults.markitup.js.markitup"] = "lua/sputnik/node_defaults/markitup/js/markitup.lua",

        ["sputnik.node_defaults.markitup.css.simple"] = "lua/sputnik/node_defaults/markitup/css/simple.lua",
        ["sputnik.node_defaults.markitup.css.markdown"] = "lua/sputnik/node_defaults/markitup/css/markdown.lua",


        ["sputnik.node_defaults.editor_test"] = "lua/sputnik/node_defaults/editor_test.lua",

        ["sputnik.editor.markitup"] = "lua/sputnik/editor/markitup.lua",


    },

  }
}

