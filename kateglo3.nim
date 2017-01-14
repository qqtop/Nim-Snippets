##
##   Program     : kateglo3.nim
##
##   Status      : stable
##
##   License     : MIT opensource
##   
##   Kateglo     : Content license is CC-BY-NC-SA except as specified below.
##                 Details licenses CC-BY-NC-SA can be found at:
##                 http://creativecommons.org/licenses/by-nc-sa/3.0/
##                 for other than personal use visit kateglo.com
##
##   Version     : 0.6.0
##
##   ProjectStart: 2015-09-06
##
##   Compiler    : Nim 0.11.3  https://github.com/nim-lang/Nim
##
##   Description : Indonesian - Indonesian  Dictionary 
##   
##                 at kateglo.com  via public API
##                 
##                 with english translation
##   
##                
##                 compile:  nim c --threads:on kateglo3      # or we used to get sigsevs ...
##                 
##                 run    :  kateglo3     
##                 
##                           
##                           
##                 to stop this program : Ctrl-C  
##
##
##   
##   Notes       : the API appears to only allow single word input
##   
##                 output is limited to 20 Sinonim , Turunan  , Gabungan Kata
##                 
##                 for performance reason 
##                 
##                 
##                 This version works only in tandem with indo8.nim it listens
##                 
##                 for a file change and then acts upon it
##                 
##                 idea is to type a word in indo8 and it also will be searched
##                 
##                 in kateglo3 provided it is one word only . If a sentence or phrase is
##                 
##                 entered in indo8 only the first word will be looked up in kateglo3.
##                 
##                 To run this meaningfully :
##                 
##                 1) change the i7file path as needed in indo8 and kateglo3
##                    it is currently set to dev/shm memory location ,but can be anywhere you like
##                 2) compile both progs as stated                  
##                 3) open 2 terminals or Terminator split horizontally once.
##                 4) start indo8 in the top terminal
##                 5) start kateglo3 in the bottom terminal
##
##                 
##   Requires    : cx.nim 
##                    
##                 
##   Project     : https://github.com/qqtop/Nim-Snippets
##
##
##   Tested      : on linux only 2017-01-14
##
##
##   Programming : qqTop
##

import os,cx,httpclient,json,strfmt,strutils,sets,rdstdin,fsmonitor,asyncio,net


var wflag :bool = false
var wflag2:bool = false
var evflag : bool = false
var tc = 0 # total line counter

var i7file = "/dev/shm/indo7q.txt"
# this file is recreated in indo8 if not existing , like after a reboot


proc getData(theWord:string):JsonNode = 
    var r:JsonNode
    var ct:string
    try:
       ct = getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord,timeout = 8000 )
       try :  
          r = parseJson(ct)
          
                 
       except JsonParsingError:
          printHl("Word " & theWord & "  not defined in kateglo.",theWord,brightgreen)
          echo()
          printLn("Maybe misspelled or not a root word.",red)
          printLn("Lema yang dicari tidak ditemukan !",red)
          r = nil
          wflag = true
          tc += 3
       finally :
            discard
    
    except HttpRequestError:
            r = nil
            printLn("Timeout solution 1 sec",red)
            sleepy(1)
            tc += 1
            r = parseJson(getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord,timeout = 8000))
        
    except OSError:
           printLn("Network gd1: Internet maybe unavailable ",red)
          
    except TimeoutError:   
       printLn("Network TimeoutError: Internet maybe unavailable ",red)   
    
    finally:
       discard
   
    result = r

proc getData2(theWord:string):JsonNode = 
    var r:JsonNode
        
    try:
       r = parseJson(getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord,timeout = 8000))
       
    except JsonParsingError:
       r = nil
       wflag = true
       
    except HttpRequestError:
       r = nil
       printLn("Timeout solution 1 sec",red)
       sleepy(1)
       tc += 1
       r = parseJson(getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord,timeout = 8000))
    
    except OSError:
        printLn("Network gd2: Internet maybe unavailable ",red)
     
    except TimeoutError:    # currently not working
        printLn("Network TimeoutError: Internet maybe unavailable ",red)
    
    finally:
        discard
    
    result = r

