import urllib, os

TEXTAREA = '<textarea name="text"  rows="20" cols="65" wrap="virtual" style="width:100%">'

def get_revision(page, revision) :

    f = open("nodes/"+page+"/"+revision, "w")

    url = "http://lua-users.org/cgi-bin/wiki.pl?action=edit&id="+page+"&revision="+revision
    capture = 0
    buffer = ""
    for line in urllib.urlopen(url).readlines() :
        #line = line.strip()
        if line.startswith(TEXTAREA) :
            capture = 1
            buffer+=line[len(TEXTAREA):]
        elif line.startswith("</textarea>") :
            capture = 0
        elif capture :
            buffer+= line
        
    f.write(buffer)


def get_history(page) :

    os.mkdir("nodes/"+page)
    f = open("nodes/"+page+"/index", "w")

    url = "http://lua-users.org/cgi-bin/wiki.pl?action=history&id="+page

    for line in urllib.urlopen(url).readlines() :
        if line.startswith("<br>Revision") :
            #<br>Revision 23: <a href="/wiki/FooBar" >View</a> Diff . . February 14, 2008 8:06 pm GMT by 75.58.19.xxx <b>[CommunityProgrammableWiki]</b> <br>
            id, rest = line[13:].split(': <a href="/wiki/', 1)
        elif line.startswith("Revision") :
            #Revision 22: <a href="/cgi-bin/wiki.pl?action=browse&amp;id=FooBar&amp;revision=22" >
            id, rest = line[9:].split(': <a href="/cgi-bin/wiki.pl?action=browse&amp;id=', 1)
        else :
            rest = 0

        if rest :
            print id
            dummy, rest = rest.split(" . . ", 1)
            date, rest = rest.split(" by ", 1)
            if rest.strip().endswith("]</b> <br>") :
                user, rest = rest.split(" <b>[", 1)
                comment = rest[:-len(" ]</b> <br>")]
            else:
                user = rest[:-len(" <br>")]
                comment = ""
            print date
            print user
            print comment

            f.write("%s\t%s\t%s\t%s\n" % (id, date, user, comment))
            get_revision(page, id)

def do_all(dir) :
   flag = 0
   exists = {}
   for node in os.listdir("nodes") :
      exists[node+".html"] = 1
   for node in os.listdir(dir) :
      if not exists.has_key(node) and not node==".rss":
         print node
         get_history(node[:-5])

do_all("lua-users.org/wiki/")

#get_history("ThisWikiImplementation")



