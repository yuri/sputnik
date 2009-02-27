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

      {name:'First Level Heading', key:"1", placeHolder:'Your title here...', 
       closeWith:function(markItUp) { 
          return miu.markdownTitle(markItUp, '=') 
       }
      },
      {name:'Second Level Heading', key:"2", placeHolder:'Your title here...',
       closeWith:function(markItUp) {
          return miu.markdownTitle(markItUp, '-') 
       } 
      },
      {name:'Heading 3', key:"3", openWith:'### ', placeHolder:'Your title here...' },
      {name:'Heading 4', key:"4", openWith:'#### ', placeHolder:'Your title here...' },
      {name:'Code Block / Code', openWith:'(!(\t|!|`)!)', closeWith:'(!(`)!)'},
      {name:'Bold', key:"B", openWith:'**', closeWith:'**'},
      {name:'Italic', key:"I", openWith:'_', closeWith:'_'},
      {name:'Bulleted List', openWith:'- ' },
      {name:'Numeric List', openWith:function(h) {
         return h.line+'. ';
      }},
      {name:'WikiLink', key:"W", openWith:'[[', closeWith:']]', placeHolder:'Another Page' },
      {separator:'---------------' },
      {name:'Picture', key:"P", replaceWith:'![[![Alternative text]!]]([![Url:!:http://]!] "[![Title]!]")'},
      {name:'Link', key:"K", openWith:'[', closeWith:']([![Url:!:http://]!] "[![Title]!]")', placeHolder:'Your text to link here...' },
      {separator:'---------------'},	
      {name:'Quotes', openWith:'> '},
      /*{separator:'---------------'},
      {name:'Preview', call:'preview', className:"markituppreview"}*/
   ]
}

// mIu nameSpace to avoid conflict.
miu = {
	markdownTitle: function(markItUp, char) {
		heading = '';
		n = $.trim(markItUp.selection||markItUp.placeHolder).length;
		for(i = 0; i < n; i++) {
			heading += char;
		}
		return '\n'+heading+'\n';
	}
}

$(document).ready(function() {
        $("textarea.editor_markitup").markItUp(mySettings);
})
]====]
