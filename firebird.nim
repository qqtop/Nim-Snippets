# #####################################################################################
# Program     : firebird.nim  
# Status      : Development 
# License     : MIT opensource  
# Version     : 0.0.4
# Compiler    : Nim 0.15.3
# Description : Conveniently access firebird database via python from nim
#               Needs a firebird installation and the python fdb.py driver installed 
#               ( pip install fdb )
#                      
# ProjectStart: 2016-06-03
# Todo        : 
# Pastebin    : 
# Tested on   : 2016-07-21 against firebird 3.0 Super-Server  with python 2.7.x
# Last        : 2016-12-09
# 
# Programming : qqTop
# 
# #####################################################################################
# #####################################################################################
## nim lib which calls python firebird database driver fdb for easy firebird connection
## todo: backup ,meta data backup , improve connection handling
## 
## Note : Do not change indentation for var. python code

import cx, pythonize , rdstdin,osproc , hashes

type
  Tfb* = tuple[res:seq[seq[string]]] 


execPython("""
import os,fdb,re
from fdb import services
""")


# query to count rows in all tables in connected database
var countall* = """
EXECUTE BLOCK
returns ( stm varchar(60), cnt integer )
as
BEGIN
   for select cast('select count(*) from "'||trim(r.RDB$RELATION_NAME)||'"' as varchar(60)) 
       from RDB$RELATIONS r
       where (r.RDB$SYSTEM_FLAG is null or r.RDB$SYSTEM_FLAG = 0) 
       and r.RDB$VIEW_BLR is null
       order by 1
   into :stm
   DO
   BEGIN
      execute statement :stm into :cnt;
      suspend;
   END
END
"""

# query to get odsversion for a firebird database version 2.1 and later
var odsversion* = "SELECT RDB$GET_CONTEXT('SYSTEM','ENGINE_VERSION') FROM RDB$DATABASE"

# query to get server time for reference only not much use inside nim
var servertime* = "select  current_timestamp from rdb$database"
# query to get best current time and day for reference only not much use inside nim
var currenttime* = "select cast('now' as timestamp) from rdb$database"
var currentday*  = "select cast('today' as date) from rdb$database"


template cleanString* (m:string) =
  # removes all kinds of unwanted chars
  m = m.replace("u'","").replace("'","\"").replace("u\"","\"")                             
  m = unquote(m)
  m = m.strip()
  
proc clearup*(s:string):string = 
  var okitem = s 
  while okitem.contains(spaces(2)):
      okitem = okitem.replace(spaces(2),spaces(1))  
 
  if okitem.endswith(","):
        okitem.removesuffix(",")
  
  result = okitem.strip(true,true).replace("\t"," ").replace("\f"," ").replace("\v"," ").replace("\r"," ").replace("\n"," ")
              

template localDsn*(s:string):string = 
  ## localDsn
  ## 
  ## creates the dns part of a firebird connection string for local databases
  ## 
  ## passed on the pathtodb  e.g. data4/mydbdir/myfile.fdb
  ## 
  ## 
  var z = ""
  if s != "":
      z = "inet://" & localip() & "//" & s
  else:
      println("Error : no database path specified ",red)
      println("""Usage : localDsn("datadir/my.fdb")""",red)
  z

  
proc connectFdb*(ahost:string,auser:string,apassword:string,acharset:string = "UTF-8") =
  # makes connection acon and creates a cursor named cur
  pythonEnvironment["ahost"] = ahost
  pythonEnvironment["auser"] = auser
  pythonEnvironment["apassword"] = apassword
  pythonEnvironment["acharset"] = acharset
  execPython("acon = fdb.connect(dsn = ahost,user = auser, password = apassword , charset = acharset)")
  execPython("cur = acon.cursor()")  
  
