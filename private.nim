{.deadCodeElim: on.}
##
##   Library     : private.nim
##
##   Status      : stable
##
##   License     : MIT opensource
##
##   Version     : 0.9.0
##
##   ProjectStart: 2015-06-20
##
##   Compiler    : Nim 0.11.3 dev
##   
##   OS          : Linux
##
##   Description : private.nim is a public library with a collection of simple procs and templates
##
##                 for easy colored display in a linux terminal , date handling and more
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
import macros

type
      PStyle* = terminal.Style  ## make terminal style constants available in the calling prog
      #Pfg*    = terminal.ForegroundColor     # maybe not longer needed
      #Pbg*    = terminal.BackgroundColor     # maybe not longer needed

const PRIVATLIBVERSION* = "0.9.0"
  

proc getfg(fg:ForegroundColor):string =
    var gFG = ord(fg)
    result = "\e[" & $gFG & 'm'
    
proc getbg(bg:BackgroundColor):string =
    var gBG = ord(bg)
    result = "\e[" & $gBG & 'm'

proc fbright(fg:ForegroundColor): string =
    var gFG = ord(fg)
    inc(gFG, 60)
    result = "\e[" & $gFG & 'm'

proc bbright(bg:BackgroundColor): string =
    var gBG = ord(bg)
    inc(gBG, 60)
    result = "\e[" & $gBG & 'm'


