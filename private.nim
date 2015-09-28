{.deadCodeElim: on.}
##
##   Library     : private.nim
##
##   Status      : stable
##
##   License     : MIT opensource
##
##   Version     : 0.8.5
##
##   ProjectStart: 2015-06-20
##
##   Compiler    : Nim 0.11.3 dev
##   
##   OS          : Linux
##
##   Description : private.nim is a public library with a collection of procs and templates
##
##                 for colored display , date handling and more
##
##                 some procs may mirror functionality found in other moduls for convenience
##                 
##   Usage       : import private              
##
##   Project     : https://github.com/qqtop/Nim-Snippets
##
##   Docs        : http://qqtop.github.io/private.html
##
##   Tested      : on Ubuntu 14.04 , OpenSuse 13.2 , Mint 17  
##
##   Programming : qqTop
##
##   Note        : may be improved at any time
##
##   Required    : see imports for modules expected to be available
##   

import os,osproc,posix,terminal,math,unicode,times,tables,json,sets
import sequtils,parseutils,strutils,random,strfmt,httpclient,rawsockets,browsers

const PRIVATLIBVERSION* = "0.8.5"
const
       red*    = "red"
       green*  = "green"
       cyan*   = "cyan"
       yellow* = "yellow"
       white*  = "white"
       black*  = "black"
       brightred*    = "brightred"
       brightgreen*  = "brightgreen"
       brightcyan*   = "brightcyan"
       brightyellow* = "brightyellow"
       brightwhite*  = "brightwhite"
       clrainbow*    = "clrainbow"
         
type
     PStyle* = terminal.Style  ## make terminal style constants available in the calling prog

let start* = epochTime()  ##  check execution timing with one line see doFinish

converter toTwInt(x: cushort): int = result = int(x)

when defined(Linux):
    proc getTerminalWidth*() : int =
        ## getTerminalWidth
        ##
        ## utility to easily draw correctly sized lines on linux terminals
        ##
        ## and get linux terminal width
        ##
        
        type WinSize = object
          row, col, xpixel, ypixel: cushort
        const TIOCGWINSZ = 0x5413
        proc ioctl(fd: cint, request: culong, argp: pointer)
          {.importc, header: "<sys/ioctl.h>".}
        var size: WinSize
        ioctl(0, TIOCGWINSZ, addr size)
        result = toTwInt(size.col)

    var tw* = getTerminalWidth()   ## terminalwidth available in tw
    var aline* = repeat("_",tw)    ## echo aline 



proc printColStr*(colstr:string,astr:string)  ## forward declaration

# templates

template msgg*(code: stmt): stmt =
      ## msgX templates
      ## convenience templates for colored text output
      ## the assumption is that the terminal is white text and black background
      ## naming of the templates is like msg+color so msgy => yellow
      ## use like : msgg() do : echo "How nice, it's in green"

      setforegroundcolor(fgGreen)
      code
      setforegroundcolor(fgWhite)


template msggb*(code: stmt): stmt   =
      setforegroundcolor(fgGreen,true)
      code
      setforegroundcolor(fgWhite)


template msgy*(code: stmt): stmt =
      setforegroundcolor(fgYellow)
      code
      setforegroundcolor(fgWhite)


template msgyb*(code: stmt): stmt =
      setforegroundcolor(fgYellow,true)
      code
      setforegroundcolor(fgWhite)


template msgr*(code: stmt): stmt =
      setforegroundcolor(fgRed)
      code
      setforegroundcolor(fgWhite)


template msgrb*(code: stmt): stmt =
      setforegroundcolor(fgRed,true)
      code
      setforegroundcolor(fgWhite)

template msgc*(code: stmt): stmt =
      setforegroundcolor(fgCyan)
      code
      setforegroundcolor(fgWhite)

template msgcb*(code: stmt): stmt =
      setforegroundcolor(fgCyan,true)
      code
      setforegroundcolor(fgWhite)

template msgw*(code: stmt): stmt =
      setforegroundcolor(fgWhite)
      code
      setforegroundcolor(fgWhite)

template msgwb*(code: stmt): stmt =
      setforegroundcolor(fgWhite,true)
      code
      setforegroundcolor(fgWhite)

template msgb*(code: stmt): stmt =
      setforegroundcolor(fgBlack,true)
      code
      setforegroundcolor(fgWhite)
      
template msgbb*(code: stmt): stmt =
      # invisible on black background 
      setforegroundcolor(fgBlack)
      code
      setforegroundcolor(fgWhite)
  
template hdx*(code:stmt):stmt =
   echo ""
   echo repeat("+",tw)
   setforegroundcolor(fgCyan)
   code
   setforegroundcolor(fgWhite)
   echo repeat("+",tw)
   echo ""




template withFile*(f: expr, filename: string, mode: FileMode, body: stmt): stmt {.immediate.} =
     ## withFile
     ##
     ## file open close utility template
     ##
     ## Example 1
     ##
     ## .. code-block:: nim
     ##    let curFile="/data5/notes.txt"    # some file
     ##    withFile(txt, curFile, fmRead):
     ##        while 1 == 1:
     ##            try:
     ##               stdout.writeln(txt.readLine())   # do something with the lines
     ##            except:
     ##               break
     ##    echo()
     ##    msgg() do : rainbow("Finished")
     ##    echo()
     ##
     ##
     ## Example 2
     ##
     ## .. code-block:: nim
     ##    import private,strutils,strfmt
     ##
     ##    let curFile="/data5/notes.txt"
     ##    var lc = 0
     ##    var oc = 0
     ##    withFile(txt, curFile, fmRead):
     ##           while 1 == 1:
     ##               try:
     ##                  inc lc
     ##                  var al = $txt.readline()
     ##                  var sw = "the"   # find all lines containing : the
     ##                  if al.contains(sw) == true:
     ##                     inc oc
     ##                     msgy() do: write(stdout,"{:<8}{:>6} {:<7}{:>6}  ".fmt("Line :",lc,"Count :",oc))
     ##                     printhl(al,sw,green)
     ##                     echo()
     ##               except:
     ##                  break
     ##
     ##    echo()
     ##    msgg() do : rainbow("Finished")
     ##    echo()
     ##

     let fn = filename
     var f: File

     if open(f, fn, mode):
         try:
             body
         finally:
             close(f)
     else:
         let msg = "Cannot open file"
         echo ()
         msgy() do : echo "Processing file " & curFile & ", stopped . Reason: ", msg
         quit()


# output  horizontal lines

proc hline*(s:string = "_",n:int = tw,col:string = white) =
     ## hline
     ## 
     ## draw a line with variable line char and length no linefeed will be issued
     ## 
     ## defaults are "_" and full terminal width
     ## 
     ## .. code-block:: nim
     ##    hline("+",30,green)
     ##     
     for x in 0.. <n:
       printColStr(col,s)
     

proc dline*(n:int = tw) =
     ## dline
     ## 
     ## draw a line with given length in current terminal font color
     ## 
     echo repeat("-",n)
     
     

proc decho*(z:int)  =
    ## decho
    ##
    ## blank lines creator
    ##
    ## .. code-block:: nim
    ##    decho(10)
    ## to create 10 blank lines
    for x in 0.. <z:
      echo()


# simple navigation

proc curUp*(x:int = 1) =
     ## curUp
     ## 
     ## mirrors terminal cursorUp
     cursorUp(x)


proc curDn*(x:int = 1) = 
     ## curDn
     ##
     ## mirrors terminal cursorDown
     cursorDown(x)


proc clearup*(x:int = 80) =
   ## clearup
   ## 
   ## a convenience proc to clear monitor
   ##
   
   erasescreen()
   curup(x)

# Var. convenience procs for colorised data output
# these procs have similar functionality 

proc printLn*(s:string , cols: varargs[string, `$`]) =
     ## printLn
     ##
     ## displays colored strings and issues a newline when finished
     ## 
     ## strings will be tokenized and colored according to colors in cols
     ## 
     ## .. code-block:: nim
     ##    printLn(st,@[clrainbow,white,red,cyan,yellow])
     ##    printLn("{} {} {}  -->   {}".fmt(123,"Nice",456,768.5),green,white,red,cyan)
     ##    printLn("{} : {} {}  -->   {}".fmt(123,"Nice",456,768.5),green,brightwhite,clrainbow,red,cyan)
     ##    printLn("blah",green,white,red,cyan)    
     ##    # can also pass a seq
     ##    printLn("blah yep 1234      333122.12  [12,45] wahahahaha",@[green,brightred,black,yellow,cyan,clrainbow])
     ##
     var col = newSeq[string]()
     var c = 0
     for x in cols:
         col.add(x)
     var pcol = ""
         
     for x in s.tokenize() :
            if x.isSep == false:
                if c < cols.len:
                  pcol = col[c]
                else :
                  pcol = white   
                printColStr(pcol,x.token)
                c += 1  
              
            else:
                write(stdout,x.token)
     echo ""    