proc showServerInfo*(spassword:string) =
    # serverinfo ok
    
    pythonEnvironment["spassword"] = spassword
    decho(3)
    println(" Firebird Server Information",peru)
    dlineln(55)
    echo()
    execPython("con2 = fdb.services.connect('','sysdba',spassword)")
    execPython("sv = con2.get_server_version()")
    printLnBiCol(" Firebird Vers.    : " &   pythonEnvironment["sv"].depythonify(string),":")
    execPython("ar = con2.get_architecture()")
    printLnBiCol(" Firebird Arch.    : " &   pythonEnvironment["ar"].depythonify(string),":")
    execPython("sm = str(con2.get_service_manager_version())")
    printLnBiCol(" Service Manager   : " &   pythonEnvironment["sm"].depythonify(string),":")
    execPython("hd = str(con2.get_home_directory())")
    printLnBiCol(" Home Directory    : " &   pythonEnvironment["hd"].depythonify(string),":")
    execPython("dbp = str(con2.get_security_database_path())")
    printLnBiCol(" Database Path     : " &   pythonEnvironment["dbp"].depythonify(string),":")
    execPython("sdp = str(con2.get_security_database_path())")
    printLnBiCol(" Security Db Path  : " &   pythonEnvironment["sdp"].depythonify(string),":")
    execPython("lfp = str(con2.get_lock_file_directory())")
    printLnBiCol(" Lock File Path    : " &   pythonEnvironment["lfp"].depythonify(string),":")
    execPython("sc = str(con2.get_server_capabilities())")
    printLnBiCol(" Server Capability : " &   pythonEnvironment["sc"].depythonify(string),":")
    execPython("mc = str(services.CAPABILITY_MULTI_CLIENT in con2.get_server_capabilities())")
    printLnBiCol(" Multi Client      : " &   pythonEnvironment["mc"].depythonify(string),":")
    execPython("qf = str(services.CAPABILITY_QUOTED_FILENAME in con2.get_server_capabilities())")
    printLnBiCol(" Quoted Filename   : " &   pythonEnvironment["qf"].depythonify(string),":")
    execPython("mfp = con2.get_message_file_directory()")
    printLnBiCol(" Message file Path : " &   pythonEnvironment["mfp"].depythonify(string),":")
    execPython("conc = str(con2.get_connection_count())")
    printLnBiCol(" Connection Count  : " &  pythonEnvironment["conc"].depythonify(string),":")
    # a bit roundabout way to get the attached databases
    execPython("adn = []")
    execPython("for nx in con2.get_attached_database_names():  adn.append(nx)")
    execPython("adnl = len(adn)")
    var adnl = pythonEnvironment["adnl"].depythonify(int)
    for x in 0.. <adnl:
       pythonEnvironment["ax"] = x
       execPython("sadn = str(adn[ax])")
       printlnBiCol(" Connected         : " & pythonEnvironment["sadn"].depythonify(string),":") 
    execPython("con2.close()")

proc hashE2*() = 
     var zz = readLineFromStdin("Create hash for a string : ")
     echo hash(zz)

proc getFbPassword*():string =
     ## getFbPassword
     ## 
     ## prompts user for the firebird password
     ##  
     # here we can do a double entry lock
     # using a hash for the cryptfile consider this for a mobile solution
     # create a hash for your password with hashE2   
     result = ""
     let zz = readPasswordFromStdin("Enter Database Password : ")
     let syst = execCmdEX("uname -m")
     if $syst.output == "x86_64":
        if hash(zz) == -4550309748678904198 :  # 64
          curup(1)
          printlnBiCol("Hash 64 Status   : ok . Access granted at " & $localTime() & ".")
          echo()
          result = zz
        else:
            echo()
            printlnBiCol("Hash 64 Status   : failed",":",red)
            printlnBiCol("Access denied at : " & $localTime() & ".",":",red)
            println("Exiting ...",salmon)
            doFinish()
            
          
     else:     
        if hash(zz) == hash(-696674300) :  # 32
                curup(1)
                printlnBiCol("Hash 32 Status   : ok . Access granted at " & $localTime() & ".")
                echo()
                result = zz
        else:
                echo()
                printlnBiCol("Hash 32 Status   : failed",":",red)
                printlnBiCol("Access denied at : " & $localTime() & ".",":",red)
                println("Exiting ...",salmon)
                doFinish()

      
  

