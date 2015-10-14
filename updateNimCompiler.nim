import os,strutils,parseopt2,strfmt,json,httpclient,private

# Reinstall Nim Development version  only if build waterfall says successfull
# suitable for linux 86_64 install only
# we only update if build satus successful 
# no update when build warnings or failure

# under development

##############################################################
# Change dirs as required

var cp = "/data4/NimCompiler/"   # where it the compiler lives
var bsjson = "/data4/NimStuff/buildstatus.json"  # path for tmp file download

##############################################################

let VERSION = "1.6"

clearup()

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
      
      downloadFile(bss,bsjson)
      var jobj = parseFile(bsjson)
      printLnBiCol("Builder Name             : " & jobj["-1"]["builderName"].getstr,":")
      var cb : string = ""
      var lcb = jobj["-1"]["text"].len
      #echo "lcb : ",lcb
      
      for x in 0.. <lcb:
        cb = $(jobj["-1"]["text"].getElems[x])
        if x == 1 and cb == """"successful"""":
           print("Build Status : Success. Updating compiler",lime)
           result = true
        elif x == 0 and cb == """"warnings"""":
           printLnBiCol("Build Status Warnings    : " & cb,":")
           result = false
        elif x == 0 and cb == """"failure"""":
           printLnBiCol("Build Status Failure     : " & cb,":")
           result = false
          
  
proc byebye() =
    echo() 
    print(usageString,termgreen)
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
  printLn("Directory $1 must exist" % cp)
  byebye()
  
else:
 superHeader("Installing Nim compiler into :  " & cp) 
 echo ""

setcurrentdir(cp)

if checkBuildStatus(buildjson) == true :
  
    decho(2)
    
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
  
  decho(2)
  printLn(" Nim Waterfall BuildStatus : Warnings or Failed .  Try update later ",white,red)
  decho(2)
    

# clean up
removeFile(bsjson)
 
doFinish()