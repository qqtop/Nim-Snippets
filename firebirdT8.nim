import cx,firebird

# MASTER EXAMPLE FOR firebird.nim testing

var password = "yourfirebirdpassword"  # <<==== your password if needed otherwise set to ""



# change conn string as required
connectFdb("192.168.2.4:isocountry3","sysdba", password,"UTF-8") # network conn needs password
#connectFdb("isocountry3","sysdba", "","UTF-8") # embedded connection no password maybe ok  

decho(2)
println("isocountry example",yellowgreen)


proc doit(n:int) =  
 for x in 1.. n:
  println("Run : " & rightarrow & spaces(2) & $x,dodgerblue) 
  #ISO NAME PRINTABLE_NAME ISO3 NUMCODE 
  let z = fdbquery("select first 5 iso,NAME, PRINTABLE_NAME, ISO3, NUMCODE  from COUNTRY order by rand()")
  doFbShow(z) 
  
proc mainProc() =
  doit(10)
  # system queries below better not run in loops or by multiple clients
  # as this seem to ev. lock up the server requiring a restart .
  # these need to be run best with network conn string
  alltables()
  allindexes()
  allviews()
  secusers()
 
if isMainModule:
  mainProc()
  
  closecons()
  doFinish()
