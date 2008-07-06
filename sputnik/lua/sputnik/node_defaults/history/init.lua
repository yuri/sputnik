module(..., package.seeall)
NODE = {
   title="Changes to the Wiki",
   category="_special_pages",
   actions=[[
      show="wiki.complete_history"
      rss="wiki.complete_history_rss"
   ]],
   content = [[the content of this page will be ignored]],
   permissions = [[
      deny(all_users, "edit")
      deny(all_users, "history")
      deny(all_users, "save")
   ]]
}

