module(..., package.seeall)

NODE = {
   title="CSS for Layout",
   prototype="@CSS"
}
NODE.content=[===[

/* Note that the layout of the top level objects is largely determined by YUI. 

   The sequence of divs at the top level elemens:

   html
      head
      body
         div #doc2
            div #login
            div #logo
         div #hd      -- the navigation bar
            ul.menu #menu
               li.front #Section_1
               li.back  #Section_2
            ul.submenu #submenu
               li.front #Page_1
               li.back  #Page_2
         div #bd
            div #yui-main
               div.yui-b #page
                  span.toolbar
                  h1.title
                     a.local
                  div.content
               div.yui-b #sidebar
*/

/*                   margin:   top right bottom left;  padding:   top right bottom left;  other params                             */
body               {                                                                      min-width: 800px; text-align: left;         }
 #doc2             {                                                                                                                  }
  #login           { margin:   0em   0em   0em   0em;  padding:  .4em   0em   0em   0em;  float: right; text-align: right;         
                                                                                          font-size: 90%;                             }  
   #rss_icon       { margin:   0em   0em   0em   0em;  padding:   0em   0em   0em   0em;  position: relative; top:3px                 }
  #logo            {                                                                                                                  }
  #hd              { margin:   0em   0em   0em   0em;  padding:   0em   0em   0em   0em;                                              }
   ul#menu         { margin: 1.1em   0em   0em   0em;  padding:   0em   0em   0em   0em;  width: 100%; text-align:left; display: block; }
   ul#menu li      { margin:   0em 0.5em   0em   0em;  padding:   0em   0em   0em   0em;  display: inline;  list-style-type: none;    }
   ul#menu li a    {                                   padding: 0.3em   1em 0.3em   1em;  position: relative; 
                                                                                          font-size: 140%; text-decoration: none;     }
   ul#submenu      { margin:   0em   0em   0em   0em;  padding: 0.8em   0em 0.4em   0em;  position: relative; left: 0em; TOP: 0em;
                                                                                          min-height: 20px;
                                                                                          text-align:left; display: block;            }
   ul#submenu li   { margin:   0em   0em   0em   0em;  padding:   0em   0em   0em   0em;  display: inline;  list-style-type: none;    }
   ul#submenu li a { margin:   0em 0.5em   0em 0.5em;  padding:   0em  .2em   0em  .2em;  font-size: 100%;
                                                                                          font-family: Verdana, sans-serif;
                                                                                          text-decoration:none; font-weight: bold;    }
  #bd              { margin:   0em   0em   0em   0em;  padding:   0em   0em   0em   2em;                                              }
   #yui-main       {                                                                                                                  }
    #page          {                                   padding:   0em   0em   0em   0em;  min-height: 450px; min-width: 830px;        }
    .content       {                                   padding:   1em   1em   1em   1em;  font-size: 100%;                            }
     .toolbar      { margin:   0em   0em   0em   0em;  padding:  .5em  .5em  .5em   2em;  float:right;                                }
     .toolbar A    {                                                                      text-decoration: none;                      }

h1                 { margin:   0em   0em  0em  0em;    padding:  .4em   0em  .5em   0em;  font-size: 270%; font-weight: normal;       }
h1 a               {                                                                      text-decoration: none;                      }
h2                 { margin:  2em   .3em  1em  -1em;   padding:   0em   0em   0em   0em;  font-size: 140%; font-weight: normal;       }
h3                 { margin:  20px   3px  10px  -5px;  padding:   1px   5px   1px   5px;  font-size: 129%; font-weight: normal;       }
h4                 { margin:  20px   3px  10px  -5px;  padding:   1px   5px   1px   5px;  font-size: 107%; font-weight: normal;       }
h5                 { margin:  20px   3px  10px  -5px;  padding:   1px   5px   1px   5px;  font-size: 100%; font-weight: normal;       }
ul                 { margin:  10px   0em  10px  15px;                                     list-style-type: square                     }
li                 {                                                                      line-height: 150%                           }
ol                 { margin:  10px   0em  10px  24px;                                     list-style-type: decimal                    } 
p                  { margin:  15px   0em  auto  auto;                                     line-height: 155%                           }
code               {                                   padding:   2px   2px   2px   2px;  font-size: 100%; font-family: monospace      } 
pre                { margin:  15px   0em  auto  auto;  padding:   8px  20px   8px  20px;  display: block; font-family: monospace; font-size: 90%      }
pre code           {                                   padding:   0em   0em   0em   0em;                                              }
th                 {                                   padding:   2px   5px   2px   5px;  vertical-align: top;                        }
td                 {                                   padding:   2px   5px   2px   5px;  vertical-align: top;                        }
em                 {                                                                      font-style: italic                          }
strong             {                                                                      font-weight: bold                           }
th                 {                                                                      font-weight: bold;                          }
a.local            {                                   padding:  auto   3px  auto  auto;  background: none transparent scroll repeat 0% 0%; }
a                  { background: url(http://media.freewisdom.org/tmp/link-icon_external_09.png) no-repeat right 50%;                  }

span.preview       { margin:  auto   5px  10px  auto;  padding:   5px   5px   5px   5px;                                              }

form               {                                                                      display: inline                             }
label              { margin:  10px 0.5em  auto  auto;                                     display: block; float: left; text-align: right; 
                                                                                          font-weight: bold                           }
input              { margin:  auto  auto   5px 200px;  padding:   3px   3px   3px   3px;  line-height: 20px; display: block; min-height: 20px; 
                                                                                          font-family: monospace                      }
select             { margin:  auto  auto   5px 200px;  padding:   3px   3px   3px   3px;  line-height: 20px; display: block; min-height: 20px; 
                                                                                          width: 168px; height: 27px;                 }
option             { margin:   0em   0em   0em   0em;  padding:   0em   0em   0em   0em;  spacing: 0em;                               }
input.button       { margin:   5px   4px   5px   4px;                                                                                 }
input.search_box   { margin:   0em   1px  auto   4px;  padding:   2px  auto   2px  auto;  line-height: 10px; display: inline; 
                                                                                          font-size: 9pt;                             }
input.submit       { margin:  auto  auto  auto  10px;                                     display: inline; float: right;  width: 130px; }
input.small_submit { margin:  auto   0em  auto   1px;  padding:   1px   0em   1px  auto;  display: inline; line-height: 10px; 
                                                                                          font-size: 90%;                 }
input.diff_radio   { margin:   0em   0em   0em   0em;  padding:   0em   0em   0em   0em;                                              }
textarea           { margin:  auto  auto   5px  auto;  padding:   4px   2px   1px   2px;  width: 100%; font-family: monospace         }
textarea.small     { margin:  auto  auto  auto 200px;                                     display: block; width: 500px;               }
#more_fields       { margin:  auto  auto  auto 200px;  padding:   auto  auto  auto 200px; display: block;                             }
input.hidden       {                                                                      display: none;                              }
div.honey          {                                                                      display: none;                              }
div.advanced_field {                                                                      display: none;                              }

ins                {                                                                      text-decoration: none                       }

.history_dates     {                                                                      font-size: 80%;                             }
.error_message     { margin:  15px  15px  15px  15px;  padding:  15px  15px  15px  15px;                                              } 

]===]

