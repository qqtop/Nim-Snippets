
## testing for private.nim printLn and echo ... procs 


import private,strfmt


superHeader("Testing var. print and echo procs from private.nim ")
var s = "Test color string"
var n = 1234567
var f = 123.4567
var l = @[1234,4567,654]


# background colors for print and println are standard terminal colors
# to use other colors use printStyled or printLnStyled
printLn(s,white,brightblack)
printLn(n,white,brightblack)
printLn(f,white,brightblack)
printLn(l,white,green)
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
# diffrence between print and cecho procs is that cecho accepts varargs too
                            
cecho(salmon,"Everyone and the cat likes fresh salmon. ")
cecho(steelblue,"The dog disagrees here. ")
cechoLn(greenyellow,"Cannot please everyone.")

# the system echo works too but needs color reset at the end, styleConstants also do not work
echo(salmon,"Everyone and the cat likes fresh salmon. ",steelblue,"The dog disagrees here. ",greenyellow,"Cannot please everyone.",termwhite,"")

echo(pastelpink,"Yippie ",lightblue,"Wow!",termwhite,"")
echo(pastelblue,int.high)
echo(pastelgreen,int.low)
echo(pastelyellow,int.high + abs(int.low))
print("Everyone and the cat likes fresh salmon. ",salmon)
print("The dog disagrees here. ",steelblue)
printLn("Cannot please everyone.",greenyellow)



# show a full list of colorNames availabale
showColors()


doFinish()