const
      # Terminal ForegroundColor Normal
      
      termred*     = getfg(fgRed)
      termgreen*   = getfg(fgGreen)
      termblue*    = getfg(fgBlue)
      termcyan*    = getfg(fgCyan)
      termyellow*  = getfg(fgYellow)
      termwhite*   = getfg(fgWhite)
      termblack*   = getfg(fgBlack)
      termmagenta* = getfg(fgMagenta)
      
      # Terminal ForegroundColor Bright
       
      brightred*     = fbright(fgRed)
      brightgreen*   = fbright(fgGreen)
      brightblue*    = fbright(fgBlue) 
      brightcyan*    = fbright(fgCyan)
      brightyellow*  = fbright(fgYellow)
      brightwhite*   = fbright(fgWhite)
      brightmagenta* = fbright(fgMagenta)
      brightblack*   = fbright(fgBlack)
       
      clrainbow*   = "clrainbow" 
       
      # Terminal BackgroundColor Normal

      bred*     = getbg(bgRed)
      bgreen*   = getbg(bgGreen)
      bblue*    = getbg(bgBlue)
      bcyan*    = getbg(bgCyan)
      byellow*  = getbg(bgYellow)
      bwhite*   = getbg(bgWhite)
      bblack*   = getbg(bgBlack)
      bmagenta* = getbg(bgMagenta)  
      
      # Terminal BackgroundColor Bright
      
      bbrightred*     = bbright(bgRed)
      bbrightgreen*   = bbright(bgGreen)
      bbrightblue*    = bbright(bgBlue) 
      bbrightcyan*    = bbright(bgCyan)
      bbrightyellow*  = bbright(bgYellow)
      bbrightwhite*   = bbright(bgWhite)
      bbrightmagenta* = bbright(bgMagenta)
      bbrightblack*   = bbright(bgBlack)
     
      # Pastel color set 
      
      pastelgreen*       =  "\x1b[38;2;179;226;205m"
      pastelorange*      =  "\x1b[38;2;253;205;172m"  
      pastelblue*        =  "\x1b[38;2;203;213;232m"
      pastelpink*        =  "\x1b[38;2;244;202;228m"
      pastelyellowgreen* =  "\x1b[38;2;230;245;201m"
      pastelyellow*      =  "\x1b[38;2;255;242;174m"    
      pastelbeige*       =  "\x1b[38;2;241;226;204m"
      pastelwhite*       =  "\x1b[38;2;204;204;204m"
      
      # colors lifted from colors.nim and massaged into rgb escape seqs

      aliceblue*            =  "\x1b[38;2;240;248;255m"
      antiquewhite*         =  "\x1b[38;2;250;235;215m"                                                    
      aqua*                 =  "\x1b[38;2;0;255;255m"                                                      
      aquamarine*           =  "\x1b[38;2;127;255;212m"                                                    
      azure*                =  "\x1b[38;2;240;255;255m"                                                    
      beige*                =  "\x1b[38;2;245;245;220m"                                                    
      bisque*               =  "\x1b[38;2;255;228;196m"                                                    
      black*                =  "\x1b[38;2;0;0;0m"                                                          
      blanchedalmond*       =  "\x1b[38;2;255;235;205m"                                                    
      blue*                 =  "\x1b[38;2;0;0;255m"                                                        
      blueviolet*           =  "\x1b[38;2;138;43;226m"                                                     
      brown*                =  "\x1b[38;2;165;42;42m"                                                      
      burlywood*            =  "\x1b[38;2;222;184;135m"                                                    
      cadetblue*            =  "\x1b[38;2;95;158;160m"                                                     
      chartreuse*           =  "\x1b[38;2;127;255;0m"                                                      
      chocolate*            =  "\x1b[38;2;210;105;30m"                                                     
      coral*                =  "\x1b[38;2;255;127;80m"                                                     
      cornflowerblue*       =  "\x1b[38;2;100;149;237m"                                                    
      cornsilk*             =  "\x1b[38;2;255;248;220m"                                                    
      crimson*              =  "\x1b[38;2;220;20;60m"                                                      
      cyan*                 =  "\x1b[38;2;0;255;255m"                                                      
      darkblue*             =  "\x1b[38;2;0;0;139m"                                                        
      darkcyan*             =  "\x1b[38;2;0;139;139m"                                                      
      darkgoldenrod*        =  "\x1b[38;2;184;134;11m"                                                     
      darkgray*             =  "\x1b[38;2;169;169;169m"                                                    
      darkgreen*            =  "\x1b[38;2;0;100;0m"                                                        
      darkkhaki*            =  "\x1b[38;2;189;183;107m"                                                    
      darkmagenta*          =  "\x1b[38;2;139;0;139m"                                                      
      darkolivegreen*       =  "\x1b[38;2;85;107;47m"                                                      
      darkorange*           =  "\x1b[38;2;255;140;0m"                                                      
      darkorchid*           =  "\x1b[38;2;153;50;204m"                                                     
      darkred*              =  "\x1b[38;2;139;0;0m"                                                        
      darksalmon*           =  "\x1b[38;2;233;150;122m"                                                    
      darkseagreen*         =  "\x1b[38;2;143;188;143m"                                                    
      darkslateblue*        =  "\x1b[38;2;72;61;139m"                                                      
      darkslategray*        =  "\x1b[38;2;47;79;79m"                                                       
      darkturquoise*        =  "\x1b[38;2;0;206;209m"                                                      
      darkviolet*           =  "\x1b[38;2;148;0;211m"                                                      
      deeppink*             =  "\x1b[38;2;255;20;147m"                                                     
      deepskyblue*          =  "\x1b[38;2;0;191;255m"                                                      
      dimgray*              =  "\x1b[38;2;105;105;105m"                                                    
      dodgerblue*           =  "\x1b[38;2;30;144;255m"                                                     
      firebrick*            =  "\x1b[38;2;178;34;34m"                                                      
      floralwhite*          =  "\x1b[38;2;255;250;240m"                                                    
      forestgreen*          =  "\x1b[38;2;34;139;34m"                                                      
      fuchsia*              =  "\x1b[38;2;255;0;255m"                                                      
      gainsboro*            =  "\x1b[38;2;220;220;220m"                                                    
      ghostwhite*           =  "\x1b[38;2;248;248;255m"                                                    
      gold*                 =  "\x1b[38;2;255;215;0m"                                                      
      goldenrod*            =  "\x1b[38;2;218;165;32m"                                                     
      gray*                 =  "\x1b[38;2;128;128;128m"                                                    
      green*                =  "\x1b[38;2;0;128;0m"                                                        
      greenyellow*          =  "\x1b[38;2;173;255;47m"                                                     
      honeydew*             =  "\x1b[38;2;240;255;240m"                                                    
      hotpink*              =  "\x1b[38;2;255;105;180m"                                                    
      indianred*            =  "\x1b[38;2;205;92;92m"                                                      
      indigo*               =  "\x1b[38;2;75;0;130m"                                                       
      ivory*                =  "\x1b[38;2;255;255;240m"                                                    
      khaki*                =  "\x1b[38;2;240;230;140m"                                                    
      lavender*             =  "\x1b[38;2;230;230;250m"                                                    
      lavenderblush*        =  "\x1b[38;2;255;240;245m"                                                    
      lawngreen*            =  "\x1b[38;2;124;252;0m"                                                      
      lemonchiffon*         =  "\x1b[38;2;255;250;205m"                                                    
      lightblue*            =  "\x1b[38;2;173;216;230m"                                                    
      lightcoral*           =  "\x1b[38;2;240;128;128m"                                                    
      lightcyan*            =  "\x1b[38;2;224;255;255m"                                                    
      lightgoldenrodyellow* =  "\x1b[38;2;250;250;210m"                                                   
      lightgrey*            =  "\x1b[38;2;211;211;211m"                                                    
      lightgreen*           =  "\x1b[38;2;144;238;144m"                                                    
      lightpink*            =  "\x1b[38;2;255;182;193m"                                                    
      lightsalmon*          =  "\x1b[38;2;255;160;122m"                                                    
      lightseagreen*        =  "\x1b[38;2;32;178;170m"                                                     
      lightskyblue*         =  "\x1b[38;2;135;206;250m"                                                    
      lightslategray*       =  "\x1b[38;2;119;136;153m"                                                    
      lightsteelblue*       =  "\x1b[38;2;176;196;222m"                                                    
      lightyellow*          =  "\x1b[38;2;255;255;224m"                                                    
      lime*                 =  "\x1b[38;2;0;255;0m"                                                        
      limegreen*            =  "\x1b[38;2;50;205;50m"                                                      
      linen*                =  "\x1b[38;2;250;240;230m"                                                    
      magenta*              =  "\x1b[38;2;255;0;255m"                                                      
      maroon*               =  "\x1b[38;2;128;0;0m"                                                        
      mediumaquamarine*     =  "\x1b[38;2;102;205;170m"                                                    
      mediumblue*           =  "\x1b[38;2;0;0;205m"                                                        
      mediumorchid*         =  "\x1b[38;2;186;85;211m"                                                     
      mediumpurple*         =  "\x1b[38;2;147;112;216m"                                                    
      mediumseagreen*       =  "\x1b[38;2;60;179;113m"                                                     
      mediumslateblue*      =  "\x1b[38;2;123;104;238m"                                                    
      mediumspringgreen*    =  "\x1b[38;2;0;250;154m"                                                      
      mediumturquoise*      =  "\x1b[38;2;72;209;204m"                                                     
      mediumvioletred*      =  "\x1b[38;2;199;21;133m"                                                     
      midnightblue*         =  "\x1b[38;2;25;25;112m"                                                      
      mintcream*            =  "\x1b[38;2;245;255;250m"                                                    
      mistyrose*            =  "\x1b[38;2;255;228;225m"                                                    
      moccasin*             =  "\x1b[38;2;255;228;181m"                                                    
      navajowhite*          =  "\x1b[38;2;255;222;173m"                                                    
      navy*                 =  "\x1b[38;2;0;0;128m"                                                        
      oldlace*              =  "\x1b[38;2;253;245;230m"                                                    
      olive*                =  "\x1b[38;2;128;128;0m"                                                      
      olivedrab*            =  "\x1b[38;2;107;142;35m"                                                     
      orange*               =  "\x1b[38;2;255;165;0m"                                                      
      orangered*            =  "\x1b[38;2;255;69;0m"                                                       
      orchid*               =  "\x1b[38;2;218;112;214m"                                                    
      palegoldenrod*        =  "\x1b[38;2;238;232;170m"                                                    
      palegreen*            =  "\x1b[38;2;152;251;152m"                                                    
      paleturquoise*        =  "\x1b[38;2;175;238;238m"                                                    
      palevioletred*        =  "\x1b[38;2;216;112;147m"                                                    
      papayawhip*           =  "\x1b[38;2;255;239;213m"                                                    
      peachpuff*            =  "\x1b[38;2;255;218;185m"                                                    
      peru*                 =  "\x1b[38;2;205;133;63m"                                                     
      pink*                 =  "\x1b[38;2;255;192;203m"                                                    
      plum*                 =  "\x1b[38;2;221;160;221m"                                                    
      powderblue*           =  "\x1b[38;2;176;224;230m"                                                    
      purple*               =  "\x1b[38;2;128;0;128m"                                                      
      red*                  =  "\x1b[38;2;255;0;0m"                                                        
      rosybrown*            =  "\x1b[38;2;188;143;143m"                                                    
      royalblue*            =  "\x1b[38;2;65;105;225m"                                                     
      saddlebrown*          =  "\x1b[38;2;139;69;19m"                                                      
      salmon*               =  "\x1b[38;2;250;128;114m"                                                    
      sandybrown*           =  "\x1b[38;2;244;164;96m"                                                     
      seagreen*             =  "\x1b[38;2;46;139;87m"                                                      
      seashell*             =  "\x1b[38;2;255;245;238m"                                                    
      sienna*               =  "\x1b[38;2;160;82;45m"                                                      
      silver*               =  "\x1b[38;2;192;192;192m"                                                    
      skyblue*              =  "\x1b[38;2;135;206;235m"                                                    
      slateblue*            =  "\x1b[38;2;106;90;205m"                                                     
      slategray*            =  "\x1b[38;2;112;128;144m"                                                    
      snow*                 =  "\x1b[38;2;255;250;250m"                                                    
      springgreen*          =  "\x1b[38;2;0;255;127m"                                                      
      steelblue*            =  "\x1b[38;2;70;130;180m"                                                     
      tan*                  =  "\x1b[38;2;210;180;140m"                                                    
      teal*                 =  "\x1b[38;2;0;128;128m"                                                      
      thistle*              =  "\x1b[38;2;216;191;216m"                                                    
      tomato*               =  "\x1b[38;2;255;99;71m"                                                      
      turquoise*            =  "\x1b[38;2;64;224;208m"                                                     
      violet*               =  "\x1b[38;2;238;130;238m"                                                    
      wheat*                =  "\x1b[38;2;245;222;179m"
      white*                =  "\x1b[38;2;255;255;255m"    # same as brightwhite
      whitesmoke*           =  "\x1b[38;2;245;245;245m"
      yellow*               =  "\x1b[38;2;255;255;0m"
      yellowgreen*          =  "\x1b[38;2;154;205;50m"





const number0 =
 @["██████"
  ,"██  ██"
  ,"██  ██"
  ,"██  ██"
  ,"██████"]
  
const number1 =
 @["    ██"
  ,"    ██"
  ,"    ██"
  ,"    ██"
  ,"    ██"]
const number2 =
 @["██████"
  ,"    ██"
  ,"██████"
  ,"██    "
  ,"██████"]
  
const number3 =
 @["██████"
  ,"    ██"
  ,"██████"
  ,"    ██"
  ,"██████"]
  
const number4 =
 @["██  ██"
  ,"██  ██"
  ,"██████"
  ,"    ██"
  ,"    ██"]
const number5 =
 @["██████"
  ,"██    "
  ,"██████"
  ,"    ██"
  ,"██████"]
  
const number6 =
 @["██████"
  ,"██    "
  ,"██████"
  ,"██  ██"
  ,"██████"]
  
