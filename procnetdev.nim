import os,math,strutils,strfmt,cx

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
## VERSION : 0.6


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

     var g      = aget(2)
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
     # do not change format string
     var pdn = "{:<8}: rx {:>7.2f} Mbps {:>7.2f} MiB/s {:>7.2f} pps  tx {:>7.2f} Mbps {:>7.2f} MiB/s {:>7.2f} pps".fmt(name,mbps1,mib1,pps1,mbps2,mib2,pps2)
     var aseq = newSeq[string]()
     drawbox(2,pdn.len + 15)
     curup(2)
     # tokenize the formated string   
     for word in tokenize(pdn):
              aseq.add(word.token)
          
     # now display values > 0.01 in color       
     print(aseq[0] & " ",brightred,xpos = 3)
     print(aseq[4],white)
     print(aseq[5],white)
     if mbps1 > 0.01 :
         print(aseq[6],cyan)
     else:
         print(aseq[6],white)
     print(" | ",greenyellow)      
     print(aseq[7],white)
     print(aseq[8],white)
     print(aseq[9],white)
     if mib1 > 0.01 :
         print(aseq[10],green)
     else:
         print(aseq[10],white)
     print(" | ",greenyellow)      
     print(aseq[11],white)
     print(aseq[12],white)
     print(aseq[13],white)
     if pps1 > 0.01 :
         print(aseq[14],yellow)
     else:
         print(aseq[14],white)
    
     print(aseq[15],white)
    
     print(" | ",greenyellow)  
    
     print(aseq[16],white)
     print(aseq[17],white)
     print(aseq[18],white)
     print(aseq[19],white)
     if mbps2 > 0.01 :
         print(aseq[20],cyan)
     else:
         print(aseq[20],white)
     print(" | ",greenyellow)  
     print(aseq[21],white)
     print(aseq[22],white)
     print(aseq[23],white)
     if mib2 > 0.01 :
         print(aseq[24],green)
     else:
         print(aseq[24],white)
     print(" | ",greenyellow)  
     print(aseq[25],white)
     print(aseq[26],white)
     print(aseq[27],white)
     
     if pps2 > 0.01 :
         print(aseq[28],yellow)
     else:
         print(aseq[28],white)
      
     print(aseq[29],white)
     print(aseq[30] ,white)
     echo()
 
     lrbytes  = rbytes
     lrpkt    = rpkt 
     lwbytes  = wbytes
     lwpkt    = wpkt
     lwcoll   = wcoll
     
     sleepy(1.0)


decho(2)
doFinish()
