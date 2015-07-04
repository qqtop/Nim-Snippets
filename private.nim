
##
##   Library     : private.nim
##
##   Status      : in use
##
##   License     : MIT opensource
##
##   Version     : 0.6
##
##   ProjectStart: 2015-06-20
##
##   Compiler    : Nim 0.11.3
##
##   Description : library with a collection of procs and templates
##
##                 display , date handling and much more
##
##   Docs        : nim doc private
##
##   Tested      : on linux only
##
##   Programming : qqTop
##
##   Note        : may change at any time
##

import os,terminal,strfmt,math,unicode,parseutils,strutils
import sequtils,random,times,tables

const PRIVATLIBVERSION = 0.6

let start* = epochTime()  #  so we can check execution timing with one line

converter toTwInt(x: cushort): int = result = int(x)
when defined(Linux):
    proc getTerminalWidth*() : int =
      ## getTerminalWidth
      ##
      ## utility to easily draw correctly sized lines on linux terminals
      ##
      ## and get linux get terminal width
      ##
      ## for windows this currently is set to terminalwidth 80
      ##
      type WinSize = object
        row, col, xpixel, ypixel: cushort
      const TIOCGWINSZ = 0x5413
      proc ioctl(fd: cint, request: culong, argp: pointer)
        {.importc, header: "<sys/ioctl.h>".}
      var size: WinSize
      ioctl(0, TIOCGWINSZ, addr size)
      result = toTwInt(size.col)

    var tw* = getTerminalWidth()
    var aline* = repeat("-",tw)

# will change this once windows gets a real terminal
# or shell which will never happen
when defined(Windows):
     tw = repeat("-",80)


template msgg*(code: stmt): stmt {.immediate.} =
      ## msgX templates
      ## convenience templates for colored text output
      ## the assumption is that the terminal is white text and black background
      ## naming of the templates is like msg+color so msgy => yellow
      ## use like : msgg() do : echo "How nice, it's in green"

      setforegroundcolor(fgGreen)
      code
      setforegroundcolor(fgWhite)


template msggb*(code: stmt): stmt {.immediate.} =

      setforegroundcolor(fgGreen,true)
      code
      setforegroundcolor(fgWhite)


template msgy*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgYellow)
      code
      setforegroundcolor(fgWhite)

template msgyb*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgYellow,true)
      code
      setforegroundcolor(fgWhite)


template msgr*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgRed)
      code
      setforegroundcolor(fgWhite)


template msgrb*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgRed,true)
      code
      setforegroundcolor(fgWhite)

template msgc*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgCyan)
      code
      setforegroundcolor(fgWhite)

template msgcb*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgCyan,true)
      code
      setforegroundcolor(fgWhite)


template msgw*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgWhite)
      code
      setforegroundcolor(fgWhite)

template msgwb*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgWhite,true)
      code
      setforegroundcolor(fgWhite)

template msgb*(code: stmt): stmt {.immediate.} =
      setforegroundcolor(fgBlack,true)
      code
      setforegroundcolor(fgBlack)



template hdx*(code:stmt):stmt {.immediate.}  =
   echo ""
   echo repeat("+",tw)
   setforegroundcolor(fgCyan)
   code
   setforegroundcolor(fgWhite)
   echo repeat("+",tw)
   echo ""


template withFile*(f: expr, filename: string, mode: FileMode,
                     body: stmt): stmt {.immediate.} =
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
     ##                     dhlecho(al,sw,"g")
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
        of 10 : msggb() do : write(stdout,astr[x])
        of 11 : msgcb() do : write(stdout,astr[x])
        else  : msgw() do  : write(stdout,astr[x])


proc dhlecho*(sen:string,cw:string,col:string) =
      ## dhlecho
      ##
      ## echo a line and highlight all appearances of a char or string
      ##
      ## with a certain color
      ##
      ## .. code-block:: nim
      ##    dhlecho("HELLO THIS IS A TEST","T","g")
      ##
      ## this would highlight all T in green
      ##
      ## available colors : g,y,c,r,w


      var rx = sen.split(cw)
      for x in rx.low.. rx.high:
          writestyled(rx[x],{})
          if x != rx.high:
            case col
            of "g" : msgg()  do : writestyled(cw ,{styleBright})
            of "y" : msgy()  do : writestyled(cw ,{styleBright})
            of "c" : msgc()  do : writestyled(cw ,{styleBright})
            of "r" : msgr()  do : writestyled(cw ,{styleBright})
            of "w" : msgwb() do : writestyled(cw ,{styleBright})
            else: msgw() do : writestyled(cw ,{})

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

