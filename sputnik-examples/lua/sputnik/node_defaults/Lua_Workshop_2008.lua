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

### Works with CGI, FastCGI, Xavante


WSAPI
-----------------

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

WSAPI
-----------------

### Application side

    local request = wsapi.request.new(wsapi_env)
    request = self:translate_request(request)
    local node = self:get_node(request.node_id)
    local action_fn = self:get_action_fn(node, request.command)
    local content, content_type = action_fn(node, request, self)    

    local response = wsapi.response.new()
    response.headers["Content-Type"] = content_type or "text/html"
    response:write(content)
    return response:finish()

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

(See http://sputnik.freewisdom.org/en/Versium)


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

### Request = Node + Command + Parameters

- Lua\_Workshop\_2008 + .slides

### Node + command ⇒ action function

- mapping can be overriden on per-node basis

### Action function returns content + status

- HTML, XML, Lua code, a binary image


Example 1
-----------------------------

### wowprogramming.com

Purpose of Site
-----------------------------

### Provide online reference material for book
### Community discussion and support
### Endpoint for targeted advertisement

Server specs
-----------------------------

### Virtual Private Server with modest limits:

* 384MB memory (guaranteed)
* 768MB memory (burst)
* 15GB disk space
* 200GB bandwidth limit

### Lighttpd web server
### WSAPI/Kepler stack

Sputnik setup
-----------------------------

### Pre-release version of Earth (slightly customized)
### Uses versium-mysql and sputnik-auth-mysql to speed up data access
### Contains custom modules:

- API documentation
- Forums
- Node comments
- AJAX web-based Lua interpreter
- Node redirection

API Documentation
-----------------------------

### Databases

Creating a database schema for API documentation is relatively
straightforward, but difficult to extend.

- Could make the schema extensible through use of tag/value pairs in a separate table
- Handles concurrent edits better than alternative methods due to centralized system/locking
- PROBLEM: How to create an intuitive web form for editing this data

API Documentation
-----------------

### XML

#### XML format is easy to validate and parse but difficult to write a schema for

- As new aspects are encountered, the schema or format must change
- Extremely difficult for a human to edit directly, so requires some sort of web form and validation.

API Documentation 
-----------------------------

### Lua tables

- Lua tables are easy to serialize and read
- Adding new elements to API definitions is as simple as adding another key/value pair to the table.
- Easy to batch process
    - Simple text-based format allowing for storage in a text-based SCM for diff/history

API Documentation 
-----------------------------

### API table for UnitHealth function

     arguments = {
      [1] = {
        name = "unit",
        desc = "The unit to query",
        type = "unitId",
      },
     }
     categories = "unit, stats"
     description = "Returns the current mana points of the given unit"
     returns = {
      [1] = {
        desc = "The unit's current mana points",
        name = "mana",
        type = "number",
      },
     }
     signature = [[mana = UnitMana("unit")]]

Editing an API table
-----------------------------

#### Although the ease of editing these tables is completely subjective, empirical observations show that these more concise definitions are easier to use than XML or direct entry into a database.

Validating API
-----------------------------

### Use AJAX to check the syntax of the Lua definitions
###  Can provide error messages as well as a simple pass/fail
###  Perform more complex validation

- Only allow valid keys and value
- Check the content of description/signatures
- Possiblities are endless

Results
-----------------------------

#### 600+ pages of World of Warcraft Programming: A Guide and Reference for Creating WoW Addons were created via two-step transformation:

- Generated markup from Lua definitions
- Run a macro to convert the markup into appropriate styling and formatting
- API documents on wowprogramming.com generated on-the-fly from Lua definitions

Conclusions - Why Lua?
-----------------------------

- Easy to edit
- Easy to parse
- Extensible

Conclusions - Why Sputnik?
-----------------------------

- Modular and easy to extend
- Versium and Saci naturally fit into the way we define API functions
- Active open source project, easy to contribute to

Conclusions - Why Kepler?
-----------------------------

- WSAPI layer makes Kepler extremely easy to deploy
- Allows Sputnik to run as a WSAPI application via CGI/FastCGI
- Fits naturally into the application stack giving us a Lua solution for web deployment.



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

http://sputnik.freewisdom.org/en/Lua\_Workshop\_2008.slides

]========]
