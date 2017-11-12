import os,osproc,parseutils,math,strfmt,rdstdin
import asyncDispatch, asyncnet
import nimcx, pythonize

# indo9   - clipboard translate utility
#           works now with indo8
# 
# Requires : gawk,transhell,xclip
#            python with mecab and jcconv module installed for japanese 
# 
# selecting some text in a website will translate from any language to english
# using transhell -w mode
# exit program Ctrl-C
#
# to start stop the clipboard reading use mouse to select .Start or .Stop words shown
 
# todo allow different switches 

# some procs and vars currently unused , but maybe used in future 
#
# 2017-10-01 added a timer to auto switch to indo8 after 1800 secs 
# 2017-11-12 slight improvement of interface and reduce echoing of unneded output fron transhell

var rx = ""
var oldrx = ""
var cp = ""
var switch = "cb"
  
let i7file = "/dev/shm/indo7q.txt"    # change path as required keep filename
  
  
var VERSION = "1.6.8 dev"
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
        var  yu = recBuff[x - 1] 
        if yu[0] == $idmax:
           result = yu
  
  
proc showHist(n:int = idd) =
   ## show last n records in recBuff
   # for better aligned display we first get the length of the longest rec in recBuff
   var x3max = 0   # len kata
   var x4max = 0   # len trans 
   for x in 0..<recBuff.len:
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
            
   dlineln(tw - 1,"-",pastelgreen)
     
   
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
#var switch    = "d" # default set to indonesian:english
var oldswitch = "cb"  
var acmd = ""
var help = ""
var bflag : bool = true
let okswitch = ["","d","dr","e","ev","ep","er","ej","ejp","dj","djp","a","av","v","ac","acp","p","k","z","cb","h","q"]

  
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
  
 
var line = ""

var a = 0
var b = 0
var stopflag:bool = false 
 


proc dokatax(akatax:string) =
     printLn(dodgerblue & curlang & "    : " & termwhite & akatax)
     writeFile(i7file,akatax)

proc dowordx(akatax:string) =
     printLn(dodgerblue & curlang & "    : " & termwhite & akatax)
     
     
proc showTop()=
        clearup()
        print("{:<9}".fmt("Active : "), moccasin)
        print("{:<4}".fmt(switch),cyan)
        printBicol("{}".fmt("Switches: d,dr,p,e,ep,er,v,ev,ej,ejp,dj,djp,a,av,ac,acp,p,k,z,cb,h=help,q=quit"))
        echo()
        print("_________^",red)
        hlineln(tw - 10,pastelgreen)  

proc doMecab(b:string) =
        pythonEnvironment["text"] = b
        execPython("mecab = MeCab.Tagger('-Oyomi')")
        execPython("kata  = mecab.parse(text)")
        nimkata = pythonEnvironment["kata"].depythonify(string)
        execPython("hira = kata2hira(kata)")
        nimhira = pythonEnvironment["hira"].depythonify(string)

# set up for japanese
execPython("""
import MeCab
from jcconv import kata2hira
""")

proc doPrompt() =
      echo()
      hlineln(tw - 10,truetomato)
      printBiCol(" .Start | .Stop | .Input ","|",lime,truetomato,":",0,false,{})
      println("| .Quit ",salmon)
      
