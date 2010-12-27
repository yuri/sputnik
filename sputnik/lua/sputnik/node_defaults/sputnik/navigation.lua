module(..., package.seeall)

NODE = {
   title="Navigation",
   prototype="@Lua_Config"
}
NODE.content=[============[

NAVIGATION = {
   {id="index", title="Let's Start",
     {id="index", title="Start"},
     {id="Another Page", title="Some Other Page"},
   },      
   {id="history", title="Timeline",
     {id="history", title="Recent Wiki Edits"},
     {id="history.rss", title="RSS Feed"},
   },
}
]============]
