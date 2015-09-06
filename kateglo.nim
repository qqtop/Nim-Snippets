import os,private,httpclient,json,strfmt,strutils,sets


##
##   Program     : kateglo.nim
##
##   Status      : development
##
##   License     : MIT opensource
##
##   Version     : 0.2.0
##
##   ProjectStart: 2015-09-06
##
##   Compiler    : Nim 0.11.3
##
##   Description : Access Indonesian - Indonesian  dictionary  at kateglo.com
##   
##                 currently returns definitions and sample text
##
##                 still needs work to parse to deeper levels of the json data
##                
##                 compile:  nim c -d:release kateglo
##                 
##                 run :  kateglo    # uses default word: pasar 
##                 
##                        kateglo  makanan  # uses desired word
##                 
##   Requires    : private.nim 
##   
##                 
##   Project     : https://github.com/qqtop/Nim-Snippets
##
##
##   Tested      : on linux only
##
##   Programming : qqTop
##
##   Note        : may be improved at any time to include:
##                 meanings,related_phrases and proverbs data
##


proc getData(theWord:string):JsonNode = 
    var r = parseJson(getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord))
    result = r

var aword = "" 
if paramCount() > 0:
   for x in commandLineParams():
      aword = aword & x
else:
  # some default word
  aword = "pasar"
  msgg() do : echo "Using default word : " & aword
  
var data = getData(aword)   
  
# prints the json data if required for dev
#msgg() do : echo "KATEGLO DATA for ",data
#echo data   

echo()  
echo "Kateglo Indonesia - Indonesian Dictionary "
hline("_",tw,cyan)
echo()


proc ss(jn:JsonNode):string = 
    # strip " from the string
    var jns = $jn
    jns = replace(jns,"\"")
    result = jns
                
var c = 0                
var sep =":"
 
for zd in data["kateglo"]["definition"]:
     #echo zd
     c += 1
     
     printLnBiCol("{:<8}{} {}".fmt(c,sep,ss(zd["phrase"])),":",brightcyan,green)
     #echo()
     if $ss(zd["def_text"]) == "null":
        printLnBiCol("{:<8}{} {}".fmt("Def",sep,"Nothing Found"),":",yellow,red)
        
     elif ss(zd["def_text"]).len > tw:
          # for nicer display we need to splitlines 
           var ok = wordwrap(ss(zd["def_text"]),tw-13)
           var oks = splitlines(ok)
           #print the first line  
           printLnBiCol("{:<8}{} {}".fmt("Def",sep,oks[0]),":",yellow,white)
           for x in 1.. <oks.len   :
               # here we pad 10 blaks on left
               oks[x] = align(oks[x],10 + oks[x].len)
               printLnColStr(white,"{}".fmt(oks[x]))
           
     else:
           printLnBiCol("{:<8}{} {}".fmt("Def",sep,ss(zd["def_text"])),":",yellow,white)
    
     if $ss(zd["sample"]) != "null":
        #echo()
        # we put the phrase into the place holders -- returned from kateglo
        var oksa = replace(ss(zd["sample"]),"--",ss(zd["phrase"]))
        # for nicer display we need to splitlines 
        var okx = wordwrap(oksa,tw-13)
        var okxs = splitlines(okx)
        #print the first line  
        printLnBiCol("{:<8}{} {}".fmt("Sample",sep,okxs[0]),sep,yellow,white)
        for x in 1.. <okxs.len   :
           # here we pad 10 blaks on left
           okxs[x] = align(okxs[x],10 + okxs[x].len)
           printLnColStr(white,"{}".fmt(okxs[x]))
           
        
     # hmmm
     #if $ss(zd["related_phrase"]) != "null":
     #   printLnBiCol("Related: " & ss(zd["sample"]),";",yellow,white)
     hline("-",tw,green)  
     
doFinish()