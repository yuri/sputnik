module(..., package.seeall)

NODE = {
   title="Search",
   prototype="@Lua_Config",
   actions=[[show="search.show_results"]]
}
NODE.content=[===[

TEMPLATE = [==[
<script src="http://www.google.com/uds/api?file=uds.js&amp;v=0.1&amp;key=$api_key"
        type="text/javascript"></script>
<script type="text/javascript">

    var search;

    function do_search() {
      // Initialize the web searcher
      search = new GwebSearch();
      search.setResultSetSize(GSearch.LARGE_RESULTSET);
      search.setSiteRestriction("$site");
      search.setSearchCompleteCallback(null, OnWebSearch);
      search.execute("$query");
    }

    function OnWebSearch() {
      if (!search.results) return;
      var searchresults = document.getElementById("searchresults");
      searchresults.innerHTML = "";

      var results = "";
      for (var i = 0; i < search.results.length; i++) {
        var thisResult = search.results[i];
        results += "<p>";
        results += "<a href=\"" + thisResult.url + "\">" + thisResult.title + "<\/a><br \/>";
        results += thisResult.content + "<br \/>";
        //results += "<span class=\"url\">" + thisResult.url + "<\/span>";
        if (thisResult.cacheUrl) {
            //results += " - <a class=\"cached\" href=\"" + thisResult.cacheUrl + "\">Cached <\/a>";
        }
        results += "<\/p>";
      }
      searchresults.innerHTML = results;
    }

    do_search();

    //]]>
    </script>
    The search results are provided by Google and may be out of date.<br/>
    <div id="searchresults"></div>
]==]
]===]

