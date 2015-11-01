import private,strutils,random,times

## small demos repository for var. procs in private
## this file is imported by privateTest.nim to actually run the demos
 

proc futureIsNimDemo*(posx:int = 0) = 
      ## futureIsNim
      ## 
      ## demo example of a box drawn with doty procs and 2 text lines
      ## 
      ## max xpos = 20
      ## 
      ## .. code-block:: nim
      ##    import private
      ##    cleanScreen()
      ##    for x in 0.. 10:
      ##        centerMark()
      ##        echo()
      ##        sleepy(0.1)
      ##    flyNimDemo()
      ##    futureIsNimDemo(20)
           
      var xpos = posx 
      if xpos > 35:
         xpos = 35
         
      drawRect(7,29 ,frhLine = widedot,frvLine = wideDot , frCol = randCol(),xpos = xpos)
     
      curup(5)
      curSetx(xpos)
      doty(1,red)
      printPos(" ",clrainbow,xpos = xpos + 20)
      doty(1,lime)
      doty(1,tomato)
      print(" Nim",salmon)
      doty(1,tomato)
      doty(1,lime)
      # 2nd text line
      curdn(1)
      curSetx(xpos)
      #doty(1,red)
      curSetx(xpos + 17)
      print("The future is now !",steelblue)
      curdn(5)



proc flyNimDemo*(astring:string = "Fly Nim",col:string = red,tx:float = 0.08) =

      ## flyNim
      ## 
      ## small animation demo
      ## 
      ## .. code-block:: nim
      ##    flyNimDemo(col = brightred)  
      ##    flyNimDemo(" Have a nice day !", col = hotpink,tx = 0.1)   
      ## 

      var twc = tw div 2
      var asc = astring.len div 2
      var sn = tw - astring.len
      for x in 0.. twc-asc:
        hline(x,yellowgreen)
        if x < twc - asc :
              printStyled("✈","",brightyellow,{styleBlink})
              hlineln(tw - 1 - x,clrainbow)
        else:
              printStyled(astring,"",red,{styleBright})
              hlineln(sn - x,salmon)
        sleepy(tx)
        curup(1) 
        
      echo()
      

proc centerNimDemo*() = 
   # test for centerpos
   var b = " C,C++,Python,Rust,Scala,Fortran,Cobol,Go"  
   cleanScreen()  
   
   for x in 0.. 4:
           centerPos(b)
           printLnStyled(b,"",gray,{styleDim})
           
   sleepy(0.1)
   echo()
   centerpos("Nim")
   printLnStyled(repeat("Nim ",20),"",red,{styleBright})
   echo()
   for x in 0.. 4:
      centerpos(b)   
      printLnStyled(b,"",gray,{styleDim})



proc printNimSx*(col:string = yellowgreen, xpos: int = 1) = 
   ## printNimSx
   ## 
   ## prints large Nim
   ## 
   ## 
  
   var maxpos = tw - nimsx[0].len + 20
   for x in nimsx :
        if xpos <= maxpos  :
            print(repeat(" ",xpos) & x,col)
        else:    
            print(repeat(" ",maxpos) & x,col)
            
            
proc movNimDemo*() =
    ## movNim
    ## 
    ## Demo moving Nim
    ## 
    ## .. code-block:: nim
    ##    import private 
    ##    decho(5)
    ##    movNimDemo()
    ##    printNimSx(salmon)
    ##    printNimSx(lime,55)
    ##    doFinish()
    ##
    cleanScreen()
    for xpos in 1.. tw - nimsx[0].len + 20:
        if float(xpos mod 8) == 0.0:
            printNimSx(red,xpos)
            sleepy(0.025)
        else:
          printNimSx(gray,xpos)
        sleepy(0.025)
        cleanScreen()

    for xpos in countdown(tw - nimsx[0].len + 20 ,1,1):
        if float(xpos mod 8) == 0.0:
            printNimSx(red,xpos)
            sleepy(0.025)
        else:
          printNimSx(gray,xpos)
        sleepy(0.025)
        cleanScreen()



proc randomCardsDemo*() =
   ## randomCards
   ## 
   ## Demo for colorful cards deck ...
   decho(2)
   for z in 0.. <th -3:
      for zz in 0.. <tw div 2 - 1:
          print cards[rxCards.randomChoice()],randCol()
      writeLine(stdout,"") 
    

proc randomCardsClockDemo*() = 
    ## randomCardsClockDemo
    ## 
    ## 
    ## 

    for x in countdown(10,0):
        randomCardsDemo()
        curup(th div 2)
        if x == 0:
                printSlimNumber($getClockStr(),fgr=lime,xpos=25)
        else:
                printSlimNumber($getClockStr(),fgr=lime,xpos=15)       
        if x > 0:
            curup(7)
            printBigNumber($x,truetomato,xpos = 75)
        curSet()
        sleepy(0.3)

    curdn(th)






proc ndLineDemo*() =
  ## ndLineDemo
  ## 
  ## Numbered dots line demo
  ## 
  ## test with bash terminal only , styleBlink may not work with some terminals
  ## 
  ## 
  curup(1)
  var c = (tw.float / 2.76666).int 
  for x in 0.. <c:
      if x == c div 2 :
        printStyled($x,$x,lime,{styleBlink})
      else:  
        printStyled($x,$x,goldenrod,{styleBright})  
      curdn(1)
      curbk(1)
      if x == c div 2 :
        printStyled(".",".",lime,{styleBright,styleBlink})
      else:
        print(".",truetomato)
      curup(1)
      curfw(1)
  decho(2)



#### sierpcarpet small snippet I lifted from somewhere and colorized

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
 
proc sierpCarpetDemo*(n) =
  ## sierpCarpetDemo
  ## 
  ## draws the carpet in color
  ## 
  for i in 0 .. <(3^n):
    for j in 0 .. <(3^n):
      if inCarpet(i, j):
        print("* ",clrainbow)
      else:
        printStyled("  ","",truetomato,{stylereverse})
        
    echo ""



proc drawRectDemo*() =
  ## drawRectDemo
  ## 
  ## examples of using drawRect
  ## 
  drawRect(15,24,frhLine = "+",frvLine = wideDot , frCol = randCol(),xpos = 8)
  curup(12)
  drawRect(9,20,frhLine = "=",frvLine = wideDot , frCol = randCol(),xpos = 10,blink = true)
  curup(12)
  drawRect(9,20,frhLine = "=",frvLine = wideDot , frCol = randCol(),xpos = 35,blink = true)
  curup(10)
  drawRect(6,14,frhLine = "~",frvLine = "$" , frCol = randCol(),xpos = 70,blink = true)




