import cx,os, httpclient,net,strutils 

# kbbi.nim
# 
# search KBBI Edisi IV from the terminal
# 
# Kamus Besar Bahasa Indonesia Pusat Bahasa Edisi IV
# 
# Last   : 2016-12-17
# 
# Status : ok
# 
# Usage  : kbbi mimpi
# 
# 

var ct = ""
var htmlsource = ""
var nct = newHttpClient(timeout = 8000)  
  
if paramCount() < 1:
  println("Tidak ada kata untuk menelusur tersedia ",red)
  printlnBiCol("Cara pakai: kbbi makanan")
  doFinish()
else:  
  ct = paramStr(1)

htmlsource = "http://kbbi4.portalbahasa.com/entri/" & ct

hdx(printlnBiCol("Mencari kata : " & ct,":",skyblue,salmon,styled={styleUnderscore}))

try:  
  ct = nct.getContent(htmlsource)
  var ctl = ct.splitLines()
  for x in ctl:    
    if x.contains("<meta name="):
           var x1 = x.split("<meta name=")[1] 
           if x1.contains("description"):
                x1 = x1.split("description")[1]
                if x1.contains("content="):
                  x1 = x1.split("""" content="""")[1]
                  removeSuffix(x1,'>')
                  removeSuffix(x1,"/")
                  x1 = x1.strip()
                  removeSuffix(x1,'"')
                  println("Description",yellowgreen)
                  var x11 = x1.split("; (")
                  for xx in x11:
                      if xx.contains("(1)") or xx.startswith("(1)"):
                        if xx.startswith("("): println(xx.strip())
                        else: println("(" & xx.strip())
                      else:
                        if x11[0].contains("(1)") or xx.startswith("(1)"):
                            println("(" & xx.strip()) 
                        else:
                            println(xx.strip())
                        
                  echo()
                
           elif x1.contains("keywords"):
                x1 = x1.split("keywords")[1]  
                if x1.contains("content="):
                    x1 = x1.split("""" content="""")[1]
                    removeSuffix(x1,'>')
                    removeSuffix(x1,"/")
                    x1 = x1.strip()
                    removeSuffix(x1,'"')
                    println("Keywords",yellowgreen)
                    println(x1.split(", definisi")[0])
                    echo()      
                
           else: x1 = ""
           
    
    if x.startswith("<a href='/entri/"):
       var x2 = x.split("<a href='/entri/")[1] 
       printLnBiCol("Kata Gabungan : " & x2.split("'>")[0] )
  
except ValueError:
    echo "Value error" & getCurrentExceptionMsg()
except OSError:
    echo "OS error" & getCurrentExceptionMsg()
except HttpRequestError:
    echo "HttpRequest Error" & getCurrentExceptionMsg()
except OverflowError:
    echo "Overflow Error" & getCurrentExceptionMsg()
except  TimeoutError:
    echo "TimeoutError: " & getCurrentExceptionMsg()
except  ProtocolError:
    echo "Protocol Error" & getCurrentExceptionMsg()
except :
    echo "Exception" & getCurrentExceptionMsg()
finally:
  println("\n Selesai pencarian kamus KBBI",peru)   
                  
doFinish()                  
                  
                  