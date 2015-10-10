import private

superHeader("Testing var. printLn procs ")
var s = "Test color string"
var n = 1234567
var f = 123.4567
var l = @[1234,4567,654]

printLnBR(s,fgWhite,bgBlack)
printLnBR(n,fgWhite,bgBlack)
printLnBR(f,fgWhite,bgBlack)
printLnBR(l,fgWhite,bgBlack)
decho(2)

printLnBB(s,fgBlue,bgWhite)
printLnBB(n,fgWhite,bgRed)
printLnBB(f,fgWhite,bgBlack)
printLnBB(l,fgWhite,bgBlack)
decho(2)

printLnBF(s,fgBlue,bgWhite)
printLnBF(n,fgWhite,bgBlack)
printLnBF(f,fgWhite,bgBlack)
printLnBF(l,fgWhite,bgBlack)
decho(2)

printLnG(s)
printLnGb(n)
printLnC(f)
printLnCb(l)
decho(2)

printLnRainbow(s,{})
printLnRainbow(n,{})
printLnRainbow(f,{})
printLnrainbow(l,{styleUnderscore})
decho(2)

printLn(s)
printLn(s,green,brightred,blue)
decho(2)
printColStr(green,s)
decho(2)
printLnStyled(s,"t",clrainbow,{styleUnderScore,styleBlink})
decho(2)
printLnBiCol(s,"c",brightgreen,brightwhite)

doFinish()
