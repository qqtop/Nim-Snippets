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
     
     # tokenize the formated string   
     for word in tokenize(pdn):
              aseq.add(word.token)
          
     # now display values > 0.01 in color       
     printColStr(brightred,aseq[0])
     #printColStr(white,aseq[1]) 
     printColStr(white,aseq[4])
     printColStr(white,aseq[5])
     if mbps1 > 0.01 :
         printColStr(cyan,aseq[6])
     else:
         printColStr(white,aseq[6])
     printColStr(white,aseq[7])
     printColStr(white,aseq[8])
     printColStr(white,aseq[9])
     if mib1 > 0.01 :
         printColStr(green,aseq[10])
     else:
         printColStr(white,aseq[10])
     printColStr(white,aseq[11])
     printColStr(white,aseq[12])
     printColStr(white,aseq[13])
     if pps1 > 0.01 :
         printColStr(yellow,aseq[14])
     else:
         printColStr(white,aseq[14])
     printColStr(white,aseq[15])
     printColStr(white,aseq[16])
     printColStr(white,aseq[17])
     printColStr(white,aseq[18])
     printColStr(white,aseq[19])
     if mbps2 > 0.01 :
         printColStr(cyan ,aseq[20])
     else:
         printColStr(white,aseq[20])
     printColStr(white,aseq[21])
     printColStr(white,aseq[22])
     printColStr(white,aseq[23])
     if mib2 > 0.01 :
         printColStr(green,aseq[24])
     else:
         printColStr(white,aseq[24])
     printColStr(white,aseq[25])
     printColStr(white,aseq[26])
     printColStr(white,aseq[27])
     if pps2 > 0.01 :
         printColStr(yellow ,aseq[28])
     else:
         printColStr(white , aseq[28])
     printColStr(white,aseq[29])
     printColStr(white,aseq[30])
     
     echo()
 
     lrbytes  = rbytes
     lrpkt    = rpkt 
     lwbytes  = wbytes
     lwpkt    = wpkt
     lwcoll   = wcoll
     
     sleepy(1.0)


decho(2)
doFinish()