proc fdbquery*(qs:string): Tfb =
     pythonEnvironment["qs"] = qs
     # ==>> needs to be intended like this so python does not crap up
     execPython("""
cur.execute(qs)
res0 = []
res1 = ''
try: 
    for x in cur:
       res0.append(x)
except:
       pass
acon.commit()       
res1 = str(res0)
# trying to clean up a bit removeing newlines etc if  possible
# remove if not ok
# That will replace any new line that is not followed by a newline or a tab with a space
#res1 = re.sub(r"\n(?=[^\n\t])", " ", res1)  
res1 = re.sub(r'(?<!\n)\n(?![\n\t])', ' ', res1.replace('\r', ''))

     """) 
     
     var cur0 = pythonEnvironment["res1"].depythonify(string)
     cleanString(cur0)
     var cur1 = $(cur0)
     var cur2 =  newSeq[seq[string]]()   
     var cur11 = cur1.split("), (")
     for x in 0.. <cur11.len:
       if cur11[x].startswith("[(") == true: cur11[x].delete(0,1)
       if cur11[x].endswith(")]") == true  : cur11[x].removeSuffix(")]")
       var b = cur11[x].split(", ")
       cur2.add(b)
     # returning a tuple here maybe could be made simpler            
     var restup : Tfb 
     restup.res = cur2
     result = restup


proc doFbShow* [T](z:T) =
  # a quick viewer for firebird select query results
  
  for x in z.res:
    var c = 1
    for b in x:
          var b0 = b
          if b0.contains(spaces(3)):
             b0 = b0.replace(spaces(3),"")  # remove triple spaces anywhere 
          if c != x.len():
            print(b0 & ", ")
          else:
            if b.endswith(",") or b.endswith(", ") == true:
               var b1 = b0.strip()
               b1.removesuffix(",")
               println(b1,rosybrown)
            else:
               println(b0.wordwrap(tw - 10))
          inc c    
    echo()   
  



proc doFbPretty* (z:Tfb,xpos:int = 1,col:string = yellowgreen,sep:bool = true) =
  # a pretty viewer for firebird select query results
  # attempt of a generic display routine
  # works ok for well behaved result sets , but may mess up
  # for memo fields and long lines with with special chars
  # 
   
  # we get a Tfb object containing cursor results
  
  var nxpos = xpos
  var ws = 2        # spacing adjuster for columns
  var res = z.res   # now the result are in res
  var reslen = res.len
  var maxcolwidth = newSeq[int]()

  block myblock1:
    for row in 0.. <reslen:
       for item in 0.. <res[row].len:
         maxcolwidth.add(0)
       break myblock1  
  
  for row in 0.. <reslen:
      # we need to find the max width of the colums returned
      # so run over each row and record max width of each item and save into maxcolwidth
      
      var cols = res[row].len # how many cols has the cursor
      for item in 0.. <cols:
         if res[row][item].len > maxcolwidth[item]:
                 maxcolwidth[item] = res[row][item].len
        
 
  for row in 0.. <reslen:    
      # display the row w/o column marker
      
      var sokitem = ""
      for item in 0.. <res[row].len:
         if maxcolwidth[item] + nxpos + 3 > tw - 2:
      
            # longline handling
            var longitem = wordwrap(res[row][item], tw - nxpos - ws)
            var slongitem = longitem.wordwrap(maxcolwidth[item] + ws).split("\n")
            
            for aitem in 0.. <slongitem.len:
                sokitem = slongitem[aitem].strip(true,true).replace("\t"," ").replace("\f"," ").replace("\v"," ").replace("\r"," ").replace("\c"," ").replace($'\x0D'," ").replace($'\x0A'," ").replace("\n"," ")
                if sokitem.contains(IdentChars):
                   # try to remove any emtylines and whitespace
                                          
                              
                   var ssokitem = splitLines(sokitem)
                   
                   if ssokitem.len == 1 and ssokitem[0] != "None":
                      cleanstring(ssokitem[0]) 

                     
                      if ssokitem[0].startswith("\n"):
                           delete(ssokitem[0],1,2)
                      
                      while ssokitem[0].contains("\n"):
                         ssokitem[0] = ssokitem[0].replace("\n"," ")
                         
                      
                      while ssokitem[0].contains(spaces(2)):
                         ssokitem[0] = ssokitem[0].replace(spaces(2)," ")
                      
                      while ssokitem[0].endswith(spaces(1)):
                              removeSuffix(ssokitem[0]," ")
                      
                                             
                      while ssokitem[0].endswith("\n"):
                           removeSuffix(ssokitem[0],"\n")
        
                      ssokitem[0] = ssokitem[0].strip(true,true).replace("\t"," ").replace("\f"," ").replace("\v"," ").replace("\r"," ").replace("\n"," ")
                      println(dodgerblue & rightarrow & lightgrey & ssokitem[0],xpos = nxpos - 1)
                     
                     
                
                # try to put blue end marker indicating end of longitem
                if slongitem.high == aitem :
                    if nxpos + maxcolwidth[item] > tw - 2:
                        println("|",lightskyblue,xpos = tw - 2)
                    else:
                        println("|",lightskyblue,xpos = nxpos + maxcolwidth[item])
                else:
                    discard 
         
         else:
            # standard length handling
            var okitem = res[row][item]
              
            if okitem.contains(IdentChars): 
                          
              while okitem.contains("\n"):
                okitem = okitem.replace("\n"," ")
                
              while okitem.contains(spaces(2)):
                  okitem = okitem.replace(spaces(2),spaces(1))  
            
              if okitem.endswith(","):
                   okitem.removesuffix(",")
              
              okitem = okitem.strip(true,true)
                      
              print(okitem,col,xpos = nxpos)
              nxpos = nxpos + maxcolwidth[item] + ws         
     
              # try put green standard length item marker
              if maxcolwidth.high == item:
                    discard
              else:  
                 if sep == true:
                    print("|",lime,xpos = nxpos)
                    nxpos = nxpos + 1
                    discard  
      
      nxpos = xpos
      echo()
    


