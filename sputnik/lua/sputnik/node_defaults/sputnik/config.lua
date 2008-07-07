module(..., package.seeall)

NODE = {
   title="Configurations",
   prototype="@Lua_Config",
}

NODE.content = [=============[
-----------------------------------------------------------------------------
----------- THINGS YOU SHOULD PROBABLY CHANGE -------------------------------
-----------------------------------------------------------------------------

DOMAIN         = "www.freewisdom.org"       -- set this for RSS feeds to work properly
SITE_TITLE     = "My New Wiki"              -- change the title of the site
NICE_URL       = BASE_URL.."?p="            -- set if you want "nicer" URLs
HOME_PAGE      = "index"
HOME_PAGE_URL  = BASE_URL                   -- or NICE_URL.."?p="..HOME_PAGE
COOKIE_NAME    = "Sputnik"                  -- change if you run several
SEARCH_PAGE    = "search"                   -- comment out remove the search box
--SEARCH_CONTENT = "Installation"
SERVER_TZ      = "-05:00"                   -- set to the correct time zone offset for sitemap to work properly

------ variables that are defined in sputnik.lua but could be changed here --

--BASE_URL
--MARKUP_MODULE

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


--- set the number of honey pots to entertain the spammers
NUM_HONEYPOTS_IN_FORMS = 5

-----------------------------------------------------------------------------
----------- NOW WAIT A SECOND -----------------------------------------------
-----------------------------------------------------------------------------
--- PLEASE READ THE DOCUMENTATION BEFORE EDITING ANY OF THE PARAMETERS BELOW 
--- CHANGING THEM CAN MAKE THE SITE UNACCESSIBLE ----------------------------
-----------------------------------------------------------------------------

STYLESHEETS = { 
  NICE_URL.."sputnik/css/yui_reset.css",
  NICE_URL.."sputnik/css/layout.css",
  NICE_URL.."sputnik/css/colors.css",
}
DEFAULT_NAVIGATION_BAR    = "sputnik/navigation"
HISTORY_PAGE              = "history"
VERSION                   = "'Earth' from the git repository"
-- the versions of those rocks will be displayed under "sputnik/version"
ROCK_LIST_FOR_VERSION     = { "sputnik", "versium", "saci",
                              "colors", "diff", "xssfilter", "recaptcha",
                              "cosmo", "wsapi", "markdown" }
]=============]


