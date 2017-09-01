
# BASED ON : https://github.com/undecided/gingerbread-man/blob/master/dance.rb
# Here after some spruce up in Nim

import nimcx
import asyncdispatch,net


let  arms = @[" /|\\ ", "--|--", " \\|/ ", " |/ ", "  \\|", "  // ", " \\\\ ", ]
let  legs = @[" / \\ ", "-- --", " | | "]


var am =  createSeqInt(50,0,6)
var lg =  createSeqInt(50,0,2)
var wd =  createSeqInt(200,1,tw - 5)

proc random_legs(): int = 
    var x = -1 
    while (x < 0 == true) or (x > 2 == true):
      x = getrndint(0,2)
      
    result = x
    
proc random_arms(): int = 
    var x = -1 
    while (x < 0 == true) or (x > 6 == true):
      x = getrndint(0,6)
    result = 2     

proc head():string =   "  O  "
  

proc abdomen():string =   "  |  "
  

proc dance() =
    
    decho(3)
    var a = random_arms()
    var l = random_legs()
   
    var xpos = getrndint(1,tw - 5)
    printLn(head(),fgr = randcol(),xpos = xpos)
    printLn(arms[a],fgr = randcol(),xpos = xpos)
    printLn(abdomen(),fgr = randcol(),xpos = xpos)
    printLn(legs[l],fgr = randcol(),xpos = xpos)
 
proc main() {.async.} = 
  while true :
        clearup()
        for x in 0.. 5:
          dance()
          curset()
        var c = 0
        for x in countup(6,th - 7,6):
            inc c
            curdn(c + 9)  
            for y in 0.. 15:
              dance()
              curset()      
          
        sleepy(0.18)  
      
asyncCheck main()

while true:
    try:
      runForever()
    except:
       printLn("Error occured : ",red)
       printLn(getCurrentExceptionMsg(),red)
       printLn("Trying to restart loop",peru)

curdn(th - 8)
