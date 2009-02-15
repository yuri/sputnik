module(..., package.seeall)

NODE = {
   title="Configurations",
   prototype="@Lua_Config",
}

NODE.content = [=============[
-----------------------------------------------------------------------------
----------- THINGS YOU SHOULD PROBABLY CHANGE -------------------------------
-----------------------------------------------------------------------------

SITE_TITLE     = "My New Wiki"        -- change the title of the site
DOMAIN         = "localhost:8080"     -- set for RSS feeds to work properly
NICE_URL       = BASE_URL.."?p="      -- set if you want "nicer" URLs
MAIN_COLOR     = 200                  -- pick a number from 0 to 360
--BODY_BG_COLOR  = "white"

HOME_PAGE      = "index"
HOME_PAGE_URL  = NICE_URL             -- or NICE_URL.."?p="..HOME_PAGE
COOKIE_NAME    = "Sputnik"            -- change if you run several
SEARCH_PAGE    = "search"             -- comment out remove the search box

--SEARCH_CONTENT = "Installation"

TIME_ZONE      = "+0000"
TIME_ZONE_NAME = "<abbr title='Greenwich Mean Time'>GMT</abbr>"

ICON_BASE_URL  = NICE_URL             -- change this to host icons elsewhere
CSS_BASE_URL   = NICE_URL             -- change this to host CSS elsewhere
JS_BASE_URL    = NICE_URL             -- change this to host JS elsewhere
LOGO_URL       = ICON_BASE_URL.."logo.png"
FAVICON_URL    = ICON_BASE_URL.."icons/sputnik.png"

-----------------------------------------------------------------------------
--------- other things you might want to change -----------------------------
-----------------------------------------------------------------------------

--- Configure the acceptable mime types for file uploads

MIME_TYPES = {
   ["image/png"] = "png",
   ["image/jpeg"] = "jpg",
   ["image/gif"] = "gif",
   ["application/pdf"] = "pdf",
   ["text/plain"] = "txt",
}

--- changes the language of the wiki interface

INTERFACE_LANGUAGE = "en"

--- configure interwiki links for sister-sites

INTERWIKI = {
   sputnik = "http://spu.tnik.org/en/",
   wikipedia = "http://en.wikipedia.org/wiki/",
   ["lua-users"] = function(node_name)
                      local prefix = "http://lua-users.org/wiki/"
                      return prefix..node_name:gsub("%s", "")
                   end
}


--- set the number of honey pots to entertain the spammers
NUM_HONEYPOTS_IN_FORMS = 5

-----------------------------------------------------------------------------
----------- NOW WAIT A SECOND -----------------------------------------------
-----------------------------------------------------------------------------
--- PLEASE READ THE DOCUMENTATION BEFORE EDITING ANY OF THE PARAMETERS BELOW 
--- CHANGING THEM CAN MAKE THE SITE UNACCESSIBLE ----------------------------
-----------------------------------------------------------------------------

ADMIN_NODE_PREFIX = "sputnik/"

HISTORY_PAGE              = "history"
DEFAULT_NAVIGATION_BAR    = ADMIN_NODE_PREFIX.."navigation"
LOGIN_NODE                = ADMIN_NODE_PREFIX.."login"
REGISTRATION_NODE         = ADMIN_NODE_PREFIX.."register"

-- The following built-in nodes do not need variables because we never link
-- to them: "sputnik/sitemap", "sputnik/version"

-- the versions of those rocks will be displayed under "sputnik/version"
ROCK_LIST_FOR_VERSION     = { "sputnik", "versium", "saci",
                              "colors", "diff", "xssfilter", "recaptcha",
                              "cosmo", "wsapi", "markdown" }
]=============]