proc day*(aDate:string) : string =
   ## day,month year extracts the relevant part from
   ##
   ## a date string of format yyyy-MM-dd
   aDate.split("-")[2]

proc month*(aDate:string) : string =
  var asdm = $(parseInt(aDate.split("-")[1]))
  if len(asdm) < 2: asdm = "0" & asdm
  result = asdm

proc year*(aDate:string) : string = aDate.split("-")[0]
     ## Format yyyy

proc intervalsecs*(startDate,endDate:string) : float =
      ## interval procs returns time elapsed between two dates in secs,hours etc.
      ##
      var f     = "yyyy-MM-dd"
      var ssecs = toSeconds(timeinfototime(startDate.parse(f)))
      var esecs = toSeconds(timeinfototime(endDate.parse(f)))
      var isecs = esecs - ssecs
      result = isecs

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


proc validdate*(adate:string):bool =

     var m30 = @["04","06","09","11"]
     var m31 = @["01","03","05","07","08","10","12"]

     var xdate = parseInt(aDate.replace("-",""))
     # check 1 is our date between 1900 - 3000
     if xdate > 19000101 and xdate < 30001212:
        var spdate = aDate.split("-")
        if parseint(spdate[0]) >= 1900 and parseint(spdate[0]) <= 3000:
             if spdate[1] in m30:
               # so day max 30
                if parseInt(spdate[2]) > 0 and parseInt(spdate[2]) < 31:
                   result = true
                else:
                   result = false

             elif spdate[1] in m31:
               # so day max 30
                if parseInt(spdate[2]) > 0 and parseInt(spdate[2]) < 32:
                   result = true
                else:
                   result = false

             else:
                   # so its february
                   if spdate[1] == "02" :
                      # check leapyear
                      if isleapyear(parseint(spdate[0])) == true:
                          if parseInt(spdate[2]) > 0 and parseint(spdate[2]) < 30:
                            result = true
                          else:
                            result = false
                      else:
                          if parseInt(spdate[2]) > 0 and parseint(spdate[2]) < 29:
                            result = true
                          else:
                            result = false



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
        var ss = epochtime()
        var ee = ss + s.float
        var c = 0
        while ee > epochtime():
            inc c
        # feedback line can be commented out
        #msgr() do : echo "Loops during waiting for ",s,"secs : ",c




proc plusDays*(aDate:string,days:int):string =
   ## plusDays
   ##
   ## adds days to date string of format yyyy-MM-dd  or result of getDateStr()
   ##
   ## and returns a string of format yyyy-MM-dd
   ##
   ## the passed in date string must be a valid date or an error message will be returned
   ##
   var rxs = ""

   if validdate(adate) == true:

        var spdate = aDate.split("-")
        var tifo = parse(aDate,"yyyy-MM-dd") # this returns a TimeInfo type
        var mflag: bool = false
        tifo.year = parseInt(spdate[0])

        case parseInt(spdate[1])
        of 1 :  tifo.month = mJan
        of 2 :  tifo.month = mFeb
        of 3 :  tifo.month = mMar
        of 4 :  tifo.month = mApr
        of 5 :  tifo.month = mMay
        of 6 :  tifo.month = mJun
        of 7 :  tifo.month = mJul
        of 8 :  tifo.month = mAug
        of 9 :  tifo.month = mSep
        of 10:  tifo.month = mOct
        of 11:  tifo.month = mNov
        of 12 : tifo.month = mDec
        else :
          mflag = true

        tifo.monthday = parseInt(spdate[2])

        if mflag == false:
            var myinterval = initInterval()
            myinterval.days = days
            var rx = tifo + myinterval
            rxs = rx.format("yyyy-MM-dd")

        else :
              msgr() do: echo "Date error. Wrong month : " &  spdate[1]
              rxs = ""

   else:
        msgr() do : echo  "Date error. Invalid date : " &  aDate,"  Format yyyy-MM-dd expected"
        rxs = ""

   result = rxs


