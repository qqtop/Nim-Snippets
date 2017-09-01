##
##   Program     : quickInfo.nim
##
##   Status      : development
##
##   License     : MIT opensource
##
##   Version     : 0.9.0
##
##   ProjectStart: 2015-08-26
##
##   Latest      : 2017-08-20
##
##   Compiler    : Nim 0.17.1
##
##   Description : proc,template,const etc. function lister of nim programs 
##   
##                 also shows relevant comments 
##
##                
##   Compile     : nim c -d:release  quickInfo
##                
##   Run         : quickInfo somefile.nim  proc template    
##                 quickInfo somefile.nim  |grep printBiCol
##                                       
##   Requires    : nimcx.nim 
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

import os,strutils,nimcx
    
from memfiles import open, lines

const QUICKINFOVERSION = 0.9
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
            printLn(line)  
        
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
           printBiCol(zl,funcy & " ",greenyellow,steelblue,":",0,false,{}) 
           echo()
           inc shown
 
 
# this part needs work , want ot display the help sections like ## blah 
#    # if blflag == true ==> we get the correct headers but no context
#    # if false we get a mess as this part does not know when comments are finished
#     if strip(line,true,false).startswith("##") and strip(line,true,true) != "##" and blflag == false:
#              var ss = split(line,"##")
#              
#              if ss[1].strip(true,false).startswith(".. code-block"):
#                 printLnBiCol("com:" & ss[1],":",peru,yellowgreen)
#              else:                      
#                 printLnBiCol("com:" & ss[1],":",peru,white)
 
           

proc main() =
  
  var cp = commandLineParams()
  var fc = newSeq[string]()
  # use self as default file 
  var afile = "quickInfo.nim"  
  # use a default with most used
  
  
  if cp.len > 1:
    for x in 2.. cp.len():
       fc.add(paramStr(x))
  else:
       fc = @["proc","template","converter","from","import","type"]
  
    
  if cp.len == 0 and not fileExists(afile) == true:
      printLn("quickInfo -  needs a nim file as first parameter",red)
      printLn("quickInfo somefile.nim")
      doFinish()
  
    
  if cp.len > 0:
     afile = paramStr(1)
   
  # this would show all available 
  #showFunc(afile)
    
  showFunc(afile,fc)
 
  decho(3)
  printLnBiCol("Shown items : " & $shown)
  printLnBiCol("File        : " & afile)
  printLn(available,rosybrown)
 

main()
doFinish()
