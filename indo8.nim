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
# Tested:  nim 0.16.0
# 
# Requires :
# 
#           python 2.7.x  because pythonize requires it
#
#           mplayer       to play the voice output
#
#           https://github.com/soimort/translate-shell
#
#           gnu awk
#
#           a working mecab (japanese lexer) installation callable via python
#
#           kateglo3 (optional) running in another terminal 
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
#
# 
# 
# 
# A rough receipe for installing mecab 0.996 from  https://github.com/taku910/mecab
# this may be different for your system and only as a guide .

# tested for :
# 
# openSuse13.2
# opensuseLeap42.1 
# openSuse Tumbleweed
#  
#    sudo zypper install git     # if not installed already
# 
#    git clone https://github.com/taku910/mecab.git
# 
# make a link to jumadic:
# 
#    ln -s --/mecab-jumandic/matrix.def
# 
# make sure you have a full gcc installation or the configure run below may complain   
# 
#    cp configure.in mecab-ipadic.spec.in
#    ./configure --with-charset="utf-8"
# 
#    
# manually change the MakeFile to refelect correct path to mecab-dict-index: /usr/local/lib/mecab/dic
# if below still not ok try with path /usr/local/lib64/mecab/dic ...
# 
# created missing dir  /usr/local/lib/mecab/dic/ipadic
# and copy as root from your local ipadic directory to the /usr/local/lib/mecab/dic/ipadic :
# 
#   unk.dic
#   dicrc 
#   char.bin
#   left-id.def
#   pos-id.def
#   rewrite.def
#   right-id.def
#   matrix.bin
#   sys.dic
# 
# 
# then try 
# 
#    make
#    sudo make install
#
#  you will also need to install the mecab.py for how to see the python directory
#  of the downloaded package.
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
        var  yu = recBuff[x - 1] 
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
       println("{:>4} {:<4} {} ".fmt(yellowgreen & rx[0],termwhite & rx[1],termwhite & rx[3])) 
    
   else :
        for x in (id - n + 1).. id: 
            var rx = getidrec(x)
            println("{:>4} {:<4} {} ".fmt(yellowgreen & rx[0],white & rx[1],cadetblue & rx[2])) 
            println("{:>4} {:<4} {} ".fmt(yellowgreen & rx[0],white & rx[1],termwhite  & rx[3])) 
            
   dlineln(tw - 1,"-",pastelgreen)
     
# some procs currently unused , but maybe handy in future   
   
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
let okswitch = ["","d","dr","e","ev","ep","er","ej","ejp","dj","djp","jd","jdp","a","av","v","ac","acp","p","k","z","cb","h","q"]

var oldword  = ""     # holds last input word/kata
var oldtrans = ""     # holds the last trans if single line
var oldrxl   = newSeq[string]()  # holds last trans if multiple lines

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
        printBicol("{}".fmt("Switches: d,dr,p,e,ep,er,v,ev,ej,ejp,dj,djp,jd,jdp,a,av,ac,acp,p,k,z,cb,h=help,q=quit"),":")
        echo()
        print("_________^",red)
        hlineln(tw - 10,pastelgreen)  

proc doMecab(b:string) =
        pythonEnvironment["text"] = b
        execPython("mecab = MeCab.Tagger('-Oyomi')")
        execPython("kata  = mecab.parse(text)")
        nimkata = pythonEnvironment["kata"].depythonify(string)
        execPython("hira = jaconv.kata2hira(kata.encode('utf-8').strip())")
        nimhira = pythonEnvironment["hira"].depythonify(string)

