import os,strutils,parseopt2,terminal,times,strfmt,json,streams,httpclient

# Reinstall Nim Development version only if build waterfall 
# on nim-lang says "successfull"
# 
# suitable for linux only
# 
# based on linux install suggestion on
# https://github.com/nim-lang/Nim

##############################################################
# Change dirs as required

var cp = "/data4/NimCompiler/"                   # where the compiler lives
var bsjson = "/data4/NimStuff/buildstatus.json"  # path for tmp file download

##############################################################

let VERSION = "1.0"
let start    = epochTime()


resetAttributes()
eraseScreen()
cursorUp(80) 

const usageString = """Usage: updateNimCompiler [OPTIONS] /myinstall/path/
  

Options:
                        Default Path /data4/NimCompiler/
                        Example : updateNimCompiler -i /myinstall/path/ 
                        this path must exist, 
                        
    -h --help           print this help menu
    -i --install        install to path specified
"""  
 

var inCommands: seq[string] = @[]

  
inCommands.add(cp)  
var iflag = false  

var buildjson = "http://buildbot.nim-lang.org/json/builders/linux-x64-builder/builds?select=-1"

  
proc checkBuildStatus(bss:string):bool =
      var s : Stream
      downloadFile(bss,bsjson)
      var jobj = parseFile(bsjson)
      echo "Builder Name : " ,jobj["-1"]["builderName"].getstr
      var cb : string = ""
      cb = $(jobj["-1"]["text"].getElems[1])
      echo "Finished     : " , cb
      if cb == """"successful"""":
         result = true
      else:
         result = false
           
  
proc byebye() =
    setForegroundColor(fgGreen) 
    echo "\n",usageString
    setForegroundColor(fgWhite)
    quit(QuitFailure)


for kind, key, val in getopt():
    case kind
    of cmdArgument:
        inCommands.add(key)
       
    of cmdShortOption, cmdLongOption:
       case key
       of  "install","i" : iflag = true
       of  "help", "h"   : byebye()
       else: discard
    of cmdEnd: discard
    
if iflag == true:
  cp = $inCommands[1]
else:
  cp = $inCommands[0]  


if not dirExists(cp):
  echo  "Directory $1 must exist" % cp
  byebye()
  
else:
 echo "Installing Nim compiler to " & cp  
 echo ""


setcurrentdir(cp)

if checkBuildStatus(buildjson) == true :
   
    setForegroundColor(fgGreen)
    echo "\n\n Ok we update"
    setForegroundColor(fgWhite)

    discard os.execShellCmd("rm -rf Nim") 
    discard os.execShellCmd("git clone git://github.com/Araq/Nim.git")
    setcurrentdir(cp&"Nim")
    discard os.execShellCmd("git clone --depth 1 git://github.com/nim-lang/csources")
    setcurrentdir(cp&"Nim/csources")
    discard os.execShellCmd("sh build.sh")
    setcurrentdir(cp&"Nim")
    discard os.execShellCmd("bin/nim c koch")
    discard os.execShellCmd("./koch boot -d:release")

else:
  setForegroundColor(fgRed)
  echo " \n\n BuildStatus = false . Try update later "
  setForegroundColor(fgWhite)  

# clean up
removeFile(bsjson)
   
when isMainModule:
  # display some info, reset attribs and exit
  
  setForegroundColor(fgCyan,false)
  let duration = epochTime() - start
  echo "{}{}{}".fmt("\nRequest Duration              : ",duration.formatFloat(ffDecimal,5)," secs")  
  echo "{}{:<11}{:>9}".fmt("Last module compilation on    : ",CompileDate ,CompileTime)  
  setForegroundColor(fgGreen,false)   
  echo "Programmed by                 : qqTop"
  eraseLine()
  setForegroundColor(fgGreen,false)
  echo "{}{:<11}{:>9}".fmt("Current time                  : ",getDateStr(),getClockStr())
  setForegroundColor(fgWhite,false)
  echo "Finished "
  
  system.addQuitProc(resetAttributes)
  quit 0