const number7 =
 @["██████"
  ,"    ██"
  ,"    ██"
  ,"    ██"
  ,"    ██"]
  
const number8 =
 @["██████"
  ,"██  ██"
  ,"██████"
  ,"██  ██"
  ,"██████"]
  
const number9 =
 @["██████"
  ,"██  ██"
  ,"██████"
  ,"    ██"
  ,"██████"]
  
 

const colon =
 @["      "
  ,"  ██  "
  ,"      "
  ,"  ██  "
  ,"      "]

const numberlen = 4


const snumber0 = 
  @["┌─┐",
    "│ │",
    "└─┘"]


const snumber1 = 
  @["  ╷",
    "  │",
    "  ╵"]
  
const snumber2 = 
   @["╶─┐",
     "┌─┘",
     "└─╴"]
   
   
const snumber3 =
  @["╶─┐",
    "╶─┤",
    "╶─┘"]
  
const snumber4 = 
  @["╷ ╷",
    "└─┤",
    "  ╵"]
  
const snumber5 = 
  @["┌─╴",  
    "└─┐",
    "╶─┘"]

const snumber6 = 
  @["┌─╴",
    "├─┐",
    "└─┘"]
  
const snumber7 = 
  @["╶─┐",  
    "  │",
    "  ╵"]
  
const snumber8 =
  @["┌─┐",  
    "├─┤",
    "└─┘"]
  
const snumber9 = 
  @["┌─┐",
    "└─┤",
    "╶─┘"] 
  
  
const scolon =
  @[" ╷",
    " ╷",   
    "  "]
  
  
const scomma = 
   @["  ",
     "  ",
     " ╷"]
   
const sdot = 
   @["  ",
     "  ",
     " ."]

const snumberlen = 2

# all colors except original terminal colors
let colorNames* = @[
      ("aliceblue", aliceblue),
      ("antiquewhite", antiquewhite),
      ("aqua", aqua),
      ("aquamarine", aquamarine),
      ("azure", azure),
      ("beige", beige),
      ("bisque", bisque),
      ("black", black),
      ("blanchedalmond", blanchedalmond),
      ("blue", blue),
      ("blueviolet", blueviolet),
      ("brown", brown),
      ("burlywood", burlywood),
      ("cadetblue", cadetblue),
      ("chartreuse", chartreuse),
      ("chocolate", chocolate),
      ("coral", coral),
      ("cornflowerblue", cornflowerblue),
      ("cornsilk", cornsilk),
      ("crimson", crimson),
      ("cyan", cyan),
      ("darkblue", darkblue),
      ("darkcyan", darkcyan),
      ("darkgoldenrod", darkgoldenrod),
      ("darkgray", darkgray),
      ("darkgreen", darkgreen),
      ("darkkhaki", darkkhaki),
      ("darkmagenta", darkmagenta),
      ("darkolivegreen", darkolivegreen),
      ("darkorange", darkorange),
      ("darkorchid", darkorchid),
      ("darkred", darkred),
      ("darksalmon", darksalmon),
      ("darkseagreen", darkseagreen),
      ("darkslateblue", darkslateblue),
      ("darkslategray", darkslategray),
      ("darkturquoise", darkturquoise),
      ("darkviolet", darkviolet),
      ("deeppink", deeppink),
      ("deepskyblue", deepskyblue),
      ("dimgray", dimgray),
      ("dodgerblue", dodgerblue),
      ("firebrick", firebrick),
      ("floralwhite", floralwhite),
      ("forestgreen", forestgreen),
      ("fuchsia", fuchsia),
      ("gainsboro", gainsboro),
      ("ghostwhite", ghostwhite),
      ("gold", gold),
      ("goldenrod", goldenrod),
      ("gray", gray),
      ("green", green),
      ("greenyellow", greenyellow),
      ("honeydew", honeydew),
      ("hotpink", hotpink),
      ("indianred", indianred),
      ("indigo", indigo),
      ("ivory", ivory),
      ("khaki", khaki),
      ("lavender", lavender),
      ("lavenderblush", lavenderblush),
      ("lawngreen", lawngreen),
      ("lemonchiffon", lemonchiffon),
      ("lightblue", lightblue),
      ("lightcoral", lightcoral),
      ("lightcyan", lightcyan),
      ("lightgoldenrodyellow", lightgoldenrodyellow),
      ("lightgrey", lightgrey),
      ("lightgreen", lightgreen),
      ("lightpink", lightpink),
      ("lightsalmon", lightsalmon),
      ("lightseagreen", lightseagreen),
      ("lightskyblue", lightskyblue),
      ("lightslategray", lightslategray),
      ("lightsteelblue", lightsteelblue),
      ("lightyellow", lightyellow),
      ("lime", lime),
      ("limegreen", limegreen),
      ("linen", linen),
      ("magenta", magenta),
      ("maroon", maroon),
      ("mediumaquamarine", mediumaquamarine),
      ("mediumblue", mediumblue),
      ("mediumorchid", mediumorchid),
      ("mediumpurple", mediumpurple),
      ("mediumseagreen", mediumseagreen),
      ("mediumslateblue", mediumslateblue),
      ("mediumspringgreen", mediumspringgreen),
      ("mediumturquoise", mediumturquoise),
      ("mediumvioletred", mediumvioletred),
      ("midnightblue", midnightblue),
      ("mintcream", mintcream),
      ("mistyrose", mistyrose),
      ("moccasin", moccasin),
      ("navajowhite", navajowhite),
      ("navy", navy),
      ("oldlace", oldlace),
      ("olive", olive),
      ("olivedrab", olivedrab),
      ("orange", orange),
      ("orangered", orangered),
      ("orchid", orchid),
      ("palegoldenrod", palegoldenrod),
      ("palegreen", palegreen),
      ("paleturquoise", paleturquoise),
      ("palevioletred", palevioletred),
      ("papayawhip", papayawhip),
      ("peachpuff", peachpuff),
      ("peru", peru),
      ("pink", pink),
      ("plum", plum),
      ("powderblue", powderblue),
      ("purple", purple),
      ("red", red),
      ("rosybrown", rosybrown),
      ("royalblue", royalblue),
      ("saddlebrown", saddlebrown),
      ("salmon", salmon),
      ("sandybrown", sandybrown),
      ("seagreen", seagreen),
      ("seashell", seashell),
      ("sienna", sienna),
      ("silver", silver),
      ("skyblue", skyblue),
      ("slateblue", slateblue),
      ("slategray", slategray),
      ("snow", snow),
      ("springgreen", springgreen),
      ("steelblue", steelblue),
      ("tan", tan),
      ("teal", teal),
      ("thistle", thistle),
      ("tomato", tomato),
      ("turquoise", turquoise),
      ("violet", violet),
      ("wheat", wheat),
      ("white", white),
      ("whitesmoke", whitesmoke),
      ("yellow", yellow),
      ("yellowgreen", yellowgreen),
      ("pastelbeige",pastelbeige),
      ("pastelblue",pastelblue),
      ("pastelgreen",pastelgreen),
      ("pastelorange",pastelorange),
      ("pastelpink",pastelpink),
      ("pastelwhite",pastelwhite),
      ("pastelyellow",pastelyellow),
      ("pastelyellowgreen",pastelyellowgreen)]


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


# forward declarations
converter colconv(cx:string) : string
proc printColStr*(colstr:string,astr:string)  ## forward declaration
proc printLnColStr*(colstr:string,mvastr: varargs[string, `$`]) ## forward declaration
proc printBiCol*(s:string,sep:string,colLeft:string = yellowgreen ,colRight:string = termwhite) ## forward declaration
proc printLnBiCol*(s:string,sep:string,colLeft:string = yellowgreen ,colRight:string = termwhite) ## forward declaration
proc rainbow*[T](s : T)  ## forward declaration
proc printStyledsimple*[T](ss:T,fg:string,astyle:set[Style]) ## forward declaration
proc printStyled*[T](ss:T,substr:string,col:string,astyle : set[Style]) ## forward declaration
proc print*[T](astring:T,fgr:string = white , bgr:string = black) 
proc hline*(n:int = tw,col:string = white) ## forward declaration
proc hlineLn*(n:int = tw,col:string = white) ## forward declaration

