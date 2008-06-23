module(..., package.seeall)

NODE = {
 prototype= "@JavaScript",
 title= "Markitup - Markdown Set",
 permissions = [[
    allow(all_users, 'js')
 ]],
}

NODE.content = [====[
// ----------------------------------------------------------------------------
// markItUp!
// ----------------------------------------------------------------------------
// Copyright (C) 2007 Jay Salvat
// http://markitup.jaysalvat.com/
// ----------------------------------------------------------------------------
// Markdown tags
// http://daringfireball.net/projects/markdown/
// http://en.wikipedia.org/wiki/Markdown/
// ----------------------------------------------------------------------------
// Basic set here. Feel free to add more tags
// ----------------------------------------------------------------------------
mySettings = {
	previewParserPath:	"", // path to your Markdown parser
	onShiftEnter:		{keepDefault:false,	openWith:'\n\n'},
	markupSet: [		 
		{name:'First Level Heading', key:"1", placeHolder:'Your title here...', openWith:"\n", 
		 closeWith:function(h) {
			heading1 = '';
			n = $.trim(h.selection||h.placeHolder).length;
			for(i = 0; i < n; i++)	{
				heading1 += '=';	
			}
			return '\n'+heading1+'\n';
		}},
		{name:'Second Level Heading', key:"2", placeHolder:'Your title here...', openWith:"\n", 
		 closeWith:function(h) {
			heading2 = '';
			n = $.trim(h.selection||h.placeHolder).length;
			for(i = 0; i < n; i++)	{
				heading2 += '-';	
			}
			return '\n'+heading2+'\n';
		}},
		{name:'Heading 3', key:"3", openWith:'### ', placeHolder:'Your title here...' },
		{name:'Heading 4', key:"4", openWith:'#### ', placeHolder:'Your title here...' },
		{name:'Heading 5', key:"5", openWith:'##### ', placeHolder:'Your title here...' },
		{name:'Heading 6', key:"6", openWith:'###### ', placeHolder:'Your title here...' },							
		{separator:'---------------' },		
		{name:'Bold', key:"B", openWith:'**', closeWith:'**'},
		{name:'Italic', key:"I", openWith:'_', closeWith:'_'},
		{separator:'---------------' },
		{name:'Bulleted List', openWith:'- ' },
		{name:'Numeric List', openWith:function(h) {
			return h.line+'. ';
		}},
		{separator:'---------------' },
		{name:'Picture', key:"P", replaceWith:'![[![Alternative text]!]]([![Url:!:http://]!] "[![Title]!]")'},
		{name:'Link', key:"L", openWith:'[', closeWith:']([![Url:!:http://]!] "[![Title]!]")', placeHolder:'Your text to link here...' },
		{separator:'---------------'},	
		{name:'Quotes', openWith:'> '},
		{name:'Code Block / Code', openWith:'(!(\t|!|`)!)', closeWith:'(!(`)!)'},																	
		{separator:'---------------'},
		{name:'Preview', call:'preview', className:"markituppreview"}
	]
}
]====]
