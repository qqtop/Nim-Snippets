## #####################################################################################
## Program     : sf 
##
## Status      : Development 
## 
## License     : MIT opensource  
## 
## ProjectStart: 2015-03-11
## 
## Compiler    : Nim 0.13.1 
## 
## Description : speed find , executes a bash find grep string command
## 
##               to find searchword in all files in a directory
##               
##               sf /data4/NimStuff/ postgresT1
##               
## Todo        : maybe allow for more than 1 searchword 
## 
##               so arg maybe sf blahdir search me now
##               
## Last Tested : 2016-02-13
## 
## Programming : Alien2
## 
## #####################################################################################

import os,osproc, strutils,strfmt,parseopt2,parseutils
import cx


const VERSION = "1.0"
const usageString =
  """Usage  : sf searchdir searchstring 
         sf searchstring   --> searchdir is currentworking dir
              
Example: sf /data4/NimStuff  money  
         sf Wuff 
Options:
                       
    -h --help           print this help menu 

"""

clearup()

var inArgs: seq[string] = @[]

for kind, key, val in getopt():
    case kind
    of cmdArgument:
        inArgs.add(key)
       
    of cmdShortOption, cmdLongOption:
       case key
       of  "help", "h": echo "\n",usageString
       else: discard
    of cmdEnd: discard


var arg1 = ""
var arg2 = ""

if len(inArgs) == 0:
  msgg() do : echo usageString
  arg1="-h"

elif len(inArgs) == 1:
   var oldarg1 = $inArgs[0]
   if arg1.find("/") == -1:
      arg1= getCurrentDir()
      arg2= oldarg1
else:     
   arg1 = $inArgs[0]
   arg2 = $inArgs[1]


if arg1 != "-h":

    var sx = "find $1 -type f -print0 | xargs -0 -P 8 grep -l $2 "  % [arg1,arg2]
    msgg() do: echo "Searching under " & arg1 & " for " & arg2
        
    var rx  = execProcess(sx)
    var rxs = ""
    var sep = " : " 
    echo()     
    msgy() do : echo "Search Results for : " & arg2 
    hline()  
    for i in 0.. <rx.len:
          rxs = rxs & $rx[i] 
    
    let rxss = rxs.fastsplit('\L')
    for x in 0.. <rxss.len-1:
       print("{:<7}: ".fmt($x),yellow)
       printLn(rxss[x],yellowgreen)
   

doFinish()





    