proc print*(s:string , cols: varargs[string, `$`] = @[white] ) =
     ## print
     ##
     ## similar to printLn
     ## 
     ## echoing of colored strings however without newline
     ## 
     ## strings will be tokenized and colored according to colors in cols
     ## 
     ## .. code-block:: nim
     ##    print(st,@[clrainbow,white,red,cyan,yellow])
     ##    print("{} {} {}  -->   {}".fmt(123,"Nice",456,768.5),green,white,red,cyan)
     ##    print("{} : {} {}  -->   {}".fmt(123,"Nice",456,768.5),green,brightwhite,clrainbow,red,cyan)
     ##    print("blah",green,white,red,cyan) 
     ##    # also can use a seq or colors
     ##    print("blah yep 1234      333122.12  [12,45] wahahahaha",@[green,brightred,black,yellow,cyan,clrainbow])
     ##
     var col = newSeq[string]()
     var c = 0
     for x in cols:
         col.add(x)
     var pcol = ""
         
     for x in s.tokenize() :
            if x.isSep == false:
                if c < cols.len:
                  pcol = col[c]
                else :
                  pcol = white   
                printColStr(pcol,x.token)
                c += 1  
              
            else:
                write(stdout,x.token)
       


proc printG*(s:string) = 
     ## printg
     ## 
     ## prints string in green 
     ## 
     ## 
     ## following single color print routines are avaialable
     ## 
     ## print<color>     ... prints string in said color no linefeed
     ## 
     ## print<color>b    ... prints string in said color bright no linefeed
     ## 
     ## printLn<color>   ... prints string in said color with linefeed
     ##
     ## printLn<color>b  ... prints string in said color bright with linefeed
     ##
     ## 
     ## colors :  g green, r red, y yellow, c  cyan, w  white, b black
     ## 
     ##           and bright types : types : gb,rb,yb,cb,wb 
     ##            
     ## 
     ## p<color> and pLn<color> routines complement the msgX templates
     ## 
     ## templates are more flexible as they also accept other code blocks
     ## 
     ## 
     ## .. code-block:: nim
     ##    var s = "color"
     ##    printLnG(s)
     ##    printLnGb(s)  
     ##    printLnR(s)  
     ##    printLnRb(s)
     ##    printLnC(s)
     ##    printLnCb(s)
     ##    printLnW(s)
     ##    printLnWb(s)
     ##    printLnB(s)
     ##    printLnY(s)
     ##    printLnYb(s)
     ##    
     ##    printB(s)
     ##    printG(s)
     ##    
     ##    
     ## .. code-block:: nim
     ##    import private,strutils,strfmt
     ##    printGb("{:<13}{}".fmt("abc : ","23e2323"))   
     ##    
     msgg() do: write(stdout,s)


proc printGb*(s:string) = 
     ## printGb
     ## 
     ## 
     msggb() do: write(stdout,s)


proc printLnG*(s:string) = 
     ## printLnG
     ## 
     ## prints a string in green and issues a newline
     ## 
     msgg() do: writeln(stdout,s)
     


proc printLnGb*(s:string) = 
     ## printLnGb
     ## 
     ## prints a string in bright green and issues a newline
     ## 
     msggb() do: writeln(stdout,s)
     


proc printR*(s:string) = 
     ## printR 
     ## 
     ## 
     msgr() do: write(stdout,s)


proc printRb*(s:string) = 
     ## printRb 
     ## 
     ## 
     msgrb() do: write(stdout,s)



proc printLnR*(s:string) = 
     ## printLnR
     ##
     ##
     msgr() do: writeln(stdout,s)  
     

proc printLnRb*(s:string) = 
     ## printLnRb
     ##
     ##
     msgrb() do: writeln(stdout,s)       
     
     

proc printY*(s:string) = 
     ## printY
     ## 
     ## 
     msgy() do: write(stdout,s)


proc printYb*(s:string) = 
     ## printY
     ## 
     ## 
     msgyb() do: write(stdout,s)


proc printLnY*(s:string) = 
     ## printLnY
     ## 
     ## 
     msgy() do: writeln(stdout,s)


proc printLnYb*(s:string) = 
     ## printLnYb
     ## 
     ## 
     msgyb() do: writeln(stdout,s)


     
proc printC*(s:string) = 
     ## printC
     ## 
     ## 
     msgc() do: write(stdout,s)


     
proc printCb*(s:string) = 
     ## printCb
     ## 
     ## 
     msgcb() do: write(stdout,s)

proc printLnC*(s:string) = 
     ## printLnC
     ## 
     ## 
     msgc() do: writeln(stdout,s)     

proc printLnCb*(s:string) = 
     ## printLnCb
     ## 
     ## 
     msgcb() do: writeln(stdout,s)


proc printW*(s:string) = 
     ## printW
     ## 
     ## 
     msgw() do: write(stdout,s)


proc printWb*(s:string) = 
     ## printWb
     ## 
     ## 
     msgwb() do: write(stdout,s)

proc printLnW*(s:string) = 
     ## printLnw
     ## 
     ## 
     msgw() do: writeln(stdout,s)     


proc printLnWb*(s:string) = 
     ## printLnWb
     ## 
     ## 
     msgwb() do: writeln(stdout,s)


proc printB*(s:string) = 
     ## printB
     ## 
     ## 
     msgb() do: write(stdout,s)


proc printLnB*(s:string) = 
     ## printLnB
     ## 
     ## 
     msgb() do: writeln(stdout,s)     


  
proc printBonG*(astring:string) =      
      ## printBonG
      ## 
      ## black foregroundcolor on green background
      ## 
      setBackGroundColor(bggreen)
      setforegroundcolor(fgBlack)
      write(stdout,astring)
      setforegroundcolor(fgWhite)
      setBackGroundColor(bgblack)
      
      
      
proc printLnBonG*(astring:string) =      
      ## printLnBonG
      ## 
      ## black foregroundcolor on green background with newline
      ## 
      setBackGroundColor(bggreen)
      setforegroundcolor(fgBlack)
      write(stdout,astring)
      setforegroundcolor(fgWhite)
      setBackGroundColor(bgblack)
      writeln(stdout,"")
   
   
proc printBonY*(astring:string) =      
      ## printBonY
      ## 
      ## black foregroundcolor on yellow background
      ## 
      setBackGroundColor(bgyellow)
      setforegroundcolor(fgBlack)
      write(stdout,astring)
      setforegroundcolor(fgWhite)
      setBackGroundColor(bgblack)
      
      
      
proc printLnBonY*(astring:string) =      
      ## printLnBonY
      ## 
      ## black foregroundcolor on yellow background with newline
      ## 
      setBackGroundColor(bgyellow)
      setforegroundcolor(fgBlack)
      write(stdout,astring)
      setforegroundcolor(fgWhite)
      setBackGroundColor(bgblack)
      writeln(stdout,"")
         
   
   
   
proc printBonR*(astring:string) =      
      ## printBonR
      ## 
      ## black foregroundcolor on red background
      ## 
      setBackGroundColor(bgred)
      setforegroundcolor(fgBlack)
      write(stdout,astring)
      setforegroundcolor(fgWhite)
      setBackGroundColor(bgblack)
      
      
      
proc printLnBonR*(astring:string) =      
      ## printLnBonR
      ## 
      ## black foregroundcolor on red background with newline
      ## 
      setBackGroundColor(bgred)
      setforegroundcolor(fgBlack)
      write(stdout,astring)
      setforegroundcolor(fgWhite)
      setBackGroundColor(bgblack)
      writeln(stdout,"")
         
      
   
proc printWonR*(astring:string) =      
      ## printWonR
      ## 
      ## white foregroundcolor on red background
      ## 
      setBackGroundColor(bgred)
      setforegroundcolor(fgWhite)
      write(stdout,astring)
      setforegroundcolor(fgWhite)
      setBackGroundColor(bgblack)
      
      
      
proc printLnWonR*(astring:string) =      
      ## printLnWonR
      ## 
      ## white foregroundcolor on red background with newline
      ## 
      setBackGroundColor(bgred)
      setforegroundcolor(fgWhite)
      write(stdout,astring)
      setforegroundcolor(fgWhite)
      setBackGroundColor(bgblack)
      writeln(stdout,"")
         
   
proc printWonB*(astring:string) =      
      ## printBonR
      ## 
      ## white foregroundcolor on black background
      ## 
      setBackGroundColor(bgwhite)
      setforegroundcolor(fgBlack)
      write(stdout,astring)
      setforegroundcolor(fgWhite)
      setBackGroundColor(bgblack)
      
      
      