# procs lifted from terminal.nim as they are not exported from there
proc styledEchoProcessArg(s: string) = write stdout, s
proc styledEchoProcessArg(style: Style) = setStyle({style})
proc styledEchoProcessArg(style: set[Style]) = setStyle style
proc styledEchoProcessArg(color: ForegroundColor) = setForegroundColor color
proc styledEchoProcessArg(color: BackgroundColor) = setBackgroundColor color

# macros

macro styledEchoPrint*(m: varargs[expr]): stmt =
  ## lifted from terminal.nim and removed new line 
  ## used in printStyled
  ## 
  let m = callsite()
  result = newNimNode(nnkStmtList)

  for i in countup(1, m.len - 1):
      result.add(newCall(bindSym"styledEchoProcessArg", m[i]))

  result.add(newCall(bindSym"write", bindSym"stdout", newStrLitNode("")))
  result.add(newCall(bindSym"resetAttributes"))


# templates


template msgg*(code: stmt): stmt =
      ## msgX templates
      ## convenience templates for colored text output
      ## the assumption is that the terminal is white text and black background
      ## naming of the templates is like msg+color so msgy => yellow
      ## use like : msgg() do : echo "How nice, it's in green"
      ## these templates have by large been superceded by various print and echo procs
      ## but are useful to have ins ome circumstances 
      ## like draw a yellow line with width 40   
      ## 
      ## 
      ## .. code-block:: nim
      ##  msgy() do: echo "yellow" 
      ##  
      ##  

      setForeGroundColor(fgGreen)
      code
      setForeGroundColor(fgWhite)


template msggb*(code: stmt): stmt   =
      setForeGroundColor(fgGreen,true)
      code
      setForeGroundColor(fgWhite)


template msgy*(code: stmt): stmt =
      setForeGroundColor(fgYellow)
      code
      setForeGroundColor(fgWhite)


template msgyb*(code: stmt): stmt =
      setForeGroundColor(fgYellow,true)
      code
      setForeGroundColor(fgWhite)

template msgr*(code: stmt): stmt =
      setForeGroundColor(fgRed)
      code
      setForeGroundColor(fgWhite)

template msgrb*(code: stmt): stmt =
      setForeGroundColor(fgRed,true)
      code
      setForeGroundColor(fgWhite)

template msgc*(code: stmt): stmt =
      setForeGroundColor(fgCyan)
      code
      setForeGroundColor(fgWhite)

template msgcb*(code: stmt): stmt =
      setForeGroundColor(fgCyan,true)
      code
      setForeGroundColor(fgWhite)

template msgw*(code: stmt): stmt =
      setForeGroundColor(fgWhite)
      code
      setForeGroundColor(fgWhite)

template msgwb*(code: stmt): stmt =
      setForeGroundColor(fgWhite,true)
      code
      setForeGroundColor(fgWhite)

template msgb*(code: stmt): stmt =
      setForeGroundColor(fgBlack,true)
      code
      setForeGroundColor(fgWhite)
      
template msgbb*(code: stmt): stmt =
      # invisible on black background 
      setForeGroundColor(fgBlack)
      code
      setForeGroundColor(fgWhite)
  
template msgbl*(code: stmt): stmt =
      setForeGroundColor(fgBlue)
      code
      setForeGroundColor(fgWhite)  
  
template msgblb*(code: stmt): stmt =
      setForeGroundColor(fgBlue,true)
      code
      setForeGroundColor(fgWhite)    
  
template msgm*(code: stmt): stmt =
      setForeGroundColor(fgMagenta)
      code
      setForeGroundColor(fgWhite)  
  
template msgmb*(code: stmt): stmt =
      setForeGroundColor(fgMagenta,true)
      code
      setForeGroundColor(fgWhite)    

  
template hdx*(code:stmt):stmt =
   echo ""
   echo repeat("+",tw)
   setForeGroundColor(fgCyan)
   code
   setForeGroundColor(fgWhite)
   echo repeat("+",tw)
   echo ""
      
template prxBCol():stmt = 
      ## internal template
      setForeGroundColor(fgWhite)
      setBackGroundColor(bgblack)


template withFile*(f: expr, filename: string, mode: FileMode, body: stmt): stmt {.immediate.} =
     ## withFile
     ##
     ## file open close utility template
     ##
     ## Example 1
     ##
     ## .. code-block:: nim
     ##   let curFile="/data5/notes.txt"    # some file
     ##   withFile(txt, curFile, fmRead):
     ##       while true:
     ##          try:
     ##             printLnW(txt.readLine())   # do something with the lines
     ##          except:
     ##             break
     ##   echo()
     ##   printLn("Finished",clRainbow)
     ##   doFinish()
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
     ##    printLn("Finished",clRainbow)
     ##    doFinish()
     ##

     let fn = filename
     var f: File

     if open(f, fn, mode):
         try:
             body
         finally:
             close(f)
     else:
         echo ()
         printLnBiCol("Error : Cannot open file " & curFile,":",red,yellow)
         quit()

# proc clear*() =
#   ## clear
#   ## 
#   ## clear screen with escape seqs
#   ## 
#   print("\e[H\e[J") 
#      
   
proc checkColor*(colname: string): bool =
     ## checkColor
     ## 
     ## returns true if colname is a known color name , obviously
     ## 
     ## 
     for x in  colorNames:
       if x[0] == colname: 
          result = true
          break
       else:
          result = false
  

# output  horizontal lines

proc hline*(n:int = tw,col:string = white) =
     ## hline
     ## 
     ## draw a full line in stated length and color no linefeed will be issued
     ## 
     ## defaults full terminal width and white
     ## 
     ## .. code-block:: nim
     ##    hline(30,green)
     ##     
     
     printColStr(col,repeat("_",n))
          


proc hlineLn*(n:int = tw,col:string = white) =
     ## hlineLn
     ## 
     ## draw a full line in stated length and color a linefeed will be issued
     ## 
     ## defaults full terminal width and white
     ## 
     ## .. code-block:: nim
     ##    hlineLn(30,green)
     ##     
     printColStr(col,repeat("_",n))
     writeLine(stdout,"") 
     


proc dline*(n:int = tw,lt:string = "-",col:string = termwhite) =
     ## dline
     ## 
     ## draw a dashed line with given length in current terminal font color
     ## line char can be changed
     ## 
     ## .. code-block:: nim
     ##    dline(30)
     ##    dline(30,"/+") 
     ##    dline(30,col= yellow)
     ## 
     if lt.len <= n:
         #writeLine(stdout,repeat(lt,n div lt.len))
         printColStr(col,repeat(lt,n div lt.len))
     

proc dlineLn*(n:int = tw,lt:string = "-",col:string = termwhite) =
     ## dlineLn
     ## 
     ## draw a dashed line with given length in current terminal font color
     ## line char can be changed
     ## 
     ## and issue a new line
     ## 
     ## .. code-block:: nim
     ##    dline(50,":",green)
     ##    dlineLn(30)
     ##    dlineLn(30,"/+/")
     ##    dlineLn(60,col = salmon) 
     ##
     if lt.len <= n:
         printColStr(col,repeat(lt,n div lt.len))
     writeLine(stdout,"")   
 
proc decho*(z:int = 1)  =
    ## decho
    ##
    ## blank lines creator
    ##
    ## .. code-block:: nim
    ##    decho(10)
    ## to create 10 blank lines
    for x in 0.. <z:
        writeLine(stdout,"")


# simple navigation

