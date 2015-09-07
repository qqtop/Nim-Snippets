import os,private,httpclient,json,strfmt,strutils,sets


##
##   Program     : kateglo.nim
##
##   Status      : stable
##
##   License     : MIT opensource
##
##   Version     : 0.5.0
##
##   ProjectStart: 2015-09-06
##
##   Compiler    : Nim 0.11.3
##
##   Description : Access Indonesian - Indonesian  Dictionary 
##   
##                 at kateglo.com  via public API
##   
##                
##                 compile:  nim c -d:release kateglo
##                 
##                 run    :  kateglo           # uses default word: pasar 
##                 
##                           kateglo  makanan  # uses desired word makanan
##   
##   Notes       : the API appears to only a low single word input
##                 
##   Requires    : private.nim 
##   
##                 
##   Project     : https://github.com/qqtop/Nim-Snippets
##
##
##   Tested      : on linux only ok on 2015-09-07
##
##
##   Programming : qqTop
##

var wflag:bool  = false
var wflag2:bool = false

proc getData(theWord:string):JsonNode = 
    var r:JsonNode
    try:
       r = parseJson(getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord))
    except JsonParsingError:
       msgr() do : echo "Word " & theWord & "  not defined in kateglo."
       msgr() do : echo "Maybe misspelled or not a root word."
       r = nil
       wflag = true
    result = r

proc getData2(theWord:string):JsonNode = 
    var r:JsonNode
    try:
       r = parseJson(getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord))
    except JsonParsingError:
       r = nil
       wflag = true
    result = r



var aword = "" 
if paramCount() > 0:
   for x in commandLineParams():
      aword = aword & " " & x
      aword = aword.strip()
else:
  # some default word
  aword = "pasar"
  msgg() do : echo "Using default word : " & aword
  
let data = getData(aword)   

