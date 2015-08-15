import "/Nimborg/high_level.nim"
import private
import os,osproc,strutils,parseutils,strfmt,rdstdin


# indo6

# initial idea for a small wrapper around translate shell
# for more convenient terminal use. 
# Now also supports mecab via python to display hiragana in
# case of japanese translation
# 
# Next entry can now be a switch or a new sentence/word
# 
# usage : 
#  kata : senang
#  
# tested nim 0.11.3 
# translate shell from github
# awk
# 
# exit with ctrl-c or q at Next prompt
# tested on linux only
# http://pastebin.com/weNKuKWL
# http://pastebin.com/9WryV2RP
# http://pastebin.com/a621e7WM
# http://pastebin.com/ERe8H9Dg
# http://pastebin.com/U1t2K5bp

var VERSION = "1.0"

setControlCHook(handler)
var fin :bool = false
var switch = "d" # default set to indonesian:english
var oldswitch = "d"  
var acmd = ""
var help = ""
var bflag : bool = true
var okswitch = ["","d","p","e","ev","ep","ej","ejp","a","av","v","k","h","q"]

# call mecab.py 
let ppmecab = pyImport("MeCab")
let ppkata2hira = pyImport("jcconv")
let ppmecabP   = ppmecab.Tagger("-Oyomi")

var cflag : bool = false
var hflag : bool = false
var katax = ""

proc dokatax(akatax) =
     printLn("Kata   : " & akatax,green,brightcyan)
     

proc dowordx(akatax) =
     printLn("Word   : " & akatax,green,brightcyan)
     

while fin == false:
        clearup()
        msgyb() do: stdout.write("{:<9}".fmt("Active : "))
        msgcb() do: stdout.write("{:<4}".fmt(switch))
        msgy()  do: stdout.write("{}".fmt("Switches : d,p,e,ep,v,ev,ej,ejp,a,av,k,h=help,none=last,q=quit"))
        echo()
        #echo repeat("_",tw)
        stdout.write("_________^")
        echo repeat("_",tw-10)  
       
        bflag = true
        case switch 
          of "d"   : 
                     if cflag == false:
                        acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(readLineFromStdin("Kata   : "))
                     else:
                        acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(katax)
                        dokatax(katax)
          of "e"   :
                    if cflag == false :  
                        acmd = "trans -b -w $1 -s en -t id "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                    else:    
                        acmd = "trans -b -w $1 -s en -t id "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
          of "ep"  : 
                     if cflag == false:
                        acmd = "trans -b -p -w $1 -s en -t id "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -b -p -w $1 -s en -t id "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
          of "v"   : 
                     if cflag == false:
                        acmd = "trans -v -w $1 -s id -t en "  % $tw & quoteshellposix(readLineFromStdin("Kata   : "))
                     else:
                        acmd = "trans -v -w $1 -s id -t en "  % $tw & quoteshellposix(katax)
                        dokatax(katax)
                        
          of "ev"  : 
                     if cflag == false: 
                        acmd = "trans -v -w $1 -s en -t id "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -v -w $1 -s en -t id "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "ej"  : 
                     if cflag == false:
                        acmd = "trans -b -w $1 -s en -t ja "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -b -w $1 -s en -t ja "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "ejp" : 
                     if cflag == false: 
                        acmd = "trans -b -p -w $1 -s en -t ja "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -b -p -w $1 -s en -t ja "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "a"   : 
                     if cflag == false:
                        acmd = "trans -b -w $1 "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -b -w $1 "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "av"  : 
                     if cflag == false:
                        acmd = "trans -v -w $1 "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -v -w $1 "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "p"   : 
                     if cflag == false:
                        acmd = "trans -p -w $1 "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -p -w $1 "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                    
          of "k"   :
                     if cflag == false:
                        acmd = "trans -d -w $1 "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -d -w $1 "  % $tw & quoteshellposix(katax)
                        dowordx(katax)
                        
          of "h"   : help = "d   indonesian english\np   any language english with voice for both, verbosed\nv   indonesian english verbose\ne   english indonesian\nep  english indonesian voice\nev  english indonesian verbose\nej  english japanese\nejp english japanese voice\na   any language to english\nav  any language to english verbose\nk   Dictionary Mode\nh   help\nq   Quit" 
           
          of "q"   : 
                     doFinish() 
          
          else     : acmd = "Wrong switch selected";bflag = false
      
          
        proc doMecab(b:string):string =
            var output2 = ppmecabP.parse(b)  # returns katakana
            var kshi = ppkata2hira.kata2hira(output2) #returns hiragana
            result = $kshi
       
               
        if switch == "h":
          msgw() do : echo help
        else: 
          if bflag == true and hflag==false:
             var rx = execProcess(acmd).strip()
             printBiCol("Trans  : $1 " % $rx," : ",clrainbow,yellow)
             if switch == "ej" or switch == "ejp":
                echo()
                echo "         ",doMecab(rx)
          else:
                msgr() do : echo acmd 
            
               
        if switch in okswitch:
           # only allow good switches 
           oldswitch = switch
        
           
        switch = nil
        katax = ""
        
              
        # switch implementation to take care of differencing between switches and words
        # seems ok now
        echo()
        while not okswitch.contains(switch) and switch.len < 4:
             switch = readLineFromStdin("Next   : ")
             # if not in okswitch we add three spaces at the end to take
             # care of all short word situations   
             if not okswitch.contains(switch) :
                 switch = switch & "   "
               
        if switch.len > 3:
           cflag = true
           katax = switch
           switch = oldswitch
        else:
           cflag = false
        
        if switch == "":
              cflag = false
              switch = oldswitch
        
        
       
   
