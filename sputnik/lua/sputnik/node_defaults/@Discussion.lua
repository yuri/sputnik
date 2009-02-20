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
