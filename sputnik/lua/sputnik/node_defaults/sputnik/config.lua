module(..., package.seeall)

NODE = {
   title="Configurations",
   prototype="sputnik/config_defaults",
}

NODE.content = [=============[

SITE_TITLE     = "My New Wiki"        -- change the title of the site
SITE_SUBTITLE  = "Don't panic!"       -- change the subtitle of the site
DOMAIN         = "localhost:8080"     -- set for RSS feeds to work properly
COOKIE_NAME    = "Sputnik"            -- change if you run several

INTERFACE_LANGUAGE = "en"             -- try also 'pt', 'es', 'ru'

]=============]

NODE.raw_content_type = "lua"

