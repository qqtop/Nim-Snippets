
# compilator.nim

# compilator compiles all *.nim files in current dir
# use after a compiler update to recompile all snippets
# and test progs 
#
# 


import os,strutils,osproc,terminal,times
 
var start = epochTime() 
var c = 0 
var failed = newSeq[string]()
for f in walkfiles("*.nim"):
  setForegroundColor(fgGreen)
  echo " Working on : ",f
  setforegroundcolor(fgWhite)
  # change below if there are different compiler settings required
  var exitCode = execCmd("nim -d:release -d:speed --hints:off --verbosity:0 -w:off c " & f) 
  
  if exitCode == 0 :
      setforegroundcolor(fgWhite)
      echo "exitCode : ",exitCode
      setforegroundcolor(fgWhite)
      inc c
  else:
      setforegroundcolor(fgRed)
      echo "exitCode : ",exitCode ,"  File : ",f,"  failed "
      setforegroundcolor(fgWhite)    
      
  if exitCode > 0:
      failed.add(f)
     
     
echo "\n\nCompilator finished in ",epochTime() - start," secs"
echo()
setforegroundcolor(fgYellow)
echo "Failed compile attempts :"
echo ()
setforegroundcolor(fgWhite)
for x in failed:
  echo x
  
echo()
echo "Failed compilations : ",failed.len
echo "Passed compilations : ",c
echo ()
echo "NimVersion : " ,NimVersion
echo ()
 
system.addQuitProc(resetAttributes)
quit 0  

   
