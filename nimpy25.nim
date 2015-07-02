# #####################################################################################
# Program     : nimpy25.nim 
# Status      : Development 
# License     : MIT opensource  
# Version     : 0.0
# Compiler    : Nim 0.11.3
# Description : Moving data between Nim and python
#               Execute python script embedded in Nim calculating chisquare
#               and some more tests , now using private lib for nicer look
#
# Tested on   : Linux with python 2.7.8 and libs numpy,scipy             
# ProjectStart: 2015-02-22
# Todo        : 
# Pastebin    :                
# Last        : 2015-07-02
# 
# Programming : I come in code :)
# 
# #####################################################################################
# #####################################################################################


import math
import tables
import strutils
import parseutils
import python
import times
import private

# init some test data float seq

var adata = @[90.0,30.0,30.0]
var bdata = @[60.0,50.0,40.0]


Py_Initialize() 
var mainModule = PyImport_ImportModule("__main__")
var mainDict   = PyModule_GetDict(mainModule)

# here starts our python script
const pycode= """
import time
tmstart = time.time()
import numpy as np
from scipy.stats.mstats import chisquare

def strToNumpyList(zdata):
       # convert the string received from Nim into a python list 
       zdataok = list(zdata.split(','))
       zdatanum=[]
       for x in range(0,len(zdataok)-1):
           zdatanum.append(float(zdataok[x]))
       return zdatanum

def doit():
  
      #from scipy docs  
      #Calculates a one-way chi square test.
      #The chi square test tests the null hypothesis that the
      #categorical data has the given frequencies.
      # http://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.mstats.chisquare.html
  
     
      # now convert this list of strings for use in numpy"
      adatanum = strToNumpyList(adata)
      print "Observed Data: ",adatanum
      # numpyfication
      observed = np.array(adatanum)
      print "Observed Sum : ",np.sum(observed)  # ok
       
      # next string 
      adatanum = strToNumpyList(adata2)
      print "Expected Data: ",adatanum
      expected = np.array(adatanum)
      print "Expected Sum : ",np.sum(expected)  # ok
               
      expected = np.array(expected) * np.sum(observed)
             
      res=chisquare(observed, expected)
      # 
      print "Chi2  [p]    : ",res[0]
      print "Prob  [p]    : ",res[1]
      
      return res

print "\nPython received Nim message :  %s" % from_nim   
print "Chi Square calculation in Python using numpy and scipy:\n"
reschi=doit()
print "\nPython has finished calculation and sending results to Nim now"
chi  = str(reschi[0])
prop = str(reschi[1])
tmend = time.time()
print "Python request timing      : ",tmend - tmstart, "secs"
print "\n"
"""
# end of python script

      
proc chiSquare(adata:seq,bdata:seq):Table[string,string] =
      var pyString   = PyString_FromString("Hello, calculate chisquare , data enclosed.")
      var pyArray    = PyString_FromString("0.5,0.5,0.4,0.4,0.6,0.7,-0.5,0.99")
      var pyArray2   = PyString_FromString("0.25, 0.25, 0.25, 0.25, 0.3,0.3,0.25, 0.25")
      discard PyDict_SetItemString(main_dict, "from_nim", pyString)
      discard PyDict_SetItemString(main_dict, "adata", pyArray)
      discard PyDict_SetItemString(main_dict, "adata2", pyArray2)
      discard PyRun_SimpleString(pycode)
      var pyVariable = PyMapping_GetItemString(mainDict, "chi")
      var pyVariable2 = PyMapping_GetItemString(mainDict, "prop")
      var pyNumber1 = PyString_AsString(pyVariable)
      var pyNumber2 = PyString_AsString(pyVariable2)
      var chires=initTable[string,string]()
      chires["chi2"] = $pyNumber1
      chires["prob"] = $pyNumber2
      return chires

proc dopy(age_of:Table):string =
     # here we calculate something in python that is aging Anabel 2 times
     var pyString = "respy = '$1 Python age now : ' + str($2 * 2)" % ["Anabel",$age_of["Anabel"]]
     discard PyRun_SimpleString(pyString)
     return "" 
     
proc myDict(age1,age2:int):string =
    # the idea here is to find to pass data from table
    # to python for some calculation
    # we use the table based on the nim python module example
    var age_of = initTable[string, int]()
    age_of["Anabel"] = age1
    age_of["Nim"]    = age2
    
    # Example of how to run something in python and get the result back
    discard dopy(age_of)  # passing table to dopy
    # now get the respy variable back from python
    var pyVariable = PyMapping_GetItemString(mainDict, "respy")
    # need to nimify it 
    var pyRespy  = PyString_AsString(pyVariable)
    # use it
    msgg() do : echo "Anabel ages quickly        : " ,pyRespy, " Result calculated in python"
    
    var s = "Anabel"
    if age_of.has_key(s):
       return s & " Nim age now    : " & $age_of[s]
    else:
       return "Not Found"


proc floatMe(adata:string):float=
     parseFloat(adata)


superheader("Nim/Python Data interchange Tests")
var chirx = chiSquare(adata,bdata)
msgy() do : echo "ChiSquare    [Nim]         : " , chirx["chi2"]
# use returned value from python to calc prob % in Nim
msgy() do : echo "Probability  [Nim]         : " , floatMe(chirx["prob"]) * 100,"%"
echo aline
msgy() do : echo "Dict/Table test"
echo "Anabel back to normal      : " , myDict(17,19)," Result calculated in Nim"
echo aline & "\n\n"
echo "Python Version             : " , Py_GetVersion()
echo "Nim Version                : ", NimVersion
msggb() do : write(stdout,"Programming by             : ")
rainbow("I come in code :) \n")

Py_XDECREF(mainModule)  # do we need this ?
Py_Finalize()
echo aline
msgy() do : echo "Finished in Nim epochTime  : ",epochtime() - start," secs"
echo aline