proc curUp*(x:int = 1) =
     ## curUp
     ## 
     ## mirrors terminal cursorUp
     cursorUp(stdout,x)


proc curDn*(x:int = 1) = 
     ## curDn
     ##
     ## mirrors terminal cursorDown
     cursorDown(stdout,x)


proc clearup*(x:int = 80) =
   ## clearup
   ## 
   ## a convenience proc to clear monitor
   ##
   
   erasescreen(stdout)
   curup(x)


 
converter colconv(cx:string) : string = 
     # converter so we can use the same terminal color names for
     # fore- and background colors in print and printLn procs.
     var bg : string = ""
     case cx
      of black        : bg = bblack
      of white        : bg = bwhite
      of green        : bg = bgreen
      of yellow       : bg = byellow
      of cyan         : bg = bcyan
      of magenta      : bg = bmagenta
      of red          : bg = bred
      of blue         : bg = bblue
      of brightred    : bg = bbrightred
      of brightgreen  : bg = bbrightgreen 
      of brightblue   : bg = bbrightblue  
      of brightcyan   : bg = bbrightcyan  
      of brightyellow : bg = bbrightyellow 
      of brightwhite  : bg = bbrightwhite 
      of brightmagenta: bg = bbrightmagenta 
      of brightblack  : bg = bbrightblack
      of gray         : bg = gray
      else            : bg = bblack # default
     result = bg


proc rainbow*[T](s : T) =
    ## rainbow
    ##
    ## multicolored string
    ##
    ## may not work with certain Rune
    ##
    var astr = $s
    var c = 0
    var a = toSeq(1.. <colorNames.len)
    for x in 0.. <astr.len:
       c = a[randomInt(a.len)]
       print(astr[x],colorNames[c][1],black)


proc print*[T](astring:T,fgr:string = white , bgr:string = black) =
    ## print
    ##
    ## same as printLn without new line
    ##
    ## for extended colorset background colors use printStyled with styleReverse
    ## 
    ## also see cecho 
    ##
    ##
    case fgr 
      of clrainbow: rainbow($astring)
      else:  stdout.write(fgr & colconv(bgr) & $astring)
    prxBCol()
    

proc printLn*[T](astring:T,fgr:string = white , bgr:string = black) =
    ## printLn
    ## 
    ## similar to echo but with foregroundcolor and backgroundcolor
    ## 
    ## selection.
    ## 
    ## see testPrintLn.nim for usage examples
    ## 
    ## all colornames are supported for font color:
    ## 
    ## color names supported for background color:
    ## 
    ## white,red,green,blue,yellow,cyan,magenta,black
    ## 
    ## brightwhite,brightred,brightgreen,brightblue,brightyellow,
    ## 
    ## brightcyan,brightmagenta,brightblack
    ## 
    ## .. code-block:: nim
    ##    printLn("Yes ,  we made it.",clrainbow,brightyellow) # background has no effect with font in  clrainbow
    ##    printLn("Yes ,  we made it.",green,brightyellow) 
    ##
    ## 
    ## As a side effect we also can do this now :
    ## 
    ## 
    ## .. code-block:: nim
    ##    echo(yellowgreen,"aha nice",termwhite) 
    ##    echo(rosybrown)
    ##    echo("grizzly bear")
    ##    echo(termwhite)  # reset to usual terminal white color
    ## 
    ## 
    ## that is we print the string in yellowgreen , but need to reset the color manually
    ## 
    ## 
    ## also see cechoLn  
    ## 
    ## 
    print(astring,fgr,bgr)       
    stdout.writeLine("")
    


# Var. convenience procs for colorised data output
# these procs have similar functionality  
# print and printLn tokenize strings for selective coloring if required
# and can be used for most standard echo like displaying jobs

proc printTK*[T](st:T , cols: varargs[string, `$`] = @[white] ) =
     ## printTK
     ##
     ## echoing of colored tokenized strings  without newline
     ## 
     ## strings will be tokenized and colored according to colors in cols
     ## 
     ## NOTE : this proc does not play well with Nimborg/high_level.nim
     ##        if using nimborg have another module with all nimborg related
     ##        processing there and import procs from this module into the main prog.
     ##     
     ##         
     ## .. code-block:: nim
     ##    import private,strfmt
     ##    printTK("test",@[clrainbow,white,red,cyan,yellow])
     ##    printTK("{} {} {}  -->   {}".fmt(123,"Nice",456,768.5),green,white,red,cyan)
     ##    printTK("{} : {} {}  -->   {}".fmt(123,"Nice",456,768.5),green,brightwhite,clrainbow,red,cyan)
     ##    printTK("blah",green,white,red,cyan) 
     ##    printTK(@[123,123,123],white,green,white)
     ##    printTK("blah yep 1234      333122.12  [12,45] wahahahaha",@[green,brightred,black,yellow,cyan,clrainbow])
     ##
     ##
     ## another way to achieve a similar effect is to use the build in
     ## styledEcho template directly like so:
     ##
     ## .. code-block:: nim
     ##    styledEcho(green,"Nice ","try ",pastelgreen,"1234 ",steelblue," yep blue")
     ##  
     ## styledEcho also supports styles so this also works
     ## 
     ## .. code-block:: nim
     ##    styledEcho(green,"Nice ","try ",pastelgreen,styleUnderscore,"1234 ",steelblue," yep blue")
     ##  
     ## 
            
     var pcol = ""
     var c = 0  
     var s = $st  
     for x in s.tokenize():
          if x.isSep == false:
                if c < cols.len:
                    pcol = $cols[c]
                else :
                    pcol = white 
                    
                print(x.token,pcol)
                c += 1
              
          else:
                write(stdout,x.token)
        

proc printLnTK*[T](st:T , cols: varargs[string, `$`]) =
     ## printLnTK
     ##
     ## displays colored tokenized strings and issues a newline when finished
     ## 
     ## strings will be tokenized and colored according to colors in cols
     ## 
     ## NOTE : this proc does not play well with Nimborg/high_level.nim
     ##        if using nimborg have another module with all nimborg related
     ##        processing there and import procs from this module into the main prog.
     ## 
     ## 
     ## .. code-block:: nim
     ##    printLnTK(@[123,456,789],@[clrainbow,white,red,cyan,yellow])
     ##    printLnTK("{} {} {}  -->   {}".fmt(123,"Nice",456,768.5),green,white,red,cyan)
     ##    printLnTK("{} : {} {}  -->   {}".fmt(123,"Nice",456,768.5),green,brightwhite,clrainbow,red,cyan)
     ##    printLnTK("blah",green,white,red,cyan)    
     ##    printLnTK("blah yep 1234      333122.12  [12,45] wahahahaha",@[green,brightred,black,yellow,cyan,clrainbow])
     ##
     printTK(st,cols)
     writeLine(stdout,"")
   
     

proc printRainbow*[T](s : T,astyle:set[Style]) =
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
    
    var astr = $s
    var c = 0
    var a = toSeq(1.. <colorNames.len)
    for x in 0.. <astr.len:
       c = a[randomInt(a.len)]
       printStyled($astr[x],"",colorNames[c][1],astyle)
    
    
proc printLnRainbow*[T](s : T,astyle:set[Style]) =
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
    printRainBow(s,astyle)  
    writeln(stdout,"")
    


proc printColStr*(colstr:string,astr:string) =
     
      ## printColStr
      ##
      ## prints a string with a named color in colstr
      ##
    
      ## .. code-block:: nim
      ##    printColStr(yellowgreen,"Nice, it is in yellowgreen !")
      ##
      print(astr,colstr)


proc printLnColStr*(colstr:string,mvastr: varargs[string, `$`]) =
    ## printLnColStr
    ##
    ## similar to printColStr but issues a writeLine() command that is
    ##
    ## every item will be shown on a new line in the same given color
    ##
    ## and most everything passed in will be converted to string
    ##
    ## .. code-block:: nim
    ##    printLnColStr lightsalmon,"Nice try 1", 2.52234, @[4, 5, 6]
    ##

    for vastr in mvastr:
        printLn(vastr,colstr)


