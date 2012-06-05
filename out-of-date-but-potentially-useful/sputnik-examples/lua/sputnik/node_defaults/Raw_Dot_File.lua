-----------------------------------------------------------------------------
-- This is a sample node that a Graphviz Dot file that gets converted on the
-- fly into png, svn or gif.
--
-- For more information, see http://sputnik.freewisdom.org/en/Graphviz_Demo
--
-- (c) 2008  Yuri Takhteyev (yuri@freewisdom.org)
-- License: MIT/X, see http://sputnik.freewisdom.org/en/License
-----------------------------------------------------------------------------

module(..., package.seeall)

NODE = {
   title="Raw Dot File"
}
NODE.actions = [[
show="wiki.code"
svg="graphviz.dot2svg"
png="graphviz.dot2png"
gif="graphviz.dot2gif"
]]
NODE.edit_ui = [[
actions = {1.7, "textarea", rows=3}
]]
NODE.content=[===[
/* See http://sputnik.freewisdom.org/en/Graphviz_Demo for information about this node. */

digraph G {
    subgraph cluster_0 {
	    style=filled;
	    color=lightgrey;
	    node [style=filled,color=white];
	    a0 -> a1 -> a2 -> a3;
	    label = "process #1";
    }

    subgraph cluster_1 {
	    node [style=filled];
	    b0 -> b1 -> b2 -> b3;
	    label = "process #2";
	    color=blue
    }
    start -> a0;
    start -> b0;
    a1 -> b3;
    b2 -> a3;
    a3 -> a0;
    a3 -> end;
    b3 -> end;
    a0 [URL="a0"];
    start [shape=Mdiamond, URL="start"];
    end [shape=Msquare, URL="end"];
}
]===]