proc printLnWonB*(astring:string) =      
      ## printLnWonB
      ## 
      ## white foregroundcolor on red background with newline
      ## 
      setBackGroundColor(bgwhite)
      setforegroundcolor(fgBlack)
      write(stdout,astring)
      setforegroundcolor(fgWhite)
      setBackGroundColor(bgblack)
      writeln(stdout,"")
         

proc rainbow*(astr : string) =
    ## rainbow
    ##
    ## multicolored string
    ##
    ## may not work with certain Rune
    ##

    var c = 0
    var a = toSeq(1.. 12)
    for x in 0.. <astr.len:
       c = a[randomInt(a.len)]
       case c
        of 1  : msgg() do  : write(stdout,astr[x])
        of 2  : msgr() do  : write(stdout,astr[x])
        of 3  : msgc() do  : write(stdout,astr[x])
        of 4  : msgy() do  : write(stdout,astr[x])
        of 5  : msggb() do : write(stdout,astr[x])
        of 6  : msgr() do  : write(stdout,astr[x])
        of 7  : msgwb() do : write(stdout,astr[x])
        of 8  : msgc() do  : write(stdout,astr[x])
        of 9  : msgyb() do : write(stdout,astr[x])
        of 10 : msgrb() do : write(stdout,astr[x])
        of 11 : msgcb() do : write(stdout,astr[x])
        else  : msgw() do  : write(stdout,astr[x])


proc printRainbow*(astr : string,astyle:set[Style]) =
    ## printRainbow
    ##
    ## print multicolored string with styles , for available styles see printStyled
    ##
    ## may not work with certain Rune
    ##
    ## .. code-block:: nim
    ##    printRainBow("WoW So Nice",{styleUnderScore})
    ##    printRainBow("  --> No Style",{}) 
    ##

    var c = 0
    var a = toSeq(1.. 12)
    for x in 0.. <astr.len:
       c = a[randomInt(a.len)]
       case c
        of 1  : msgg() do  : writestyled($astr[x],astyle)
        of 2  : msgr() do  : writestyled($astr[x],astyle)
        of 3  : msgc() do  : writestyled($astr[x],astyle)
        of 4  : msgy() do  : writestyled($astr[x],astyle)
        of 5  : msggb() do : writestyled($astr[x],astyle)
        of 6  : msgr() do  : writestyled($astr[x],astyle)
        of 7  : msgwb() do : writestyled($astr[x],astyle)
        of 8  : msgc() do  : writestyled($astr[x],astyle)
        of 9  : msgyb() do : writestyled($astr[x],astyle)
        of 10 : msgrb() do : writestyled($astr[x],astyle)
        of 11 : msgcb() do : writestyled($astr[x],astyle)
        else  : msgw() do  : writestyled($astr[x],astyle)



proc printLnRainbow*(astr : string,astyle:set[Style]) =
    ## printLnRainbow
    ##
    ## print multicolored string with styles , for available styles see printStyled
    ## 
    ## and issues a new line
    ##
    ## may not work with certain Rune
    ##
    ## .. code-block:: nim
    ##    printLnRainBow("WoW So Nice",{styleUnderScore})
    ##    printLnRainBow("Aha --> No Style",{}) 
    ##

    var c = 0
    var a = toSeq(1.. 12)
    for x in 0.. <astr.len:
       c = a[randomInt(a.len)]
       case c
        of 1  : msgg() do  : writestyled($astr[x],astyle)
        of 2  : msgr() do  : writestyled($astr[x],astyle)
        of 3  : msgc() do  : writestyled($astr[x],astyle)
        of 4  : msgy() do  : writestyled($astr[x],astyle)
        of 5  : msggb() do : writestyled($astr[x],astyle)
        of 6  : msgr() do  : writestyled($astr[x],astyle)
        of 7  : msgwb() do : writestyled($astr[x],astyle)
        of 8  : msgc() do  : writestyled($astr[x],astyle)
        of 9  : msgyb() do : writestyled($astr[x],astyle)
        of 10 : msgrb() do : writestyled($astr[x],astyle)
        of 11 : msgcb() do : writestyled($astr[x],astyle)
        else  : msgw() do  : writestyled($astr[x],astyle)
    echo()
    
    



proc printColStr*(colstr:string,astr:string) =
      ## printColStr
      ##
      ## prints a string with a named color in colstr
      ##
      ## colors : green,red,cyan,yellow,white,black
      ##
      ##          brightgreen,brightred,brightcyan,brightyellow,brightwhite
      ##
      ## .. code-block:: nim
      ##    printColStr(green,"Nice, it is in green !")
      ##

      case colstr
      of green  : msgg() do  : write(stdout,astr)
      of red    : msgr() do  : write(stdout,astr)
      of cyan   : msgc() do  : write(stdout,astr)
      of yellow : msgy() do  : write(stdout,astr)
      of white  : msgw() do  : write(stdout,astr)
      of black  : msgb() do  : write(stdout,astr)
      of brightgreen : msggb() do : write(stdout,astr)
      of brightwhite : msgwb() do : write(stdout,astr)
      of brightyellow: msgyb() do : write(stdout,astr)
      of brightcyan  : msgcb() do : write(stdout,astr)
      of brightred   : msgrb() do : write(stdout,astr)
      of clrainbow   : rainbow(astr)
      else  : msgw() do  : write(stdout,astr)


proc printLnColStr*(colstr:string,mvastr: varargs[string, `$`]) =
    ## printLnColStr
    ##
    ## similar to printColStr but issues a echo() command that is
    ##
    ## every item will be shown on a new line in the same given color
    ##
    ## and most everything passed in will be converted to string
    ##
    ## .. code-block:: nim
    ##    printLnColStr green,"Nice try 1", 2.52234, @[4, 5, 6]
    ##

    for vastr in mvastr:
      case colstr
      of green  : msgg() do  : writeln(stdout,vastr)
      of red    : msgr() do  : writeln(stdout,vastr)
      of cyan   : msgc() do  : writeln(stdout,vastr)
      of yellow : msgy() do  : writeln(stdout,vastr)
      of white  : msgw() do  : writeln(stdout,vastr)
      of black  : msgb() do  : writeln(stdout,vastr)
      of brightgreen : msggb() do  : writeln(stdout,vastr)
      of brightwhite : msgwb() do  : writeln(stdout,vastr)
      of brightyellow: msgyb() do  : writeln(stdout,vastr)
      of brightcyan  : msgcb() do  : writeln(stdout,vastr)
      of brightred   : msgrb() do  : writeln(stdout,vastr)
      of clrainbow   :
                       rainbow(vastr)
                       echo()
      else  : msgw() do  : writeln(stdout,vastr)



proc printBiCol*(s:string,sep:string,colLeft:string = "yellow" ,colRight:string = "white") =
     ## printBiCol
     ##
     ## echos a line in 2 colors based on a seperators first occurance
     ## 
     ## .. code-block:: nim
     ##    for x  in 0.. <3:     
     ##       # here use default colors for left and right side of the seperator     
     ##       printBiCol("Test $1  : Ok this was $1 : what" % $x,":")
     ##
     ##    for x  in 4.. <6:     
     ##        # here we change the default colors
     ##        printBiCol("Test $1  : Ok this was $1 : what" % $x,":",cyan,red) 
     ##
     ##    # following requires strfmt module
     ##    printBiCol("{} : {}     {}".fmt("Good Idea","Number",50),":",yellow,green)  
     ##
     ##
     var z = s.split(sep)
     # in case sep occures multiple time we only consider the first one
     if z.len > 2:
       for x in 2.. <z.len:
          z[1] = z[1] & sep & z[x]
     
     printColStr(colLeft,z[0] & sep)
     printColStr(colRight,z[1])  
     


proc printLnBiCol*(s:string,sep:string,colLeft:string = "yellow" ,colRight:string = "white") =
     ## printLnBiCol
     ##
     ## same as printBiCol but issues a new line
     ## 
     ## .. code-block:: nim
     ##    for x  in 0.. <3:     
     ##       # here use default colors for left and right side of the seperator     
     ##       printLnBiCol("Test $1  : Ok this was $1 : what" % $x,":")
     ##
     ##    for x  in 4.. <6:     
     ##        # here we change the default colors
     ##        printLnBiCol("Test $1  : Ok this was $1 : what" % $x,":",cyan,red) 
     ##
     ##    # following requires strfmt module
     ##    printLnBiCol("{} : {}     {}".fmt("Good Idea","Number",50),":",yellow,green)  
     ##
     ##
     var z = s.split(sep)
     # in case sep occures multiple time we only consider the first one
     if z.len > 2:
       for x in 2.. <z.len:
          z[1] = z[1] & sep & z[x]
     
     printColStr(colLeft,z[0] & sep)
     printLnColStr(colRight,z[1])  
     