# set up for japanese
execPython("# coding: utf-8")
execPython("import MeCab , jaconv")   # new jaconv  pip2 installed
#execPython("from jcconv import kata2hira")

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
          
          
          of "cb"  :
                     curlang = "Ind"
                     if cflag == false:
                        var cpc = checkclip()
                        acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(cpc)
                        print("ClipB  : ", greenyellow)
                        println(cpc,powderblue,xpos = 9)
                     else:
                        acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(katax)
                        dokatax(katax)
          
       
          of "d"   : 
                     curlang = "Ind"
                     if cflag == false:
                        acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(katax)
                        dokatax(katax)
                        
          of "dr"  :
                     curlang = "Ind"  
                     acmd = "trans -b -w $1 -s id -t en "  % $tw   % $tw & quoteshellposix(oldtrans)
                     dowordx(oldtrans)                
                        
                        
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
                        
                        
          of "er"  :
                     curlang = "Eng"  
                     acmd = "trans -b -w $1 -s en -t id "  % $tw   % $tw & quoteshellposix(oldtrans)
                     dowordx(oldtrans)   

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
          
          
          of "jd"  : 
                     curlang = "Jap"
                     if cflag == false:
                        acmd = "trans -b -w $1 -s ja -t ja+id+en "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -w $1 -s ja -t ja+id+en "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
          
          
          
          of "jdp" :
                     curlang = "Jap"
                     if cflag == false:
                        acmd = "trans -b -p -w $1 -s ja -t ja+id+en "  % $tw & quoteshellposix(readLineFromStdin(curlang &  "    : "))
                     else:
                        acmd = "trans -b -p -w $1 -s ja -t ja+id+en "  % $tw & quoteshellposix(katax)
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
                        
          of "h"   : help = "d   indonesian english\ndr  translate last sentence back into english\np   any language english with voice for both, verbosed\nv   indonesian english verbose\ne   english indonesian\nep  english indonesian voice\ner  translate last sentence back into indonesian\nev  english indonesian verbose\nej  english japanese\nejp english japanese voice\ndj  indo japanese,english\ndjp indo japanese,english voice\njd indo,english\njdp  indo,english voice\na   any language to english\nav  any language to english verbose\nac  any language to chinese\nacp any language to chinese voice\nk   Dictionary Mode\nh   help\nq   Quit" 
           
          of "q"   : doFinish() 
          
          else     : acmd = "Wrong switch selected";bflag = false
      
                
        if switch == "h":
             echo()
             printlnbicol("indo8:   Switches Information",":",salmon,greenyellow)
             hlineln(60,"_")
             echo()
             printlnbicol("d    :   indonesian english")
             printlnbicol("dr   :   translate last sentence to english")
             printlnbicol("dj   :   indo japanese,english")
             printlnbicol("djp  :   indo japanese,english,japanese voice")
             printlnbicol("v    :   indonesian english verbose")
             printlnbicol("p    :   any language english with voice for both, verbose")
             printlnbicol("e    :   english indonesian")
             printlnbicol("ep   :   english indonesian voice")
             printlnbicol("er   :   translate last sentence to indonesian")
             printlnbicol("ev   :   english indonesian verbose")
             printlnbicol("ej   :   english japanese")
             printlnbicol("ejp  :   english japanese voice")
             printlnbicol("jd   :   indonesian english ")
             printlnbicol("jdp  :   indonesian english japanese voice")           
             printlnbicol("a    :   any language to english")
             printlnbicol("av   :   any language to english verbose")
             printlnbicol("ac   :   any language to chinese")
             printlnbicol("acp  :   any language to chinese voice")
             printlnbicol("k    :   Dictionary Mode")
             printlnbicol("cb   :   AutoclipBoard Mode")     
             printlnbicol("h    :   help")
             printlnbicol("q    :   Quit")
             hlineln(60,"_")
             echo()
        else: 
          if bflag == true and hflag==false:
             # consider to use a seq of acmd to iterate over to be more selective in what to output
             # during multiple language translations and mecab ... not yet implemented
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
                        println(nimhira,pastelgreen,xpos = 10)
                    
                else:
                        printLn(mediumspringgreen & "Trans" & dodgerblue & "  : " & termwhite)
                        for rxline in rxl:
                            # also tried with wordwrap function here but japanese is not cut off correctly
                            if rxl.len == 2:
                                println(rxline,yellowgreen,xpos = 10)
                            else:
                                # in case of many lines we provide a bit more space
                                println(rxline,yellowgreen,xpos = 2)
                            if switch == "ej" or switch == "ejp" or switch == "dj" or switch == "djp" :
                                if rxl.len == 2:
                                      doMecab(rxline)
                                      println(nimhira,pastelgreen,xpos = 10)
                                else:      
                                      doMecab(rxline)
                                      println(nimhira,pastelgreen,xpos = 2) 
                            
                            # Note that we get double lines back as there is no way
                            # to know when a new language translation starts
                            if switch == "jd" or switch == "jdp":
                                if rxl.len == 2:
                                      doMecab(rxline)
                                      println(nimhira,pastelgreen,xpos = 10)
                                else:  
                                      doMecab(rxline)
                                      println(truetomato & rightarrow & pastelblue & nimhira & white,pastelblue,xpos = 1)
                              
                         
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