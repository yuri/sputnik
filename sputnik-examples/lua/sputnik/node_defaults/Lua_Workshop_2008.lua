module(..., package.seeall)

NODE = {
   title="Lua Workshop 2008",
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
  This is Sputnik presentation for Lua Workshop 2008.  You it can be viewed as a slideshow.
</span>

To see this as a slideshow:

- On Firefox install [FullerScreen](https://addons.mozilla.org/en-US/firefox/addon/4650)
    - Supposedly it works in Opera out-of-the-box
- Go to [[Lua Workshop 2008.slides]]
- Press F11

Use "Page Up" and "Page Down" to navigate.

&nbsp;
-----------------------------

<span style="font-size: 700%">Sputnik</span>

<span style="font-size: 300%">A Wiki in Lua</span>

<br/>

<span style="display: block; font-size: 150%; margin-left: 2em;">
 Yuri Takhteyev & Jim Whitehead II
 <br/>
 July 14, 2008
</span>



Outline
-----------------------------

### Sputnik is a wiki
### Sputnik is written in Lua
### Sputnik is extensible ... into other things

- - -

### Example 1: wowprogramming.com
### Example 2: Tickets


Demo!
-----------------------------

WSAPI
-----------------

### Easy to install

    $ bash kepler-install-1.1-1 --prefix=$SPUTNIK

### Simple web API

    #! /bin/bash /home/yuri/sputnik/bin/wsapi.cgi
    require('sputnik')
    local my_sputnik = sputnik.new{
       -- set a bunch of parameters
    }
    return function(wsapi_env)
       return my_sputnik.run(wsapi_env)
    end

WSAPI
-----------------

### Or

    #! /bin/bash /home/yuri/sputnik/bin/wsapi.cgi
    require('sputnik')
    return sputnik.new_wsapi_run_fn{
       -- set a bunch of parameters
    }

### Works with CGI, FastCGI, Xavante

LuaRocks
-----------------

### Easy to install

    $ ./bin/luarocks --from=$URL install sputnik

### Easy to add plugins, libraries

    $ ./bin/luarocks install wsapi-fcgi
    $ ./bin/luarocks --from=$URL1 install sputnik-tickets
    $ ./bin/luarocks --from=$URL2 install your-plugin



Other Components
-----------------

### Core

#### Cosmo, Markdown
#### LuaFileSystem, MD5, lbase64, luasocket

### Optional

#### LuaSQL, LuaSVN


Extensibility
----------------------

### Storage
### Markup, templates, i18n
### Object types
### Actions


Storage (and History)
----------------------

### A simple API: "Versium"

#### Five implementations

- files & directories (131 lines)
- git (167 lines)
- mysql (208 lines)
- sqlite3 (200 lines)
- subversion (coming soon)

http://sputnik.freewisdom.org/en/Versium


Markup
---------------------

### Markdown is the default

#### But anything is possible

- LuaPod (Sérgio Medeiros)
- Medialike (Hisham Muhammad)


Templates
------------------------

### 1. Cosmo templates

    $do_messages[[<p class="$class">$message</p>]]
    <div class='content'>$content</div>

### 2. A Lua Table

    {
      do_messages      = node.messages,
      content          = node.inner_html,
    }

Templates
------------------------

### Produces

    <p class="notice">Successfully created your new account.\</p>
    <div class='content'>\</div>

(See http://cosmo.luaforge.net)


Internationalization
-------------------

### 1. Keys in Templates

    $if_logged_in[[ _(HI_USER) (<a $logout_link>_(LOGOUT)</a>) ]]

### 2. A Translation File

    HI_USER = {
       en_US = "Hi, $user!",
       ru    = "Превед, $user!",
       pt_BR = "Oi, $user!", 
    }

Internationalization
-------------------

### 3. A Config Value

    INTERFACE_LANGUAGE = "ru"

### Produces

    Превед, Медвед!


Saci
-------------------

### A document-oriented hierarchical<br/>storage system with history.

Saci Nodes
-------------------

### Chunks of data
#### Stored as Lua code
#### Stored with history (via "Versium")

Saci Nodes
-------------------

### Can be "activated"
### Are self-describing
### Use prototype inheritance
### Can have children (sort of)


Commands & Actions
-----------------

### Request = Node + Command

- Lua\_Workshop\_2008 + .slides

### Node + command ⇒ action function

- mapping can be overriden on per-node basis

### Action function returns content + status

- HTML, XML, Lua code, a binary image


Example 1
-----------------------------

wowprogramming.com


wowprogramming.com
-----------------------------

### Purpose of Site
### Server specs
### Sputnik setup

wowprogramming.com API
----------------------

### Generating API Documentation and Reference
- Databases
- XML
- Lua tables

### API table for UnitHealth function
### Editing an API table
### Validating API

wowprogramming.com: Conclusions
-------------------------------

### Why Lua?
### Why Sputnik?
### Why Kepler?


Example 2
---------------------------

### "Tickets" - a simple issue tracker

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

Q&A
--------------

### http://sputnik.freewisdom.org/

http://sputnik.freewisdom.org/en/Lua_Workshop_2008.slides



]========]