proc printHl*(s:string,substr:string,col:string) =
      ## printHl
      ##
      ## print and highlight all appearances of a char or substring of a string
      ##
      ## with a certain color
      ##
      ## .. code-block:: nim
      ##    printHl("HELLO THIS IS A TEST","T",green)
      ##
      ## this would highlight all T in green
      ##
      ## available colors : green,yellow,cyan,red,white,black,brightgreen,brightwhite
      ## 
      ##                    brightred,brightcyan,brightyellow,clrainbow
 
      var rx = s.split(substr)
      for x in rx.low.. rx.high:
          writestyled(rx[x],{})
          if x != rx.high:
              case col
              of green  : msgg() do  : write(stdout,substr)
              of red    : msgr() do  : write(stdout,substr)
              of cyan   : msgc() do  : write(stdout,substr)
              of yellow : msgy() do  : write(stdout,substr)
              of white  : msgw() do  : write(stdout,substr)
              of black  : msgb() do  : write(stdout,substr)
              of brightgreen : msggb() do : write(stdout,substr)
              of brightwhite : msgwb() do : write(stdout,substr)
              of brightyellow: msgyb() do : write(stdout,substr)
              of brightcyan  : msgcb() do : write(stdout,substr)
              of brightred   : msgrb() do : write(stdout,substr)
              of clrainbow   : rainbow(substr)
              else  : msgw() do  : write(stdout,substr)


proc printStyled*(s:string,substr:string,col:string,astyle : set[Style] ) =
      ## printStyled
      ##
      ## extended version of writestyled and printHl to allow color and styles
      ##
      ## to print and highlight all appearances of a substring of a string
      ##
      ## styles may and in some cases not have the desired effect
      ## 
      ## available styles :
      ## 
      ## styleBright = 1,            ## bright text
      ## styleDim,                   ## dim text
      ## styleUnknown,               ## unknown
      ## styleUnderscore = 4,        ## underscored text
      ## styleBlink,                 ## blinking/bold text
      ## styleReverse = 7,           ## unknown
      ## styleHidden                 ## hidden text
      ##
      ## with a certain color
      ##
      ## .. code-block:: nim
      ## 
      ##    # this highlights all T in green and underscore them
      ##    printStyled("HELLO THIS IS A TEST","T",green,{styleUnderScore})
      ##    
      ##    # this highlights all T in rainbow colors underscore and blink them
      ##    printStyled("HELLO THIS IS A TEST","T",clrainbow,{styleUnderScore,styleBlink})
      ##
      ##    # this highlights all T in rainbow colors , no style is applied
      ##    printStyled("HELLO THIS IS A TEST","T",clrainbow,{})
      ##    
      ##
      ## available colors : green,yellow,cyan,red,white,black,brightgreen,brightwhite
      ## 
      ##                    brightred,brightcyan,brightyellow,clrainbow
      ##                    
 
      var rx = s.split(substr)
      for x in rx.low.. rx.high:
          writestyled(rx[x],{})
          if x != rx.high:
              case col
              of green  : msgg() do  : writestyled(substr,astyle)
              of red    : msgr() do  : writestyled(substr,astyle)
              of cyan   : msgc() do  : writestyled(substr,astyle)
              of yellow : msgy() do  : writestyled(substr,astyle)
              of white  : msgw() do  : writestyled(substr,astyle)
              of black  : msgb() do  : writestyled(substr,astyle)
              of brightgreen : msggb() do : writestyled(substr,astyle)
              of brightwhite : msgwb() do : writestyled(substr,astyle)
              of brightyellow: msgyb() do : writestyled(substr,astyle)
              of brightcyan  : msgcb() do : writestyled(substr,astyle)
              of brightred   : msgrb() do : writestyled(substr,astyle)
              of clrainbow   : printRainbow(substr,astyle)
              else  : msgw() do  : writestyled(substr,{styleUnknown})


proc printTuple*(xs: tuple): string =
     ## printTuple
     ##
     ## tuple printer , returns a string
     ##
     ## code ex nim forum
     ##
     ## .. code-block:: nim
     ##    echo printTuple((1,2))         # prints (1, 2)
     ##    echo printTuple((3,4))         # prints (3, 4)
     ##    echo printTuple(("A","B","C")) # prints (A, B, C)

     result = "("
     for x in xs.fields:
       if result.len > 1:
           result.add(", ")
       result.add($x)
     result.add(")")


# Var. date and time handling procs mainly to provide convenice for
# date format yyyy-MM-dd handling

proc validdate*(adate:string):bool =
      ## validdate
      ##
      ## try to ensure correct dates of form yyyy-MM-dd
      ##
      ## correct : 2015-08-15
      ##
      ## wrong   : 2015-08-32 , 201508-15, 2015-13-10 etc.
      ##
      let m30 = @["04","06","09","11"]
      let m31 = @["01","03","05","07","08","10","12"]
      let xdate = parseInt(aDate.replace("-",""))
      # check 1 is our date between 1900 - 3000
      if xdate > 19000101 and xdate < 30001212:
          var spdate = aDate.split("-")
          if parseInt(spdate[0]) >= 1900 and parseInt(spdate[0]) <= 3000:
              if spdate[1] in m30:
                  #  day max 30
                  if parseInt(spdate[2]) > 0 and parseInt(spdate[2]) < 31:
                    result = true
                  else:
                    result = false

              elif spdate[1] in m31:
                  # day max 31
                  if parseInt(spdate[2]) > 0 and parseInt(spdate[2]) < 32:
                    result = true
                  else:
                    result = false

              else:
                    # so its february
                    if spdate[1] == "02" :
                        # check leapyear
                        if isleapyear(parseInt(spdate[0])) == true:
                            if parseInt(spdate[2]) > 0 and parseInt(spdate[2]) < 30:
                              result = true
                            else:
                              result = false
                        else:
                            if parseInt(spdate[2]) > 0 and parseInt(spdate[2]) < 29:
                              result = true
                            else:
                              result = false


proc day*(aDate:string) : string =
   ## day,month year extracts the relevant part from
   ##
   ## a date string of format yyyy-MM-dd
   ## 
   aDate.split("-")[2]

proc month*(aDate:string) : string =
    var asdm = $(parseInt(aDate.split("-")[1]))
    if len(asdm) < 2: asdm = "0" & asdm
    result = asdm


proc year*(aDate:string) : string = aDate.split("-")[0]
     ## Format yyyy


proc intervalsecs*(startDate,endDate:string) : float =
      ## interval procs returns time elapsed between two dates in secs,hours etc.
      #  since all interval routines call intervalsecs error message display also here
      #  
      if validdate(startDate) and validdate(endDate):
          var f     = "yyyy-MM-dd"
          var ssecs = toSeconds(timeinfototime(startDate.parse(f)))
          var esecs = toSeconds(timeinfototime(endDate.parse(f)))
          var isecs = esecs - ssecs
          result = isecs
      else:
          msgr() do : echo  "Date error. : " &  startDate,"/",endDate," incorrect date found."
          #result = -0.0

proc intervalmins*(startDate,endDate:string) : float =
           var imins = intervalsecs(startDate,endDate) / 60
           result = imins



proc intervalhours*(startDate,endDate:string) : float =
         var ihours = intervalsecs(startDate,endDate) / 3600
         result = ihours


proc intervaldays*(startDate,endDate:string) : float =
          var idays = intervalsecs(startDate,endDate) / 3600 / 24
          result = idays

proc intervalweeks*(startDate,endDate:string) : float =
          var iweeks = intervalsecs(startDate,endDate) / 3600 / 24 / 7
          result = iweeks


proc intervalmonths*(startDate,endDate:string) : float =
          var imonths = intervalsecs(startDate,endDate) / 3600 / 24 / 365  * 12
          result = imonths

proc intervalyears*(startDate,endDate:string) : float =
          var iyears = intervalsecs(startDate,endDate) / 3600 / 24 / 365
          result = iyears


proc compareDates*(startDate,endDate:string) : int =
     # dates must be in form yyyy-MM-dd
     # we want this to answer
     # s == e   ==> 0
     # s >= e   ==> 1
     # s <= e   ==> 2
     # -1 undefined , invalid s date
     # -2 undefined . invalid e and or s date
     if validdate(startDate) and validdate(enddate):
        var std = startDate.replace("-","")
        var edd = endDate.replace("-","")
        if std == edd:
          result = 0
        elif std >= edd:
          result = 1
        elif std <= edd:
          result = 2
        else:
          result = -1
     else:
          result = -2



proc sleepy*[T:float|int](s:T) =
    # s is in seconds
    let ss = epochtime()
    let ee = ss + s.float
    var c = 0
    while ee > epochtime():
        inc c
    # feedback line can be commented out
    #msgr() do : echo "Loops during waiting for ",s,"secs : ",c




