import cx,os,osproc

# wifi scanner  (requires root password)
# requires iwlist and iw installed
# pass in your wifi interface to obtain info about other wifi routers in the vicinity

# usage : scanWifi wlp6s0     (or any other wifi interface, wlp6s0 is used as default if no other interface given)

proc scan(wifiinterface:string) = 
   let (outp,errc) = execCmdEx("sudo iwlist $1 scanning | egrep 'Cell |Encryption|Quality|Last beacon|ESSID'" % wifiinterface)
   
   if errc == 0:
     for line in outp.splitlines():
        if line.contains("Cell "):
            echo()
            printLnBiCol(line.strip(),":",lightseagreen,styled={styleReverse},xpos=16)
        elif line.contains("key:off"):
           printLn(line,red)
        elif line.contains("key:on")  :
           printLn(line,yellowgreen)
        elif line.contains("ESSID")  :
           printLnBiCol(line,":",peru)
        else:
           printLn(line)
   else:
        printLn("iwlist returned errorcode : " & $errc & " for interface : " & wifiinterface,red)
      

proc signalStrength(wifiinterface:string) =
   # sorted list of signal strength of routers in vicinty
   # requires iw
   printLn("\n\nVicinity routers sorted by strength , strongest on top",yellowgreen)
   echo()
   let (outp,errc) = execCmdEx("""sudo iw dev $1 scan | egrep "signal|SSID" | sed -e "s/\tsignal: //" -e "s/\tSSID: //" | awk '{ORS = (NR % 2 == 0)? "\n" : " "; print}' | sort"""  % wifiinterface)
   if errc == 0:
      echo outp
   else:
        printLn("iw returned errorcode : " & $errc & " for interface : " & wifiinterface,red)


# run the scans

var z = ""      
try:
  z = paramStr(1)
except IndexError:
  z = "wlp6s0"
scan(z)
signalStrength(z)

doFinish()
