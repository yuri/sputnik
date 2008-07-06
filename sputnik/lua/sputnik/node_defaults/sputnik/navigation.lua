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
   {id="News", title="Timeline",
     {id="News"},
     {id="Future Plans"},
     {id="history", title="Recent Wiki Edits"},
     {id="history/edits_by_recent_users", title="Edits by Recent Users"},
     {id="history.rss", title="RSS Feed"},
   },
}
]============]
