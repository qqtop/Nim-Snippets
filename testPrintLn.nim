
## testing for private.nim printLn... procs 


import private,strfmt


superHeader("Testing var. printLn procs ")
var s = "Test color string"
var n = 1234567
var f = 123.4567
var l = @[1234,4567,654]

printLn(s,white,brightblack)
printLn(n,white,brightblack)
printLn(f,white,brightblack)
printLn(l,white,brightblack)
decho(2)

printLn(s,lime)
printLn(n,brightgreen)
printLn(f,chartreuse)
printLn(l,rosybrown)
decho(2)

printLnRainbow(s,{})
printLnRainbow(n,{})
printLnRainbow(f,{})
printLnrainbow(l,{styleUnderscore})
decho(2)

printLnTK(s)
printLnTK(s,green,brightred,blue)
decho(2)
printColStr(green,s)
decho(2)
printLnStyled(s,"t",clrainbow,{styleUnderScore,styleBlink})
decho(2)
printLnBiCol(s,"c",brightgreen,brightwhite)
decho 2

# note every item will be tokenized so we need more colors than strings passed in
printLnTK("{} {} {} {}".fmt(s,n,f,l),brightgreen,brightcyan,brightyellow,brightmagenta,clrainbow,brightblue,brightred)
# all in one color
printLn("{} {} {} {}".fmt(s,n,f,l),greenyellow)      
# all in one color with new background, note printLn,printLnBB,printLnBF need terminal color constants
printLn("{} {} {} {}".fmt(s,n,f,l),brightyellow,brightblue)

printLnTK(s & " wuff",black,brightgreen,clrainbow,yellow)  


printLn(s,clrainbow,brightyellow)  


printLn(s,lime)
decho(1)
printLn(s,black,brightmagenta)
printLn(s)

# even echo works with color

echo(lightsalmon,"Yippie",lightblue,"Wow!",termwhite)



doFinish()
