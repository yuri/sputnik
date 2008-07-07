module(..., package.seeall)

NODE = {
   title="Color Configuration",
   prototype="@Lua_Config",
   actions=[[css="css.fancy_css"]],
   fields = [[content.activate = nil]],
   permissions=[[allow(all_users, "css")]],
}

NODE.content = [===[
MAIN_HUE             = 200  -- pick a number between 0 and 360
STARTING_SATURATION  =  .7  -- pick a number between 0 and 1
MAIN                 = colors.new(MAIN_HUE, STARTING_SATURATION, .50)

SECOND, THIRD        = MAIN:neighbors()      -- MAIN:terciary() for more contrast
THIRD                = SECOND                -- stick with just one color

GRAY                 = MAIN:desaturate_to(0) -- set value > 0 to make your "grays" lightly colored
LIGHT_GRAY           = GRAY:tint(.7)         -- higher number = lighter
LIGHTEST_GRAY        = GRAY:tint(.9)         -- higher number = lighter
DARK_GRAY            = GRAY:shade(.7)        -- higher nu mber = darker
WHITE                = "white"
BLACK                = "black"

BODY_BG              = MAIN:desaturate_to(.2):tint(.4) -- or set to WHITE
LINK                 = "#0000cc" -- darker blue
TEXT                 = BLACK

NAVBAR               = SECOND:desaturate_to(.7):shade(.1)

MENU_TEXT         = WHITE
MENU_TEXT_HOVER   = "yellow"
MENU_BG           = SECOND:shade(.5)
MENU_BG_HOVER     = SECOND:shade(.4)
SUBMENU_CURRENT_BG     = THIRD:shade(.2)
SUBMENU_CURRENT_BORDER = WHITE
SUBMENU_CURRENT_FG     = WHITE
SUBMENU_BG           = THIRD:shade(.2)
SUBMENU_BORDER  = THIRD:tint(.3)
SUBMENU_FG      = WHITE

HEADER               = THIRD:shade(.1)
H_LINE               = THIRD:shade(.1)

FORM_BG              = SECOND:desaturate_to(.6):tint(.9)
FORM_BG_SUBMIT       = SECOND:desaturate_to(.8):tint(.3)
FORM_BG_READONLY     = SECOND:desaturate_to(.2):tint(.7)
FORM_BORDER          = SECOND
INS                  = "#cfc"


CSS = [[

body                  {                          background: $BODY_BG;                                                     }

#bd                   {                          background: $WHITE;               BORDER:        1px solid  $DARK_GRAY;   }
#sidebar              {                                                            border-right:  1px solid  $NAVBAR;      }
H1                    {                                                            BORDER-BOTTOM: 4px solid  $NAVBAR;      }
H1.title A            { color: black;                                                                                      }
H2                    { COLOR: $HEADER;                                            BORDER-BOTTOM: 4px solid  $H_LINE;      }
H3                    { COLOR: $HEADER;                                            BORDER-BOTTOM: 2px dotted $H_LINE;      }
H4                    { COLOR: $HEADER;                                            BORDER-BOTTOM: 1px dotted $H_LINE;      }
H5                    { COLOR: $HEADER;                                                                                    }
ul#menu a             { color: $MENU_TEXT;       background: $MENU_BG;                                                     }
ul#menu li a:hover    { color: $MENU_TEXT_HOVER;                                                                           }
ul#menu li.front a    {                          background: $NAVBAR;                                                      }
ul#menu li ul            {                          background: $NAVBAR;                                                      }
ul#menu li ul li.front a { color: $WHITE;           background: $SUBMENU_CURRENT_BG;  BORDER:        2px solid  $SUBMENU_CURRENT_BORDER; }
ul#menu li ul li.back a  { color: $SUBMENU_FG;      background: $SUBMENU_BG;          BORDER:        1px solid  $SUBMENU_BORDER; }
ul#menu li ul li a:hover { color: $MENU_TEXT_HOVER;                                                                           }

DEL                   { COLOR: $BLACK;           background: $LIGHT_GRAY;                                                  }
INS                   { COLOR: $TEXT;            background: $INS;                                                         }
A:link                { COLOR: $LINK;                                                                                      }
A:visited             { COLOR: $LINK;                                                                                      }
A:hover               { COLOR: $LINK;                                                                                      }
A.no_such_node        {                          background: #fffacd;                                                      }

CODE                  {                          background: $LIGHTEST_GRAY;                                               }
PRE                   {                          background: $LIGHTEST_GRAY;       BORDER:        1px solid  $LIGHT_GRAY;  }
TH                    {                          background: $LIGHTEST_GRAY;       BORDER:        1px solid  $LIGHT_GRAY;  }
TD                    {                                                            BORDER:        1px solid  $LIGHT_GRAY;  } 
.preview              {                                                            BORDER:        4px solid  #666;         }
.missing_page         {                          background: $LIGHT_GRAY                                                   }




INPUT, SELECT         {                          background: $FORM_BG;             BORDER:        1px solid  $FORM_BORDER; }
INPUT.readonly        {                          background: $FORM_BG_READONLY;    BORDER:        1px solid  $FORM_BORDER; }
INPUT.checkbox        {                          background: $FORM_BG;             BORDER:        1px solid  $FORM_BORDER; }
TEXTAREA              {                          background: $FORM_BG;             BORDER:        1px solid  $FORM_BORDER; }
INPUT.submit          {                          background: $FORM_BG_SUBMIT;      BORDER:        1px outset $FORM_BORDER; }
A.button              {                          background: $FORM_BG_SUBMIT;      BORDER:        1px outset $FORM_BORDER; 
    color: black; text-decoration: none;                                                                               
}
INPUT.small_submit    {                          background: $FORM_BG_SUBMIT;      BORDER:        1px outset $FORM_BORDER; }
.save input           {                          background: #ffa20f;              border:        2px outset #d7b9c9       }

.error_message        {                                                            BORDER:        2px solid  red;          }
.content .preview     {                                                            BORDER:        3px dashed $NAV_BAR;     }
]]
]===]