## output examples:
## 
## Next   : d                                                                                 
## Switch : d   Available : d,e,ep,v,ev,ej,ejp,a,av,h or none=last
## Kata   : marah atau senang
## Trans  : angry or happy

## Next   : 


## Switch : ej   Available : d,e,ep,v,ev,ej,ejp,a,av,h or none=last
## Words  : The flight over Siberia was long and boring
## Trans  : シベリア以上のフライトは長く、退屈でした
##          しべりあいじょうのふらいとはながく、たいくつでした
## 
## 
## Next   : 


#trans help
# # 
# # Usage:  trans [OPTIONS] [SOURCE]:[TARGETS] [TEXT]...
# # 
# # Information options:
# #     -V, -version
# #         Print version and exit.
# #     -H, -help
# #         Print help message and exit.
# #     -M, -man
# #         Show man page and exit.
# #     -T, -reference
# #         Print reference table of languages and exit.
# #     -R, -reference-english
# #         Print reference table of languages (in English names) and exit.
# #     -L CODES, -list CODES
# #         Print details of languages and exit.
# #     -U, -upgrade
# #         Check for upgrade of this program.
# # 
# # Display options:
# #     -verbose
# #         Verbose mode. (default)
# #     -b, -brief
# #         Brief mode.
# #     -d, -dictionary
# #         Dictionary mode.
# #     -show-original Y/n
# #         Show original text or not.
# #     -show-original-phonetics Y/n
# #         Show phonetic notation of original text or not.
# #     -show-translation Y/n
# #         Show translation or not.
# #     -show-translation-phonetics Y/n
# #         Show phonetic notation of translation or not.
# #     -show-prompt-message Y/n
# #         Show prompt message or not.
# #     -show-languages Y/n
# #         Show source and target languages or not.
# #     -show-original-dictionary y/N
# #         Show dictionary entry of original text or not.
# #     -show-dictionary Y/n
# #         Show dictionary entry of translation or not.
# #     -show-alternatives Y/n
# #         Show alternative translations or not.
# #     -w NUM, -width NUM
# #         Specify the screen width for padding.
# #     -indent NUM
# #         Specify the size of indent (number of spaces).
# #     -theme FILENAME
# #         Specify the theme to use.
# #     -no-theme
# #         Do not use any other theme than default.
# #     -no-ansi
# #         Do not use ANSI escape codes.
# # 
# # Audio options:
# #     -p, -play
# #         Listen to the translation.
# #     -player PROGRAM
# #         Specify the audio player to use, and listen to the translation.
# #     -no-play
# #         Do not listen to the translation.
# # 
# # Terminal paging and browsing options:
# #     -v, -view
# #         View the translation in a terminal pager.
# #     -pager PROGRAM
# #         Specify the terminal pager to use, and view the translation.
# #     -no-view
# #         Do not view the translation in a terminal pager.
# #     -browser PROGRAM
# #         Specify the web browser to use.
# # 
# # Networking options:
# #     -x HOST:PORT, -proxy HOST:PORT
# #         Use HTTP proxy on given port.
# #     -u STRING, -user-agent STRING
# #         Specify the User-Agent to identify as.
# # 
# # Interactive shell options:
# #     -I, -interactive, -shell
# #         Start an interactive shell.
# #     -E, -emacs
# #         Start the GNU Emacs front-end for an interactive shell.
# #     -no-rlwrap
# #         Do not invoke rlwrap when starting an interactive shell.
# # 
# # I/O options:
# #     -i FILENAME, -input FILENAME
# #         Specify the input file.
# #     -o FILENAME, -output FILENAME
# #         Specify the output file.
# # 
# # Language preference options:
# #     -l CODE, -hl CODE, -lang CODE
# #         Specify your home language.
# #     -s CODE, -sl CODE, -source CODE
# #         Specify the source language.
# #     -t CODES, -tl CODE, -target CODES
# #         Specify the target language(s), joined by '+'.
# # 
# # Other options:
# #     -no-init
# #         Do not load any initialization script.
# # 
# # See the man page trans(1) for more information.