proc createFbDatabase*(dsn:string,auser:string,apassword:string) = 
  
  pythonEnvironment["dsn"] = dsn
  pythonEnvironment["auser"] = auser
  pythonEnvironment["apassword"] = apassword
  #pythonEnvironment["acharset"] = acharset

  execPython("""
def newdatabase(dsn,auser,apassword):
    try:
      cx = fdb.connect(dsn=dsn , user=auser, password=apassword)
    except:
      cx = fdb.create_database("create database '%s' user '%s' password '%s'" % (dsn,auser,apassword))  
      cx.commit()
      cx.close()
    return cx 

newdatabase(dsn,auser,apassword)
  """)  
 
proc createFbTable*(atabledata:string) = 
  # create a table in current database
  pythonEnvironment["tabledata"] = atabledata
  execPython("""  
acon.execute_immediate(tabledata) 
acon.commit()
  """)


proc droptable*(dtable:string) =
  # convenince function to drop a table
  pythonEnvironment["dtable"] = dtable
  execPython("""
try:
 ds = "drop table %s" % str(dtable)
 acon.execute_immediate(ds)
 print "\nCould not drop %s table\n" % dtable 
except:
    print "\n%s table dropped successfully\n" % dtable   
  """) 



# below can be accessed after connectFdb has been run on any database
 
proc alltables*() =
    printLn("\nTables in Db ", salmon,styled = {styleUnderScore},substr = "Tables in Db ")
    echo()
    let allt = fdbquery("select rdb$relation_name from rdb$relations where rdb$view_blr is null and (rdb$system_flag is null or rdb$system_flag = 0)")   
    for x in 0.. <allt.res.len:
       for xx in allt.res[x]:
          echo xx.replace(",","").strip()
 
                               
proc allviews*() =
    printLn("\nViews in Db ", salmon,styled = {styleUnderScore},substr = "Views in Db ")
    echo()
    let allv = fdbquery("select rdb$relation_name from rdb$relations where rdb$view_blr is not null and (rdb$system_flag is null or rdb$system_flag = 0)")  
    for x in 0.. <allv.res.len:
       for xx in allv.res[x]:
          echo xx.replace(",","").strip()
 