proc minusDays*(aDate:string,days:int):string =
   ## minusDays
   ##
   ## subtracts days from a date string of format yyyy-MM-dd  or result of getDateStr()
   ##
   ## and returns a string of format yyyy-MM-dd
   ##
   ## the passed in date string must be a valid date or an error message will be returned
   ##

   var rxs = ""
   if validdate(adate) == true:

        var spdate = aDate.split("-")
        var tifo = parse(aDate,"yyyy-MM-dd")  # this returns a TimeInfo type
        var mflag: bool = false
        tifo.year = parseInt(spdate[0])

        case parseInt(spdate[1])
        of 1 :  tifo.month = mJan
        of 2 :  tifo.month = mFeb
        of 3 :  tifo.month = mMar
        of 4 :  tifo.month = mApr
        of 5 :  tifo.month = mMay
        of 6 :  tifo.month = mJun
        of 7 :  tifo.month = mJul
        of 8 :  tifo.month = mAug
        of 9 :  tifo.month = mSep
        of 10:  tifo.month = mOct
        of 11:  tifo.month = mNov
        of 12 : tifo.month = mDec
        else :
          mflag = true

        tifo.monthday = parseInt(spdate[2])

        if mflag == false:
            var myinterval = initInterval()
            myinterval.days = days
            var rx = tifo - myinterval
            rxs = rx.format("yyyy-MM-dd")

        else :
              msgr() do: echo "Date error. Wrong month : " &  spdate[1]
              rxs = ""
   else:
        msgr() do : echo  "Date error. Invalid date : " &  aDate ,"  Format yyyy-MM-dd expected"
        rxs = ""

   result = rxs


proc handler*() {.noconv.} =
        ## handler
        ##
        ## this runs if ctrl-c is pressed
        ##
        ## and provides some feedback upon exit
        ##
        ## just by this library into your project you will have an automatic
        ##
        ## exit handler via ctrl-c
        eraseScreen()
        echo()
        echo aline
        msgg() do: echo "Thank you for using     : ",getAppFilename()
        msgc() do: echo "{}{:<11}{:>9}".fmt("Last compilation on     : ",CompileDate ,CompileTime)
        echo aline
        echo "private Version         : ", PRIVATLIBVERSION
        echo "Nim Version             : ", NimVersion
        echo()
        rainbow("Have a Nice Day !")  ## change or add custom messages as required
        decho(2)
        system.addQuitProc(resetAttributes)
        quit(0)



proc superHeader*(bstring:string) =
  ## superheader
  ##
  ## a framed header display routine
  ##
  ## suitable for one line headers , overlong lines will
  ##
  ## be cut to terminal window size with out ceremony
  ##
  var astring = bstring
  # minimum default size that is string max len = 43 and
  # frame = 46
  var mmax = 43
  var mddl = 46

  ## max length = tw-2
  var okl = tw - 6
  var astrl = astring.len
  if astrl > okl :
     astring = astring[0.. okl]
     mddl = okl + 5

  elif astrl > mmax :
       mddl = astrl + 4

  else :
      # default or smaller
       var n = mmax - astrl
       for x in 0.. <n:
          astring = astring & " "
       mddl = mddl + 1

  var pdl = repeat("#",mddl)
  # now show it with the framing in yellow and text in white
  # really need to have a terminal color checker to avoid invisible lines
  echo ()
  msgy() do : echo pdl
  msgy() do : write(stdout,"# ")
  msgw() do : write(stdout,astring)
  msgy() do : echo " #"
  msgy() do : echo pdl
  echo ()