proc printBiCol*(s:string,sep:string,colLeft:string = yellowgreen ,colRight:string = termwhite) =
     ## printBiCol
     ##
     ## echos a line in 2 colors based on a seperators first occurance
     ## 
     ## .. code-block:: nim
     ##    import private,strutils,strfmt
     ##    
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
     print(z[0] & sep,colLeft,black)
     print(z[1],colRight,black)  
     


proc printLnBiCol*(s:string,sep:string, colLeft:string = yellowgreen, colRight:string = termwhite) =
     ## printLnBiCol
     ##
     ## same as printBiCol but issues a new line
     ## 
     ## .. code-block:: nim
     ##    import private,strutils,strfmt
     ##       
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
     print(z[0] & sep,colLeft,black)
     printLn(z[1],colRight,black)  
          


proc printHl*(s:string,substr:string,col:string = termwhite) =
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
   
      var rx = s.split(substr)
      for x in rx.low.. rx.high:
          print(rx[x])
          if x != rx.high:
             print(substr,col)


proc printLnHl*(s:string,substr:string,col:string = termwhite) =
      ## printHl
      ##
      ## print and highlight all appearances of a char or substring of a string
      ##
      ## with a certain color and issue a new line
      ##
      ## .. code-block:: nim
      ##    printHl("HELLO THIS IS A TEST","T",yellowgreen)
      ##
      ## this would highlight all T in yellowgreen
      ##
     
      printHl(s,substr,col)
      writeln(stdout,"")


proc printStyledSimple*[T](ss:T,fg:string,astyle:set[Style]) =
   ## printStyledsimple
   ## 
   ## an extended version of writestyled to enable colors
   ##
   ## 
   var astr = $ss
   case fg 
      of clrainbow   : printRainbow($astr,astyle)
      else: styledEchoPrint(fg,astyle,$astr,termwhite)
      

proc printStyled*[T](ss:T,substr:string,col:string,astyle : set[Style] ) =
      ## printStyled
      ##
      ## extended version of writestyled and printHl to allow color and styles
      ##
      ## to print and highlight all appearances of a substring 
      ##
      ## styles may and in some cases not have the desired effect
      ## 
      ## available styles :
      ## 
      ## styleBright = 1,            # bright text
      ## 
      ## styleDim,                   # dim text
      ## 
      ## styleUnknown,               # unknown
      ## 
      ## styleUnderscore = 4,        # underscored text
      ## 
      ## styleBlink,                 # blinking/bold text
      ## 
      ## styleReverse = 7,           # reverses currentforground and backgroundcolor
      ## 
      ## styleHidden                 # hidden text
      ## 
      ##
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
      var s = $ss                  
      if substr.len > 0:
          var rx = s.split(substr)
          for x in rx.low.. rx.high:
              writestyled(rx[x],{})
              if x != rx.high:
                case col 
                  of clrainbow   : printRainbow(substr,astyle)
                  else: styledEchoPrint(col,astyle,substr,termwhite) 
      else:
          printStyledSimple(s,col,astyle)

      

proc printLnStyled*[T](ss:T,substr:string,col:string,astyle : set[Style] ) =
      ## printLnStyled
      ##
      ## extended version of writestyled and printHl to allow color and styles
      ##
      ## to print and highlight all appearances of a substring and issue a new line
      ##
      ## styles may and in some cases not have the desired effect
      ##
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
      ##                    
      printStyled($ss,substr,col,astyle)
      writeLine(stdout,"")


proc cecho*(col:string,ggg: varargs[string, `$`] = @[""] ) =
      ## cecho
      ## 
      ## color echo w/o new line this also automically resets the color attribute
      ## 
      ## 
      ## .. code-block:: nim
      ##     import private,strfmt
      ##     cechoLn(salmon,"{:<10} : {} ==> {} --> {}".fmt("this ", "zzz ",123 ," color is something else"))
      ##     echo("ok")  # color resetted
      ##     echo(salmon,"{:<10} : {} ==> {} --> {}".fmt("this ", "zzz ",123 ," color is something else"))
      ##     echo("ok")  # still salmon
       
      case col 
       of clrainbow : 
                for x  in ggg:
                     rainbow(x)
       else:
         write(stdout,col) 
         write(stdout,ggg)
      write(stdout,termwhite)

proc cechoLn*(col:string,ggg: varargs[string, `$`] = @[""] ) =
      ## cechoLn
      ##  
      ## color echo with new line
      ## 
      ## 
      ## .. code-block:: nim
      ##     import private,strutils
      ##     cechoLn(steelblue,"We made it in $1 hours !" % $5)
      ##
      ## 
      cecho(col,ggg)
      writeLn(stdout,"")

  
proc showColors*() =
  ## showColors
  ## 
  ## display all colorNames in color !
  ## 
  for x in colorNames:
     print("{:<23} {}  {}  {} --> {} ".fmt(x[0] , repeat("▒",10), repeat("⌘",10) ,"ABCD abcd 1234567890"," Nim Colors " ),x[1],black)  # note x[1] is the color itself.
     printLnStyled("{:<23}".fmt("  " & x[0]),"{:<23}".fmt("  " & x[0]),x[1],{styleReverse})
     
  decho(2)   
  
 

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
          cechoLn(red,"Date error. : " &  startDate,"/",endDate," incorrect date found.")
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
    # cechoLn(red,"Loops during waiting for ",s,"secs : ",c)


proc printBigNumber*(anumber:string,fgr:string = yellowgreen ,bgr:string = black,xpos:int = 1) =
    ## printBigNumber
    ## 
    ## prints a string in big block font
    ## 
    ## available 1234567890:
    ## 
    ## 
    ## usufull for big counter etc , a clock can also be build easily but
    ## running in a tight while loop just uses up cpu cycles needlessly.
    ## 
    ## .. code-block:: nim
    ##    for x in 990.. 1005:
    ##         clearup()
    ##         printBigNumber($x)
    ##         sleepy(0.008)
    ##
    ##    decho(5)   
    ##    
    ##    printBigNumber($23456345,steelblue)
    ##
    ## 
    
    var asn = newSeq[string]()
    var printseq = newSeq[seq[string]]()
    for x in anumber: asn.add($x)
    #echo asn
    for x in asn:
      case  x 
        of "0": printseq.add(number0)
        of "1": printseq.add(number1)
        of "2": printseq.add(number2)
        of "3": printseq.add(number3)
        of "4": printseq.add(number4)
        of "5": printseq.add(number5)
        of "6": printseq.add(number6)
        of "7": printseq.add(number7)
        of "8": printseq.add(number8)
        of "9": printseq.add(number9)
        of ":": printseq.add(colon)
        else: discard
          
    for x in 0.. numberlen:
        print repeat(" ",xpos) 
        for y in 0.. <printseq.len:
            print(" " & printseq[y][x],fgr,bgr)
        echo()   



