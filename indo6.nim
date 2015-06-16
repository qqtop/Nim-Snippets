import "/Nimborg/high_level.nim"
import os,osproc,strutils,parseutils,strfmt,terminal,times,rdstdin

# indo6
# a small wrapper around soimorts translate shell
# for more convenient terminal use. 
# Now also supports mecab via python to display hiragana in
# case of japanese translation
# 
# Next entry can now be a switch or a new sentence/word
# 
# usage : 
#  kata : senang
#  
# requires:
# 
# nim 0.11.3 
# translate shell from github
# awk or gawk
# python 2.7.x  and mecab library for japanese 
# 
# switches can be changed on the Next :   prompt
# 
# exit with ctrl-c
#
# tested on linux only

var VERSION = "1.0"

let t = epochTime()
var fin :bool = false
var switch = "d" # default set to indonesian:english
var oldswitch = "d"  
var acmd = ""
var help = ""
var bflag : bool = true
var okswitch = ["","d","p","e","ev","ep","ej","ejp","a","av","v","k","h"]

# call mecab.py 
let ppmecab = pyImport("MeCab")
let ppkata2hira = pyImport("jcconv")
let ppmecabP   = ppmecab.Tagger("-Oyomi")


converter toTwInt(x: cushort): int = result = int(x)
# we export the the proc getTerminalWidth so we can use this from another module
proc getTerminalWidth*() : int =
  
  type WinSize = object
     row, col, xpixel, ypixel: cushort
  const TIOCGWINSZ = 0x5413
  proc ioctl(fd: cint, request: culong, argp: pointer)
     {.importc, header: "<sys/ioctl.h>".}
  var size: WinSize
  ioctl(0, TIOCGWINSZ, addr size)

  # ok we get something back in the form of a cushort ,
  # in order to use this convert it into an int :  
  result = toTwInt(size.col)
  
var tw = getTerminalWidth()
var aline = repeat("=",tw)

template msgg*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgGreen)
      code
      setforegroundcolor(fgWhite)
      
template msgy*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgYellow)
      code
      setforegroundcolor(fgWhite)

template msgr*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgRed)
      code
      setforegroundcolor(fgWhite)

template msgc*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgCyan,true)
      code
      setforegroundcolor(fgWhite)


proc handler() {.noconv.} =
  # this runs if we press ctrl-c to kill all
  setForegroundColor(fgYellow,false)
  echo "\nindo6 has run for             : ", formatFloat(epochTime() - t, precision = 0), " seconds"
  setForegroundColor(fgCyan,false)
  echo "{}{:<11}{:>9}".fmt("Last module compilation on    : ",CompileDate ,CompileTime)  
  setForegroundColor(fgGreen,false)   
  echo "Programmed by                 : qqTop"
  echo "Nim Version                   : ", NimMajor,".",NimMinor,".",NimPatch
  echo "Sampai Jumpa , Have a Nice Day !"
  system.addQuitProc(resetAttributes)
  quit(0)
  
 
setControlCHook(handler)

var cflag : bool = false
var hflag : bool = false
var katax = ""

