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

### Easy to Install

    $ bash kepler-install-1.1-1 --prefix=$SPUTNIK --without-readline

### Simple Web API

    #! /bin/bash /home/yuri/sputnik/bin/wsapi.cgi
    require('sputnik')
    return sputnik.new_wsapi_run_fn{
       -- set some parameters
    }

LuaRocks
-----------------

### Easy to Install

    $ ./bin/luarocks --from=http://sputnik.freewisdom.org/rocks/earth
         install sputnik

### Easy to Add Plugins

    $ ./bin/luarocks --from=http://sputnik.freewisdom.org/rocks/earth
         install sputnik-tickets


Other Components
-----------------

### Cosmo, Markdown
### LuaFileSystem, MD5, lbase64, luasocket
### Optionally: LuaSQL, LuaSVN


Extensibility
----------------------

### Storage
### Markup
### Templates
### Internationalization

- - -

### Object Types
### Actions


Storage
----------------------

### A Simple API: "Versium"

#### Five Implementations

- files & directories (131 lines)
- git (167 lines)
- mysql (208 lines)
- sqlite3 (200 lines)
- subversion (coming soon)


Markup
---------------------

### Markdown is the default

#### But anything is possible

- LuaPod (Sérgio Medeiros)
- Medialike (Hisham Muhammad)


Templates
------------------------

### 1. Cosmo Templates

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

### A document-oriented hierarchical storage system

#### "Nodes"

- have history
- represented as Lua code
- can be activated
- self-describing
- use prototype inheritance
- can have children (sort of)

(Physical storage is abstracted via "Versium")

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

### wowprogramming.com


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


]========]
