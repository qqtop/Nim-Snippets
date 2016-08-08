# #####################################################################################
# Program     : firebird.nim  
# Status      : Development 
# License     : MIT opensource  
# Version     : 0.0.2
# Compiler    : Nim 0.14.3
# Description : conveniently access firebird database via python from nim
#               
#                      
# ProjectStart: 2016-06-03
# Todo        : 
# Pastebin    : 
# Tested on   : 2016-07-21 against firebird 3.0 Super-Server
# Last        : 2016-08-08
# 
# Programming : qqTop
# 
# #####################################################################################
# #####################################################################################
## nim lib which calls python firebird database driver fdb for easy firebird connection
## todo: backup ,meta data backup , improve connection handling
## Note : Do not change indentation for var. python code

import cx, pythonize

type
  Tfb* = tuple[res:seq[seq[string]]] 


execPython("""
import os,fdb
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
    printlnStyled("\nTables in Db ","Tables in Db ", salmon,{styleUnderScore})
    echo()
    let allt = fdbquery("select rdb$relation_name from rdb$relations where rdb$view_blr is null and (rdb$system_flag is null or rdb$system_flag = 0)")   
    for x in 0.. <allt.res.len:
       for xx in allt.res[x]:
          echo xx.replace(",","").strip()
 
                               
proc allviews*() =
    printlnStyled("\nViews in Db ","Views in Db ", salmon,{styleUnderScore})
    echo()
    let allv = fdbquery("select rdb$relation_name from rdb$relations where rdb$view_blr is not null and (rdb$system_flag is null or rdb$system_flag = 0)")  
    for x in 0.. <allv.res.len:
       for xx in allv.res[x]:
          echo xx.replace(",","").strip()
 
proc allindexes*() =  
   printlnStyled("\nIndexes in Db ","Indexes in Db ", salmon,{styleUnderScore})
   println(rightarrow & "Name, UniqueFlag, Table, Field",dodgerblue)
   echo()
   doFbShow(fdbquery("select i.rdb$index_name,i.rdb$unique_flag,i.rdb$relation_name, s.rdb$field_name from rdb$indices i, rdb$index_segments s where  i.rdb$index_name=s.rdb$index_name and  i.rdb$index_name not like 'RDB$%'"))
  
   
proc allgenerators*() = 
   printLnStyled("\nGenerators in current Database ","Generators in current Database ", salmon,{styleUnderScore})
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
     printLnStyled("\nSecusers  Authentication","Secusers  Authentication", salmon,{styleUnderScore})
     echo()
     doFbShow(fdbquery("select SEC$USER_NAME, SEC$PLUGIN from sec$users")) 
 
  
proc allinfo*() =
    printLnStyled("\nCurrent Connection Information for Database ","Current Connection Information for Database ", salmon,{styleUnderScore})
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
       