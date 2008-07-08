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

$if_has_tickets[=[

    <h2>Your Tickets</h2>

    <table class="sortable" width="100%">
     <thead>
      <tr>
       <th>&nbsp;</th>
       <th>ID</th>
       <th>priority</th>
       <th>title</th>
       <th>assigned to</th>
       <th>status</th>
       <th>component</th>
      </tr>
     </thead>
     $do_my_tickets[[
      <tr style="background:$color">
       <td width="5px"><a title="Edit Ticket $ticket_id" $edit_link><img src="$edit_icon" alt="Edit"/></a></td>
       <td width="20px"><a $ticket_link>$ticket_id</a></td>
       <td width="20px">$priority</td>
       <td>$title</td>
       <td>$assigned_to</td>
       <td sorttable_customkey="$num_status" width="20px">$status</td>
       <td>$component</td>
      </tr>
     ]]
    </table>
]=]

$if_has_no_tickets[=[<br/>You have no tickets assigned to you.]=]

<h2>Other People's Tickets</h2>

<table class="sortable" width="100%">
 <thead>
  <tr>
   <th>&nbsp;</th>
   <th>ID</th>
   <th>priority</th>
   <th>title</th>
   <th>assigned to</th>
   <th>status</th>
   <th>component</th>
  </tr>
 </thead>
 $do_tickets[[
  <tr style="background:$color">
   <td width="5px"><a title="Edit Ticket $ticket_id" $edit_link><img src="$edit_icon" alt="Edit"/></a></td>
   <td width="20px"><a $ticket_link>$ticket_id</a></td>
   <td width="20px">$priority</td>
   <td>$title</td>
   <td>$assigned_to</td>
   <td sorttable_customkey="$num_status" width="20px">$status</td>
   <td>$component</td>
  </tr>
 ]]
</table>

(Click on the headers to sort.)
]===]

SHOW = [===[

<table width="100%">
 <tr style="background:$ticket_status_color">
  <td width="15%" style="text-align: right;">
   <span style="font-size: 80%">ticket id</span><br/>
   <span style="font-size: 200%;">$ticket_id</span>
  </td>
  <td width="15%" style="text-align: right;">
   <span style="font-size: 80%">status</span><br/>
   <span style="font-size: 200%">$status</span>
  </td>
  <td width="15%" style="text-align: right;">
   <span style="font-size: 80%">priority $priority</span><br/>
   <span style="font-size: 200%">$priority_stars</span>
  </td>
  <td width="15%" style="text-align: right;">
   <span style="font-size: 80%">assigned to</span><br/>
   <span style="font-size: 200%">$assigned_to</span>
  </td>
  <td width="40%" style="text-align: right;">
   Reported by: $reported_by<br/>
   Component: $component
  </td>
 </tr>
</table>
<br/>

$content

$if_resolved[[

<h2>Resolution</h2>
<p style="font-size: 150%; font-weight: bold">$resolution</p>

$resolution_details

]]

]===]   

]=====]
