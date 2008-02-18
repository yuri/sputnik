
## todo - support for definition links


import os, re

#camel = re.compile("([A-Z][a-z]+([A-Z][a-z]+)+)")

listre = re.compile("((\t|(        ))\*.*?\n\n)", re.DOTALL)

def convertList(match) :
   l = match.groups(0)[0]
   ##print(l)

   l = l.replace("        ", "\t")
   l = l.replace("\t\t\t", "***").replace("\t\t*", "\t**").replace("\t*", "*").replace("\t", "        ")
   return l
    



camel = re.compile("(\[.*?\]|\n( ){8,100}{{{(.*?)}}}|\n\t\s*{{{(.*?)}}}|\n{{{(.*?)}}}|{{.*?}}|([A-Z][a-z]+([A-Z][a-z]+)+))", re.DOTALL)  # .*\}\}

exceptions = ['FuncTables', 'HereDoc', 'LuaCheia', 'LuaForge', 'LuaCurl', 'LuaBinaries', 'LuaRocks', 'LuaShell', 
'LuaUnit', 'McFin', 'SourceForge', 'TypeOf', 'VeLoSo', 'VisLua', 'VmMerge', 'VxWorks', 'WebLua', 'WikiNames']

minicamel = re.compile("([A-Z][a-z]+)")

def convertLink(wikiLinkMatch) :
    wikiLink = wikiLinkMatch.groups(0)[0]

    if wikiLink.startswith("\n") :
        #print wikiLink
        code = wikiLink.strip()[3:-3]
        if code.startswith("!") :
            lang, code = code.split("\n", 1)
            return "\n\n<source lang='%s'>\n%s\n</source>\n" % (lang, code)
        else :
            return "\n\n<source>\n%s\n</source>\n" % code
    elif wikiLink.startswith("{{") :
        return "<code>"+wikiLink[2:-2]+"</code>"
    elif wikiLink.startswith("[") : 
        return wikiLink
    elif wikiLink in exceptions :
        return "[["+wikiLink+"]]"
    else :
        return "[["+minicamel.sub("\\1 ", wikiLink).strip()+"]]"


replacements = (
  ('\r\n', '\n'),
  ('&#39;', "'")
)


for node in os.listdir("nodes") :
   if len(node) > 2 :
      print node
      #os.mkdir("decameled/"+node)
      for rev in os.listdir("nodes/"+node) :
         if not rev=="index" :
            #print rev
            content = open("nodes/"+node+"/"+rev).read()

            for r in replacements :
                content = content.replace(r[0], r[1])

            content = listre.sub(convertList, content+"\n\n")
            #print 
            open("decameled/"+node+"/"+rev, "w").write(camel.sub(convertLink, content))


