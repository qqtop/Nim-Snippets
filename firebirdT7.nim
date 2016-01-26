import cx,pythonize,strutils

# Example of using pythonize to access service api of a Firebird 2.5.x Superserver
# change connection data as needed

# required libraries can be obtained via
# nimble install pythonize
# nimble install nimFinLib


execPython("import os")
execPython("import fdb")
execPython("from fdb import services")

let ahost     = "127.0.0.1"
let auser     = "sysdba"
let apassword = "masterkey"
let acharset  = "UTF-8"

pythonEnvironment["ahost"] = ahost
pythonEnvironment["auser"] = auser
pythonEnvironment["apassword"] = apassword
pythonEnvironment["acharset"] = acharset


# serverinfo ok only a few items returning non strings in python need to be str(..) in python
decho(3)
println("Firebird Server Information",peru)
dlineln(55)
echo()
execPython("con2 = fdb.services.connect(ahost, auser, apassword)")
execPython("sv = con2.get_server_version()")
printLnBiCol("Firebird Vers.    : " &   pythonEnvironment["sv"].depythonify(string),":")
execPython("ar = con2.get_architecture()")
printLnBiCol("Firebird Arch.    : " &   pythonEnvironment["ar"].depythonify(string),":")
execPython("sm = str(con2.get_service_manager_version())")
printLnBiCol("Service Manager   : " &   pythonEnvironment["sm"].depythonify(string),":")
execPython("hd = con2.get_home_directory()")
printLnBiCol("Home Directory    : " &   pythonEnvironment["hd"].depythonify(string),":")
execPython("dbp = con2.get_security_database_path()")
printLnBiCol("Database Path     : " &   pythonEnvironment["dbp"].depythonify(string),":")
execPython("sdp = con2.get_security_database_path()")
printLnBiCol("Security Db Path  : " &   pythonEnvironment["sdp"].depythonify(string),":")
execPython("lfp = con2.get_lock_file_directory()")
printLnBiCol("Lock File Path    : " &   pythonEnvironment["lfp"].depythonify(string),":")
execPython("sc = str(con2.get_server_capabilities())")
printLnBiCol("Server Capability : " &   pythonEnvironment["sc"].depythonify(string),":")
execPython("mc = str(services.CAPABILITY_MULTI_CLIENT in con2.get_server_capabilities())")
printLnBiCol("Multi Client      : " &   pythonEnvironment["mc"].depythonify(string),":")
execPython("qf = str(services.CAPABILITY_QUOTED_FILENAME in con2.get_server_capabilities())")
printLnBiCol("Quoted Filename   : " &   pythonEnvironment["qf"].depythonify(string),":")
execPython("mfp = con2.get_message_file_directory()")
printLnBiCol("Message file Path : " &   pythonEnvironment["mfp"].depythonify(string),":")
execPython("cc = str(con2.get_connection_count())")
printLnBiCol("Connection Count  : " &  pythonEnvironment["cc"].depythonify(string),":")

# 
# # get stats  .. works ok but needs a few secs
# decho(3)
# println("Running Stats Report for tatoebamaster .. please wait",yellowgreen)
# execPython("gs = con2.get_statistics('/data5/dbmaster/tatoebamaster.fdb')")
# execPython("stat_report = con2.readlines()")
# execPython("for line in stat_report: print line")
# #                        
# # example of meta data backup
# decho(3)
# println("Running Metadata backup for tatoebamaster .. please wait",yellowgreen)
# execPython("con2.backup('/data5/dbmaster/tatoebamaster.fdb', '/data5/dbmaster/tatoebamasterMeta.fbk', metadata_only=True, collect_garbage=False)")
# execPython("backup_report = con2.readlines()")
# execPython("for line in backup_report: print line")
# 
# println("Bring to Nim like so\n",peru)
# var br = $pythonEnvironment["backup_report"]
# var brs = split(br,",")
# 
# for x in 0.. <brs.len:
#   # remove leading and end square bracket 
#   brs[x] = replace(brs[x],"[","")
#   brs[x] = replace(brs[x],"]","")
#   printlnBiCol(replace(brs[x],"'",""))  # remove apostrophs brought in from python
# 

#for more like sweep,backup,restore modify ,add user etc see
#http://www.firebirdsql.org/file/documentation/drivers_documentation/python/fdb/usage-guide.html#

execPython("con2.commit()")
execPython("con2.close()")



doFinish()

