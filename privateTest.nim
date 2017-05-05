
## privateTest.nim
## 
## rough testing for private.nim 
## 
## best run in a large console window


import private,privateDemo,strfmt,strutils,sequtils,times,random

superHeader("Testing print and echo procs from private.nim and run demos")

var s = "Test color string"
var n = 1234567
var f = 123.4567
var l = @[1234,4567,654]


# background colors for print and println are standard terminal colors
# to use other colors use printStyled or printLnStyled
printLn(s,white,brightblack)
printLn(n,white,red)
printLn(f,white,blue)
printLnStyled(l,$l,steelblue,{stylereverse})
printLnStyled(f,$f,rosybrown,{stylereverse})

decho(2)

printLn(s,lime)
printLn(n,brightgreen)
printLn(f,greenyellow)
printLn(l,rosybrown)
decho(2)

printLnRainbow(s,{})
printLnRainbow(n,{})
printLnRainbow(f,{})
printLnrainbow(l,{styleUnderscore})
decho(2)

printLnTK(s)
printLnTK(s,green,brightred,blue)
decho(1)

printColStr(green,s)
decho(1)

printLnStyled(s,"t",clrainbow,{styleUnderScore,styleBlink})
decho(2)

printLnBiCol(s,"c",brightgreen,brightwhite)
printLnBiCol(s,"c")  # default colors
decho(2)

# note : every item will be tokenized so we need more colors than strings passed in
printLnTK("{} {} {} {}".fmt(s,n,f,l),brightgreen,brightcyan,brightyellow,brightmagenta,clrainbow,brightblue,brightred)

printLnTK(s & " wuff",steelblue,brightgreen,clrainbow,yellow)  

# all in one color
printLn("{} {} {} {}".fmt(s,n,f,l),greenyellow)      
# all in one color with new background 
printLn("{} {} {} {}".fmt(s,n,f,l),brightyellow,brightblue)

printLn(s,clrainbow,brightyellow)  
printLn(s,lime)
decho(1)

printLn(s,black,brightmagenta)
printLn(s &  " ---> this is white")


printLnStyled("Everyone and the cat likes fresh salmon.","the cat",yellowgreen,{styleUnderScore})
decho(2)
printStyled("123423456576782312345","23",lightseagreen,{stylereverse})
echo()
printLnStyled("The dog blinks . ","dog",rosybrown,{styleUnderScore,styleBlink})


# compare usage to achieve same output
# difference between print and cecho procs is that cecho accepts varargs too
                            
cecho(salmon,"Everyone and the cat likes fresh salmon. ")
cecho(steelblue,"The dog disagrees here. ")
cechoLn(greenyellow,"Cannot please everyone. ",pastelpink,"Indeed !")

# the system echo works too but needs color reset at the end, styleConstants also do not work
# similar to the just introduced styledwrite and resetStyle 
echo(salmon,"Everyone and the cat likes fresh salmon. ",steelblue,"The dog disagrees here. ",greenyellow,"Cannot please everyone.",termwhite,"")

echo(pastelpink,"Yippie ",lightblue,"Wow!",termwhite,"")
echo()

echo(pastelblue," ",int.high)
echo(pastelgreen,int.low)
dlineLn(21,col = lime)
echo(pastelyellow,int.high + abs(int.low))
echo()

print("Everyone and the cat likes fresh salmon. ",salmon)
print("The dog disagrees here. ",steelblue)
printLn("Cannot please everyone.",greenyellow)

decho(2)

dline() # white dashed line
printLn(repeat("✈",tw),yellowgreen)
dline(60,lt = "/+",truetomato) 
printLn("  -->  truetomato",truetomato)
decho(2)

echo() 
superHeader("Sierp Carpet in Multi Color - Sierp Carpet in Multi Color",clrainbow,lightsteelblue)
echo()
sierpCarpetDemo(3)

decho(3)


printSlimNumber($getClockStr() & "  ",pastelpink,black,xpos=25)
decho(5)

printBigNumber($getClockStr(),fgr=salmon,xpos=10)
decho(5)

superHeader("Nim Colors ")
# show a full list of colorNames availabale
showColors()
decho(2)

cleanScreen()
for x in 0.. 10:
    centerMark()
    echo()
    sleepy(0.1)

flyNimDemo()

futureIsNimDemo(25)

decho(3)
ndLineDemo()
decho(2)
sleepy(3.5)
   
movNimDemo()   

clearUp(18)
curSet()
drawRectDemo()
decho(5)  
sleepy(3)

decho(3)
randomCardsClockDemo() 

decho(2)

# testing emojis

printLn(heart & " Nim " & heart,red)    
print(smile,randcol())  
print(copyright,randcol())
print(trademark,randcol())  
print(roof,lime)
print(snowflake,randcol())  
print(music,lime)
print(xmark,randcol())  
print(check,randcol())
print(scissors,randcol())  
print(darkstar,randcol())
print(star,randcol())  
print(umbrella,randcol())
print(flag,randcol())  
print(skull,randcol())
print(heart,red)  

println(sun,randcol())
print(innocent,randcol())
print(lol,randcol())
print(smiley,randcol())
print(tongue,randcol())
print(blush,randcol())
print(sad,randcol())
print(cry,randcol())
print(rage,randcol())
print(cat,randcol())
print(kitty,randcol())
print(monkey,randcol())
printLn(cow,randcol())

happyemojis()
sleepy(2)


proc printNimSxR*(col:string = yellowgreen, xpos: int = 1) = 
   ## printNimSx
   ## 
   ## prints large Nim
   ## 
   ## 
  
   var maxpos = tw - nimsx[0].len + 20
   for x in nimsx :
        if xpos <= maxpos  :
            print(repeat(" ",xpos) & x,randcol())
        else:    
            print(repeat(" ",maxpos) & x,randcol())
            

for x in 0 .. 10:
   cleanscreen()
   curset()
   decho(toSeq(1.. th - 8).randomchoice())
   printNimsxR(randcol(),xpos = toSeq(0.. tw - 20).randomchoice())
   sleepy(1)
   curup(6)



decho(2)
var twc = tw div 2
showTerminalSize()
printLnBiCol("Terminal Center : " & $twc,":")

doFinish()
