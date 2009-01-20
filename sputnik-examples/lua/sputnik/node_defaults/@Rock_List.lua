module(..., package.seeall)
NODE = {
   title      = "@Rock_List",
   actions    = [[
      show = "rocklist.show_list_of_rocks"
   ]],
}

NODE.fields = [[
path_to_rockspecs = {}
]]

NODE.admin_edit_ui = [[
path_to_rockspecs = {0.0, "text_field"}
]]

NODE.html_content = [[
<style>
.luarocks_package_name {
  font-size: 150%;
}

.luarocks_kudos {
  border: 1px solid green;
  background: white;
  margin: .3em;
  padding: .3em;
}

.luarocks_details {
  border: 1px solid gray;
  background-color: #dd8;
  padding: .5em;
  margin: .5em;
  display: none;
}
</style>
<table border="0">
 <tr>
  <th width="30%">Package</th>
  <th width="10%">Stacks</th>
  <th width="60%">Description</th>
 </tr>
$do_rocks[=[
 <tr>
  <td class="luarocks_package_name">$package</td>
  <td>$kudos$stacks</td>
  <td>
  $description_summary
  <a href="#" class="luarocks_more">...</a>
  <div class="luarocks_details">
   $description_detailed
   <br/><br/>

   license: $description_license<br/>
   home page: <a href="$description_homepage">$description_homepage</a><br/>
   latest version: $version<br/>
   source: <a href="$source_url">$source_url</a><br/>
   md5 hash: $source_md5<br/>
   rock maintainer: $description_maintainer<br/>
   $kudos_text

  </div>
  
  </td>
 </tr>
]=]
</table>
]]

