module(..., package.seeall)

actions = {}

function actions.test(node, request, sputnik)
	node.inner_html = [=[
<script type="text/javascript" src="/book.ws?p=jquery.js"></script>
<script type="text/javascript" src="/book.ws?p=markitup/js/markitup.js"></script>
<script type="text/javascript" src="/book.ws?p=markitup/js/markdown.js"></script>
<link rel="stylesheet" type="text/css" href="/book.ws?p=markitup/css/simple.css" />
<link rel="stylesheet" type="text/css" href="/book.ws?p=markitup/css/markdown.css" />

<script type="text/javascript" >
   $(document).ready(function() {
      $("textarea").markItUp(mySettings);
   });
</script>
<textarea id="myTextarea"></textarea>
]=]

	return node.wrappers.default(node, request, sputnik)
end