if wflag == false:
      echo()  
      superHeader("Kateglo Indonesian - Indonesian Dictionary   Data for : " & aword)
      

      proc ss(jn:JsonNode):string = 
          # strip " from the string
          var jns = $jn
          jns = replace(jns,"\"")
          result = jns
                            
      var c = 0                
      var sep =":"


      proc defini(data:JsonNode) =
            msgg() do: echo "Definitions"
            for zd in data["kateglo"]["definition"]:
                c += 1
                printLnBiCol("{:>7}{} {}".fmt(c,sep,ss(zd["phrase"])),":",brightcyan,green)
                if $ss(zd["def_text"]) == "null":
                    printLnBiCol("{:>7}{} {}".fmt("Def",sep,"Nothing Found"),":",yellow,red)
                    
                elif ss(zd["def_text"]).len > tw:
                      # for nicer display we need to splitlines 
                      var ok = wordwrap(ss(zd["def_text"]),tw-20)
                      var oks = splitlines(ok)
                      #print the first line  
                      printLnBiCol("{:>7}{} {}".fmt("Def",sep,oks[0]),":",yellow,white)
                      for x in 1.. <oks.len   :
                          # here we pad 10 blaks on left
                          oks[x] = align(oks[x],10 + oks[x].len)
                          printLnColStr(white,"{}".fmt(oks[x]))
                      
                else:
                      printLnBiCol("{:>7}{} {}".fmt("Def",sep,ss(zd["def_text"])),":",yellow,white)
                
                if ss(zd["sample"]) != "null":
                    # put the phrase into the place holders -- or ~ returned from kateglo
                    var oksa = replace(ss(zd["sample"]),"--",ss(zd["phrase"]))
                    oksa = replace(oksa,"~",ss(zd["phrase"]))
                    var okx = wordwrap(oksa,tw-20)
                    var okxs = splitlines(okx)
                    #print the first line  
                    printLnBiCol("{:>7}{} {}".fmt("Sample",sep,okxs[0]),sep,yellow,white)
                    for x in 1.. <okxs.len   :
                      # here pad 10 blanks on left
                      okxs[x] = align(okxs[x],10 + okxs[x].len)
                      printLnColStr(white,"{}".fmt(okxs[x]))
                hline("-",tw,green)  
                         
                
      proc relati(data:JsonNode) =   
            var dx = data["kateglo"]["all_relation"]
            msgg() do: echo "Related Phrases"
            msgc() do: echo "{:>5} {:<14} {}".fmt("No.","Type","Phrase")
           
            for zd in 0.. <dx.len:
                var trsin = ""
                # we try to get the translations of the related phrases if type  = sinonim
                var rphr = ss(dx[zd]["related_phrase"])  
                var rtyp = ss(dx[zd]["rel_type_name"])
                if rtyp == "Sinonim" or rtyp == "Turunan" or rtyp == "Antonim":
                   # TODO : check that we only pass a single word rather than a phrase
                   #        to avoid errors and slow down
                   var phrdata = getData2(rphr)
                   if wflag2 == false:
                    try: 
                      var phdx = phrdata["kateglo"]["translations"]
                      if phdx.len > 0:
                          trsin =  ss(phdx[0]["translation"])   
                          printLnBiCol("{:>4}{} {:<14}: {}".fmt($zd,":",ss(dx[zd]["rel_type_name"]),ss(dx[zd]["related_phrase"])),sep,yellow,white)  
                          
                          var okx = wordwrap(trsin,tw - 40)
                          var okxs = splitlines(okx)
                          # print trans first line
                          printLnBiCol("{:>20}{} {}".fmt("Trans",":",okxs[0]),sep,cyan,white)
                          if okxs.len > 1:
                              for x in 1.. <okxs.len :
                                  # here pad 22 blanks on left
                                  okxs[x] = align(okxs[x],22 + okxs[x].len)
                                  printLnColStr(white,"{}".fmt(okxs[x]))
                    except:
                         discard
                    
                    
                   # need a sleep here or we hit the kateglo server too hard
                   # if too many crashes like
                   # Error: unhandled exception: 503 Service Temporarily Unavailable [HttpRequestError]
                   # then increase 
                   sleepy(1.0)
                   
                else:
                   printLnBiCol("{:>4}{} {:<14}: {}".fmt($zd,":",rtyp,rphr),sep,yellow,white)  
                   echo()   
      
      proc transl(data:JsonNode) =
            var dx = data["kateglo"]["translations"]
            msgg() do: echo "Translation"
            for zd in 0.. <dx.len:
                printLnBiCol("{:>8}{} {}".fmt(ss(dx[zd]["ref_source"]),":",ss(dx[zd]["translation"])),sep,yellow,white)  
            hline("-",tw,green)  
      
      
      
      proc proverbi(data:JsonNode) =
            var dx = data["kateglo"]["proverbs"]
            msgg() do: echo "Proverbs"
            for zd in 0.. <dx.len:
                printLnBiCol("{:>4} Prov {} {}".fmt($zd,":",ss(dx[zd]["proverb"])),sep,yellow,white)  
                printLnBiCol("{:>4} Mean {} {}".fmt($zd,":",ss(dx[zd]["meaning"])),sep,yellow,white) 
            hline("-",tw,green) 
      
      transl(data)
      decho(1)
      defini(data)          
      decho(1)
      proverbi(data)
      decho(1)
      relati(data)
          
doFinish()



