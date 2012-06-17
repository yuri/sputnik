module(..., package.seeall)

NODE = {
   title="Configurations",
   prototype="@Lua_Config",
}

NODE.fields = [[
content.proto = "concat"
]]

NODE.content = [=============[

-----------------------------------------------------------------------------
--------- The Basics --------------------------------------------------------
-----------------------------------------------------------------------------

SITE_TITLE     = "My New Wiki"        -- change the title of the site
SITE_SUBTITLE  = "Don't panic!"       -- change the subtitle of the site
DOMAIN         = "localhost:8080"     -- set for RSS feeds to work properly
COOKIE_NAME    = "Sputnik"            -- change if you run several

HOME_PAGE_URL  = BASE_URL
HOME_PAGE      = "index"              -- the id of the homepage node
SEARCH_PAGE    = "search"             -- comment out remove the search box

--SEARCH_CONTENT = "Installation"

TIME_ZONE      = "+0000"
TIME_ZONE_NAME = "<abbr title='Greenwich Mean Time'>GMT</abbr>"

-----------------------------------------------------------------------------
--------- URLs --------------------------------------------------------------
-----------------------------------------------------------------------------

--ICON_BASE_URL  = "/some/path/"       -- set this to host icons elsewhere
--CSS_BASE_URL   = "/some/path/"       -- set this to host CSS elsewhere
--JS_BASE_URL    = "/some/path/"       -- set this to host JavaScript elsewhere
--FONT_BASE_URL    = "/some/path/"     -- set this to host fonts elsewhere
FAVICON_NODE     = "icons/sputnik.png"
--FAVICON_URL    = ICON_BASE_URL..FAVICON_NODE

-----------------------------------------------------------------------------
--------- Interface ---------------------------------------------------------
-----------------------------------------------------------------------------

-- the language of the interface
INTERFACE_LANGUAGE = "en"

-- Actions that may appear in the node toolbar as commands
-- (this is the maximum set of commands for the toolbar - each user will only
-- see those they can permissions for)
TOOLBAR_COMMANDS = {"edit", "configure", "history", "rss"}

-- Optional icons for the commands
TOOLBAR_ICONS = {
   edit = "icons/edit.png",
   configure = "icons/system.png",
   history = "icons/history.png",
   rss = "icons/rss.png",
}

NEW_NODE_PROTOTYPES = {
   {"@Image", title="Image", icon="icons/picture.png"},
   {"@Binary_File", title="Binary File", icon="icons/attach.png"},
   {"@Collection", title="Collection", icon = "icons/collection.png"},
   {"@Discussion", title="Discussion", icon = "icons/discussion.png"},
   {"@DiscussionForum", title="Discussion Forum", icon="icons/forum.png"},
}

-- If no other section of the navigation bar is selected, choose this index
-- from the navigation table and set it's class to 'front'.  You can set this
-- value to nil to disable this behavior.
DEFAULT_NAVSECTION = 1

-----------------------------------------------------------------------------
--------- Etc. --------------------------------------------------------------
-----------------------------------------------------------------------------

--- Configure the acceptable mime types for file uploads

MIME_TYPES = {
   ["image/png"] = "png",
   ["image/jpeg"] = "jpg",
   ["image/gif"] = "gif",
   ["application/pdf"] = "pdf",
   ["text/plain"] = "txt",
   ["application/x-font-woff"] = "woff",
}

--- configure interwiki links for sister-sites

INTERWIKI = {
   sputnik = "http://spu.tnik.org/en/",
   wikipedia = "http://en.wikipedia.org/wiki/%s",
   ["lua-users"] = function(node_name)
                      local prefix = "http://lua-users.org/wiki/"
                      return prefix..node_name:gsub("%s", "")
                   end
}

--- set the number of honey pots to entertain the spammers
NUM_HONEYPOTS_IN_FORMS = 5

-----------------------------------------------------------------------------
--- PLEASE READ THE DOCUMENTATION BEFORE EDITING ANY OF THE PARAMETERS BELOW 
--- CHANGING THEM CAN MAKE THE SITE UNACCESSIBLE ----------------------------
-----------------------------------------------------------------------------

-- Node names

ADMIN_NODE_PREFIX = "sputnik/"
HISTORY_PAGE              = "history"
DEFAULT_NAVIGATION_BAR    = ADMIN_NODE_PREFIX.."navigation"
LOGIN_NODE                = ADMIN_NODE_PREFIX.."login"
LOGOUT_NODE               = ADMIN_NODE_PREFIX.."logout"
REGISTRATION_NODE         = ADMIN_NODE_PREFIX.."register"
-- The following built-in nodes do not need variables because we never link
-- to them: "sputnik/sitemap", "sputnik/version"

-- the versions of those rocks will be displayed under "sputnik/version"
ROCK_LIST_FOR_VERSION     = { "sputnik", "versium", "saci",
                              "colors", "diff", "xssfilter", "recaptcha",
                              "cosmo", "wsapi", "markdown" }
]=============]


