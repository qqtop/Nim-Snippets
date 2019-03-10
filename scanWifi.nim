import nimcx

# wifi scanner  (may require root password)
# for linux only
# requires iwlist and iw installed
# try's to automatically dedect you wifi interface wifi interface
# to obtain info about other wifi routers in the vicinity
# Usage   : scanWifi 
# Last    : 2019-03-10
# 

proc scan(wifiinterface:string) = 
  
   let (outp,errc) = execCmdEx("sudo iwlist $1 scanning | egrep 'Cell |Encryption|Quality|Last beacon|ESSID'" % wifiinterface)
   
   if errc == 0:
     for line in outp.splitlines():
        if line.contains("Cell "):
            echo()
            printLnBiCol(line.strip(),colLeft=lightseagreen,xpos = 1,styled={styleReverse})
        elif line.contains("key:off"):
           printLn(line,red)
        elif line.contains("key:on")  :
           printLn(line,yellowgreen)
        elif line.contains("ESSID")  :
           printLnBiCol(line,colLeft=peru)
        else:
           printLn(line)
   else:
        echo()
        printLnErrorMsg("iw returned errorcode : " & $errc & " for interface : " & wifiinterface,xpos = 1)
        decho(2)
   printLn("====   End of interface scan output for  $1   ====" % wifiinterface,xpos = 1)  
   decho()

proc signalStrength(wifiinterface:string) =
   # sorted list of signal strength of routers in vicinty
   # requires iw
   decho(2)
   printLn("Routers & Access Points strongest signal on top     ",yellowgreen,xpos = 1,styled={styleUnderscore})
   echo()
   let (outp,errc) = execCmdEx("""sudo iw dev $1 scan | egrep "signal|SSID" | sed -e "s/\tsignal: //" -e "s/\tSSID: //" | awk '{ORS = (NR % 2 == 0)? "\n" : " "; print}' | sort""" % wifiinterface)
   if errc == 0:
      var op = outp.splitLines()
      for aline in op:
          printLn(aline,pastelpink,xpos = 1)
   else:
         decho()
         printLnErrorMsg("iw returned errorcode : " & $errc & " for interface : " & wifiinterface,xpos = 1)
   printLn("====   End of signal strength output ====",xpos = 1)
   decho(2)

# run the scans

proc main() =
    printLn("scanWifi    -     Wifi Interface Scan  " & spaces(40),yellowgreen,xpos = 1,styled={styleUnderscore}) 
    decho(2)
    let (di,de) = execCmdEx("sudo ip route | grep default")
    if de == 0:
         let zz = di.splitLines()
         for zzz in 0 ..< zz.len - 1:
             printLnBiCol("Testing Interface : " & zz[zzz],colLeft=yellowgreen,xpos = 1)
             try:
                 let zzzzz = zz[zzz].split("dev ")[1].split(" proto")[0].strip()
                 # now check if this is a wifi interface  
                 scan(zzzzz)
                 signalStrength(zzzzz)
             except:
                  discard
    else:
          printLnErrorMsg("Are ip , iw ,iwlist installed on your linux system ?")
          
when isMainModule: 
    main()
    doFinish()