#############################################################################
# OUTPUT EXAMPLE OF THIS PRGRAM
#############################################################################

                                                                                         
                                                                                           
                                                                                           
################################################################                           
# Kateglo Indonesian - Indonesian Dictionary   Data for : ahli #                           
################################################################                           
#                                                                                            
# Translation                                                                                
#   ebsoft: 1.1) expert, specialist. 2) virtuoso. 3) skilled, highly competent, professional. 2. 1) members. 2 relatives.                                                               
#   gkamus: 1.1) expert, specialist. 2) virtuoso. 3) skilled, highly competent, professional.  2. 1) members. 2 relatives.                                                              
# -------------------------------------------------------------------------------------------
# Definitions
#       1: ahli                                                                              
#     Def: orang yang mahir, paham sekali dalam suatu ilmu (kepandaian)
# -------------------------------------------------------------------------------------------      2: ahli
#     Def: mahir benar
#  Sample: dia seorang yang ahli menjalankan mesin itu                                       
# -------------------------------------------------------------------------------------------      3: ahli
#     Def: anggota; orang(-orang) yang termasuk dalam suatu golongan; keluarga atau kaum
# -------------------------------------------------------------------------------------------
# Proverbs
# -------------------------------------------------------------------------------------------
# Related Phrases
#   No. Type           Phrase
#    0: Sinonim       : andal
#                Trans: 1 rely on. 2 trade on.                                               
#    1: Sinonim       : anggota                                                              
#                Trans: 1 member. 2 member, limb. 3 part, component.                         
#    3: Sinonim       : berilmu                                                              
#                Trans: bookish                                                              
#    4: Sinonim       : bernas                                                               
#                Trans: 1 filled out. 2 full (of breasts). 3 pithy, terse,                   
#                       spirited.                                                            
#    5: Sinonim       : berpengalaman                                                        
#                Trans: case hardened,have eyeteeth,through the                              
#                       mill,well-grounded                                                   
#    6: Sinonim       : berpengetahuan                                                       
#                Trans: knowledgeable.                                                       
#    7: Sinonim       : cakap                                                                
#                Trans: 1. 1) able, capable. 2) adroid, clever, skillful.                    
#                       3) good-looking. 2. words, statement.                                
#    8: Sinonim       : campin                                                               
#                Trans: 1 skillful, handy. 2 clever, adept.                                  
#    9: Sinonim       : cendekiawan                                                          
#                Trans: 1 an intellectual. 2 the educated (class).                           
#   11: Sinonim       : empu                                                                 
#                Trans: 1 (Lit.) master craftsman. 2 armorer. 3 master.                      
#   12: Sinonim       : hebat                                                                
#                Trans: unusually intensive (excitement, attractiveness,                     
#                       intelligence, violence, etc.).                                       
#   13: Sinonim       : jago                                                                 
#                Trans: 1 cock, rooster. 2 gamecock. 3 champion, athlete. 4                  
#                       (Pol.) candidate. 5 charismatic leader of a group.                   
#   14: Sinonim       : jauhari                                                              
#                Trans: 1 jeweler. 2 expert, specialist.                                     
#   15: Sinonim       : jempolan                                                             
#                Trans: hotstuff                                                             
#   16: Sinonim       : johar                                                                
#                Trans: 1. k.o. fast-growing shade tree the crown of which                   
#                       yields firewood. 2. see BINTANG, ZOHRAH. 3. see                      
#                       JAUHAR.                                                              
#   17: Sinonim       : juara                                                                
#                Trans: 1 champion. 2 referee in a cockfight.                                
#   18: Sinonim       : kawakan                                                              
#                Trans: experienced, veteran.                                                
#   19: Sinonim       : kompeten                                                             
#                Trans: competent.                                                           
#   20: Sinonim       : lihai                                                                
#                Trans: 1 shrewd, astute. 2 wily, cunning. 3 terrific,                       
#                       tremendous.                                                          
#   21: Sinonim       : mahir                                                                
#                Trans: skilled, well-versed, clever.                                        
#   22: Sinonim       : mampu                                                                
#                Trans: 1 capable, able. 2 well-to-do, wealthy. 3 afford,                    
#                       be able.                                                             
#   25: Sinonim       : pakar                                                                
#                Trans: expert in certain field.                                             
#   26: Sinonim       : pandai                                                               
#                Trans: 1. 1) bright, smart. 2) capable. 3) know, know how.                  
#                       2. goldsmith.                                                        
#   27: Sinonim       : pendeta                                                              
#                Trans: 1 Protestant clergyman, Hindu or Budhist priest. 2                   
#                       (Lit.) pundit, scholar.                                              
#   28: Sinonim       : piawai                                                               
#                Trans: skilled, expert, sophisticated.                                      
#   29: Sinonim       : profesional                                                          
#                Trans: professional                                                         
#   30: Sinonim       : sarjana                                                              
#                Trans: 1 scholar, academician degree-holder. 2 title of                     
#                       degree similar to the Bachelor's. sarjana-Hukum                      
#                       Master of Law. sarjana-lengkap PhD Candidate                         
#                       (pre-1980s). sarjana-Kimia BS in chemistry.                          
#   31: Sinonim       : spesialis                                                            
#                Trans: specialist.                                                          
#   32: Sinonim       : teknikus                                                             
#                Trans: technician.                                                          
#   33: Sinonim       : terampil                                                             
#                Trans: see TRAMPIL.                                                         
#   34: Sinonim       : tukang                                                               
#                Trans: 1 skilled laborer or craftsman. tukang-azan o. who                   
#                       summons to. tukang-besi blacksmith. tukang-bubut a                   
#                       filter. tukang-jambret purse snatcher. tukang-loak                   
#                       seconhand dealer. 2 o. who has the bad habit of                      
#   36: Sinonim       : ulung                                                                
#                Trans: 1 capable, skilled, experienced. 2 excelent,                         
#                       superior.                                                            
#   37: Sinonim       : unggul                                                               
#                Trans: superior, excellent.                                                 
#   39: Turunan       : keahlian                                                             
#                Trans: expertise, skill, competence, know-how.                              
#   41: Gabungan kata : ahli agama                                                           
# 
#   42: Gabungan kata : ahli bahasa                                                          
# 
#   43: Gabungan kata : ahli bait                                                            
# 
#   44: Gabungan kata : ahli bedah                                                           
# 
#   45: Gabungan kata : ahli bumi                                                            
# 
#   46: Gabungan kata : ahli famili                                                          
# 
#   47: Gabungan kata : ahli filsafat                                                        
# 
#   48: Gabungan kata : ahli fisika                                                          
# 
#   49: Gabungan kata : ahli fitopatologi                                                    
# 
#   50: Gabungan kata : ahli gempa                                                           
# 
#   51: Gabungan kata : ahli geofisika                                                       
# 
#   52: Gabungan kata : ahli geologi                                                         
# 
#   53: Gabungan kata : ahli geologi minyak                                                  
# 
#   54: Gabungan kata : ahli hadis                                                           
# 
#   55: Gabungan kata : ahli hukum                                                           
# 
#   56: Gabungan kata : ahli ibadah                                                          
# 
#   57: Gabungan kata : ahli ilmu racun                                                      
# 
#   58: Gabungan kata : ahli informasi                                                       
# 
#   59: Gabungan kata : ahli kitab                                                           
# 
#   60: Gabungan kata : ahli kubur                                                           
# 
#   61: Gabungan kata : ahli maksiat                                                         
# 
#   62: Gabungan kata : ahli matematika                                                      
# 
#   63: Gabungan kata : ahli media                                                           
# 
#   64: Gabungan kata : ahli mesin kapal                                                     
# 
#   65: Gabungan kata : ahli mikologi                                                        
# 
#   66: Gabungan kata : ahli multimedia                                                      
# 
#   67: Gabungan kata : ahli nujum                                                           
# 
#   68: Gabungan kata : ahli obat                                                            
# 
#   69: Gabungan kata : ahli patung                                                          
# 
#   70: Gabungan kata : ahli peneliti madya                                                  
# 
#   71: Gabungan kata : ahli peneliti muda                                                   
# 
#   72: Gabungan kata : ahli peneliti utama                                                  
# 
#   73: Gabungan kata : ahli peserta                                                         
# 
#   74: Gabungan kata : ahli pikir                                                           
# 
#   75: Gabungan kata : ahli purbakala                                                       
# 
#   76: Gabungan kata : ahli rumah                                                           
# 
#   77: Gabungan kata : ahli seismologi                                                      
# 
#   78: Gabungan kata : ahli sejarah                                                         
# 
#   79: Gabungan kata : ahli sihir                                                           
# 
#   80: Gabungan kata : ahli sufah                                                           
# 
#   81: Gabungan kata : ahli sufi                                                            
# 
#   82: Gabungan kata : ahli suluk                                                           
# 
#   83: Gabungan kata : ahli sunah                                                           
# 
#   84: Gabungan kata : ahli sunah waljamaah
# 
#   85: Gabungan kata : ahli tafsir
# 
#   86: Gabungan kata : ahli tarekat
# 
#   87: Gabungan kata : ahli tarikh
# 
#   88: Gabungan kata : ahli tasawuf
# 
#   89: Gabungan kata : ahli Taurat
# 
#   90: Gabungan kata : ahli tetas
# 
#   91: Gabungan kata : ahli waris
# 
#   92: Gabungan kata : asisten ahli
# 
#   93: Gabungan kata : pekerja ahli
# 
#   94: Gabungan kata : saksi ahli
# 
# 
# 
# ___________________________________________________________________________________________
# Application : kateglo | Nim : 0.11.3 | private : 0.7.0 | qqTop - 2015
# Elapsed     : 55.005 secs
# 
# 
