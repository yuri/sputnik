module(..., package.seeall)

NODE = {
   title="Sputnik's System Nodes",
   category="_special_pages"
}
NODE.content=[=====[

<span class="teaser">
 Sputnik is a collection of nodes. Most of them are for you to create,
 but a few basic ones are included with the installation.
</span>

Sputnik has a number of system nodes. Some of those store information that
affects the behavior of the site. Such nodes could be edited to customize
your Sputnik installation. You will need to be logged in as "Admin" to do so.
Other nodes provide out of the box functionality but do not store much
inforation. There would be little benefit to editing them.

## Nodes to Edit for Configuration or Customization

* [[sputnik/config]] - the site-wide configuration node. This is the first
  thing to try for any configuration.
* [[sputnik/navigation]] - controls the navigation bar.
* [[sputnik/style]] - the stylesheet.
* [[sputnik/passwords]] - the password file. You can edit it to give certain
  users admin privileges, to delete accounts, etc.
* [[logo]] - the Sputnik logo. You can upload your own image file instead.

See also the @Root node below.

## Useful System Nodes that Probably Should Not Be Edited

* [[history]] - your history (also [[history.rss|history.rss]]).
* [[sitemap]] - the list of the pages (also [[sitemap.xml|sitemap.xml]]).
* [[sputnik/register]] - the registration page.
* [[sputnik/version]] - version information.

## Built-in Prototype Nodes

A node can inherit properties of other nodes by having its "prototype" field
set to the name of that node. As a convention, we usually prefix prototype
nodes with "@", but this is just a convention. Here are prototype nodes
available out of the box. (You can add your own.) Note that many of the
prototype nodes cannot be viewed. Instead, you can look at their "raw"
representation or configure them by changing ".raw" to ".configure".

* [[@Root.raw]] - the root prototype node. All nodes inherit from @Root
  directly or indirectly. So, edits to this node will thus affect **all**
  nodes.
* [[@Binary_File.raw]] - a prototype for nodes that store binary files.
* [[@CSS.raw]] - a prototype for nodes that store CSS code.
* [[@JavaScript.raw]] - a prototype for nodes that store Javascript.
* [[@Image.raw]] - a prototype for nodes that store images.
* [[@Lua_Config.raw]] - a prototype for nodes that store Lua configurations.
* [[@Text_Config.raw]] - a prototype for nodes that store plain-text
  configurations.
* [[@User_Profile.raw]] - a prototype for nodes representing users.

### More Complicated Prototypes

* [[@Collection.raw]] - a prototype for a node that represents a collection
  of items.
* [[@Comment.raw]] - a prototype for a node that represents a comment.
* [[@Discussion.raw]] - a @Disscussion is a [[@Collection.raw]] of
  [[@Comment.raw]]s.
* [[@Discussion_Forum.raw]] - a @Disscussion_Forum is a [[@Collection.raw]]
  of [[@Discussion.raw]]s.
* [[@UID.raw]] - a prototype for nodes that are used for generating unique IDs.

## Additional System Nodes That Store Configurations or Javascript

* [[sputnik/translations]] - the text used in the UI.
* [[sputnik/templates]] - the templates for site-wide elements.
* [[sputnik/scripts]] - Sputnik's Javascript for a regular node.
* [[sputnik/edit_scripts]] - Javascript for the editing mode.

## Icon Nodes

* [[icons/admin]]
* [[icons/anon]]
* [[icons/attach]]
* [[icons/basic_node]]
* [[icons/diff]]
* [[icons/discussion]]
* [[icons/edit]]
* [[icons/forum]]
* [[icons/history]]
* [[icons/logout]]
* [[icons/lua]]
* [[icons/minus]]
* [[icons/picture]]
* [[icons/plus]]
* [[icons/rss]]
* [[icons/search]]
* [[icons/sputnik]]
* [[icons/system]]
* [[icons/star]]
* [[icons/user]]

## Font Nodes

* [[sputnik/fonts/header]]

]=====]

