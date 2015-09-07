import os,private,httpclient,json,strfmt,strutils,sets


##
##   Program     : kateglo.nim
##
##   Status      : stable
##
##   License     : MIT opensource
##
##   Version     : 0.5.0
##
##   ProjectStart: 2015-09-06
##
##   Compiler    : Nim 0.11.3
##
##   Description : Access Indonesian - Indonesian  Dictionary 
##   
##                 at kateglo.com  via public API
##   
##                
##                 compile:  nim c -d:release kateglo
##                 
##                 run    :  kateglo           # uses default word: pasar 
##                 
##                           kateglo  makanan  # uses desired word makanan
##   
##   Notes       : the API appears to only a low single word input
##                 
##   Requires    : private.nim 
##   
##                 
##   Project     : https://github.com/qqtop/Nim-Snippets
##
##
##   Tested      : on linux only ok on 2015-09-07
##
##
##   Programming : qqTop
##

var wflag:bool  = false
var wflag2:bool = false

proc getData(theWord:string):JsonNode = 
    var r:JsonNode
    try:
       r = parseJson(getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord))
    except JsonParsingError:
       msgr() do : echo "Word " & theWord & "  not defined in kateglo."
       msgr() do : echo "Maybe misspelled or not a root word."
       r = nil
       wflag = true
    result = r

proc getData2(theWord:string):JsonNode = 
    var r:JsonNode
    try:
       r = parseJson(getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord))
    except JsonParsingError:
       r = nil
       wflag = true
    result = r



var aword = "" 
if paramCount() > 0:
   for x in commandLineParams():
      aword = aword & " " & x
      aword = aword.strip()
else:
  # some default word
  aword = "pasar"
  msgg() do : echo "Using default word : " & aword
  
let data = getData(aword)   

if wflag == false:
      echo()  
      superHeader("Kateglo Indonesian - Indonesian Dictionary   Data for : " & aword)
      

      proc ss(jn:JsonNode):string = 
          # strip " from the string
          var jns = $jn
          jns = replace(jns,"\"")
          result = jns
                            
      var c = 0                
      var sep =":"


      proc defini(data:JsonNode) =
            msgg() do: echo "Definitions"
            for zd in data["kateglo"]["definition"]:
                c += 1
                printLnBiCol("{:>7}{} {}".fmt(c,sep,ss(zd["phrase"])),":",brightcyan,green)
                if $ss(zd["def_text"]) == "null":
                    printLnBiCol("{:>7}{} {}".fmt("Def",sep,"Nothing Found"),":",yellow,red)
                    
                elif ss(zd["def_text"]).len > tw:
                      # for nicer display we need to splitlines 
                      var ok = wordwrap(ss(zd["def_text"]),tw-20)
                      var oks = splitlines(ok)
                      #print the first line  
                      printLnBiCol("{:>7}{} {}".fmt("Def",sep,oks[0]),":",yellow,white)
                      for x in 1.. <oks.len   :
                          # here we pad 10 blaks on left
                          oks[x] = align(oks[x],10 + oks[x].len)
                          printLnColStr(white,"{}".fmt(oks[x]))
                      
                else:
                      printLnBiCol("{:>7}{} {}".fmt("Def",sep,ss(zd["def_text"])),":",yellow,white)
                
                if ss(zd["sample"]) != "null":
                    # put the phrase into the place holders -- or ~ returned from kateglo
                    var oksa = replace(ss(zd["sample"]),"--",ss(zd["phrase"]))
                    oksa = replace(oksa,"~",ss(zd["phrase"]))
                    var okx = wordwrap(oksa,tw-20)
                    var okxs = splitlines(okx)
                    #print the first line  
                    printLnBiCol("{:>7}{} {}".fmt("Sample",sep,okxs[0]),sep,yellow,white)
                    for x in 1.. <okxs.len   :
                      # here pad 10 blanks on left
                      okxs[x] = align(okxs[x],10 + okxs[x].len)
                      printLnColStr(white,"{}".fmt(okxs[x]))
                hline("-",tw,green)  
                         
                
      proc relati(data:JsonNode) =   
            var dx = data["kateglo"]["all_relation"]
            msgg() do: echo "Related Phrases"
            msgc() do: echo "{:>5} {:<14} {}".fmt("No.","Type","Phrase")
           
            for zd in 0.. <dx.len:
                var trsin = ""
                # we try to get the translations of the related phrases if type  = sinonim
                var rphr = ss(dx[zd]["related_phrase"])  
                var rtyp = ss(dx[zd]["rel_type_name"])
                if rtyp == "Sinonim" or rtyp == "Turunan" or rtyp == "Antonim":
                   # TODO : check that we only pass a single word rather than a phrase
                   #        to avoid errors and slow down
                   var phrdata = getData2(rphr)
                   if wflag2 == false:
                    try: 
                      var phdx = phrdata["kateglo"]["translations"]
                      if phdx.len > 0:
                          trsin =  ss(phdx[0]["translation"])   
                          printLnBiCol("{:>4}{} {:<14}: {}".fmt($zd,":",ss(dx[zd]["rel_type_name"]),ss(dx[zd]["related_phrase"])),sep,yellow,white)  
                          
                          var okx = wordwrap(trsin,tw - 40)
                          var okxs = splitlines(okx)
                          # print trans first line
                          printLnBiCol("{:>20}{} {}".fmt("Trans",":",okxs[0]),sep,cyan,white)
                          if okxs.len > 1:
                              for x in 1.. <okxs.len :
                                  # here pad 22 blanks on left
                                  okxs[x] = align(okxs[x],22 + okxs[x].len)
                                  printLnColStr(white,"{}".fmt(okxs[x]))
                    except:
                         discard
                    
                    
                   # need a sleep here or we hit the kateglo server to hard
                   # if too many crashes like
                   # Error: unhandled exception: 503 Service Temporarily Unavailable [HttpRequestError]
                   # then increase 
                   sleepy(1.0)
                   
                else:
                   printLnBiCol("{:>4}{} {:<14}: {}".fmt($zd,":",rtyp,rphr),sep,yellow,white)  
                   echo()   
      
      proc transl(data:JsonNode) =
            var dx = data["kateglo"]["translations"]
            msgg() do: echo "Translation"
            for zd in 0.. <dx.len:
                printLnBiCol("{:>8}{} {}".fmt(ss(dx[zd]["ref_source"]),":",ss(dx[zd]["translation"])),sep,yellow,white)  
            hline("-",tw,green)  
      
      
      
      proc proverbi(data:JsonNode) =
            var dx = data["kateglo"]["proverbs"]
            msgg() do: echo "Proverbs"
            for zd in 0.. <dx.len:
                printLnBiCol("{:>4} Prov {} {}".fmt($zd,":",ss(dx[zd]["proverb"])),sep,yellow,white)  
                printLnBiCol("{:>4} Mean {} {}".fmt($zd,":",ss(dx[zd]["meaning"])),sep,yellow,white) 
            hline("-",tw,green) 
      
      transl(data)
      decho(1)
      defini(data)          
      decho(1)
      proverbi(data)
      decho(1)
      relati(data)
          
doFinish()