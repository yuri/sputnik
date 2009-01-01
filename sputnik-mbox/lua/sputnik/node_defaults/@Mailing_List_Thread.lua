module(..., package.seeall)

NODE = {
   actions="show='mbox.show'",
   title = "Mailing List Thread",
   content = "   "
}

NODE.permissions = [[
deny(all, edit_and_save)
allow(Admin, edit_and_save)
]]

NODE.html_content = [====[
<div width='100%'>
 <style>
  .email_from {
    font-size: 200%;
  }
  .email_address {
    font-family: monospace;
    color: #666;
  }
  .email_date {
    font-size: 140%;
    color: #333;
  }
  .email_message pre {
    border: none;
    background: white;
  }
  .email_message code {
    font-size: 100%;
    background: white;
  }
  .email_message {

  }
  .email_attachment {
    padding: 3 3 3 3;
    margin-left: 20px;    
  }
  .email_header {
    width: 100%;
    border: 1px solid orange;
    background: #eee;
    margin: 0 0 0 0;
    padding: 3px 10px 3px 15px;
  }
  blockquote {
    border-left: 2px solid #ddd;
    margin-left: 10px;
    padding-left: 10px;
  }
  pre.email_body {
    background: white;
    border: none;
    size: 110%;
  }
  span.quote_in_email {
    color: #994;
  }
 </style>
  
 $do_messages[=[

     <h2>
      <span id="trigger_message_$message_id" class="ctrigger $closed">
       $username <span class="email_address">($date)</span>
      </span>
     </h2>
     <div id="message_$message_id" class="collapse">
     <span class="email_address">$name &lt;$email&gt;</span><br/>

     <pre class="email_body">$body</pre>
     $do_attachments[[
      <div class="email_attachment">
      Attachment: <a href="$url">$name</a> ($size)
      </div>
     ]]
     </div>
   ]=]

</div>
]====]

