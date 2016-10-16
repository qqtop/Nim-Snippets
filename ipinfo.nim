import cx,osproc

var z = tupletostr(execCmdEx("ip route | grep src"))
var zz = z.split("src")
var zzz = zz[1].split(", 0")  # keep space after comma  !!

println("IP Info",salmon,styled={styleunderScore})
echo()
printlnBiCol("Current Local Ip:" & zzz[0])
showWanIP()

doFinish()