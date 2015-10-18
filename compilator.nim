
# compilator.nim

# compilator compiles all *.nim files in current dir
# use after a compiler update to recompile all snippets and test progs 
#
# this proc can most likely not be stopped with ctrl-c  use ctrl-z instead
# 
# 

import os,private,strutils,osproc,strfmt

# change below if there are different compiler settings required
var cc = "nim -d:release --opt:speed --hints:off --verbosity:0 -w:off c " 
var c = 0 
var pc = 0 # file counter
var failed = newSeq[string]()
for f in walkfiles("*.nim"):
  inc pc
  var compilecommand = cc & f
  
  printLnStyled(" Compiling file " & $pc & " : " & $f ,"",olivedrab,{stylereverse})
  echo()
  
  var exitCode = execCmd(compilecommand) 
  
  if exitCode == 0 :
      cechoLn(yellowgreen,"exitCode : ",exitCode)
      inc c
  else:
      cechoLn(red,"exitCode : ",exitCode ,"  File : ",f,"  failed ")
      
  if exitCode > 0:
      failed.add(f)
  
  hline()
  decho(2)
  
     
echo()
cechoLn(yellow,"Failed compile attempts :")
echo ()
for x in failed:
  echo x
  
echo()
superheader("Total Compile attempts : " & $pc & "  Passed : " & $c  &  "  Failed : " & $failed.len)
printLn("All files compiled with : ")
printLn(cc,pastelyellow)

doFinish() 
 

   