var aword = "" 
var disp = newDispatcher()
var monitor = newMonitor()
var rq = 0  # request counter
# create the i7file if not existing , works ok now
if existsFile(i7file) == false:
     var f: File
     if open(f, i7file,fmWrite):
       write(f,"")
     close(f)  
    
proc main() =
      infoLine() 
      decho(2)
      while true:
        if not disp.poll(): break
      
   

monitor.add(i7file)
disp.register(monitor,proc (m: FSMonitor, ev: MonitorEvent) = 
        #echo("Got event: ", ev.kind)
        if ev.kind == MonitorCloseWrite:
            evflag = true
            wflag = false
            wflag2 = false
            aword = ""
            var tword = ""  
            tc = 0  
            var tw = getTerminalWidth()  
            rq += 1
            echo()
            printLn("Request $1 start : " % $rq ,cyan)
            echo()
            tc += 3
            
            if evflag == true:
              tword = readFile(i7file)
              # if it is a phrase current kateglo api may return an error so
              # we only allow one word to be passed in
              tword = tword.strip()
              var ts = tword.split(" ")
              aword = ts[0]
              
              let data = getData(aword)
              # now we need to take of no internet situation  
              if isNil(data) == false:
                # all ok we try to process                
                var sep = ":"
                  
                if wflag == false:
                                             
                      superHeader("Kateglo Indonesian - Indonesian Dictionary")
                      printLnBiCol("Dicari Kata    : " & aword,sep,brightcyan,brightgreen)
                      echo()
                      tc += 5
                      proc ss(jn:JsonNode):string = 
                          # strip " from the string
                          #var jns = $jn
                          var jns = replace($jn,"\"")
                          result = jns
                      
                      var c = 0                
                      
                      proc defini(data:JsonNode) =
                            printLn("Definitions",lime)
                            echo()
                            tc += 1
                            for zd in data["kateglo"]["definition"]:
                                c += 1
                                printLnBiCol("{:>7}{} {}".fmt(c,sep,ss(zd["phrase"])),":",brightcyan,green)
                                tc += 1
                                if $ss(zd["def_text"]) == "null":
                                    printLnBiCol("{:>7}{} {}".fmt("Def",sep,"Nothing Found"),":",yellow,red)
                                    tc += 1
                                    
                                elif ss(zd["def_text"]).len > tw:
                                      # for nicer display we need to splitlines 
                                      var oks = splitlines(wordwrap(ss(zd["def_text"]),tw-20))
                                      #print the first line  
                                      printLnBiCol("{:>7}{} {}".fmt("Def",sep,oks[0]),":",yellow,white)
                                      tc += 1
                                      for x in 1.. <oks.len   :
                                          # here we pad 10 blaks on left
                                          oks[x] = align(oks[x],10 + oks[x].len)
                                          printLn("{}".fmt(oks[x]),white)
                                          tc += 1
                                      
                                else:
                                      printLnBiCol("{:>7}{} {}".fmt("Def",sep,ss(zd["def_text"])),":",yellow,white)
                                      tc += 1
                                
                                if ss(zd["sample"]) != "null":
                                    # put the phrase into the place holders -- or ~ returned from kateglo
                                    var oksa = replace(ss(zd["sample"]),"--",ss(zd["phrase"]))
                                    oksa = replace(oksa,"~",ss(zd["phrase"]))
                                    var okxs = splitlines(wordwrap(oksa,tw-20))
                                    #print the first line  
                                    printLnBiCol("{:>7}{} {}".fmt("Sample",sep,okxs[0]),sep,yellow,white)
                                    tc += 1
                                    for x in 1.. <okxs.len   :
                                      # here pad 10 blanks on left
                                      okxs[x] = align(okxs[x],10 + okxs[x].len)
                                      printLn("{}".fmt(okxs[x]),white)
                                      tc += 1
                                hline(tw,black)  
                                tc += 1
                                        
                                
                      proc relati(data:JsonNode) =   
                          var dx = data["kateglo"]["all_relation"]
                          if isNil(dx) == false:
                            try:
                                var maxsta = dx.len-1
                                if maxsta > 0:
                                    if maxsta > 20: maxsta = 20  # limit data to abt 20
                                    printLn("Related Phrases",lime)
                                    echo()
                                    tc += 2
                                    var mm = "{:>5} {:<14} {}".fmt("No.","Type","Phrase")
                                    print(mm,mm,yellow,styled = {styleUnderscore})
                                    decho(2)
                                    tc += 3
                                    for zd in 0.. <maxsta:
                                        var trsin = ""
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
                                                  printLnBiCol("{:>4}{} {:<14}: {}".fmt($(zd+1),":",ss(dx[zd]["rel_type_name"]),ss(dx[zd]["related_phrase"])),sep,yellow,white)  
                                                  tc += 1
                                                  var okxs = splitlines(wordwrap(trsin,tw - 40))
                                                  # print trans first line
                                                  printLnBiCol("{:>20}{} {}".fmt("Trans",":",okxs[0]),sep,cyan,white)
                                                  tc += 1
                                                  if okxs.len > 1:
                                                      for x in 1.. <okxs.len :
                                                          # here pad 22 blanks on left
                                                          okxs[x] = align(okxs[x],22 + okxs[x].len)
                                                          printLn("{}".fmt(okxs[x]),white)
                                                          tc += 1
                                            except:
                                                discard
                                            
                                            
                                          # need a sleep here or we hit the kateglo server too hard
                                          # if too many crashes like
                                          # Error: unhandled exception: 503 Service Temporarily Unavailable [HttpRequestError]
                                          # then increase waiting secs --> see getData2 we wait one sec for next request
                                          # in case of error and this seems to remove most crashes
                                          sleepy(0.5)
                                          
                                        else:
                                          printLnBiCol("{:>4}{} {:<14}: {}".fmt($zd,":",rtyp,rphr),sep,yellow,white)  
                                          tc += 1
                                        echo()   
                                        tc += 1
                            except:
                                discard
                              
                      
                      proc transl(data:JsonNode) =
                          try:
                            var dx = data["kateglo"]["translations"]
                            printLn("Translation",lime)
                            echo()
                            tc += 3
                            for zd in 0.. <dx.len:
                                printLnBiCol("{:>8}{} {}".fmt(ss(dx[zd]["ref_source"]),":",ss(dx[zd]["translation"])),sep,yellow,white)  
                                tc += 1
                            hline(tw,green)  
                            tc += 1
                          except:
                            println("JsonNode empty no data received",red)
                          finally:
                            discard
                      
                            
                      proc proverbi(data:JsonNode) =
                            var dx = data["kateglo"]["proverbs"]
                            if isNil(dx) == false:
                                var maxsta = dx.len-1
                                if maxsta > 0:
                                    if maxsta > 20: maxsta = 20  # limit data to abt 20
                                    printLn("Proverbs",lime)
                                    echo()
                                    tc += 2
                                    for zd in 0.. <dx.len:
                                        printLnBiCol("{:>4} Prov {} {}".fmt($(zd+1),":",ss(dx[zd]["proverb"])),sep,yellow,white)  
                                        printLnBiCol("{:>4} Mean {} {}".fmt($(zd+1),":",ss(dx[zd]["meaning"])),sep,yellow,white) 
                                        hline(tw,black)
                                        tc += 3
                                  
                  
                      # main display loop
                      transl(data)
                      decho(1)
                      defini(data)          
                      decho(1)
                      proverbi(data)
                      decho(1)
                      relati(data)
                      tc += 3
                if ts.len > 1:
                    #echo "Len TS: ",ts.len
                    printHl("Only first word of phrase " & tword & " used.",tword,brightgreen)
                    echo()
                    tc += 3
                printLn("Request $1 Complete ... Lines : $2 " % [$rq,$tc],yellowgreen)      
                
                
        else:
          evflag = false)

main()
         
