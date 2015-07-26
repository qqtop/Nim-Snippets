import os,math,strutils,strfmt,private

## parse /proc/net/dev to see what's happening on the interface
## 
## to close :  ctrl-c
## 
## linux only
## 
## compile with  :  nim c -d:release -r  procnetdev
## 
## License : MIT opensource
## 
## VERSION : 0.5


type
  
    Da = object
      da0  : string
      da1  : int
      da2  : int
      da9  : int
      da10 : int
      da11 : int


proc aparse(line:string):Da =
    var dax = Da()
    var bits = line.split()
    dax.da0 = bits[0]  
    dax.da1 = parseint(bits[1])
    dax.da2 = parseint(bits[2])
    dax.da9 = parseint(bits[9])
    dax.da10 = parseint(bits[10])
    dax.da11 = parseint(bits[11])
    result = dax

proc aget(idx:int) : Da =
    var lines = newSeq[string]()
    let curFile = "/proc/net/dev"
    withFile(fp, curFile , fmRead):
       try:       
         while 1 == 1: 
           var lx = fp.readline()
           lines.add($lx)
       except:
           discard
       
    result = aparse(lines[2])    
  
var 
    lrbytes = 0
    lrpkt   = 0
    lwbytes = 0
    lwpkt   = 0
    lwcoll  = 0
 
while 1 == 1:

     var g      = aget(3)
     var name   = g.da0
     var rbytes = g.da1
     var rpkt   = g.da2
     var wbytes = g.da9
     var wpkt   = g.da10
     var wcoll  = g.da11
     
     var mbps1    = ((8 * (rbytes.float - lrbytes.float)) / 1e6)
     var mib1     = (((rbytes.float - lrbytes.float)) / 1048576)
     var pps1     = (rpkt.float - lrpkt.float)
     var mbps2    = ((8 * (wbytes.float - lwbytes.float)) / 1e6)
     var mib2     = (((wbytes.float - lwbytes.float)) / 1048576)
     var pps2     = (wpkt.float - lwpkt.float)
      
     clearup()  # comment this out for full history
     
     printColStr(brightred,name & " ")
     
     if mbps1 > 0.01 :
        printColStr(cyan ," rx " & formatFloat(mbps1, ffDecimal, 2) & " Mbps | ")
     else:
        printColStr(white," rx " & formatFloat(mbps1, ffDecimal, 2) & " Mbps | ")
     
     if mib1 > 0.01 :
        printColStr(green , formatFloat(mib1, ffDecimal, 2) & " MiB/s | ")
     else:
        printColStr(white,  formatFloat(mib1, ffDecimal, 2) & " MiB/s | ")
         
     if pps1 > 0.01 :
        printColStr(yellow ,formatFloat(pps1, ffDecimal, 2) & " pps tx | ")
     else:
        printColStr(white,formatFloat(pps1, ffDecimal, 2) & " pps tx  | ")
            
     if mbps2 > 0.01 :
        printColStr(cyan ,formatFloat(mbps2, ffDecimal, 2) & " Mbps  | ")
     else:
        printColStr(white,formatFloat(mbps2, ffDecimal, 2) & " Mbps  | ")
       
     if mib2 > 0.01 :
        printColStr(green ,formatFloat(mib2, ffDecimal, 2) & " MiB/s | ")
     else:
        printColStr(white,formatFloat(mib2, ffDecimal, 2) & " MiB/s | ")
                
     if pps2 > 0.01 :
        printColStr(yellow ,formatFloat(pps2, ffDecimal, 2) & " pps")
     else:
        printColStr(white ,formatFloat(pps2, ffDecimal, 2) & " pps")
      
     echo()
      
     lrbytes  = rbytes
     lrpkt    = rpkt 
     lwbytes  = wbytes
     lwpkt    = wpkt
     lwcoll   = wcoll
     
     sleepy(1.0)


decho(2)
doFinish()
