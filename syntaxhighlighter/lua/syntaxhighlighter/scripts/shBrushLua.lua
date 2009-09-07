module(...)
content = [=========================[
/**
 * SyntaxHighlighter
 * http://alexgorbatchev.com/
 *
 * SyntaxHighlighter is donationware. If you are using it, please donate.
 * http://alexgorbatchev.com/wiki/SyntaxHighlighter:Donate
 *
 * @version
 * 2.0.320 (May 03 2009)
 * 
 * @copyright
 * Copyright (C) 2004-2009 Alex Gorbatchev.
 *
 * @license
 * This file is part of SyntaxHighlighter.
 * 
 * SyntaxHighlighter is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * SyntaxHighlighter is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with SyntaxHighlighter.  If not, see <http://www.gnu.org/copyleft/lesser.html>.
 */
SyntaxHighlighter.brushes.Lua = function()
{
	var keywords =	'and break do else elseif  ' +
					'end false for function if ' +
					'in local nil not or ' +
					'repeat return then true until while';

	var functions =	'assert collectgarbage dofile error getfenv ' +
		            'getmetatable ipairs load loadfile loadstring ' +
					'next pairs pcall print rawequal ' +
					'rawget rawset select setfenv setmetatable ' +
					'tonumber tostring type unpack xpcall';

	this.regexList = [
		{ regex: new RegExp('[0-9][\\.0-9]*', 'gm'), css: 'constants' },                        // -- comments
		{ regex: new RegExp('[{}=\\[\\]]', 'gm'), css: 'color1' },                        // -- comments
		{ regex: new RegExp('--[^!\\[].*$', 'gm'), css: 'comments' },                        // -- comments
		{ regex: new RegExp('--\\[\\[[\\s\\S]*?\\]\\]', 'gm'), css: 'comments' },         // [[...]] comments
		{ regex: new RegExp('--\\[=\\[[\\s\\S]*?\\]=\\]', 'gm'), css: 'comments' },       // [==[.. comments
		{ regex: new RegExp('--\\[==\\[[\\s\\S]*?\\]==\\]', 'gm'), css: 'comments' },     // [==[.. comments
		{ regex: new RegExp('--\\[===\\[[\\s\\S]*?\\]===\\]', 'gm'), css: 'comments' },   // [===[.. comments
		{ regex: new RegExp('--\\[====\\[[\\s\\S]*?\\]====\\]', 'gm'), css: 'comments' }, // [===[.. comments
		{ regex: SyntaxHighlighter.regexLib.doubleQuotedString,	css: 'string' },          // double quoted strings
		{ regex: SyntaxHighlighter.regexLib.singleQuotedString,	css: 'string' },          // single quoted strings
		{ regex: new RegExp('\\[\\[[\\s\\S]*?\\]\\]', 'gm'), css: 'string' },             // [[...]] string
		{ regex: new RegExp('\\[=\\[[\\s\\S]*?\\]=\\]', 'gm'), css: 'string' },           // [=[...]=] string
		{ regex: new RegExp('\\[==\\[[\\s\\S]*?\\]==\\]', 'gm'), css: 'string' },         // [==[...]===] string
		{ regex: new RegExp('\\[===\\[[\\s\\S]*?\\]===\\]', 'gm'), css: 'string' },       // [===[...]===] string
		{ regex: new RegExp(this.getKeywords(functions), 'gm'),    css: 'functions bold' },
		{ regex: new RegExp(this.getKeywords(keywords), 'gm'),     css: 'keyword' }       // keywords
		];
	
	this.forHtmlScript(SyntaxHighlighter.regexLib.scriptScriptTags);
};

SyntaxHighlighter.brushes.Lua.prototype	= new SyntaxHighlighter.Highlighter();
SyntaxHighlighter.brushes.Lua.aliases	= ['lua'];
]=========================]
