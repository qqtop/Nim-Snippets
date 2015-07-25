
##
##   Library     : private.nim
##
##   Status      : stable
##
##   License     : MIT opensource
##
##   Version     : 0.6.5
##
##   ProjectStart: 2015-06-20
##
##   Compiler    : Nim 0.11.3
##
##   Description : private.nim is a public library with a collection of procs and templates
##
##                 for display , date handling and much more
##
##                 some procs mirror functionality of other moduls for convenience
##
##   Docs        : http://qqtop.github.io/private.html
##
##   Tested      : on linux only
##
##   Programming : qqTop
##
##   Note        : may change at any time
##

import os,terminal,math,unicode,times,tables
import sequtils,parseutils,strutils
import random,strfmt,httpclient

const PRIVATLIBVERSION = "0.6.6"
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
       clrainbow*    = "rainbow"

let start* = epochTime()  ##  check execution timing with one line see doFinish

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


template msgg*(code: stmt): stmt   =
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
     ##                     dhlecho(al,sw,green)
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


proc rainbowPW*() :string =
           ## rainbowPW
           ##
           ## under development
           ##
           ## idea is to have a number password with hidden colorcode
           ##
           ## the colorcode is only accessible privatly
           ##
           ## so if the password number is exposed there is no problem
           ##

           var c = 0
           var a = toSeq(0.. 9)
           c = a[randomInt(a.len)]
           case c
            of 1  : msgg() do  : result = $c & green
            of 2  : msgr() do  : result = $c & red
            of 3  : msgc() do  : result = $c & cyan
            of 4  : msgy() do  : result = $c & yellow
            of 5  : msggb() do : result = $c & brightgreen
            of 6  : msgwb() do : result = $c & brightwhite
            of 7  : msgyb() do : result = $c & brightyellow
            of 8  : msgrb() do : result = $c & brightred
            of 9  : msgcb() do : result = $c & brightcyan
            else  : msgw() do  : result = $c & white


proc printColStr*(colstr:string,astr:string) =
      ## printColStr
      ##
      ## prints a string with a named color
      ##
      ## colors : green,red,cyan,yellow,white,black
      ##
      ##          brightgreen,brightred,brightcyan,brightyellow,brightwhite
      ##
      ## .. code-block:: nim
      ##    printColStr("green","Nice it is in green")
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
      else  : msgw() do  : write(stdout,astr)



proc print*(colstr:string = white,mvastr: varargs[string, `$`]) =
    ## print
    ##
    ## similar to printColStr but issues a echo() command that is
    ##
    ## every item will be shown on a new line in the same color
    ##
    ## and most everything passed in will be converted to string
    ##
    ## .. code-block:: nim
    ##    print green,"Nice try 1", 2.52234, @[4, 5, 6]
    ##

    for vastr in mvastr:
      case colstr
      of green  : msgg() do  : echo vastr
      of red    : msgr() do  : echo vastr
      of cyan   : msgc() do  : echo vastr
      of yellow : msgy() do  : echo vastr
      of white  : msgw() do  : echo vastr
      of black  : msgb() do  : echo vastr
      of brightgreen : msggb() do : echo vastr
      of brightwhite : msgwb() do : echo vastr
      of brightyellow: msgyb() do : echo vastr
      of brightcyan  : msgcb() do : echo vastr
      of brightred   : msgrb() do : echo vastr
      of clrainbow   :
                       rainbow(vastr)
                       echo()
      else  : msgw() do  : echo vastr


proc makeColPW*(n:int = 12):seq[string] =
        ## makeColPW
        ##
        ## make a colorcoded pw with length n default = 12
        ##
        var z = newSeq[string]()
        for x in 0..<n:
           z.add(rainbowPW())
        result =  z


proc dhlecho*(sen:string,astr:string,col:string) =
      ## dhlecho
      ##
      ## print a string and highlight all appearances of a char or string
      ##
      ## with a certain color
      ##
      ## .. code-block:: nim
      ##    dhlecho("HELLO THIS IS A TEST","T",green)
      ##
      ## this would highlight all T in green
      ##
      ## available colors : green,yellow,cyan,red,white

      var rx = sen.split(astr)
      for x in rx.low.. rx.high:
          writestyled(rx[x],{})
          if x != rx.high:
              case col
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


