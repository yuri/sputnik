module(..., package.seeall)

NODE = {
   title="Home Page"
}

NODE.content=[===[

Congratulations, you just installed
[Sputnik](http://sputnik.freewisdom.org/)!  

What's next? 

**First**, check if can you edit pages.  (Click the pencil icon on this page.)
<b>If you experience problems editing a page, check that your data directory is writable by your web server.</b>

**Second**, click on "register" and create an account called "Admin". This
account will be special - you will be able to use it to edit pages that are
not editable by other users.  You can also create a "regular" account for
yourself, calling it something like "Bob" or "Andre".

After that, logged in as "Admin", you can do some customizations.  See
[[sputnik]] for the complete list of options, but here are some basic ideas:

Edit [[sputnik/config.edit]] page to change the title of your wiki, set the domain
of your server, a URL for your logo, etc.  While there, you can also edit the
``NICE_URL`` parameter to whatever you want the your "short" URLs to start
with.  E.g., if you set it to "/mysite/" your wikilinks will point to
"/mysite/Page_Name".

Also, edit the [[sputnik/navigation.edit]] page to set your navigation bar.
If you are new to Lua, don't get scared.  Use the "preview" button to check
if your navigation is correct. You can also change the color scheme of your
wiki by editing [[sputnik/css/colors.edit]]. (See the
[Customization](http://www.freewisdom.org/projects/sputnik/Customization)
page on the [Sputnik Wiki](http://www.freewisdom.org/projects/sputnik/) for
more information.)

]===]

