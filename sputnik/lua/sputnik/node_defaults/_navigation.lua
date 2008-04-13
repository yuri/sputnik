module(..., package.seeall)

NODE = {
   title="Navigation",
   prototype="@Lua_Config"
}
NODE.content=[============[

NAVIGATION = {
   {id="Home_Page", title="Let's Start",
     {id="Home Page"},
     {id="Another Page", title="Some Other Page"},
   },      
   {id="News", title="Timeline",
     {id="News"},
     {id="Future Plans"},
     {id="_history", title="Recent Wiki Edits"},
     {id="_edits_by_recent_users", title="Edits by Recent Users"},
     {id="_history.rss", title="RSS Feed"},
   },
   
   -- leave the section below if you want all the config pages in your menu
   {id="_readme", title="_",  
     {id="_readme"},
     {id="_config"},
 	 {id="_navigation"},
 	 {id="_colors"},
 	 {id="_layout"},
 	 {id="_templates"},
 	 {id="_translations"},
 	} 
}
]============]
