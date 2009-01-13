module(..., package.seeall)

NODE = {
   title="PUC Presentation 2009",
   templates="_templates_for_s9"
}
NODE.actions = [[
slides = "s9.slides"
]]
NODE.permissions = [[
allow(all_users, "slides")
]]

NODE.content = [========[
<span class="teaser">
  Those are slides for a Sputnik presentation at PUC in 2009.  They can be viewed as a slideshow.
</span>

To see this as a slideshow:

- On Firefox install [FullerScreen](https://addons.mozilla.org/en-US/firefox/addon/4650)
    - Supposedly it works in Opera out-of-the-box
- Go to [[PUC Presentation 2009.slides]]
- Press F11

Use "Page Up" and "Page Down" to navigate.

&nbsp;
-----------------------------

<span style="font-size: 700%">Sputnik</span>

<span style="font-size: 300%">Content Management in Lua</span>

<br/>

<span style="display: block; font-size: 150%; margin-left: 2em;">
 Yuri Takhteyev
 <br/>
 January 13, 2009
</span>

&nbsp;
---------------------------------------------------------------------

<br/><br/><br/>

<center>
 <span style="font-size: 500%">Introduction</span>
</center>


Introduction
---------------------------------------------------------------------

### Sputnik is a simple CMS
### Sputnik is functional as a wiki out of the box
### Sputnik is extensible into other things



Sputnik &amp; Lua
---------------------------------------------------------------------

### Sputnik is written in Lua
### Sputnik uses Lua for configuration
### Sputnik stores data in Lua



Sputnik &amp; Kepler
---------------------------------------------------------------------

### WSAPI for web stuff

Can use Xavante as the server. Or (fast)cgi.

### LuaRocks for package management

Both initial installation and for adding plugins later.

### Other Kepler Modules

LuaFileSystem, MD5, cosmo


Other Modules
---------------------------------------------------------------------

### Must Have

LPEG (for cosmo)

### Good to Have

lbase64, luasocket, Markdown

### Optional

LuaSQL, LuaSVN, LuaSQL, lzlib

*(All available as Rocks.)*


&nbsp;
---------------------------------------------------------------------

<br/><br/><br/>

<center>
 <span style="font-size: 500%">A guided demo</span>
</center>




Installation
---------------------------------------------------------------------

### Pick a place

    mkdir ~/sputnik
    cd ~/sputnik

### Install Lua + LuaRocks + Kepler

    wget http://luaforge.net/frs/download.php/3468/kepler-install-1.1-1 
    bash kepler-install-1.1-1 --prefix=${PWD} --without-readline

### Install Sputnik

    ./bin/luarocks --only-from=http://sputnik.freewisdom.org/rocks/earth install sputnik
    ./bin/lua -lluarocks.require -e 'require("sputnik").setup()'
    mkdir wiki-data && chmod -R a+rw wiki-data


Live Dangerously
---------------------------------------------------------------------

### Add the latest code from git

    git clone git://gitorious.org/sputnik/mainline.git mainline.git
    bash mainline.git/scripts/link_rock.sh -i ${PWD} -g mainline.git


What Did We Get? A Wiki.
---------------------------------------------------------------------

### Standard Wiki Features

Editable pages, history, diff, RSS, permissions, user accounts.

### Configurability

sputnik/config, sputnik/navigation, etc


Markup
---------------------------------------------------------------------

### Markdown is the default

### Easy to replace

- LuaPod (Sérgio Medeiros)
- Medialike (Hisham Muhammad)
- Store HTML and edit with TinyMCE

(Just plug in a function.)


Templates
---------------------------------------------------------------------

### 1. Cosmo templates

    $do_messages[[<p class="$class">$message</p>]]
    <div class='content'>$content</div>

### 2. A Lua table

    {
      do_messages      = node.messages,
      content          = node.inner_html,
    }


Templates
---------------------------------------------------------------------

### Produces

    <p class="notice">Successfully created your new account.\</p>
    <div class='content'>\</div>

(See http://cosmo.luaforge.net)


Internationalization
---------------------------------------------------------------------

### 1. Keys in templates

    $if_logged_in[[ _(HI_USER) (<a $logout_link>_(LOGOUT)</a>) ]]

### 2. A translation file

    HI_USER = {
       en_US = "Hi, $user!",
       ru    = "Превед, $user!",
       pt_BR = "Oi, $user!", 
    }


Internationalization
---------------------------------------------------------------------

### 3. A config value

    INTERFACE_LANGUAGE = "ru"

### Produces

    Превед, Медвед!



What's In a Node?
---------------------------------------------------------------------

### Everything! (Except for the code.)

Configurations, javascript, css, passwords.

See "sputnik" node for a (nearly) complete list.

### Everything?

Yes, everything. Even the icons.

(We'll come back to this.)


&nbsp;
---------------------------------------------------------------------

<br/><br/><br/>

<center>
 <span style="font-size: 500%">Getting under the hood</span>
</center>


Directory Layout
---------------------------------------------------------------------

    ~/sputnik
              bin/
                  lua
                  luarocks, luarocks-admin
                  xavante-start, wsapi.cgi
              rocks/
                    sputnik, etc
              kepler/
                     htdocs/
                            sputnik.ws
              mainline.git/


Directory Layout
---------------------------------------------------------------------

### Lua + LuaRocks

    ~/sputnik/
    ~/sputnik/bin/lua, luarocks

### Kepler

    ~/sputnik/rocks/wsapi, lfs, etc.
    ~/sputnik/bin/xavante-start, wsapi.cgi
    ~/sputnik/kepler/htdocs/

### Sputnik

    ~/sputnik/rocks/sputnik, etc.
    ~/sputnik/kepler/htdocs/sputnik.ws
    ~/sputnik/wiki-data/
    ~/sputnik/mainline-git/


sputnik.ws
---------------------------------------------------------------------

### ~/sputnik/kepler/htdocs/sputnik.ws

    require('sputnik')
    return sputnik.wsapi_app.new{
       VERSIUM_PARAMS = { '/home/yuri/sputnik/wiki-data/' },
       BASE_URL       = '/sputnik.ws',
       PASSWORD_SALT  = 'ADzkBbB51xfJgsptsDF0Wep1LAJxK0sbuRlWTMRL',
       TOKEN_SALT     = '9XkgfzAy25oPaEHL4h9E7rFr9ReStVttIEzN4ZbX',
    }

(sputnik.cgi looks basically the same.)

sputnik.wsapi\_app.new()
---------------------------------------------------------------------

### Initialization

1. instantiate my\_sputnik

### For each request (returned as a function)

1. wsapi\_env -->**\[wsapi\]**--> a request

2. preprocess the request

3. request.node_id -->**\[my_sputnik\]**--> a node

4. request.command -->**\[node\]**--> action_function

5. request.params -->**\[action_function\]**--> content, content\_type

(All wrapped in pcalls for error handling.)


Storage
---------------------------------------------------------------------

### Saci

A document-oriented hierarchical storage system with history.

(Like ORM but without the R.)

* Inflation and deflation of nodes
* Lua as the format
* Inheritance
* Permissions
* History
* Abstracted from physical storage


Versioned Physical Storage
---------------------------------------------------------------------

### A simple API

"Versium"

### Five implementations

- files & directories (131 lines)
- git (167 lines)
- mysql (208 lines)
- sqlite3 (200 lines)
- subversion (coming soon)

(See http://sputnik.freewisdom.org/en/Versium)


Inflation with Saci
---------------------------------------------------------------------

### Chunks of data, stored as Lua code

* Versioned (via "Versium")
* Self-describing
* Can be "activated"
* Use prototype inheritance
* Can have children (sort of)

Fields Description and Activation
---------------------------------------------------------------------

    fields = [[
      fields          = {0.0, proto="concat", activate="lua"}
      title           = {0.1  }
      ...
      prototype       = {0.6  }
      ...
      content         = {0.8  }
    ]]

    title = "@Root (Root Prototype)"

    content = [[
      ...
    ]]

The numbers are for ordering fields. "activate" tells us what to do with the field.

Inheritance
-----------------

### none

Only use own value

### fallback

Use own value if set, otherwise of the prototype node

### concat

Concatentate own value with that of the prototype node - most useful if content is Lua.

Inheritance Examples
--------------------------------

    fields = [[
      fields          = {0.0, proto="concat", activate="lua"}  -- Example #2
      title           = {0.1  }
      ...
      prototype       = {0.6  }
      permissions     = {0.7, proto="concat"}                  -- Example #1
      ...
      content         = {0.8  }
      edit_ui         = {0.9, proto="concat"}                  -- Example #3
    ]]

<br/>

Note: permissions and edit_ui store Lua code, but are not activated automatically.
This is because they require a custom environment.

node.permissions
--------------------------------

### @Root

    deny(all_users, all_actions)
    allow(all_users, "show")
    allow(all_users, "edit")

### @Text_Config

    deny(all_users, all_actions)
    allow(Admin, all_actions)
    allow(all_users, "login")

### @JavaScript

    allow(all_users, "js")


node.fields
--------------------------------

### @Root

    ...
    content         = {0.8  }

### @Lua_Config

    content.activate = "lua"


node.edit\_ui
--------------------------------

### @Root

    page_name       = {1.1, "readonly_text"}
    title           = {1.2, "text_field"}
    ...
    content         = {3.01, "editor", rows=15, no_label=true}

### @Binary_File

    content         = nil
    file_upload     = {1.30, "file"}
    file_description = {1.31, "text_field"}
    file_copyright  = {1.32, "text_field"}


Commands & Actions
-----------------

### Request = node + command ( + parameters )

- Lua\_Workshop\_2008 + .slides ( & version=000004 )

### Node + command ⇒ action function

- mapping can be overriden on per-node basis

### Action function returns content + status

- HTML, XML, Lua code, a binary image


Mapping Actions
---------------------------------------------------------------------

### @Root

    show            = "wiki.show"
    show_content    = "wiki.show_content"
    history         = "wiki.history"
    edit            = "wiki.edit"

### @Binary_File

    show            = "binaryfile.show"
    save            = "binaryfile.save"
    download        = "binaryfile.download"

### logo

    png             = "binaryfile.mimetype"


A Round of Q&amp;A
---------------------------------------------------------------------

(But we are not done yet.)


&nbsp;
---------------------------------------------------------------------

<br/><br/><br/>

<center>
 <span style="font-size: 500%">Collections</span>
</center>

Collections
---------------------------------------------------------------------

(A live demo.)

Tickets
---------------------------

### A simple issue tracker

1. A prototype
2. Templates
3. Two actions



Adding a Prototype
---------------------------

### More Fields

    fields= [[
      reported_by = {.11}
      priority    = {.12}
      component   = {.13}
      assigned_to = {.14}
      status      = {.15} 
      resolution  = {.16}
    ]]

Adding a Prototype
-------------------------------

### Edit UI

    NODE.edit_ui= [[
      reported_by    = {1.31, "text_field"}
      assigned_to    = {1.32, "text_field"}
      status         = {1.33, "select", 
                      options = {"open", "someday", ... }}
      resolution     = {1.35, "select",
                      options = {"n.a.", "fixed", "wontfix"}}
      priority       = {2.10, "select", 
                      options = {"unassigned", "high", ... }}
      page_name   = null
    ]]

Loose Ends
-------------------------------

    actions= [[show = "tickets.show"]]

    translations = "tickets/translations"
    templates    = "tickets/templates"

Adding Templates
-------------------------------

    <table width="100%">
     <tr style="background:$status_color">
      <td width="15%" style="text-align: right;">
       <span style="font-size: 80%">ticket id</span><br/>
       <span style="font-size: 200%;">$ticket_id</span>
      </td>
      <td width="15%" style="text-align: right;">
       <span style="font-size: 80%">status</span><br/>
       <span style="font-size: 200%">$status</span>
       ...

Adding Templates
-------------------------------

               
                           $status_color  
       
        
                                      $ticket_id
       
       
     
                                     $status


Adding Actions
--------------

    actions.show = function(node, request, sputnik)
       local parent_id = node.id:match(PARENT_PATTERN)
       local index_node = sputnik:get_node(parent_id)
       local ticket_info = {
          status       = node.status
          status_color = status_to_color[node.status] or "white",
          ticket_id    = node.id:gsub(parent_id.."/", ""),
          ...
       }
       ...
       node.inner_html = cosmo.fill(node.templates.SHOW, ticket_info)
       return node.wrappers.default(node, request, sputnik)
    end


&nbsp;
---------------------------------------------------------------------

<br/><br/><br/>

<center>
 <span style="font-size: 500%">One more thing</span>
</center>



Reading Mail
---------------------

### Sputnik Side

A new prototype node

A custom action to read mbox content

### Loader

mpop for fetching mail

A Lua script for loading it into Sputnik (66 lines)



&nbsp;
---------------------------------------------------------------------

<br/><br/><br/>

<center>
 <span style="font-size: 500%">Yes, we are done.</span>
</center>


Q&amp;A
--------------

### http://sputnik.freewisdom.org/

http://sputnik.freewisdom.org/en/PUC\_Presentation\_2009.slides

### Credits

André Carregal, Bruno Guedes, Dado Sutter, Hisham Muhammad, Jérôme Vuarand, Jim Whitehead, Pierre Pracht, Sérgio Medeiros, Yuri Takhteyev

(see http://sputnik.freewisdom.org/en/Credits/)

]========]
