module(..., package.seeall)

NODE = {
   title="Configurations",
   prototype="sputnik/config_defaults",
}

NODE.content = [=============[

SITE_TITLE     = "Sputnik"            -- change the title of the site
SITE_SUBTITLE  = "An extensible wiki in Lua"       -- change the subtitle of the site
DOMAIN         = "localhost:8080"     -- set for RSS feeds to work properly
--USE_NICE_URL   = false                -- set if you want "nicer" URLs
MAIN_COLOR     = 200                  -- pick a number from 0 to 360
--BODY_BG_COLOR  = "white"

HOME_PAGE      = "index"
HOME_PAGE_URL  = BASE_URL             -- or BASE_URL.."?p="..HOME_PAGE
COOKIE_NAME    = "Sputnik"            -- change if you run several

--SEARCH_CONTENT = "Installation"

TIME_ZONE      = "+0000"
TIME_ZONE_NAME = "<abbr title='Greenwich Mean Time'>GMT</abbr>"


INTERFACE_LANGUAGE = "en"

]=============]

NODE.raw_content_type = "lua"

