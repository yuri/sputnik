module(..., package.seeall)

NODE = {
   title="@Text_Config (Prototype for Text Config File)",
   category="_prototypes",
   actions=[[show = "wiki.code"]],
   permissions = [[
      deny(all, "save")
      allow("Admin", "save")
   ]],
}
NODE.content=[===[
The content of this page is ignored but it's fields are inherited by 
some of the other pages of this wiki.
]===]