proc printSlimNumber*(anumber:string,fgr:string = yellowgreen ,bgr:string = black,xpos:int = 1) =
    ## printBigNumber
    ## 
    ## prints an string in big block font
    ## 
    ## available chars 123456780,.:
    ## 
    ## 
    ## usufull for big counter etc , a clock can also be build easily but
    ## running in a tight while loop just uses up cpu cycles needlessly.
    ## 
    ## .. code-block:: nim
    ##    for x in 990.. 1005:
    ##         clearup()
    ##         printSlimNumber($x)
    ##         sleepy(0.075)
    ##    echo()   
    ##
    ##    printSlimNumber($23456345,blue)
    ##    decho(2)
    ##    printSlimNumber("1234567:345,23.789",fgr=salmon,xpos=20)
    ##    decho(5)  
    ##    import times
    ##    printSlimNumber($getClockStr(),fgr=salmon,xpos=20)
    ##    decho(5)
    ## 
    
    var asn = newSeq[string]()
    var printseq = newSeq[seq[string]]()
    for x in anumber: asn.add($x)
    #echo asn
    for x in asn:
      case  x 
        of "0": printseq.add(snumber0)
        of "1": printseq.add(snumber1)
        of "2": printseq.add(snumber2)
        of "3": printseq.add(snumber3)
        of "4": printseq.add(snumber4)
        of "5": printseq.add(snumber5)
        of "6": printseq.add(snumber6)
        of "7": printseq.add(snumber7)
        of "8": printseq.add(snumber8)
        of "9": printseq.add(snumber9)
        of ":": printseq.add(scolon)
        of ",": printseq.add(scomma)
        of ".": printseq.add(sdot)
        else: discard
          
    for x in 0.. snumberlen:
        print repeat(" ",xpos) 
        for y in 0.. <printseq.len:
            print(" " & printseq[y][x],fgr,bgr)
        echo()   









proc dayOfWeekJulianA*(day, month, year: int): WeekDay =
  #
  # may be part of times.nim later
  # This is for the Julian calendar
  # Day & month start from one.
  # original code from coffeepot 
  # but seems to be off for dates after 2100-03-01 which should be a monday 
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
      cechoLn(red,"Date error : ",aDate)
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
      cechoLn(red,"Date error : ",aDate)
      result = "Error"



proc getFirstMondayYear*(ayear:string):string = 
    ## getFirstMondayYear
    ## 
    ## returns date of first monday of any given year
    ## should be ok for the next years but after 2100-02-28 all bets are off
    ## 
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
        print("Error received a date with value : nil",red)
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
  
  # some framechars
  #let framechar = "▒"
  let framechar = "⌘"  
  let pdl = repeat(framechar,mddl)  
  # now show it with the framing in yellow and text in white
  # really want a terminal color checker to avoid invisible lines
  echo ()
  printLn(pdl,yellowgreen)
  print(framechar & " ",yellowgreen)
  print(astring)
  printLn(" " & framechar,yellowgreen)
  printLn(pdl,yellowgreen)
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

    let framechar = "⌘"
    let pdl = repeat(framechar,mddl)
    # now show it with the framing in yellow and text in white
    # really want to have a terminal color checker to avoid invisible lines
    echo ()

    # frame line
    proc frameline(pdl:string) =
        print(pdl,frmcol)
        echo()

    proc framemarker(am:string) =
        print(am,frmcol)
        
    proc headermessage(astring:string)  =
        print(astring,strcol)
        

    # draw everything
    frameline(pdl)
    #left marker
    framemarker(framechar & " ")
    # header message sring
    headermessage(astring)
    # right marker
    framemarker(" " & framechar)
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
              curup(80)
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
       print("Check Heroku Status : https://status.heroku.com",red)
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
     printBiCol("Current Wan Ip  : " & getwanip(),":",yellowgreen,gray)
 

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
      printLn("Ip-Info for " & ip,lightsteelblue)
      dline(40,col = yellow)
      for x in jz.getfields():
          echo "{:<15} : {}".fmt($x.key,$x.val)
      printLnBiCol("{:<15} : {}".fmt("Source","ip-api.com"),":",yellowgreen,salmon)



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
    cechoLn(yellowgreen,"Hosts Data for " & dm)
    var z = getHosts(dm)
    if z.len < 1:
         printLn("Nothing found or not resolved",red)
    else:
       for x in z:
         printLn(x)


# Convenience procs for random data creation and handling


# init the MersenneTwister
var rng = initMersenneTwister(urandom(2500))


proc getRandomInt*(mi:int = 0,ma:int = int.high):int =
    ## getRandomInt
    ##
    ## convenience proc so we do not need to import random in calling prog
    ##
    ##
    ## .. code-block:: nim
    ##    import private,math
    ##    var ps : Runningstat
    ##    loopy(0.. 1000000,ps.push(getRandomInt(0,10000)))
    ##    showStats(ps)
    ##    doFinish()
    ##    
    ##    


    result = rng.randomInt(mi,ma + 1)


proc createSeqInt*(n:int = 10,mi:int=0,ma:int=int.high) : seq[int] =
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
    if mi <= ma:
      for x in 0.. <n:
         z.add(getRandomInt(mi,ma))
      result = z   
    else:
      print("Error : Wrong parameters for min , max ",red)


proc ff*(zz:float,n:int64 = 5):string =
    ## ff
    ## 
    ## formats a float to string with n decimals
    ##  
    result = $formatFloat(zz,ffDecimal,n)
      

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
  ##    import private,math,strfmt  
  ##    # get randompoints in a circle
  ##    var crad:float = 1
  ##    for x in 0.. 100:
  ##       var k = getRandomPointInCircle(crad)
  ##       assert k[0] <= crad and k[1] <= crad
  ##       printLnBiCol("{:<25}  :  {}".fmt($k[0],$k[1]),":")
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
         
  
proc tupleToStr*(xs: tuple): string =
     ## tupleToStr
     ##
     ## tuple to string unpacker , returns a string
     ##
     ## code ex nim forum
     ##
     ## .. code-block:: nim
     ##    echo tupleToStr((1,2))         # prints (1, 2)
     ##    echo tupleToStr((3,4))         # prints (3, 4)
     ##    echo tupleToStr(("A","B","C")) # prints (A, B, C)

     result = "("
     for x in xs.fields:
       if result.len > 1:
           result.add(", ")
       result.add($x)
     result.add(")")
     
              
template loopy*[T](ite:T,st:stmt) =
     ## loopy
     ## 
     ## the lazy programmer's quick for-loop template
     ##
     ## .. code-block:: nim            
     ##     loopy(0.. 100,printLnTK("The house is in the back.",brightwhite,brightblack,salmon,yellowgreen))
     ##     
     for x in ite:
       st
                 

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
         printLn("Harmonics here defined for positive n only",red)
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
    ##    showStats(rs)
    ##    doFinish()
    ## 
    var sep = ":"
    printLnBiCol("Sum     : " & ff(x.sum),sep,yellowgreen,white)
    printLnBiCol("Var     : " & ff(x.variance),sep,yellowgreen,white)
    printLnBiCol("Mean    : " & ff(x.mean),sep,yellowgreen,white)
    printLnBiCol("Std     : " & ff(x.standardDeviation),sep,yellowgreen,white)
    printLnBiCol("Min     : " & ff(x.min),sep,yellowgreen,white)
    printLnBiCol("Max     : " & ff(x.max),sep,yellowgreen,white)
    


proc newDir*(dirname:string) = 
  ## newDir
  ## 
  ## creates a new directory and provides some feedback 
  
  if not existsDir(dirname):
        try:
           createDir(dirname)
           printLn("Directory " & dirname & " created ok",green)
        except OSError:   
           printLn(dirname & " creation failed. Check permissions.",red)
  else:
      printLn("Directory " & dirname & " already exists !",red)



proc remDir*(dirname:string) =
  ## remDir
  ## 
  ## deletes an existing directory , all subdirectories and files  and provides some feedback
  ## 
  ## root and home directory removal is disallowed 
  ## 
  
  if dirname == "/home" or dirname == "/" :
       printLn("Directory " & dirname & " removal not allowed !",brightred)
     
  else:
    
      if existsDir(dirname):
          
          try:
              removeDir(dirname)
              printLn("Directory " & dirname & " deleted ok",yellowgreen)
          except OSError:
              printLn("Directory " & dirname & " deletion failed",red)
      else:
              printLn("Directory " & dirname & " does not exists !",red)




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
         cechoLn(red,"Error : minimum word length larger than maximum word length")
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
         cechoLn(red,"Error : minimum word length larger than maximum word length")
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
         cechoLn(red,"Error : minimum word length larger than maximum word length")
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
         cechoLn(red,"Error : minimum word length larger than maximum word length")
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
         cechoLn(red,"Error : minimum word length larger than maximum word length")
         result = ""
           


