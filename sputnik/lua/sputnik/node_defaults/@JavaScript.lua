module(..., package.seeall)
NODE = {
   title="@JavaScript (Prototype for Javascript Pages)",
   prototype="@Text_Config",
   category="_prototypes",
   actions=[[js="javascript.js"]],
   permissions = [[allow(all_users, "js")]],
   content=[[ The content of this page is ignored but it's fields are inherited by some of the other pages of this wiki.]],
   http_cache_control = "max-age=3600",
   http_expires = "2",
}

