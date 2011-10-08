module(..., package.seeall)

NODE = {
   title="Home Page"
}

NODE.abstract=[===[

Congratulations, you just installed [Sputnik](http://spu.tnik.org/)!

]===]

NODE.content=[===[

<span class="teaser">
 Congratulations, you've got [Sputnik](http://spu.tnik.org/)!
</span>

What's next?

**First**, check if can you edit pages.  (Click the pencil icon on this page.)
<b>If you experience problems editing a page, check that your data directory is writable by your web server.</b>

**Second**, click on "register" and create an account called "Admin". This
account will be special - you will be able to use it to edit pages that are
not editable by other users.  You can also create a "regular" account for
yourself, calling it something like "Alice" or "Bob".

After that, logged in as "Admin", you can do some customizations.  See node
[[sputnik]] for the complete list of options, but here are some basic ideas:

Edit [[sputnik/config.edit]] node to change the title of your wiki and the domain
of your server.  While there, you can also set the ``USE_NICE_URL`` to ``true``
and edit the ``BASE_URL``parameter to whatever you want to use shorter URLs.
E.g., if you set it to "/mysite/" your wikilinks will point to "/mysite/Page_Name".

Also, edit the [[sputnik/navigation.edit]] page to set your navigation bar.
If you are new to Lua, don't get scared.  Use the "preview" button to check
if your navigation is correct. You can also change the appearance of your
wiki by editing [[sputnik/style.edit]]. (See the
[Configuration](http://spu.tnik.org/en/Configuration)
page on the [Sputnik Wiki](http://spu.tnik.org) for more information.)

]===]