proc doClip(ms:int = 100) {.async.} =
    var nn = epochTime()
    while true:        
         
         cp = checkClip()
         cp = strip(cp,true,false)
         
         if epochTime() - nn > 1800:
           cp = ".Input"   # autoswitch to indo8 after 30 mins secs

                    
         if cp.startswith(".Stop") == true and stopflag == false :  
            stopflag = true
            curup(1)
            printlnBiCol(rightarrow & " Status : stopped",greenyellow,red,":",40,false,{})           
            # we are getting high cpu upon stop 
         
         elif cp.startswith(".Start") == true and stopflag == true:  
            stopflag = false
            curup(1)
            printlnBiCol(rightarrow & " Status : ok" & spaces(6),greenyellow,skyblue,":",40,false,{})
            nn = epochTime()
         
         elif cp.startswith(".Input") == true and stopflag == false:  
            stopflag = true
            curup(1)
            printlnBiCol(rightarrow & " Status : input" & spaces(6),greenyellow,skyblue,":",40,false,{})
            # we call indo8 in case we want to manually input words
            discard execCMD("indo8")
            cleanscreen()
            echo()
            println(" Manual input finished . Please select menu item below.\n",lightsalmon)
            doPrompt()
            nn = epochTime()
         
         elif cp.startswith(".Quit") == true :  
            curup(1)
            printlnBiCol(rightarrow & " Status : exiting" & spaces(6),greenyellow,salmon,":",40,false,{})
            quit(0) 
          
                   
         else : discard 
         
            
         if stopflag == false and cp.startswith(".Start") == false:
 
                #acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(cp)
                #acmd = "trans -b -w $1 "  % $tw & quoteshellposix(cp)
                let xpos = 0
                acmd = "trans -w $1 "  % $tw & quoteshellposix(cp)              
                var cpl = splitlines(cp)
                var oldcpl:type(cpl)
                if cpl != oldcpl:
                      echo()
                      printLn(gold & "ClipB" & dodgerblue & "  : " & termwhite,styled={styleReverse})
                      echo()
                      for cpline in cpl:
                          print(wordwrap(cpline, tw),powderblue,xpos = xpos) 
                          echo()
                      oldcpl = cpl
                await sleepAsync(ms)
                                                           
                if bflag == true and hflag == false:
                    
                    rx = execProcess(acmd).strip()  # here the trans is executed
                    if $rx == oldtrans:
                      discard
                    else:  
                      if zflag == false:
                          oldtrans = $rx      # save these values for redisplaying later
                          oldword  = katax
                          addrec(switch,katax,$rx)
                          var rxl = splitlines($rx)
                          oldrxl   = rxl
                          if rxl.len == 1:
                              printLn(gold & "Trans" & dodgerblue & "  : " & white & $rx & termwhite,styled={styleReverse})
                              echo()
                              if switch == "ej" or switch == "ejp" or switch == "dj" or switch == "djp":
                                  echo()
                                  doMecab(rx)
                                  print(wordwrap(nimhira,tw),pastelgreen,xpos = xpos)
                                  echo()
                          else:
                                  printLn(gold & "Trans" & dodgerblue & "  : " & termwhite,styled={styleReverse})
                                  echo()
                                  for rxline in rxl:
                                  
                                      #print(wordwrap(rxline,tw),yellowgreen,xpos = xpos)   # orig
                                      #echo()                                               # orig
                                      # testing
                                      if rxl.len == 2:
                                            print(wordwrap(rxline,tw),yellowgreen,xpos = xpos)
                                            echo()
                                      else:
                                            # in case of many lines we provide a bit more space and remove empty lines 
                                            # and lines with see line below:
                                            if rxline.startswith("Translations of ") == true or rxline.contains("->") == true  or isEmpty(rxline) == true : discard
                                            else:  
                                                # here we can try different colors for grammar indicators like noun etc
                                                if rxline.strip() in @["noun","verb","adjective","adverb","preposition","conjunction","auxiliary verb"] == true:
                                                    println(rxline,lightslategray,xpos = 2,styled = {stylereverse})
                                                elif rxline.startswith("Definitions of ") == true :
                                                    echo()
                                                    printlnBicol(rxline,plum,powderblue,"of",2,false,{styleReverse})
                                                else:   
                                                    println(wordwrap(rxline,tw),yellowgreen,xpos = 2)
                                                
                                      # end testing  
                                      
                                      if switch == "ej" or switch == "ejp" or switch == "dj" or switch == "djp":
                                          if rxl.len == 2:
                                                doMecab(rxline)
                                                print(wordwrap(nimhira,tw),pastelgreen,xpos = xpos)
                                                echo()
                                          else:      
                                                doMecab(rxline)
                                                print(wordwrap(nimhira,tw),pastelgreen,xpos = xpos) 
                                                echo()
                          doprompt()
                         
                                                   
                          
                else:
                        println(acmd,truetomato) 
              
         else:
               await sleepAsync(ms * 10)                   
      
asyncCheck doClip()
#waitFor doClip()     # this blocks until doclip is finished

while true:
    try:
       runForever()
    except:
       println("Error occured : ",red)
       println(getCurrentExceptionMsg(),red)
       println("Trying to restart loop",peru)



