import os,osproc,strutils,parseutils,math,strfmt,rdstdin

import cx, pythonize

# indo8
# 
# a  wrapper around soimorts translate shell  for more convenient terminal use. 
# Now also supports mecab via python to display hiragana in case of japanese use
# 
# and saving of word in "/dev/shm/indo7q.txt" for access by kateglo3
# 
# 
# Usage :  indo8  
# 
#          enter some indonesian words or play with the switches and other languages
#          
#          switches ending with p play voice from google
#  
# Tested:  nim 0.13.0 
# 
# Requires :
# 
#           https://github.com/soimort/translate-shell
#
#           gnu awk
#
#           kateglo3 (optional) 
#           
#           if kateglo3 is available any indonesian word entered in indo8 will
#           
#           also be looked up in kateglo3 automatically
#           
#           the used tempfile is /dev/shm/indo7q.txt in case /dev/shm not
#           
#           available change this to any on disk or in memory file 
#
# exit with ctrl-c or q at Next prompt
#
#
# now using cx.nim to handle most color printing tasks
#

let i7file = "/dev/shm/indo7q.txt"    # change path as required keep filename
  
  
var VERSION = "1.6.5"
setControlCHook(handler)

var recBuff = newSeq[seq[string]]()
var id  = 0
var idd = 2  # initial number of history recs shown
var idds = ""
  
proc addrec(sw:string,kata:string,trn:string) =
    ## add a new rec to recBuff
    inc id
    recBuff.add(@[$id,sw,kata,trn])


proc getidrec(idx:string|int):seq[string] =
     ## get a record from recBuff based on id
     var idmax = idx
     if idmax > id:
        idmax = id
        
     for x in 1.. id:
        var  yu = recBuff[x-1] 
        if yu[0] == $idmax:
           result = yu
  
  
proc showHist(n:int = idd) =
   ## show last n records in recBuff
   # for better aligned display we first get the length of the longest rec in recBuff
   var x3max = 0   # len kata
   var x4max = 0   # len trans 
   for x in 0.. <recBuff.len:
       var z = recBuff[x]
       if z[3].len > x3max:
          x3max = z[3].len
       
   if x3max > tw - 11:
      x3max = tw - 11
  
   if id < n:
     for x in 1.. id:      
       var rx = getidrec(x)
       println("{:>4} {:<4} {} ".fmt(yellowgreen & rx[0],termwhite & rx[1],cadetblue & rx[2])) 
       println("{:>4} {:<4} {} ".fmt(yellowgreen & rx[0],termwhite & rx[1],termwhite  & rx[3])) 
    
   else :
        for x in id-n+1.. id: 
            var rx = getidrec(x)
            println("{:>4} {:<4} {} ".fmt(yellowgreen & rx[0],white & rx[1],cadetblue & rx[2])) 
            println("{:>4} {:<4} {} ".fmt(yellowgreen & rx[0],white & rx[1],termwhite  & rx[3])) 
            
   dlineln(tw-1,"-",pastelgreen)
     
    
   
proc showHistSingle(n:int) =
       var rx = getidrec(n)
       var xpos = tw - 10 - rx[0].len - rx[1].len - rx[2].len
       println("{:>4} {:<4} {:<50} {}".fmt(yellowgreen & rx[0],termwhite & rx[1],truetomato & rx[2], termwhite & rx[3]),xpos = xpos)
    
  
proc getidswitch(idx:string|int):string =
     ## get last switch of a certain record in recBuff
     result = getidrec(idx)[1]

  
proc getidkata(idx:string|int):string =
     ## get last kata of a certain record in recBuff
     result = getidrec(idx)[2]

   
proc getidtrans(idx:string|int):string =
     ## get last trans of a certain record in recBuff
     result = getidrec(idx)[3]


