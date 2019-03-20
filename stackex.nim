import nimcx,httpclient, os, streams, xmltree, parsexml, xmlparser

# stackexchange feed viewer
# based on idea found in nim gitter
# status ok     |  2019-03-20
# compile with : nim c --stackTrace:off --opt:size -d:ssl -r stackex

proc getFeed(): StringStream =
    var client = newHttpClient()
    newStringStream(client.getContent("https://stackexchange.com/feeds/questions"))

let entries = getFeed().parseXml.findAll "entry"

for line in splitLines($entries):
  var aline = line
  if line.contains("<category scheme>"): printLn(line,pink)
  elif line.contains("""<title type="text">"""): 
                                               aline = aline.replace("""<title type="text">""","")
                                               aline = aline.replace("</title>","")
                                               aline = aline.replace("&quot;","'")
                                               aline = aline.replace("&amp;gt;",">")
                                               aline = aline.replace("&amp;lt;","<")
                                               aline = aline.replace("&#x2F;","/")
                                               aline = aline.replace("&#x27;","'")
                                               aline = aline.replace("&apos;","'")
                                               printLnBiCol("\n" & "Title     : " & aline,yellowgreen,truetomato,":",0,false,{})
  elif line.contains("<name>"): 
                               aline = aline.replace("</name>","")
                               aline = aline.replace("<name>","")
                               printLnBiCol("Author    :   " & aline.strip(),yellowgreen,steelblue,":",0,false,{})
  elif line.contains("""<link rel="alternate" href=""") : 
                               aline = aline.replace("""<link rel="alternate" href="""","")
                               aline = aline.replace("""" />""","")
                               printLnBiCol("Link      :  " & " " & aline.strip(),yellowgreen,pastelyellow,":",0,false,{})
  elif line.contains("<uri>"): discard
  elif line.contains("<published>"): 
                               aline = aline.replace("</published>","")
                               aline = aline.replace("<published>","")
                               printLnBiCol("Published : " & aline,yellowgreen,pastelgreen,":",0,false,{})
  elif line.contains("<updated>"): 
                               aline = aline.replace("</updated>","")
                               aline = aline.replace("<updated>","")
                               printLnBiCol("Updated   : " & aline,yellowgreen,pastelgreen,":",0,false,{})
  elif line.contains("<summary type="): 
                               aline = aline.replace("""<summary type="html">""","")
                               aline = aline.replace("&quot;","'")
                               aline = aline.replace("&#x27;","`")
                               aline = aline.replace("&amp;gt;",">")
                               aline = aline.replace("&amp;lt;","<")
                               aline = aline.replace("&#x2F;","/")
                               aline = aline.replace("&#x27;","'")
                               aline = aline.replace("&apos;","'")
                               printLn("Summary   : ",dodgerblue)
                               let z = aline.wordwrap(90)
                               for x in z.splitlines():
                                    printLn(x.strip(),pastelwhite,xpos=14)
  else : discard # printLn(line)

doFinish()
