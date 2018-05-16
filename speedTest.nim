import nimcx,httpclient

var client = newHttpClient()
var url = "http://speedtest-ams2.digitalocean.com/100mb.test"
var slowspeed:BiggestInt = 10000
var maxspeed:BiggestInt = 0
var sumcurspeed:BiggestInt = 0
var c:BiggestInt = 0
printLn(url,salmon)
echo()

proc onProgressChanged(total, progress, speed: BiggestInt)  =
  var curspeed : BiggestInt = speed div 1000
  printLnBiCol(cleareol & "Downloaded   : " & ff2(progress) & " of " & ff2(total))
  printLnBiCol(cleareol & "Current rate : " & ff2(curspeed) & "kb/s")
  if curspeed < slowspeed: slowspeed  = curspeed
  if curspeed > maxspeed : maxspeed  = curspeed
  printLnBiCol(cleareol & "Slowest rate : " & ff2(slowspeed) & "kb/s")
  printLnBiCol(cleareol & "Fastest rate : " & ff2(maxspeed) & "kb/s")
  sumcurspeed = sumcurspeed + curspeed
  inc c
  printLnBiCol(cleareol & "Avg. rate    : " & ff2(sumcurspeed div c) & "kb/s")
  curup(5)  
  
proc main()  =  
   client.onProgressChanged = onProgressChanged
   discard client.getContent(url)
   
   
main()
curdn(8)
doFinish()
