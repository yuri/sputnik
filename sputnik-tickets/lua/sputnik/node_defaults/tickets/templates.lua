module(..., package.seeall)
NODE = {
   prototype="@Lua_Config"
}
NODE.content = [=====[
LIST = [===[
<a $new_ticket_link>Create a New Ticket</a> | 
$if_showing_all[[<a $link>Hide closed</a>]]
$if_showing_open[[<a $link>Show closed</a>]]
<br/><br/>

<script type="text/javascript">
/* <![CDATA[ */
 $sorttable_script
/* ]]> */
</script>
<table class="sortable" width="100%">
 <thead>
  <tr>
   <th>ID</th>
   <th>priority</th>
   <th>milestone</th>
   <th>status</th>
   <th>title</th>
  </tr>
 </thead>
 $do_tickets[[
  <tr style="background:$color">
   <td width="20px"><a $ticket_link>$ticket_id</a></td>
   <td width="20px">$priority</td>
   <td width="20px">$milestone</td>
   <td sorttable_customkey="$num_status" width="20px">$status</td>
   <td>$title</td>
  </tr>
 ]]
</table>

(Click on the headers to sort.)
]===]

SHOW = [===[

See <a $index_link>all tickets</a> <br/><br/>

<table width="50%">
 <tr>
  <td width="40px">Reported by</td>
  <td width="100px">$reported_by</td>
 </tr>
 <tr style="background:$ticket_status_color">
  <td>Status</td>
  <td>$status</td>
 </tr>
 <tr>
  <td>Severity</td>
  <td>$severity</td>
 </tr>
 <tr style="background:$ticket_priority_color">
  <td>Priority</td>
  <td>$priority</td>
 </tr>
 <tr>
  <td>Milestone</td>
  <td>$milestone</td>
 </tr>
 <tr>
  <td>Version</td>
  <td>$prod_version</td>
 </tr>
 <tr>
  <td>Component</td>
  <td>$component</td>
 </tr>
 <tr>
  <td>Keywords</td>
  <td>$keywords</td>
 </tr>
 <tr>
  <td>Assigned to</td>
  <td>$assigned_to</td>
 </tr>
</table>
<br/>

$content

]===]   

]=====]
