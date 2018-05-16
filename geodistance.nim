import nimcx

# geodistance.nim
# 
# haversine great circle distance formular in nim
# 
# distanceTo is implemented in cxutils.nim
# 
# 2018-05-16
# 
        
        
hlineln()        
echo "Haversine Great Circle Formular with Earth Radius : 6371.0 km"        
echo "expect best +/- 0.5% from actual distance " 
hlineln()
echo()
echo "Examples "
decho(2)
echo "Oslo - Vancouver"
echo distanceto((10.738741, 59.913818),(-123.138565,49.263588)) , " km"   
echo distanceto((10.738741, 59.913818),(-123.138565,49.263588)) / 1.609345 ," miles"
decho(2)

echo "Oslo - Madrid"
echo distanceto((10.738741, 59.913818),(-3.700345,40.41669)) , " km"
echo distanceto((10.738741, 59.913818),(-3.700345,40.41669)) / 1.609345 ," miles"
decho(2)

echo "Hongkong - London"
echo distanceto((114.109497,22.396427),(-0.126236,51.500153)) , " km"
echo distanceto((114.109497,22.396427),(-0.126236,51.500153)) / 1.609345 ," miles"
decho(2)
hlineln()
decho(2)
# we also allow input from commandline if blank just using some default Oslo-Vancouver data

var origin    = readLineFromStdin("Origin      eg Oslo        : ")
if origin == "": origin = "Oslo"
var originlon = readLineFromStdin("Longitude   eg 10.738741   : ") 
if originlon == "": originlon = "10.738741"
var originlat = readLineFromStdin("Latitude    eg 59.913818   : ")
if originlat == "": originlat = "59.913818"

var dest    = readLineFromStdin("Destination eg Vancouver   : ")
if dest == "" : dest = "Vancouver"
var destlon = readLineFromStdin("Longitude   eg -123.138565 : ") 
if destlon == "" : destlon = "-123.138565"
var destlat = readLineFromStdin("Latitude    eg 49.263588   : ")
if destlat == "" : destlat = "49.263588"
decho(2)
printLnBicol(&"Great Circle Distance    : {origin} - {dest}")
printlnbicol("                   km    : " & $distanceto((parseFloat(originlon),parseFloat(originlat)),(parseFloat(destlon),parsefloat(destlat))))
printlnbicol("                miles    : " & $(distanceto((parseFloat(originlon),parseFloat(originlat)),(parseFloat(destlon),parsefloat(destlat))) / 1.609345))
doFinish()
