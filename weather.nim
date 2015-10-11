import os,strutils,sequtils,yahooweather,strfmt, private

##   Program     : weather.nim
##
##   Status      : stable
##
##   License     : MIT opensource
##
##   Version     : 1.2
##
##   ProjectStart: 2015-03-20
##
##   Compiler    : Nim 0.11.3
##
##   Description : weather.nim 
##   
##                 fetches yahoo weather information based on WOEID codes
##                 
##                 which can be found at :  http://woeid.rosselliot.co.nz/lookup
##                 
##   Requires    : private.nim      
##   
##   Compile     : nim c weather
##                 
##   Project     : https://github.com/qqtop/Nim-Snippets
##
##   Docs        : 
##
##   Tested      : on linux only
##
##   Programming : qqTop
##
##   Note        : may be improved at any time
##


var woeid = ""
let version = "1.2"
var currentflag:bool = false
var helpflag:bool = false
var versionflag:bool = false

proc woeidblock() =
         msgb() do: echo "Yahoo WOEID not provided. Default used"
         msgb() do: echo "Usage   : weather  woeid"
         msgb() do: echo "Example : weather 2165352"
         msgb() do: echo "Example : weather 2165352 -c"
         msgb() do: echo "Example : weather -h"
         woeid="2165352"

proc helpblock() =
         
         superHeader("NIM Yahoo Weather - Service")
         msgb() do: echo "Nim Weather "
         msgb() do: echo "Usage   : weather  woeid"
         msgb() do: echo "Example : weather 2165352"
         msgb() do: echo "Example : weather 2165352 -c"
         msgb() do: echo "Example : weather 12723"
         msgb() do: echo "Help    : weather -h"
         msgb() do: echo "Version : weather -v"
         msgb() do: echo "Get woeid from http://woeid.rosselliot.co.nz/lookup"
         woeid="2165352" # default = Hongkong
  

clearup()

if len(commandLineParams())>0:
    for param in commandLineParams():
    
       case param
       of "-c" : currentflag = true
       of "-h", "-?": helpflag = true
       of "-v" : versionflag = true
       else: woeid = param
    
    if woeid == "":
         woeidblock()
       
else:
      woeidblock()
   

var yres:YWeather
var resq:string
var acity:string
var acountry:string

if helpflag == true:
   helpblock() 
 
elif versionflag == true:
   superHeader("NIM Yahoo Weather - Service")
   msgc() do : echo "  Nim Weather Version : ",version
 
else:
        
      try:
        yres=getWeather(woeid)
        resq = $yres
        var c : int
        var resx: string  
        resq = resq.replace("(","").replace(")","")
        for str in resq.split(','):
            var wxs1 = split(str,": ")
            if wxs1[0].strip() == "city":
                    acity = wxs1[1].capitalize() 
            if wxs1[0].strip() == "country":
                    acountry = wxs1[1].capitalize() 
        
        superHeader("NIM Weather - Service for : $1 , $2   woeid : $3"  % [acity,acountry,woeid])
              
        let aha = getForecasts(woeid)
        let strings = aha.mapIt(string, $(it))
        var sstrings :string="" 
        var xxs:string  
        for x in (0..len(strings)-1):
            hline()
            sstrings = strings[x].replace("(","").replace(")","")
            #msgg() do : echo "Forecast for $1 , $2  WOEID: $3 \n" % [acity,acountry,woeid]
            printLn("Forecast for $1 , $2  WOEID: $3 " % [acity,acountry,woeid],brightgreen)
            for xx in sstrings.split(","):
              
              xxs = strip(xx,true,false)
              var xxss = xxs.split(":")
              printBiCol("{:<7} : {}".fmt(xxss[0].capitalize(),xxss[1]),":",yellow,cyan)
              echo()   
                  
        if currentflag == true:
                    decho(2)
                    superHeader("Current Weather Details for $1 , %2" % [acity,acountry])
                    resq = $yres
                    resq = resq.replace("(","").replace(")","")
                    for str in resq.split(','):
                      var wxs = split(str,": ")
                      if wxs[0].strip() != "link" and wxs[0].strip() != "htmlDescription":
                          try:
                            printColStr(yellow,"{:<15}".fmt(wxs[0].strip().capitalize()))
                            printLnColStr(green,"{:<}".fmt(wxs[1].strip()))
                          except:
                            echo()
                    
      except:
        let
          e   = getCurrentException()
          msg = getCurrentExceptionMsg()
        msgr() do: echo "Forecast Failed !"    
        msgr() do: echo "Got exception ", repr(e), " with message ", msg

  
doFinish()  

 