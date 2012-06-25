module(..., package.seeall)

NODE = {
   title="@User_Profile (Prototype for User Profiles)",
   icon = "icons/user.png",
   permissions = [[
      deny(all_users, edit_and_save)
      allow(owners, edit_and_save)
      allow(Admin, edit_and_save)
   ]]
}