proc dayOfWeekJulianA*(day, month, year: int): WeekDay =
  #
  # may be part of times.nim later
  # This is for the Julian calendar
  # Day & month start from one.
  # original code from coffeeshop 
  # but seems to be off for dates after 2100-03-01 which shud be a monday 
  # but it returned a tuesday .. 
  # 
  let
    a = (14 - month) div 12
    y = year - a
    m = month + (12*a) - 2
  var d  = (5 + day + y + (y div 4) + (31*m) div 12) mod 7
  # The value of d is 0 for a Sunday, 1 for a Monday, 2 for a Tuesday, etc. so we must correct
  # for the WeekDay type.
  result = d.WeekDay


proc dayOfWeekJulian*(datestr:string): string =
   ## dayOfWeekJulian 
   ##
   ## returns the day of the week of a date given in format yyyy-MM-dd as string
   ## 
   ## valid for dates up to 2099-12-31 
   ##
   ##
   if parseInt(year(datestr)) < 2100:
     let dw = dayofweekjulianA(parseInt(day(datestr)),parseInt(month(datestr)),parseInt(year(datestr))) 
     result = $dw
   else:
     result = "Not defined for years > 2099"
  

proc fx(nx:TimeInfo):string =
        result = nx.format("yyyy-MM-dd")


proc plusDays*(aDate:string,days:int):string =
   ## plusDays
   ##
   ## adds days to date string of format yyyy-MM-dd  or result of getDateStr()
   ##
   ## and returns a string of format yyyy-MM-dd
   ##
   ## the passed in date string must be a valid date or an error message will be returned
   ##
   if validdate(aDate) == true:
      var rxs = ""
      let tifo = parse(aDate,"yyyy-MM-dd") # this returns a TimeInfo type
      var myinterval = initInterval()   
      myinterval.days = days
      rxs = fx(tifo + myinterval)
      result = rxs
   else:
      msgr() do : echo "Date error : ",aDate
      result = "Error"

proc minusDays*(aDate:string,days:int):string =
   ## minusDays
   ##
   ## subtracts days from a date string of format yyyy-MM-dd  or result of getDateStr()
   ##
   ## and returns a string of format yyyy-MM-dd
   ##
   ## the passed in date string must be a valid date or an error message will be returned
   ##

   if validdate(aDate) == true:
      var rxs = ""
      let tifo = parse(aDate,"yyyy-MM-dd") # this returns a TimeInfo type
      var myinterval = initInterval()   
      myinterval.days = days
      rxs = fx(tifo - myinterval)
      result = rxs
   else:
      msgr() do : echo "Date error : ",aDate
      result = "Error"



proc getFirstMondayYear*(ayear:string):string = 
    ## getFirstMondayYear
    ## 
    ## returns date of first monday of any given year
    ## should be ok for the next years but after 2100-02-28 all bets are off
    ## 
    ## .. code-block:: nim
    ##    echo  getFirstMondayYear("2015")
    ##    
    ##    
  
    #var n:WeekDay
    for x in 1.. 8:
       var datestr= ayear & "-01-0" & $x
       if validdate(datestr) == true:
         var z = dayofweekjulian(datestr) 
         if z == "Monday":
             result = datestr
        


proc getFirstMondayYearMonth*(aym:string):string = 
    ## getFirstMondayYearMonth
    ## 
    ## returns date of first monday in given year and month
    ## 
    ## .. code-block:: nim
    ##    echo  getFirstMondayYearMonth("2015-12")
    ##    echo  getFirstMondayYearMonth("2015-06")
    ##    echo  getFirstMondayYearMonth("2015-2")
    ##    
    ## in case of invalid dates nil will be returned
    ## should be ok for the next years but after 2100-02-28 all bets are off
    
    #var n:WeekDay
    var amx = aym
    for x in 1.. 8:
       if aym.len < 7:
          let yr = year(amx) 
          let mo = month(aym)  # this also fixes wrong months
          amx = yr & "-" & mo 
       var datestr = amx & "-0" & $x
       if validdate(datestr) == true:
         var z = dayofweekjulian(datestr) 
         if z == "Monday":
            result = datestr
         


proc getNextMonday*(adate:string):string = 
    ## getNextMonday
    ## 
    ## .. code-block:: nim
    ##    echo  getNextMonday(getDateStr())
    ## 
    ## 
    ## .. code-block:: nim
    ##      import private
    ##      # get next 10 mondays
    ##      var dw = "2015-08-10"
    ##      for x in 1.. 10:
    ##          dw = getNextMonday(dw)
    ##          echo dw
    ## 
    ## 
    ## in case of invalid dates nil will be returned
    ## 

    #var n:WeekDay
    var ndatestr = ""
    if isNil(adate) == true :
        printLnR "Error received a date with value : nil"
        
    else:
        
        if validdate(adate) == true:  
            var z = dayofweekjulian(adate) 
            
            if z == "Monday":
              # so the datestr points to a monday we need to add a 
              # day to get the next one calculated
                ndatestr = plusDays(adate,1)
                
            else:
                ndatestr = adate 
                        
            for x in 0.. <7:
              if validdate(ndatestr) == true:
                z = dayofweekjulian(ndatestr) 
                
                if z.strip() != "Monday":
                    ndatestr = plusDays(ndatestr,1)  
                else:
                    result = ndatestr  


# Framed headers with var. colorising options

proc superHeader*(bstring:string) =
  ## superheader
  ##
  ## a framed header display routine
  ##
  ## suitable for one line headers , overlong lines will
  ##
  ## be cut to terminal window width without ceremony
  ##
  var astring = bstring
  # minimum default size that is string max len = 43 and
  # frame = 46
  let mmax = 43
  var mddl = 46
  ## max length = tw-2
  let okl = tw - 6
  let astrl = astring.len
  if astrl > okl :
     astring = astring[0.. okl]
     mddl = okl + 5
  elif astrl > mmax :
       mddl = astrl + 4
  else :
      # default or smaller
       let n = mmax - astrl
       for x in 0.. <n:
          astring = astring & " "
       mddl = mddl + 1

  let pdl = repeat("#",mddl)
  # now show it with the framing in yellow and text in white
  # really want a terminal color checker to avoid invisible lines
  echo ()
  msgy() do : writeln(stdout,pdl)
  msgy() do : write(stdout,"# ")
  msgw() do : write(stdout,astring)
  msgy() do : writeln(stdout," #")
  msgy() do : writeln(stdout,pdl)
  echo ()



proc superHeader*(bstring:string,strcol:string,frmcol:string) =
    ## superheader
    ##
    ## a framed header display routine
    ##
    ## suitable for one line headers , overlong lines will
    ##
    ## be cut to terminal window size without ceremony
    ##
    ## the color of the string can be selected, available colors
    ##
    ## green,red,cyan,white,yellow and for going completely bonkers the frame
    ##
    ## can be set to clrainbow too .
    ##
    ## .. code-block:: nim
    ##    import private
    ##
    ##    superheader("Ok That's it for Now !",clrainbow,white)
    ##    echo()
    ##
    var astring = bstring
    # minimum default size that is string max len = 43 and
    # frame = 46
    let mmax = 43
    var mddl = 46
    let okl = tw - 6
    let astrl = astring.len
    if astrl > okl :
       astring = astring[0.. okl]
       mddl = okl + 5
    elif astrl > mmax :
         mddl = astrl + 4
    else :
        # default or smaller
         let n = mmax - astrl
         for x in 0.. <n:
            astring = astring & " "
         mddl = mddl + 1

    let pdl = repeat("#",mddl)
    # now show it with the framing in yellow and text in white
    # really want to have a terminal color checker to avoid invisible lines
    echo ()

    # frame line
    proc frameline(pdl:string) =
        case frmcol
        of  green : msgg()  do : writestyled(pdl ,{})
        of  yellow: msgy()  do : writestyled(pdl ,{})
        of  cyan  : msgc()  do : writestyled(pdl ,{})
        of  red   : msgr()  do : writestyled(pdl ,{})
        of  white : msgwb() do : writestyled(pdl ,{})
        of  black : msgb()  do : writestyled(pdl ,{})
        of  clrainbow : rainbow(pdl)
        else: msgw() do : writestyled(pdl ,{})
        echo()

    proc framemarker(am:string) =
        case frmcol
        of  green : msgg()  do : writestyled(am ,{})
        of  yellow: msgy()  do : writestyled(am ,{})
        of  cyan  : msgc()  do : writestyled(am ,{})
        of  red   : msgr()  do : writestyled(am ,{})
        of  white : msgwb() do : writestyled(am ,{})
        of  black : msgb()  do : writestyled(am ,{})
        of  clrainbow : rainbow(am)
        else: msgy() do : writestyled(am ,{})

    proc headermessage(astring:string)  =
        case strcol
        of green  : msgg()  do : writestyled(astring ,{styleBright})
        of yellow : msgy()  do : writestyled(astring ,{styleBright})
        of cyan   : msgc()  do : writestyled(astring ,{styleBright})
        of red    : msgr()  do : writestyled(astring ,{styleBright})
        of white  : msgwb() do : writestyled(astring ,{styleBright})
        of black  : msgb()  do : writestyled(pdl ,{})
        of clrainbow : rainbow(astring)
        else: msgw() do : writestyled(astring ,{})

    # draw everything
    frameline(pdl)
    #left marker
    framemarker("# ")
    # header message sring
    headermessage(astring)
    # right marker
    framemarker(" #")
    # we need a new line
    echo()
    # bottom frame line
    frameline(pdl)
    # finished drawing


