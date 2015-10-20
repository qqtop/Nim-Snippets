
## testing for private.nim printLn and echo ... procs 


import private,strfmt,strutils,times


superHeader("Testing var. print and echo procs from private.nim ")
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

# note every item will be tokenized so we need more colors than strings passed in
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
printStyled("123423456576782312345","23",lightseagreen,{stylereverse})
echo()
printLnStyled("The dog blinks . ","dog",rosybrown,{styleUnderScore,styleBlink})


# compare usage to achieve same output
# difference between print and cecho procs is that cecho accepts varargs too
                            
cecho(salmon,"Everyone and the cat likes fresh salmon. ")
cecho(steelblue,"The dog disagrees here. ")
cechoLn(greenyellow,"Cannot please everyone. ",pastelpink,"I think . ")

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

msgblb() do : dline()
printLn(repeat("✈",tw),yellowgreen)

msgblb() do : dline()
decho(2)


#### sierpcarpet small refreshed snippet I lifted from somewhere

proc `^`*(base: int, exp: int): int =
  var (base, exp) = (base, exp)
  result = 1
 
  while exp != 0:
    if (exp and 1) != 0:
      result *= base
    exp = exp shr 1
    base *= base
 
proc inCarpet(x, y): bool =
  var x = x
  var y = y
  while true:
    if x == 0 or y == 0:
      return true
    if x mod 3 == 1 and y mod 3 == 1:
      return false
 
    x = x div 3
    y = y div 3
 
proc carpet(n) =
  for i in 0 .. <(3^n):
    for j in 0 .. <(3^n):
      if inCarpet(i, j):
        print("* ",clrainbow)
      else:
        printStyled("  ","",goldenrod,{stylereverse})
    echo ""

echo() 
superHeader("Sierp Carpet in Multi Color - Sierp Carpet in Multi Color",clrainbow,lightsteelblue)
echo()
carpet(3)

decho(3)


printSlimNumber($getClockStr(),white,green,xpos=18)
decho(5)

printBigNumber($getClockStr(),fgr=salmon,xpos=10)
decho(5)

superHeader("Nim Colors ")
# show a full list of colorNames availabale
showColors()

decho(2)

var twc = tw div 2
printLnBiCol("Terminalwidth   : " & $tw,":")
printLnBiCol("Terminal Center : " & $twc,":")
hline(twc,yellowgreen)
printStyled("✈","",brightyellow,{styleBlink})
hlineln(twc-1,salmon)



doFinish()
