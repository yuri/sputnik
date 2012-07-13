module(..., package.seeall)
NODE = {
   title="@CSS (Prototype for CSS Pages)",
   prototype="@Text_Config",
   category="_prototypes",
   actions=[[css="css.css"]],
   content=[[ The content of this page is ignored but it's fields are inherited by some of the other pages of this wiki.]],
   permissions=[[allow(all_users, "css")]],
   http_cache_control = "max-age=3600",
   http_expires = "2",
}