var fin :bool = false
var switch    = "d" # default set to indonesian:english
var oldswitch = "d"  
var acmd = ""
var help = ""
var bflag : bool = true
let okswitch = ["","d","e","ev","ep","ej","ejp","dj","djp","a","av","v","ac","acp","p","k","z","h","q"]

  
var oldword  = ""     # holds last input word/kata
var oldtrans = ""     # holds the last trans if single line
var oldrxl   = @[""]  # holds last trans if multiple lines

var cflag : bool = false
var hflag : bool = false
var zflag : bool = false

var katax   = ""
var nimkata = ""
var nimhira = "" 
var curlang = ""

proc dokatax(akatax:string) =
     printLn(dodgerblue & curlang & "    : " & termwhite & akatax)
     writeFile(i7file,akatax)

proc dowordx(akatax:string) =
     printLn(dodgerblue & curlang & "    : " & termwhite & akatax)
     
     
proc showTop()=
        clearup()
        print("{:<9}".fmt("Active : "), moccasin)
        print("{:<4}".fmt(switch),cyan)
        printBicol("{}".fmt("Switches: d,p,e,ep,v,ev,ej,ejp,dj,djp,a,av,ac,acp,,p,k,z,h=help,q=quit"),":")
        echo()
        print("_________^",red)
        hlineln(tw-10,pastelgreen)  

proc doMecab(b:string) =
        pythonEnvironment["text"] = b
        execPython("mecab = MeCab.Tagger('-Oyomi')")
        execPython("kata  = mecab.parse(text)")
        nimkata = pythonEnvironment["kata"].depythonify(string)
        execPython("hira = kata2hira(kata)")
        nimhira = pythonEnvironment["hira"].depythonify(string)

# set up for japanese
execPython("import MeCab")
execPython("from jcconv import kata2hira")

