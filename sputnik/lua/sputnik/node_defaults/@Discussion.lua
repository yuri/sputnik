module(..., package.seeall)
NODE = {
prototype="@Collection"
}

NODE.child_defaults = [=[
new = [[ 
prototype = "@Comment"
title     = "New Comment"
actions   = 'save="comments.save_new"'
]]
]=]

NODE.html_content = [=[
Add <a href="$new_url">new comment</a>.

<br/><br/>

 $do_nodes[[

  <h2>
   <span id="trigger_message_$short_id" class="ctrigger $closed">
    <span class="email_address">$short_id |</span> <img alt="author" src="$icon"/> some dude </span>
  </h2>

  <div id="message_$short_id">
  $content

  <p><a href="$new_url&parent_comment=$short_id">reply</a>, $parent_comment</p> 
  </div>

 ]]
 </table>
]=]
