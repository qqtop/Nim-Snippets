import nimcx

## Get the latest news headlines from The Guardian in your terminal
## API key required available free at : http://open-platform.theguardian.com/explore/
   
let apikey  = ""    # <<------  put guardian apikey here
if apikey == "":
    printLn(" Hello ! API KEY required ...")
    printLnBiCol(" API key available free at : http://open-platform.theguardian.com/explore/")
    doFinish()

let baseurl = "http://content.guardianapis.com/search?api-key=$1" % apikey

let zcli = newHttpClient(timeout = 1000)

printLn("The Guardian - " & cxnow(),truetomato,styled={styleUnderscore})
echo()
var res1 = parseJson(zcli.getContent(url = baseurl))
var c = 0
for res2 in res1.mpairs():
    for x in res2.val.mpairs():              
        if $x.key == "results":
           for rr in x.val.items():
             inc c
             echo()
             printLn($rr["sectionName"],peru)
             printLn(toRunes($rr["webTitle"]),yellowGreen)
             printLn($rr["webUrl"],pastelyellow)
             hlineln(tw - 5)
             
    decho(2)         
    printLn("Latest " & $c & " items from The Guardian via API - " & cxnow(),truetomato)

doFinish()                        