proc superHeader*(bstring:string,strcol:string,frmcol:string) =
    ## superheader
    ##
    ## a framed header display routine
    ##
    ## suitable for one line headers , overlong lines will
    ##
    ## be cut to terminal window size with out ceremony
    ##
    ## the color of the string can be selected available colors
    ##
    ## g,r,c,w,y and for going completely bonkers the frame
    ##
    ## can be set to rainbow too .
    ##
    ## .. code-block:: nim
    ##    import private,terminal
    ##
    ##    superheader("Ok That's it for Now !","rainbow","w")
    ##    echo()
    ##
    var astring = bstring
    # minimum default size that is string max len = 43 and
    # frame = 46
    var mmax = 43
    var mddl = 46

    ## max length = tw-2
    var okl = tw - 6
    var astrl = astring.len
    if astrl > okl :
       astring = astring[0.. okl]
       mddl = okl + 5

    elif astrl > mmax :
         mddl = astrl + 4

    else :
        # default or smaller
         var n = mmax - astrl
         for x in 0.. <n:
            astring = astring & " "
         mddl = mddl + 1

    var pdl = repeat("#",mddl)
    # now show it with the framing in yellow and text in white
    # really need to have a terminal color checker to avoid invisible lines
    echo ()

    # frame line
    proc frameline(pdl:string) =
        case frmcol
        of "g" : msgg()  do : writestyled(pdl ,{})
        of "y" : msgy()  do : writestyled(pdl ,{})
        of "c" : msgc()  do : writestyled(pdl ,{})
        of "r" : msgr()  do : writestyled(pdl ,{})
        of "w" : msgwb() do : writestyled(pdl ,{})
        of "b" : msgb()  do : writestyled(pdl ,{})
        of "rainbow" : rainbow(pdl)
        else: msgw() do : writestyled(pdl ,{})
        echo()

    proc framemarker(am:string) =
        case frmcol
        of "g" : msgg()  do : writestyled(am ,{})
        of "y" : msgy()  do : writestyled(am ,{})
        of "c" : msgc()  do : writestyled(am ,{})
        of "r" : msgr()  do : writestyled(am ,{})
        of "w" : msgw()  do : writestyled(am ,{})
        of "b" : msgb()  do : writestyled(am ,{})
        of "rainbow" : rainbow(am)
        else: msgy() do : writestyled(am ,{})

    proc headermessage(astring:string)  =
        case strcol
        of "g" : msgg()  do : writestyled(astring ,{styleBright})
        of "y" : msgy()  do : writestyled(astring ,{styleBright})
        of "c" : msgc()  do : writestyled(astring ,{styleBright})
        of "r" : msgr()  do : writestyled(astring ,{styleBright})
        of "w" : msgwb() do : writestyled(astring ,{styleBright})
        of "b" : msgb()  do : writestyled(pdl ,{})
        of "rainbow" : rainbow(astring)
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


proc superHeaderA*(bb:string,strcol:string,frmcol:string,down:bool) =
  ## superHeaderA
  ##
  ## animated superheader
  ##
  ## parameters for animated superheaderA :
  ##
  ## headerstring, txt color, frame color, updown animation : true/false
  ##
  ## .. code-block:: nim
  ##    import private,terminal
  ##    erasescreen()
  ##    cursorup(80)
  ##    let bb = "NIM the system language for the future, which extends to as far as you need and still is small !!"
  ##    superHeaderA(bb,"rainbow","y",false)
  ##    decho(3)
  ##    superheader("Ok That's it for Now !","rainbow","b")
  ##

  for x in 0.. <1:
    erasescreen()
    for zz in 0.. bb.len:
          superheader($bb[0.. zz],strcol,frmcol)
          sleepy(0.05)
          cursorup(5)
    if down == true:
        for zz in countdown(bb.len,-1,1):
              superheader($bb[0.. zz],strcol,frmcol)
              sleepy(0.1)
              erasescreen()
              cursorup(5)

    sleepy(0.5)

  echo()




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
      var rng2 = initMersenneTwister(urandom(2500))
      for x in 0.. <n:
        z.add(rng2.random())
      result = z



proc newWordCJK*(maxwl:int = 10):string =
      ## newWordCJK
      ##
      ## creates a new string consisting of n chars default = max 10
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
      var chc = toSeq(parsehexint("3400").. parsehexint("4DB5"))
      var nw = ""
      # words with length range 3 to maxwl
      var maxws = toSeq(3.. <maxwl)
      # get a random length for a new word choosen from between 3 and maxwl
      var nwl = maxws.randomChoice()
      for x in 0.. <nwl:
            nw = nw & $Rune(chc.randomChoice())
      result = nw


proc newWord*(maxwl:int = 10 ):string =
       ## newWord
       ##
       ## creates a new lower case word with chars from Letters set
       ##
       ## with default max word length maxwl = 10  , min = 3
       ##

       var nw = ""
       # words with length range 3 to maxwl
       var maxws = toSeq(3.. <maxwl)
       # get a random length for a new word
       var nwl = maxws.randomChoice()
       var chc = toSeq(33.. 126)
       while nw.len < nwl:
           var x = chc.randomChoice()
           if char(x) in Letters:
               nw = nw & $char(x)
       result = normalize(nw)   # return in lower case , cleaned up


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
  ## returns a seq containing hiragan unicode chars
  var hir = newSeq[string]()
  # 12353..12436 hiragana
  for j in 12353..12436:
         hir.add($Rune(j))
  result = hir





# putting this here we can stop all programs which use this lib and get the desired exit messages
setControlCHook(handler)
# this will reset any color changes in the terminal
# so no need for this line in the calling prog
system.addQuitProc(resetAttributes)