proc iching*():seq[string] =
    ## iching
    ##
    ## returns a seq containing iching unicode chars
    var ich = newSeq[string]()
    for j in 119552..119638:
           ich.add($Rune(j))
    result = ich



proc ada*():seq[string] =
    ## ada
    ##
    ## returns a seq containing ada language symbols
    ##
    var adx = newSeq[string]()
    # s U+30A0–U+30FF.
    for j in parsehexint("2300") .. parsehexint("23FF"):
        adx.add($Rune(j))
    result = adx
    
    
    
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
  ## maybe best results compile prog with : nim cc -d:release --gc:markandsweep 
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



# small demos

proc flyNim*(astring:string = "Nim",col:string = red,tx:float = 0.08) =

      ## flyNim
      ## 
      ## small animation demo
      ## 
      ## .. code-block:: nim
      ##    flyNim(col = brightred)  
      ##    flyNim(" Have a nice day !", col = hotpink,tx = 0.1)   
      ## 

      var twc = tw div 2
      var asc = astring.len div 2
      var sn = tw - astring.len
      for x in 0.. twc-asc:
        hline(x,yellowgreen)
        if x < twc - asc :
              printStyled("✈","",brightyellow,{styleBlink})
              hlineln(2 * twc -1 - x,salmon)
        else:
              printStyled(astring,"",col,{styleBright})
              hlineln(sn -x,salmon)
        sleepy(tx)
        curup(1)
      echo()
      



# Info and handlers procs for quick information about


proc qqTop*() =
  ## qqTop
  ##
  ## prints qqTop in custom color
  ## 
  print("qq",cyan)
  print("T",brightgreen)
  print("o",brightred)
  print("p",cyan)


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
  printLnBiCol("Last compilation on           : " & CompileDate &  " at " & CompileTime,sep,green,brightblack)
  # this only makes sense for non executable files
  #printLnBiCol("Last access time to file      : " & filename & " " & $(fromSeconds(int(getLastAccessTime(filename)))),sep,green,brightblack)
  printLnBiCol("Last modificaton time of file : " & filename & " " & $(fromSeconds(int(modTime))),sep,green,brightblack)
  printLnBiCol("Local TimeZone                : " & $(getTzName()),sep,green,brightblack)
  printLnBiCol("Offset from UTC  in secs      : " & $(getTimeZone()),sep,green,brightblack)
  printLnBiCol("Now                           : " & getDateStr() & " " & getClockStr(),sep,green,brightblack)
  printLnBiCol("Local Time                    : " & $getLocalTime(getTime()),sep,green,brightblack)
  printLnBiCol("GMT                           : " & $getGMTime(getTime()),sep,green,brightblack)
  printLnBiCol("Environment Info              : " & getEnv("HOME"),sep,green,brightblack)
  printLnBiCol("File exists                   : " & $(existsFile filename),sep,green,brightblack)
  printLnBiCol("Dir exists                    : " & $(existsDir "/"),sep,green,brightblack)
  printLnBiCol("AppDir                        : " & getAppDir(),sep,green,brightblack)
  printLnBiCol("App File Name                 : " & getAppFilename(),sep,green,brightblack)
  printLnBiCol("User home  dir                : " & getHomeDir(),sep,green,brightblack)
  printLnBiCol("Config Dir                    : " & getConfigDir(),sep,green,brightblack)
  printLnBiCol("Current Dir                   : " & getCurrentDir(),sep,green,brightblack)
  let fi = getFileInfo(filename)
  printLnBiCol("File Id                       : " & $(fi.id.device) ,sep,green,brightblack)
  printLnBiCol("File No.                      : " & $(fi.id.file),sep,green,brightblack)
  printLnBiCol("Kind                          : " & $(fi.kind),sep,green,brightblack)
  printLnBiCol("Size                          : " & $(float(fi.size)/ float(1000)) & " kb",sep,green,brightblack)
  printLnBiCol("File Permissions              : ",sep,green,brightblack)
  for pp in fi.permissions:
      printLnBiCol("                              : " & $pp,sep,green,brightblack)
  printLnBiCol("Link Count                    : " & $(fi.linkCount),sep,green,brightblack)
  # these only make sense for non executable files
  #printLnBiCol("Last Access                   : " & $(fi.lastAccessTime),sep,green,brightblack)
  #printLnBiCol("Last Write                    : " & $(fi.lastWriteTime),sep,green,brightblack)
  printLnBiCol("Creation                      : " & $(fi.creationTime),sep,green,brightblack)

  when defined windows:
        printLnBiCol("System                        : Windows ..... Really ??",sep,red,brightblack) 
  elif defined linux:
        printLnBiCol("System                        : Running on Linux" ,sep,brightcyan,green)
  else:
        printLnBiCol("System                        : Interesting Choice" ,sep,green,brightblack)

  when defined x86:
        printLnBiCol("Code specifics                : x86" ,sep,green,brightblack)

  elif defined amd64:
        printLnBiCol("Code specifics                : amd86" ,sep,green,brightblack)
  else:
        printLnBiCol("Code specifics                : generic" ,sep,green,brightblack)

  printLnBiCol("Nim Version                   : " & $NimMajor & "." & $NimMinor & "." & $NimPatch,sep,green,brightblack) 
  printLnBiCol("Processor count               : " & $countProcessors(),sep,green,brightblack)
  printBiCol("OS                            : "& hostOS,sep,green,brightblack)
  printBiCol(" | CPU: "& hostCPU,sep,green,brightblack)
  printLnBiCol(" | cpuEndian: "& $cpuEndian,sep,green,brightblack)
  let pd = getpid()
  printLnBiCol("Current pid                   : " & $pd,sep,green,brightblack)
  


proc infoLine*() = 
    ## infoLine
    ## 
    ## prints some info for current application
    ## 
    hlineLn()
    print("{:<14}".fmt("Application :"),yellowgreen)
    printColStr(brightblack,extractFileName(getAppFilename()))
    printColStr(brightblack," | ")
    printColStr(brightgreen,"Nim : ")
    printColStr(brightblack,NimVersion & " | ")
    printColStr(peru,"private : ")
    printColStr(brightblack,PRIVATLIBVERSION)
    printColStr(brightblack," | ")
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
    infoLine()
    printLnColStr(brightblack," - " & year(getDateStr())) 
    printColStr(yellowgreen,"{:<14}".fmt("Elapsed     : "))
    printLn("{:<.3f} {}".fmt(epochtime() - private.start,"secs"),goldenrod)
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
    hlineLn()
    cechoLn(yellowgreen,"Thank you for using     : ",getAppFilename())
    msgc() do: echo "{}{:<11}{:>9}".fmt("Last compilation on     : ",CompileDate ,CompileTime)
    hlineLn()
    echo "private Version         : ", PRIVATLIBVERSION
    echo "Nim Version             : ", NimVersion
    printColStr(yellow,"{:<14}".fmt("Elapsed     : "))
    printLnColStr(brightblack,"{:<.3f} {}".fmt(epochtime() - private.start,"secs"))
    echo()
    rainbow("Have a Nice Day !")  ## change or add custom messages as required
    decho(2)
    system.addQuitProc(resetAttributes)
    quit(0)



# putting decho here will put two blank lines before anyting else runs
decho(2)
# putting this here we can stop most programs which use this lib and get the
# automatic exit messages , it may not work in tight loops involving execCMD or
# waiting for readLine() inputs.
setControlCHook(handler)
# this will reset any color changes in the terminal
# so no need for this line in the calling prog
system.addQuitProc(resetAttributes)
# end of private.nim
