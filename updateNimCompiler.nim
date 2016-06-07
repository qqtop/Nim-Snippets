import os,strutils,parseopt2,strfmt,json,httpclient,cx

# Reinstall Nim Development branch only if build waterfall says success
# suitable for linux 86_64 install only
# we only update if build status is : Success 
# no update when build warnings,exceptions or failure

# under development

##############################################################
# Change dirs as required

var cp     = "/data4/NimCompiler/"               # where it the compiler lives
var bsjson = "/data4/NimStuff/buildstatus.json"  # path for tmp file download

##############################################################

let VERSION = "1.8.2"

clearup()

const usageString = """Usage: updateNimCompiler [OPTIONS] /myinstall/path/
  
Options:
                        Default Path /data4/NimCompiler/
                        Example : updateNimCompiler -i:/myinstall/path/    # --> path must exist
                        
    -v --version        print version and exit                    
    -h --help           print this help menu
    -i --install        install to path specified
    -j --tmpfile        path for tmp file download default is current working directory
    
"""  


 

let buildjson = "http://buildbot.nim-lang.org/json/builders/linux-x64-builder/builds?select=-1"
  
  
proc checkBuildStatus(bss:string):bool =
      
      downloadFile(bss,bsjson)
      var jobj = parseFile(bsjson)
      printLnBiCol("Builder Name             : " & jobj["-1"]["builderName"].getstr,":")
      var cb : string = ""
      var lcb = jobj["-1"]["text"].len
      for x in 0.. <lcb:
        cb = $(jobj["-1"]["text"].getElems[x])
        if x == 1 and cb == """"successful"""":
           printLnBiCol("Build Status             : Success.  ===> Updating compiler now !",lime)
           result = true
        elif x == 0 and cb == """"warnings"""":
           printLnBiCol("Build Status Warnings    : " & cb,":",yellow)
           result = false
        elif x == 0 and cb == """"failure"""":
           printLnBiCol("Build Status Failure     : " & cb,":",red)
           result = false
        elif x == 0 and cb == """"exception"""":
           printLnBiCol("Build Status Exception   : " & cb,":",truetomato)
           result = false  
        elif x == 0 and cb == """"retry"""":
           printLnBiCol("Build Status Notice      : " & cb,":",magenta)
           result = false  
           
           
  
proc byebye() =
    echo() 
    print(usageString,termgreen)
    quit(QuitFailure)

var filename = ""  
for kind, key, val in getopt():
    case kind
    of cmdArgument:
        #inCommands.add(key)
        filename =  key
       
    of cmdShortOption, cmdLongOption:
       case key
       of  "version","v" :  
                           echo() 
                           printLnBiCol("updateNimCompiler Version : " & VERSION)
                           infoline()
                           echo()
                           quit(0)
       of  "install","i" :  cp     = $val     #iflag = true
       of  "tmpfile","j" :  
                            bsjson = $val
                            if bsjson.endswith("/"):
                                bsjson = $val & "buildstatus.json"
                            else:
                                bsjson = $val & "/buildstatus.json"
                      
       of  "help"   ,"h" :  byebye()
       else: discard
    of cmdEnd: discard


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
    case  cp.endswith("/") 
      of true : setcurrentdir(cp&"Nim")
      of false: setcurrentdir(cp&"/Nim")
    discard os.execShellCmd("git clone --depth 1 git://github.com/nim-lang/csources")
    case  cp.endswith("/") 
      of true : setcurrentdir(cp&"Nim/csources")
      of false: setcurrentdir(cp&"/Nim/csources")
    discard os.execShellCmd("sh build.sh")
    case  cp.endswith("/") 
      of true : setcurrentdir(cp&"Nim")
      of false: setcurrentdir(cp&"/Nim")
    discard os.execShellCmd("bin/nim c koch")
    discard os.execShellCmd("./koch boot -d:release")

    # we come to here the compiler was build ok
    decho(2)
    println("The nim compiler build was successful and is now in. ")
    case  cp.endswith("/") 
      of true : println(cp & "Nim/bin",yellowgreen)
      of false: println(cp & "/Nim/bin",yellowgreen)
     

else:
  
  decho(2)
  printLn(" Nim Waterfall BuildStatus : Warnings,Exceptions or Failed .  Try update later ",white,red)
  decho(2)
    

# clean up
removeFile(bsjson)
 
doFinish()