while fin == false:
        showtop()
        showHist()
       
        bflag = true
                          
        case switch 
                
          of "z"   : 
                     # we use this as a reply starting from a certain id number entered
                     # which will be fix until changed again
                     idds = quoteshellposix(readLineFromStdin("Menunjukkan terakhir : ")) 
                     try:
                        showHist(parseInt(idds))
                        idd = parseInt(idds)
                     except:
                        discard
                   
        
          of "d"   : 
                     curlang = "Ind"
                     if cflag == false:
                        acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(katax)
                        dokatax(katax)
          of "e"   :
            
                    curlang = "Eng"
                    if cflag == false :  
                        acmd = "trans -b -w $1 -s en -t id "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                    else:    
                        acmd = "trans -b -w $1 -s en -t id "  % $tw & quoteshellposix(katax)
                        dowordx(katax)

          of "ep"  : 
                     curlang = "Eng"
                     if cflag == false:
                        acmd = "trans -b -p -w $1 -s en -t id "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -p -w $1 -s en -t id "  % $tw & quoteshellposix(katax)
                        dowordx(katax)

          of "v"   : 
                     curlang = "Ind"
                     if cflag == false:
                        acmd = "trans -v -w $1 -s id -t en "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -v -w $1 -s id -t en "  % $tw & quoteshellposix(katax)
                        dokatax(katax)
                        
          of "ev"  : 
                     curlang = "Eng"
                     if cflag == false: 
                        acmd = "trans -v -w $1 -s en -t id "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -v -w $1 -s en -t id "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "ej"  : 
                     curlang = "Eng"
                     if cflag == false:
                        acmd = "trans -b -w $1 -s en -t ja "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -w $1 -s en -t ja "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "ejp" : 
                     curlang = "Eng"
                     if cflag == false: 
                        acmd = "trans -b -p -w $1 -s en -t ja "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -p -w $1 -s en -t ja "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
          
          of "dj"  : 
                     curlang = "Ind"
                     if cflag == false:
                        acmd = "trans -b -w $1 -s id -t ja+en "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -w $1 -s id -t ja+en "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
              
          of "djp" : 
                     curlang = "Indo"
                     if cflag == false:
                        acmd = "trans -b -p -w $1 -s id -t ja+en "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -p -w $1 -s id -t ja+en "  % $tw & quoteshellposix(katax)
                        dowordx(katax)      
          
          of "a"   : 
                     curlang= "Any"
                     if cflag == false:
                        acmd = "trans -b -w $1 "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -w $1 "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "av"  : 
                     curlang= "Any"
                     if cflag == false:
                        acmd = "trans -v -w $1 "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -v -w $1 "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "p"   : 
                     curlang= "Any"  
                     if cflag == false:
                        acmd = "trans -p -w $1 "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -p -w $1 "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
           
          of "ac"  : 
                     curlang= "Any"
                     if cflag == false:
                        acmd = "trans -b -w $1 -t zh "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -w $1 -t zh "  % $tw & quoteshellposix(katax)
                        dowordx(katax)   
                        
          of "acp"  : 
                     curlang= "Any"
                     if cflag == false:
                        acmd = "trans -b -p -w $1 -t zh "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -p -w $1 -t zh "  % $tw & quoteshellposix(katax)
                        dowordx(katax)                 
                        
                        
                        
          of "k"   :
                     if cflag == false:
                        acmd = "trans -d -w $1 "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -d -w $1 "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "h"   : help = "d   indonesian english\np   any language english with voice for both, verbosed\nv   indonesian english verbose\ne   english indonesian\nep  english indonesian voice\nev  english indonesian verbose\nej  english japanese\nejp english japanese voice\ndj   indo japanese,english\ndj   indo japanese,english voice\na   any language to english\nav  any language to english verbose\nac   any language to chinese\nacp   any language to chinese voice\nk   Dictionary Mode\nh   help\nq   Quit" 
           
          of "q"   : doFinish() 
          
          else     : acmd = "Wrong switch selected";bflag = false
      
                
        if switch == "h":
              println(help)
        else: 
          if bflag == true and hflag==false:
             var rx = execProcess(acmd).strip()
             if zflag == false:
                oldtrans = $rx      # save these values for redisplaying later
                oldword  = katax
                addrec(switch,katax,$rx)
                var rxl = splitlines($rx)
                oldrxl   = rxl
                if rxl.len == 1:
                    print(mediumspringgreen & "Trans" & dodgerblue & "  : " & white & $rx & termwhite)
                    if switch == "ej" or switch == "ejp" or switch == "dj" or switch == "djp":
                        echo()
                        doMecab(rx)
                        println("         " & nimhira,pastelblue)
                    
                else:
                        printLn(mediumspringgreen & "Trans" & dodgerblue & "  : " & termwhite)
                        for rxline in rxl:
                            # also tried with wordwrap function here but japanese is not cut off correctly
                            if rxl.len == 2:
                                println(rxline,yellowgreen,xpos = 10)
                            else:
                                # in case of many lines we provide a bit more space
                                println(rxline,yellowgreen,xpos = 2)
                            if switch == "ej" or switch == "ejp" or switch == "dj" or switch == "djp":
                                if rxl.len == 2:
                                      doMecab(rxline)
                                      println("         " & nimhira,pastelblue)
                                else:      
                                      doMecab(rxline)
                                      println("  " & nimhira,pastelblue) 
                         
          else:
                println(acmd,truetomato) 
            
               
        if switch in okswitch:
           # only allow good switches 
           oldswitch = switch
      
        
        switch = nil
        katax = ""
      
        # switch implementation to take care of differencing between switches and words
        echo()
        while not okswitch.contains(switch) and switch.len < 4:
             #switch = readLineFromStdin(pastelblue & "Next " & dodgerblue & "  : " & termwhite)
             switch = readLineFromStdin("Next   : ")
             # if not in okswitch add three spaces at end to take care of all short word situations   
             if not okswitch.contains(switch) :
                 switch = strip(switch,trailing = true) & "   "
             switch = strip(switch,trailing = true)
               
        if switch.len > 3:
           cflag = true
           katax = switch
           switch = oldswitch
        else:
           cflag = false
        
        if switch == "":
              cflag = false
              switch = oldswitch
        
######################################################################################