proc validdate*(adate:string):bool =
     ## validdate
     ##
     ## try to ensure correct dates of form yyyy-MM-dd
     ##
     ## correct : 2015-08-15
     ##
     ## wrong   : 2015-08-32 , 201508-15, 2015-13-10 etc.
     ##

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
      #  since all interval routines call error message display also here
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
    var ss = epochtime()
    var ee = ss + s.float
    var c = 0
    while ee > epochtime():
        inc c
    # feedback line can be commented out
    #msgr() do : echo "Loops during waiting for ",s,"secs : ",c




proc dayOfWeekJulian*(day, month, year: int): WeekDay =
  # will soon be part of times.nim
  # This is for the Julian calendar
  # Day & month start from one.
  let
    a = (14 - month) div 12
    y = year - a
    m = month + (12*a) - 2
    d = (5 + day + y + (y div 4) + (31*m) div 12) mod 7
  # The value of d is 0 for a Sunday, 1 for a Monday, 2 for a Tuesday, etc. so we must correct
  # for the WeekDay type.
  if d == 0: return dSun
  result = d.WeekDay









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
        else  : mflag = true
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
        else  : mflag = true
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
        rxs = ""

   result = rxs



proc handler*() {.noconv.} =
    ## handler
    ##
    ## this runs if ctrl-c is pressed
    ##
    ## and provides some feedback upon exit
    ##
    ## just by using this library your project will have an automatic
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
  # really want a terminal color checker to avoid invisible lines
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
    ## green,red,cyan,white,yellow and for going completely bonkers the frame
    ##
    ## can be set to clrainbow too .
    ##
    ## .. code-block:: nim
    ##    import private,terminal
    ##
    ##    superheader("Ok That's it for Now !",clrainbow,white)
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
  ##    superHeaderA(bb,,"y",false)
  ##    decho(3)
  ##    superheader("Ok That's it for Now !",clrainbow,"b")
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




proc getWanIp*():string =
   ## getWanIp
   ##
   ## get your wan ip from heroku
   ##

   var myWanIp = "Wan Ip not established."
   try:
      myWanIP = getContent("http://my-ip.heroku.com")
   except:
      discard
   result = myWanIp




# init the MersenneTwister
var rng = initMersenneTwister(urandom(2500))

proc getRandomInt*(mi:int = 0,ma:int = 1_000_000_000):int =
    ## getRandomInt
    ##
    ## convenience prog so we do not need to import random
    ##
    ## in calling prog

    result = rng.randomInt(mi,ma)


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
    ##    # create a seq with 50 random integers ,between 100 and 2000
    ##    echo createSeqInt(50,100,2000)

    var z = newSeq[int]()
    for x in 0.. <n:
       z.add(getRandomInt(mi,ma))
    result = z




proc harmonics*(n:int64):float64 =
     ## harmonics
     ##
     ## returns a float containing sum of 1 + 1/2 + 1/3 + 1/n
     ##
     if n == 0:
       result = 0.0

     elif n > 0:

        var h = 0.0
        for x in 1.. n:
           var hn = 1.0 / x.float64
           h = h + hn
        result = h

     else:
         msgr() do : echo "Harmonics here defined for positive n only"
         #result = -1


proc getRandomFloat*():float =
    ## getRandomFloat
    ##
    ## convenience prog so we do not need to import random
    ##
    ## in calling prog
    result = rng.random()


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


proc newWord*(minwl:int=3,maxwl:int = 10 ):string =
    ## newWord
    ##
    ## creates a new lower case word with chars from Letters set
    ##
    ## default min word length minwl = 3
    ##
    ## default max word length maxwl = 10
    ##
    var nw = ""
    # words with length range 3 to maxwl
    var maxws = toSeq(minwl.. maxwl)
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



proc doFinish*() =
    ## doFinish
    ##
    ## a end of program routine which displays some information
    ##
    ## can be changed to anything desired
    ##
    decho(2)
    msgb() do : echo "{:<15}{} | {}{} | {}{} - {}".fmt("Application : ",getAppFilename(),"Nim : ",NimVersion,"qqTop private : ",PRIVATLIBVERSION,year(getDateStr()))
    msgy() do : echo "{:<15}{}{}".fmt("Elapsed     : ",epochtime() - private.start," secs")
    echo()
    quit 0


# putting decho here will put two blank lines before anyting else runs
decho(2)
# putting this here we can stop all programs which use this lib and get the desired exit messages
setControlCHook(handler)
# this will reset any color changes in the terminal
# so no need for this line in the calling prog
system.addQuitProc(resetAttributes)
# end of private.nim