proc superHeaderA*(bb:string = "",strcol:string = white,frmcol:string = green,anim:bool = true,animcount:int = 1) =
  ## superHeaderA
  ##
  ## attempt of an animated superheader , some defaults are given
  ##
  ## parameters for animated superheaderA :
  ##
  ## headerstring, txt color, frame color, left/right animation : true/false ,animcount
  ##
  ## Example :
  ##
  ## .. code-block:: nim
  ##    import private
  ##    clearup()
  ##    let bb = "NIM the system language for the future, which extends to as far as you need !!"
  ##    superHeaderA(bb,white,red,true,3)
  ##    clearup(3)
  ##    superheader("Ok That's it for Now !",clrainbow,"b")
  ##    doFinish()
  
  for am in 0..<animcount:
      for x in 0.. <1:
        erasescreen()
        for zz in 0.. bb.len:
              erasescreen()
              superheader($bb[0.. zz],strcol,frmcol)
              sleepy(0.05)
              cursorup(80)
        if anim == true:
            for zz in countdown(bb.len,-1,1):
                  superheader($bb[0.. zz],strcol,frmcol)
                  sleepy(0.1)
                  clearup()
        else:
             clearup()
        sleepy(0.5)
        
  echo()


# Var. internet related procs

proc getWanIp*():string =
   ## getWanIp
   ##
   ## get your wan ip from heroku
   ##
   ## problems ? check : https://status.heroku.com/

   var z = "Wan Ip not established. "
   try:
      z = getContent("http://my-ip.heroku.com",timeout = 1000)
      z = z.replace(sub = "{",by = " ")
      z = z.replace(sub = "}",by = " ")
      z = z.replace(sub = "\"ip\":"," ")
      z = z.replace(sub = '"' ,' ')
      z = z.strip()
   except:
       printLnR("Check Heroku Status : https://status.heroku.com")
       try:
         opendefaultbrowser("https://status.heroku.com")
       except:
         discard
   result = z
   
   
proc showWanIp*() = 
     ## showWanIp
     ## 
     ## show your current wan ip
     ## 
     printBiCol("Current Wan Ip      : " & getwanip(),":",yellow,black)
         

proc getIpInfo*(ip:string):JsonNode =
     ## getIpInfo
     ##
     ## use ip-api.com free service limited to abt 250 requests/min
     ## 
     ## exceeding this you will need to unlock your wan ip manually at their site
     ## 
     ## the JsonNode is returned for further processing if needed
     ## 
     ## and can be queried like so
     ## 
     ## .. code-block:: nim
     ##   var jz = getIpInfo("208.80.152.201")
     ##   echo getfields(jz)
     ##   echo jz["city"].getstr
     ##
     ##
     if ip != "":
        result = parseJson(getContent("http://ip-api.com/json/" & ip))
        

proc showIpInfo*(ip:string) =
      ## showIpInfo
      ##
      ## Displays details for a given IP
      ## 
      ## Example:
      ## 
      ## .. code-block:: nim
      ##    showIpInfo("208.80.152.201")
      ##    showIpInfo(getHosts("bbc.com")[0])
      ## 
      let jz = getIpInfo(ip)
      decho(2)
      msgg() do: echo "Ip-Info for " & ip
      msgy() do: dline(40)
      for x in jz.getfields():
          echo "{:<15} : {}".fmt($x.key,$x.val)
      msgy() do : echo "{:<15} : {}".fmt("Source","ip-api.com")



proc getHosts*(dm:string):seq[string] =
    ## getHosts
    ## 
    ## returns IP addresses inside a seq[string] for a domain name and 
    ## 
    ## may resolve multiple IP pointing to same domain
    ## 
    ## .. code-block:: Nim
    ##    import private
    ##    var z = getHosts("bbc.co.uk")
    ##    for x in z:
    ##      echo x
    ##    doFinish()
    ## 
    ## 
    var rx = newSeq[string]()
    try:
      for i in getHostByName(dm).addrList:
        if i.len > 0:
          var s = ""
          var cc = 0  
          for c in i:
              if s != "": 
                  if cc == 3:
                    s.add(",")
                    cc = 0
                  else:
                    cc += 1
                    s.add('.')
              s.add($int(c))
          var ss =s.split(",")
          for x in 0.. <ss.len:
              rx.add(ss[x])
              #msgy() do: echo ss[x]
        else:
          rx = @[]
    except:     
           rx = @[]
    var rxs = rx.toSet # removes doubles
    rx = @[]
    for x in rxs:
        rx.add(x)
    result = rx


proc showHosts*(dm:string) = 
    ## showHosts 
    ## 
    ## displays IP addresses for a domain name and 
    ## 
    ## may resolve multiple IP pointing to same domain
    ## 
    ## .. code-block:: Nim
    ##    import private
    ##    showHosts("bbc.co.uk")  
    ##    doFinish()
    ## 
    ## 
    msgg() do: echo "Hosts Data for " & dm
    var z = getHosts(dm)
    if z.len < 1:
         msgr() do : echo "Nothing found or not resolved"
    else:
       for x in z:
         echo x


# Convenience procs for random data creation and handling


# init the MersenneTwister
var rng = initMersenneTwister(urandom(2500))


proc getRandomInt*(mi:int = 0,ma:int = 1_000_000_000):int =
    ## getRandomInt
    ##
    ## convenience proc so we do not need to import random
    ##
    ## in calling prog

    result = rng.randomInt(mi,ma + 1)


proc createSeqInt*(n:int = 10,mi:int=0,ma:int=1_000_000_000) : seq[int] =
    ## createSeqInt
    ##
    ## convenience proc to create a seq of random int with
    ##
    ## default length 10
    ##
    ## form @[4556,455,888,234,...] or similar
    ##
    ## .. code-block:: nim
    ##    # create a seq with 50 random integers ,of set 100 .. 2000
    ##    # including the limits 100 and 2000
    ##    echo createSeqInt(50,100,2000)

    var z = newSeq[int]()
    for x in 0.. <n:
       z.add(getRandomInt(mi,ma))
    result = z


proc getRandomFloat*():float =
    ## getRandomFloat
    ##
    ## convenience proc so we do not need to import random
    ##
    ## in calling prog
    result = rng.random()


proc createSeqFloat*(n:int = 10) : seq[float] =
      ## createSeqFloat
      ##
      ## convenience proc to create a seq of random floats with
      ##
      ## default length 10
      ##
      ## form @[0.34,0.056,...] or similar
      ##
      ## .. code-block:: nim
      ##    # create a seq with 50 random floats
      ##    echo createSeqFloat(50)

      var z = newSeq[float]()
      for x in 0.. <n:
        z.add(getRandomFloat())
      result = z




proc getRandomPointInCircle*(radius:float) : seq[float] =
  ## getRandomPointInCircle
  ## 
  ## based on answers found in
  ## 
  ## http://stackoverflow.com/questions/5837572/generate-a-random-point-within-a-circle-uniformly
  ## 
  ## 
  ## 
  ## .. code-block:: nim
  ##    import private,math  
  ##    # get randompoints in a circle
  ##    var crad:float = 1
  ##    for x in 0.. 100:
  ##       var k = getRandomPointInCircle(crad)
  ##       assert k[0] <= crad and k[1] <= crad
  ##       echo k
  ##    doFinish()
  ##    
  ##     
  
  var t = 2 * math.Pi * getRandomFloat()
  var u = getRandomFloat() + getRandomFloat()
  var r = 0.00
  if u > 1 :
     r = 2-u 
  else:
     r = u 
  var z = newSeq[float]()
  z.add(radius * r * math.cos(t))
  z.add(radius * r * math.sin(t))
  return z
      
      
      
# Misc. routines 

