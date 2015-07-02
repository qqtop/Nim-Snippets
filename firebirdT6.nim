import os,times,terminal,strutils,parseutils,strfmt
import private
import python


# Connect to firebird 2.5.4 Superserver using python module  
# and display data from the isocountry.fdb 


var sq1 = "select first 30 * from COUNTRY"

eraseScreen()
cursorUp(80)

const pycode = """

import fdb

def connect_db(s):
    try:

       acon = fdb.connect(dsn='127.0.0.1:/data5/dbmaster/ISOCOUNTRY.FDB', user='sysdba', password='xxxxxxxxx', charset='UTF-8')
       cur = acon.cursor()
       try:
         cur.execute(s)
       except:
         # show tables
         cur.execute("select rdb$relation_name from rdb$relations where rdb$view_blr is null and (rdb$system_flag is null or rdb$system_flag = 0)")
         # show views
         #cur.execute("select rdb$relation_name from rdb$relations where rdb$view_blr is not null and (rdb$system_flag is null or rdb$system_flag = 0)")

       res=[]
       for rx in cur:
          for rz in rx:
            try:
              res.append(rz.encode("utf8"))
            except:
              res.append(rz)
       if len(res)<1:
         res.append("Not Found. PyMsg")

       acon.close()     # <== required otherwise we get a weak reference error in Nim

       return res

    except:
        print("No connection to database")
        raise

ares = connect_db(from_nim)  # here the query string is being moved in from nim side
# we pack up the cursor result into a nice python list
# and send it over to nim for unpacking
resl = []
for x in xrange(0,len(ares)):
   resl.append(str(ares[x]))  # <== needs to be string as nim seq can only hold one type

"""

msgy() do : echo "Visiting python to get the data"
Py_Initialize()
var mainModule = PyImport_ImportModule("__main__")
var mainDict   = PyModule_GetDict(mainModule)
var pyString   = PyString_FromString(sq1)
discard PyDict_SetItemString(main_dict, "from_nim", pyString)
discard PyRun_SimpleString(pycode)

msgy() do : echo "\nBack in Nim and Displaying python list\n"
echo aline
let pyVariable = PyMapping_GetItemString(mainDict, "resl")
var cc = 0
var pyItem1 :cstring = ""

var c = 0

for x in 0.. <PySequence_Length(pyVariable):
    inc c 
    var pyData  = PySequence_GetItem(pyVariable,x)
    pyItem1 =  PyString_AsString(pyData)
    if c < 5 :
      write(stdout,pyItem1)
      write(stdout," , ")
    else:
      c = 0
      echo()

echo()
echo aline
Py_XDECREF(mainModule)
Py_XDECREF(pyString)
Py_XDECREF(pyVariable)
Py_Finalize()
