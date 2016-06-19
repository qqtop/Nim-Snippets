##
##   Program     : quickInfo.nim
##
##   Status      : development
##
##   License     : MIT opensource
##
##   Version     : 0.8.0
##
##   ProjectStart: 2015-08-26
##
##   Latest      : 2016-06-19
##
##   Compiler    : Nim 0.14.3
##
##   Description : proc,template,const etc. function lister of nim programs 
##   
##                 also shows relevant comments 
##
##                
##   Compile     : nim c -d:release  quickInfo
##                
##   Run         : quickInfo somefile.nim      
##                 
##                                       
##   Requires    : cx.nim 
##   
##                 
##   Project     : https://github.com/qqtop/Nim-Snippets
##
##
##   Tested      : on linux only
##
##   Programming : qqTop
##
##   Note        : may be improved at any time
##   
##                 still needs some work but useable for a quick outline
##   
##

import os,strutils,cx
    
from memfiles import open, lines

const QUICKINFOVERSION = 0.8
const available = "Available   : proc,template,macro,converter,var,let,const,type,from,import,method"

var blflag:bool = false
var oldfuncy : string 
var shown = 0

proc showFunc*(fname: string,funcs: seq[string] = @["proc","template","macro","converter","var","let","const","type","from","import","method"]) =
  superHeader("Info for : " & fname & $funcs,white,tomato)
  decho(2)
  var file = memfiles.open(fname, fmRead)
  for line in memfiles.lines(file):  
     
    if blflag == true:  # to print block intended text 
          if line.startswith(oldfuncy):
            discard
          elif strip(line,true,false).startswith("##")  == true:
            discard
          else:
            println(line)  
        
    let fields = line.fastsplit('\t')
    for funcy in funcs:
      oldfuncy = funcy
      var zl = fields[fields.low].strip()
                       
      if zl.endswith("=") :
              delete(zl,zl.len - 1 , zl.len)
              
      if zl.startswith(funcy):
               
        if funcy != "from" or funcy != "import":
           echo()
           hlineLn(tw,brightblack)
           blflag = false
                        
        if zl.strip(true,true) == funcy:
           # this happens if we run into a block like
           # import
           #    blah1,blah2
           # 
           printLn(funcy  & " ",greenyellow,steelblue) 
           blflag = true
           inc shown
                 
        else:
           blflag = false
           printBiCol(zl,funcy & " ",greenyellow,steelblue) 
           echo()
           inc shown
    
    if strip(line,true,false).startswith("##") and strip(line,true,true) != "##":
             var ss = split(line,"##")
             
             if ss[1].strip(true,false).startswith(".. code-block"):
                printlnbicol("com:" & ss[1],":",peru,yellowgreen)
             else:                      
                printlnbicol("com:" & ss[1],":",peru,white)
 


proc main() =
  
  var cp = commandLineParams()
  var fc = newSeq[string]()
  # use self as default file 
  var afile = "quickInfo.nim"  
  # use a default with most used
  fc = @["proc","template","converter","from","import","type"]
  
    
  if cp.len == 0 and not fileExists(afile) == true:
      println("quickInfo -  needs a nim file as first parameter",red)
      println("quickInfo somefile.nim")
      doFinish()
  
    
  if cp.len > 0:
     afile = paramStr(1)
   
  # this would show all available 
  #showFunc(afile)
    
  showFunc(afile,fc)
 
  decho(3)
  printlnbicol("Shown items : " & $shown)
  printlnbicol("File        : " & afile)
  println(available,rosybrown)
 

main()
doFinish()
