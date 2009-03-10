module(..., package.seeall)
NODE = {
prototype="@Collection"
}

NODE.save_hook = "forums.save_discussion"
NODE.fields = [[
 subject = {1.1}
 content = {1.2}
 author = {1.3}
 creation_time = {1.4}
 activity_time = {1.5}
 activity_node = {1.6}
]]
NODE.edit_ui = [[
 local origContent = content
 reset()
 prototype = {1.0, "hidden", div_class="hidden"}
 subject = {1.1, "text_field"}
 content = origContent
 content[1] = 1.2
]]

NODE.child_proto = "@Comment"

NODE.child_defaults = [=[
new = [[ 
prototype = "@Comment"
title     = "New Reply"
actions   = 'save="collections.save_new"'
]]
]=]

NODE.html_content = [=[
Add <a href="$new_url">new comment</a>.

<style>
.comment_toolbar {
 border-top: 1px solid #eee;
 margin-top: 1em;
}
.comment_toolbar a {
   text-decoration: none;
   color: #99c;
}
.comment_toolbar a:hover {
   text-decoration: underline;
   color: blue;
}
</style>

<br/><br/>

 $do_nodes[[

  <h2>
   <span id="trigger_message_$short_id" class="ctrigger $closed">
    $title
   </span>
  </h2>
  
  <div id="message_$short_id">
  <p>
  $content
  </p>

  <div class="comment_toolbar">
   $comment_author on $comment_date |
   <a href="$new_url&comment_parent=$short_id">reply</a>
   <a href="#trigger_message_$comment_parent">parent</a>
   <a href="#trigger_message_$short_id">link</a>
  </div>
  </div>

 ]]
 </table>
]=]