proc harmonics*(n:int64):float64 =
     ## harmonics
     ##
     ## returns a float containing sum of 1 + 1/2 + 1/3 + 1/n
     ##
     var hn = 0.0
     var h = 0.0
     
     if n == 0:
       result = 0.0

     elif n > 0:

        h = 0.0
        for x in 1.. n:
           hn = 1.0 / x.float64
           h = h + hn
        result = h

     else:
         msgr() do : echo "Harmonics here defined for positive n only"
         #result = -1



proc shift*[T](x: var seq[T], zz: Natural = 0): T =
    ## shift takes a seq and returns the first , and deletes it from the seq
    ##
    ## build in pop does the same from the other side
    ##
    ## .. code-block:: nim
    ##    var a: seq[float] = @[1.5, 23.3, 3.4]
    ##    echo shift(a)
    ##    echo a
    ##
    ##
    result = x[zz]
    x.delete(zz)



proc ff*(zz:float,n:int64 = 5):string =
    ## ff
    ## 
    ## formats a float to string with n decimals
    ##  
    result = $formatFloat(zz,ffDecimal,n)



proc showStats*(x:Runningstat) =
    ## showStats
    ## 
    ## quickly display runningStat data
    ##  
    ## .. code-block:: nim 
    ##  
    ##    import private,math
    ##    var rs:Runningstat
    ##    var z =  createSeqFloat(500000)
    ##    for x in z:
    ##        rs.push(x)
    ##    statistics(rs)
    ##    doFinish()
    ## 
    var sep = ":"
    printLnBiCol("Sum     : " & ff(x.sum),sep,yellow,white)
    printLnBiCol("Var     : " & ff(x.variance),sep,yellow,white)
    printLnBiCol("Mean    : " & ff(x.mean),sep,yellow,white)
    printLnBiCol("Std     : " & ff(x.standardDeviation),sep,yellow,white)
    printLnBiCol("Min     : " & ff(x.min),sep,yellow,white)
    printLnBiCol("Max     : " & ff(x.max),sep,yellow,white)
    


proc newDir*(dirname:string) = 
  ## newDir
  ## 
  ## creates a new directory and provides some feedback 
  
  if not existsDir(dirname):
        try:
           createDir(dirname)
           printLnG("Directory " & dirname & " created ok")
        except OSError:   
           printLnR(dirname & " creation failed. Check permissions.")
  else:
      printLnR("Directory " & dirname & " already exists !")



proc remDir*(dirname:string) =
  ## remDir
  ## 
  ## deletes an existing directory , all subdirectories and files  and provides some feedback
  ## 
  ## root and home directory removal is disallowed 
  ## 
  
  if dirname == "/home" or dirname == "/" :
     printLnRB("Directory " & dirname & " removal not allowed !")
     
  else:
    
      if existsDir(dirname):
          
          try:
            removeDir(dirname)
            printLnG("Directory " & dirname & " deleted ok")
          except OSError:
            printLnR("Directory " & dirname & " deletion failed")
      else:
          printLnR("Directory " & dirname & " does not exists !")




# Unicode random word creators

proc newWordCJK*(maxwl:int = 10):string =
      ## newWordCJK
      ##
      ## creates a new random string consisting of n chars default = max 10
      ##
      ## with chars from the cjk unicode set
      ##
      ## http://unicode-table.com/en/#cjk-unified-ideographs
      ##
      ## requires unicode
      ##
      ## .. code-block:: nim
      ##    # create a string of chinese or CJK chars
      ##    # with max length 20 and show it in green
      ##    msgg() do : echo newWordCJK(20)
      # set the char set
      let chc = toSeq(parsehexint("3400").. parsehexint("4DB5"))
      var nw = ""
      # words with length range 3 to maxwl
      let maxws = toSeq(3.. <maxwl)
      # get a random length for a new word choosen from between 3 and maxwl
      let nwl = maxws.randomChoice()
      for x in 0.. <nwl:
            nw = nw & $Rune(chc.randomChoice())
      result = nw



proc newWord*(minwl:int=3,maxwl:int = 10 ):string =
    ## newWord
    ##
    ## creates a new lower case random word with chars from Letters set
    ##
    ## default min word length minwl = 3
    ##
    ## default max word length maxwl = 10
    ##
    
    if minwl <= maxwl:
        var nw = ""
        # words with length range 3 to maxwl
        let maxws = toSeq(minwl.. maxwl)
        # get a random length for a new word
        let nwl = maxws.randomChoice()
        let chc = toSeq(33.. 126)
        while nw.len < nwl:
          var x = chc.randomChoice()
          if char(x) in Letters:
              nw = nw & $char(x)
        result = normalize(nw)   # return in lower case , cleaned up

    else:
         msgr() do : echo "Error : minimum word length larger than maximum word length"
         result = ""


proc newWord2*(minwl:int=3,maxwl:int = 10 ):string =
    ## newWord2
    ##
    ## creates a new lower case random word with chars from IdentChars set
    ##
    ## default min word length minwl = 3
    ##
    ## default max word length maxwl = 10
    ##
    if minwl <= maxwl:
        var nw = ""
        # words with length range 3 to maxwl
        let maxws = toSeq(minwl.. maxwl)
        # get a random length for a new word
        let nwl = maxws.randomChoice()
        let chc = toSeq(33.. 126)
        while nw.len < nwl:
          var x = chc.randomChoice()
          if char(x) in IdentChars:
              nw = nw & $char(x)
        result = normalize(nw)   # return in lower case , cleaned up
    
    else: 
         msgr() do : echo "Error : minimum word length larger than maximum word length"
         result = ""
 

proc newWord3*(minwl:int=3,maxwl:int = 10 ,nflag:bool = true):string =
    ## newWord3
    ##
    ## creates a new lower case random word with chars from AllChars set if nflag = true 
    ##
    ## creates a new anycase word with chars from AllChars set if nflag = false 
    ##
    ## default min word length minwl = 3
    ##
    ## default max word length maxwl = 10
    ##
    if minwl <= maxwl:
        var nw = ""
        # words with length range 3 to maxwl
        let maxws = toSeq(minwl.. maxwl)
        # get a random length for a new word
        let nwl = maxws.randomChoice()
        let chc = toSeq(33.. 126)
        while nw.len < nwl:
          var x = chc.randomChoice()
          if char(x) in AllChars:
              nw = nw & $char(x)
        if nflag == true:      
           result = normalize(nw)   # return in lower case , cleaned up
        else :
           result = nw
        
    else:
         msgr() do : echo "Error : minimum word length larger than maximum word length"
         result = ""
           

proc newHiragana*(minwl:int=3,maxwl:int = 10 ):string =
    ## newHiragana
    ##
    ## creates a random hiragana word without meaning from the hiragana unicode set 
    ##
    ## default min word length minwl = 3
    ##
    ## default max word length maxwl = 10
    ##
    if minwl <= maxwl:
        var nw = ""
        # words with length range 3 to maxwl
        let maxws = toSeq(minwl.. maxwl)
        # get a random length for a new word
        let nwl = maxws.randomChoice()
        let chc = toSeq(12353.. 12436)
        while nw.len < nwl:
           var x = chc.randomChoice()
           nw = nw & $Rune(x)
        
        result = nw
        
    else:
         msgr() do : echo "Error : minimum word length larger than maximum word length"
         result = ""
           
        

proc newKatakana*(minwl:int=3,maxwl:int = 10 ):string =
    ## newKatakana
    ##
    ## creates a random katakana word without meaning from the katakana unicode set 
    ##
    ## default min word length minwl = 3
    ##
    ## default max word length maxwl = 10
    ##
    if minwl <= maxwl:
        var nw = ""
        # words with length range 3 to maxwl
        let maxws = toSeq(minwl.. maxwl)
        # get a random length for a new word
        let nwl = maxws.randomChoice()
        let chc = toSeq(parsehexint("30A0") .. parsehexint("30FF"))
        while nw.len < nwl:
           var x = chc.randomChoice()
           nw = nw & $Rune(x)
        
        result = nw
        
    else:
         msgr() do : echo "Error : minimum word length larger than maximum word length"
         result = ""
           


proc iching*():seq[string] =
    ## iching
    ##
    ## returns a seq containing iching unicode chars
    var ich = newSeq[string]()
    for j in 119552..119638:
           ich.add($Rune(j))
    result = ich


proc hiragana*():seq[string] =
    ## hiragana
    ##
    ## returns a seq containing hiragana unicode chars
    var hir = newSeq[string]()
    # 12353..12436 hiragana
    for j in 12353..12436:
           hir.add($Rune(j))
    result = hir


proc katakana*():seq[string] =
    ## full width katakana
    ##
    ## returns a seq containing full width katakana unicode chars
    ##
    var kat = newSeq[string]()
    # s U+30A0–U+30FF.
    for j in parsehexint("30A0") .. parsehexint("30FF"):
        kat.add($RUne(j))
    result = kat


