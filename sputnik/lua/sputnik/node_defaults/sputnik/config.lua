module(..., package.seeall)

NODE = {
   title="Configurations",
   prototype="sputnik/config_defaults",
}

NODE.content = [=============[

SITE_TITLE     = "My New Wiki"        -- change the title of the site
DOMAIN         = "localhost:8080"     -- set for RSS feeds to work properly
NICE_URL       = BASE_URL.."?p="      -- set if you want "nicer" URLs
MAIN_COLOR     = 200                  -- pick a number from 0 to 360
--BODY_BG_COLOR  = "white"

HOME_PAGE      = "index"
HOME_PAGE_URL  = NICE_URL             -- or NICE_URL.."?p="..HOME_PAGE
COOKIE_NAME    = "Sputnik"            -- change if you run several

--SEARCH_CONTENT = "Installation"

TIME_ZONE      = "+0000"
TIME_ZONE_NAME = "<abbr title='Greenwich Mean Time'>GMT</abbr>"


INTERFACE_LANGUAGE = "en"

]=============]


