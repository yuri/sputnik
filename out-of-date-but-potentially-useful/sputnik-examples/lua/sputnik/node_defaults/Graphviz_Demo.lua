module(..., package.seeall)
NODE = {
   title = "GraphViz Demo"
}
NODE.actions = [[
show = "graphviz.show_with_objects"
]]

NODE.content = [======[
<span class="teaser">
  You can use Sputnik to collaboratively edit graphs.  You do this by storing text
  representation of the graph in the body of a node and telling Sputnik to use
  [Graphviz](http://www.graphviz.org/) to generate image files for you on the fly.
</span>

## What Does This Demo Do?

The Demo consists of two nodes.  This node ("Graphviz Demo") is a regular node
used for presenting the text of the demo.  A separate node - "Raw Dot File" - is used to
store [dot](http://www.graphviz.org/Documentation/) code, which is converted to SVG on the fly.
The default action for "Raw Dot File" (see [[Raw Dot File]]) shows the dot code.  However, we also
add several alternative actions: ".png", ".gif", and ".svg" which will give us the PNG, GIF and SVG
representations of the graph.  You can see their respective outputs here:

* [[Raw Dot File]] - the dot source
* [[Raw_Dot_File.png|Raw\_Dot\_File.png]] -- the graph as a PNG file
* [[Raw_Dot_File.gif|Raw\_Dot\_File.gif]] -- the graph as a GIF file
* [[Raw_Dot_File.svg|Raw\_Dot\_File.svg]] -- the graph as a SVG file

For PNG and GIF we can simple include the file in a different node as we would with any
other image:

    <img src="Raw_Dot_File.gif"/>

which would give us:

<center>
 <img src="Raw_Dot_File.gif"/><br/>
</center>

For SVG, we'll need to embed it with the `<object>` tag:

    <object type="image/svg+xml" data="http://sputnik.freewisdom.org/en/Raw_Dot_File.svg" width="500" height="600"/>

which gives us this:

<center>
 <object type="image/svg+xml" data="http://sputnik.freewisdom.org/en/Raw_Dot_File.svg" width="350" height="600"></object>
</center>

(The SVG image might not display in all browsers, but it's prettier and it allows us to
hyperlink nodes - click on "start" for example.)

Note that this image is a wiki node.  You can [[Raw_Dot_File.edit|edit]] it.

## How Does this Work?

First, we create a new action, which we save into
`~/sputnik/share/lua/5.1/sputnik/actions/graphviz.lua`:

    module(..., package.seeall)
    require"lfs"

    function dot(source, format)
        local tempfile = "/tmp/"..math.random()
        local f = io.open(tempfile, "w")
        f:write(source)
        f:close()
        local pipe = io.popen("dot -T"..format.." "..tempfile)
        return pipe:read("*all")
    end

    actions = {}
    actions.dot2svg = function(node, request, sputnik)
        return dot(node.content, "svg"), "image/svg+xml"
    end
    actions.dot2png = function(node, request, sputnik)
        return dot(node.content, "png"), "image/png"
    end
    actions.dot2gif = function(node, request, sputnik)
        return dot(node.content, "gif"), "image/gif"
    end

We then create a new node ([[Raw Dot File]]), and set "action" parameter to 

    show="wiki.code" -- to avoid running the content throw markdown
    svg="graphviz.dot2svg" 
    png="graphviz.dot2png"
    gif="graphviz.dot2gif"

That's it.  We can now access [[Raw Dot File.gif|Raw Dot File.gif]]
]======]