# string splitters with additional capabilities to original split()

proc fastsplit*(s: string, sep: char): seq[string] =
  ## fastsplit
  ## 
  ##  code by jehan lifted from Nim Forum
  ##  
  ## for best results compile prog with : nim cc -d:release --gc:markandsweep 
  ## 
  ## seperator must be a char type
  ## 
  var count = 1
  for ch in s:
    if ch == sep:
      count += 1
  result = newSeq[string](count)
  var fieldNum = 0
  var start = 0
  for i in 0..high(s):
    if s[i] == sep:
      result[fieldNum] = s[start..i-1]
      start = i+1
      fieldNum += 1
  result[fieldNum] = s[start..^1]



proc splitty*(txt:string,sep:string):seq[string] =
   ## splitty
   ## 
   ## same as build in split function but this retains the
   ## 
   ## separator on the left side of the split
   ## 
   ## z = splitty("Nice weather in : Djibouti",":")
   ##
   ## will yield:
   ## 
   ## Nice weather in :
   ## Djibouti
   ## 
   ## rather than:
   ## 
   ## Nice weather in
   ## Djibouti
   ##
   ## with the original split()
   ## 
   ## 
   var rx = newSeq[string]()   
   let z = txt.split(sep)
   for xx in 0.. <z.len:
     if z[xx] != txt and z[xx] != nil:
        if xx < z.len-1:
             rx.add(z[xx] & sep)
        else:
             rx.add(z[xx])
   result = rx          


# Info and handlers procs for quick information about


proc qqTop*() =
  ## qqTop
  ##
  ## prints qqTop in custom color
  ## 
  printHl("qq","qq",cyan)
  printHl("T","T",brightgreen)
  printHl("o","o",brightred)
  printHl("p","p",cyan)
  

proc doInfo*() =
  ## doInfo
  ## 
  ## A more than you want to know information proc
  ## 
  ## 
  let filename= extractFileName(getAppFilename())
  #var accTime = getLastAccessTime(filename)
  let modTime = getLastModificationTime(filename)
  let sep = ":"
  superHeader("Information for file " & filename & " and System")
  printLnBiCol("Last compilation on           : " & CompileDate &  " at " & CompileTime,sep,green,black)
  # this only makes sense for non executable files
  #printLnBiCol("Last access time to file      : " & filename & " " & $(fromSeconds(int(getLastAccessTime(filename)))),sep,green,black)
  printLnBiCol("Last modificaton time of file : " & filename & " " & $(fromSeconds(int(modTime))),sep,green,black)
  printLnBiCol("Local TimeZone                : " & $(getTzName()),sep,green,black)
  printLnBiCol("Offset from UTC  in secs      : " & $(getTimeZone()),sep,green,black)
  printLnBiCol("Now                           : " & getDateStr() & " " & getClockStr(),sep,green,black)
  printLnBiCol("Local Time                    : " & $getLocalTime(getTime()),sep,green,black)
  printLnBiCol("GMT                           : " & $getGMTime(getTime()),sep,green,black)
  printLnBiCol("Environment Info              : " & getEnv("HOME"),sep,green,black)
  printLnBiCol("File exists                   : " & $(existsFile filename),sep,green,black)
  printLnBiCol("Dir exists                    : " & $(existsDir "/"),sep,green,black)
  printLnBiCol("AppDir                        : " & getAppDir(),sep,green,black)
  printLnBiCol("App File Name                 : " & getAppFilename(),sep,green,black)
  printLnBiCol("User home  dir                : " & getHomeDir(),sep,green,black)
  printLnBiCol("Config Dir                    : " & getConfigDir(),sep,green,black)
  printLnBiCol("Current Dir                   : " & getCurrentDir(),sep,green,black)
  let fi = getFileInfo(filename)
  printLnBiCol("File Id                       : " & $(fi.id.device) ,sep,green,black)
  printLnBiCol("File No.                      : " & $(fi.id.file),sep,green,black)
  printLnBiCol("Kind                          : " & $(fi.kind),sep,green,black)
  printLnBiCol("Size                          : " & $(float(fi.size)/ float(1000)) & " kb",sep,green,black)
  printLnBiCol("File Permissions              : ",sep,green,black)
  for pp in fi.permissions:
      printLnBiCol("                              : " & $pp,sep,green,black)
  printLnBiCol("Link Count                    : " & $(fi.linkCount),sep,green,black)
  # these only make sense non executable files
  #printLnBiCol("Last Access                   : " & $(fi.lastAccessTime),sep,green,black)
  #printLnBiCol("Last Write                    : " & $(fi.lastWriteTime),sep,green,black)
  printLnBiCol("Creation                      : " & $(fi.creationTime),sep,green,black)

  when defined windows:
        printLnBiCol("System                        : Windows ..... Really ??",sep,red,black) 
  elif defined linux:
        printLnBiCol("System                        : Running on Linux" ,sep,brightcyan,green)
  else:
        printLnBiCol("System                        : Interesting Choice" ,sep,green,black)

  when defined x86:
        printLnBiCol("Code specifics                : x86" ,sep,green,black)

  elif defined amd64:
        printLnBiCol("Code specifics                : amd86" ,sep,green,black)
  else:
        printLnBiCol("Code specifics                : generic" ,sep,green,black)

  printLnBiCol("Nim Version                   : " & $NimMajor & "." & $NimMinor & "." & $NimPatch,sep,green,black) 
  printLnBiCol("Processor count               : " & $countProcessors(),sep,green,black)
  printBiCol("OS                            : "& hostOS,sep,green,black)
  printBiCol(" | CPU: "& hostCPU,sep,green,black)
  printLnBiCol(" | cpuEndian: "& $cpuEndian,sep,green,black)
  let pd = getpid()
  printLnBiCol("Current pid                   : " & $pd,sep,green,black)
  


proc infoLine*() = 
    ## infoLine
    ## 
    ## prints some info for current application
    ## 
    echo aline
    printColStr(brightyellow,"{:<14}".fmt("Application :"))
    printColStr(black,extractFileName(getAppFilename()))
    printColStr(black," | ")
    printColStr(brightgreen,"Nim : ")
    printColStr(black,NimVersion & " | ")
    printColStr(brightcyan,"private : ")
    printColStr(black,PRIVATLIBVERSION)
    printColStr(black," | ")
    qqTop()
    
    
proc doFinish*() =
    ## doFinish
    ##
    ## a end of program routine which displays some information
    ##
    ## can be changed to anything desired
    ## 
    ## and should be the last line of the application
    ##
    decho(2)
    
    # version 1
    #msgb() do : echo "{:<15}{} | {}{} | {}{} - {}".fmt("Application : ",getAppFilename(),"Nim : ",NimVersion,"qqTop private : ", PRIVATLIBVERSION,year(getDateStr()))
    
    # version 2
    #msgb() do : write(stdout,"{:<15}{} | {}{} | {}{} - {} | ".fmt("Application : ",getAppFilename(),"Nim : ",NimVersion,"private : ", PRIVATLIBVERSION,year(getDateStr())))
    #qqTop()
    
    # version 3
    infoLine()
    printLnColStr(black," - " & year(getDateStr())) 
    printColStr(yellow,"{:<14}".fmt("Elapsed     : "))
    printLnColStr(black,"{:<.3f} {}".fmt(epochtime() - private.start,"secs"))
    echo()
    quit 0


proc handler*() {.noconv.} =
    ## handler
    ##
    ## this runs if ctrl-c is pressed
    ##
    ## and provides some feedback upon exit
    ##
    ## just by using this module your project will have an automatic
    ##
    ## exit handler via ctrl-c
    ## 
    ## this handler may not work if code compiled into a .dll or .so file
    ##
    ## or under some circumstances like being called during readLineFromStdin
    ## 
    ## 
    eraseScreen()
    echo()
    echo aline
    msgg() do: echo "Thank you for using     : ",getAppFilename()
    msgc() do: echo "{}{:<11}{:>9}".fmt("Last compilation on     : ",CompileDate ,CompileTime)
    echo aline
    echo "private Version         : ", PRIVATLIBVERSION
    echo "Nim Version             : ", NimVersion
    printColStr(yellow,"{:<14}".fmt("Elapsed     : "))
    printLnColStr(black,"{:<.3f} {}".fmt(epochtime() - private.start,"secs"))
    echo()
    rainbow("Have a Nice Day !")  ## change or add custom messages as required
    decho(2)
    system.addQuitProc(resetAttributes)
    quit(0)


# putting decho here will put two blank lines before anyting else runs
decho(2)
# putting this here we can stop most programs which use this lib and get the
# automatic exit messages
setControlCHook(handler)
# this will reset any color changes in the terminal
# so no need for this line in the calling prog
system.addQuitProc(resetAttributes)
# end of private.nim