proc allindexes*() =  
   printLn("\nIndexes in Db ", salmon,styled = {styleUnderScore}, substr = "Indexes in Db ")
   println(rightarrow & "Name, UniqueFlag, Table, Field",dodgerblue)
   echo()
   doFbShow(fdbquery("select i.rdb$index_name,i.rdb$unique_flag,i.rdb$relation_name, s.rdb$field_name from rdb$indices i, rdb$index_segments s where  i.rdb$index_name=s.rdb$index_name and  i.rdb$index_name not like 'RDB$%'"))
  
   
proc allgenerators*() = 
   printLn("\nGenerators in current Database ", salmon,styled = {styleUnderScore}, substr = "Generators in current Database ")
   echo()
   doFbShow(fdbquery("select rdb$generator_name from  rdb$generators where rdb$system_flag is null"))

 
proc allusers*() =   
     execPython("""
usx = acon.db_info(fdb.isc_info_user_names)
usxs = str(usx)
     """)
     var usx = pythonEnvironment["usxs"].depythonify(string)
     printlnBiCol("Users : " & usx)
   
 
proc secusers*() = 
     # the newer fb3 related user query
     printLn("\nSecusers  Authentication", salmon,styled = {styleUnderScore},substr = "Secusers  Authentication")
     echo()
     doFbShow(fdbquery("select SEC$USER_NAME, SEC$PLUGIN from sec$users"))
     
 
  
proc allinfo*() =
    printLn("\nCurrent Connection Information for Database ", salmon,styled = {styleUnderScore},substr = "Current Connection Information for Database ")
    echo()
    execPython("""
buf = acon.database_info(fdb.isc_info_db_id, 's')
# Parse the filename from the buffer.
beginningOfFilename = 2
# The second byte in the buffer contains the size of the database filename
# in bytes.
lengthOfFilename = fdb.ibase.ord2(buf[1])
filename = buf[beginningOfFilename:beginningOfFilename + lengthOfFilename]
# Parse the host name from the buffer.
beginningOfHostName = (beginningOfFilename + lengthOfFilename) + 1
# The first byte after the end of the database filename contains the size
# of the host name in bytes.
lengthOfHostName = fdb.ibase.ord2(buf[beginningOfHostName - 1])
host = buf[beginningOfHostName:beginningOfHostName + lengthOfHostName]
print 'Connected to : ', filename
print 'Host         : ', host
# Retrieving an integer info item is quite simple.
bytesInUse = acon.database_info(fdb.isc_info_current_memory, 'i')
print 'Server uses  :  %d bytes ' % bytesInUse
#Show connected users
c=0
for un in acon.db_info(fdb.isc_info_user_names):
  c+=1
  print 'User     ',c,' : ',un
print '\n'        
    """)
   
proc allcolumns*() =
   printLn("\nColumns", salmon,styled = {styleUnderScore},substr = "Columns")
   echo()
   doFbShow(fdbquery("select f.rdb$relation_name, f.rdb$field_name from rdb$relation_fields f join rdb$relations r on f.rdb$relation_name = r.rdb$relation_name and r.rdb$view_blr is null and (r.rdb$system_flag is null or r.rdb$system_flag = 0) order by 1, f.rdb$field_position"))
     
proc closecons*() =
   # close down current database connection
   execPython("""
acon.commit()
acon.close()
   """)  

# some utility queries for dispaly only

proc showRowCount*() =
   println("Rows count for all tables in current database ",salmon)
   doFbShow(fdbquery(countall))


proc showOds*() = 
   print("ODS Version : ",peru)
   doFbShow(fdbquery(odsversion))


proc showServerTime*() =
   print("ServerTime  : ")
   var zwt = fdbquery(servertime)
   var nwt = ($(zwt.res[0][0..5])).replace("@[datetime.datetime(","").replace("]","")
   echo nwt


proc showCurrentTime*() =
   print("CurrentTime : ")
   var zwt = fdbquery(currenttime)
   var nwt = ($(zwt.res[0][0..5])).replace("@[datetime.datetime(","").replace("]","")
   echo nwt


############
       