while fin == false:
        tw = getTerminalWidth()
        erasescreen()
        cursorup(80)
        msgy() do: stdout.write("{:<9}".fmt("Active : "))
        msgc() do: stdout.write("{:<4}".fmt(switch))
        msgy() do: stdout.writeln("{}".fmt("Switches : d,p,e,ep,v,ev,ej,ejp,a,av,k,h=help,none=last"))
        #echo repeat("-",tw-23)
        setforegroundcolor(fgGreen)  
        bflag = true
        case switch 
          of "d"   : 
                     if cflag == false:
                        acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(readLineFromStdin("Kata   : "))
                     else:
                        acmd = "trans -b -w $1 -s id -t en "  % $tw & quoteshellposix(katax)
                        echo "Kata   : ",katax
          of "e"   :
                    if cflag == false :  
                        acmd = "trans -b -w $1 -s en -t id "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                    else:    
                        acmd = "trans -b -w $1 -s en -t id "  % $tw & quoteshellposix(katax)
                        echo "Words  : ",katax
          of "ep"  : 
                     if cflag == false:
                        acmd = "trans -b -p -w $1 -s en -t id "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -b -p -w $1 -s en -t id "  % $tw & quoteshellposix(katax)
                        echo "Words  : ",katax
          of "v"   : 
                     if cflag == false:
                        acmd = "trans -v -w $1 -s id -t en "  % $tw & quoteshellposix(readLineFromStdin("Kata   : "))
                     else:
                        acmd = "trans -v -w $1 -s id -t en "  % $tw & quoteshellposix(katax)
                        echo "Kata   : ",katax
                        
          of "ev"  : 
                     if cflag == false: 
                        acmd = "trans -v -w $1 -s en -t id "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -v -w $1 -s en -t id "  % $tw & quoteshellposix(katax)
                        echo "Words  : ",katax
                        
          of "ej"  : 
                     if cflag == false:
                        acmd = "trans -b -w $1 -s en -t ja "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -b -w $1 -s en -t ja "  % $tw & quoteshellposix(katax)
                        echo "Words  : ",katax
                        
          of "ejp" : 
                     if cflag == false: 
                        acmd = "trans -b -p -w $1 -s en -t ja "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -b -p -w $1 -s en -t ja "  % $tw & quoteshellposix(katax)
                        echo "Words  : ",katax
                        
          of "a"   : 
                     if cflag == false:
                        acmd = "trans -b -w $1 "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -b -w $1 "  % $tw & quoteshellposix(katax)
                        echo "Words  : ",katax
                        
          of "av"  : 
                     if cflag == false:
                        acmd = "trans -v -w $1 "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -v -w $1 "  % $tw & quoteshellposix(katax)
                        echo "Words  : ",katax
                        
          of "p"   : 
                     if cflag == false:
                        acmd = "trans -p -w $1 "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -p -w $1 "  % $tw & quoteshellposix(katax)
                        echo "Words  : ",katax
                    
          of "k"   :
                     if cflag == false:
                        acmd = "trans -d -w $1 "  % $tw & quoteshellposix(readLineFromStdin("Words  : "))
                     else:
                        acmd = "trans -d -w $1 "  % $tw & quoteshellposix(katax)
                        echo "Words  : ",katax          
                        
          of "h"   : help = "d   indonesian english\np   any language english with voice for both, verbosed\nv   indonesian english verbose\ne   english indonesian\nep  english indonesian voice\nev  english indonesian verbose\nej  english japanese\nejp english japanese voice\na   any language to english\nav  any language to english verbose\nk   Dictionary Mode\nh   help" 
          else     : acmd = "Wrong switch selected";bflag = false

       
       
          
        proc doMecab(b:string):string =
            var output2 = ppmecabP.parse(b)  # returns katakana
            var kshi = ppkata2hira.kata2hira(output2) #returns hiragana
            result = $kshi
       
        
        setforegroundcolor(fgyellow,true)
        if switch == "h":
          setforegroundcolor(fgWhite)
          echo help
        else: 
          if bflag == true and hflag==false:
             var rx = execProcess(acmd).strip()
             echo "Trans  : ",rx
             if switch == "ej" or switch == "ejp":
                echo "         ",doMecab(rx)
          else:
                setForegroundColor(fgRed)
                echo acmd 
            
        setforegroundcolor(fgWhite)
        
        if switch in okswitch:
           # only allow good switches 
           oldswitch = switch
        
           
        switch = nil
        katax = ""
        
              
        # switch implementation to take care of differencing between switches and words
      
        while not okswitch.contains(switch) and switch.len < 4:
        
           setforegroundcolor(fgWhite,true)
           switch = readLineFromStdin("\nNext   : ")
           setforegroundcolor(fgWhite,false)
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
