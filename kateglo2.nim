import os,cx,httpclient,json,strfmt,strutils,sets,rdstdin

##
##   Program     : kateglo2.nim
##
##   Status      : stable
##
##   License     : MIT opensource
##
##   Kateglo     : Content license is CC-BY-NC-SA except as specified below.
##                 Details licenses CC-BY-NC-SA can be found at:
##                 http://creativecommons.org/licenses/by-nc-sa/3.0/
##                 for other than personal use visit kateglo.com
##
##   Version     : 0.7.0
##
##   ProjectStart: 2015-09-06
##
##   Compiler    : Nim 0.16.0  https://github.com/nim-lang/Nim
##
##   Description : Indonesian - Indonesian  Dictionary
##
##                 at kateglo.com  via public API
##
##                 with english translation
##
##
##                 compile:  nim c -d:release kateglo2
##
##                 run    :  kateglo2
##
##
##
##                 to stop this program : Ctrl-C   or enter word : quit
##
##
##
##   Notes       : the API appears to only allow single word input
##
##                 output is limited to 20 Sinonim , Turunan  , Gabungan Kata
##
##                 for performance reason , kateglo has some malformed json
##
##                 data which maybe skipped by our parsing efforts which
##
##                 shows when numbering has holes .
##
##
##   Requires    : cx.nim
##
##
##   Project     : https://github.com/qqtop/Nim-Snippets
##
##
##   Tested      : on linux only 2017-01-14
##
##
##   Programming : qqTop
##

var wflag :bool = false
var wflag2:bool = false

proc getData(theWord:string):JsonNode =
    var r:JsonNode
    var zcli = newHttpClient(timeout = 1000)
    try:
       r = parseJson(zcli.getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord))
    except JsonParsingError:
       msgr() do : echo "Word " & theWord & "  not defined in kateglo."
       msgr() do : echo "Maybe misspelled or not a root word."
       msgr() do : echo "Lema yang dicari tidak ditemukan !"
       r = nil
       wflag = true
    result = r

proc getData2(theWord:string):JsonNode =
    var r:JsonNode
    var zcli = newHttpClient(timeout = 1000)
    try:
       r = parseJson(zcli.getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord))

    except JsonParsingError:
       r = nil
       wflag = true

    except HttpRequestError:
       r = nil
       sleepy(1)
       printLn("Timeout 1 sec : Kateglo server was hit too fast",red)
       r = parseJson(zcli.getContent("http://kateglo.com/api.php?format=json&phrase=" & theWord))

    result = r


var aword = ""
infoLine()
echo()
while true:
      wflag = false
      wflag2 = false
      aword = ""
      var tw = getTerminalWidth()
      msgc() do: echo "..."
      echo()
      aword = readLineFromStdin("Kata : ")
      if aword == "quit":
        doFinish()

      let data = getData(aword)
      let sep = ":"

      if wflag == false:

            echo()
            superHeader("Kateglo Indonesian - Indonesian Dictionary")
            printLnBiCol("Dicari Kata    : " & aword,sep,brightcyan,rosybrown)
            echo()
            proc ss(jn:JsonNode):string =
                # strip " from the string
                #var jns = $jn
                var jns = replace($jn,"\"")
                result = jns

            var c = 0

            proc defini(data:JsonNode) =
                  printLn("Definitions",yellowgreen)
                  echo()
                  for zd in data["kateglo"]["definition"]:
                      c += 1
                      printLnBiCol("{:>7}{} {}".fmt(c,sep,ss(zd["phrase"])),":",brightcyan,rosybrown)
                      if $ss(zd["def_text"]) == "null":
                          printLnBiCol("{:>7}{} {}".fmt("Def",sep,"Nothing Found"),":",lightcoral,red)

                      elif ss(zd["def_text"]).len > tw:
                            # for nicer display we need to splitlines
                            var oks = splitlines(wordwrap(ss(zd["def_text"]),tw-20))
                            #print the first line
                            printLnBiCol("{:>7}{} {}".fmt("Def",sep,oks[0]),":",lightcoral,termwhite)
                            for x in 1.. <oks.len   :
                                # here we pad 10 blaks on left
                                oks[x] = align(oks[x],10 + oks[x].len)
                                printLn("{}".fmt(oks[x]),termwhite)

                      else:
                            printLnBiCol("{:>7}{} {}".fmt("Def",sep,ss(zd["def_text"])),":",lightcoral,termwhite)

                      if ss(zd["sample"]) != "null":
                          # put the phrase into the place holders -- or ~ returned from kateglo
                          var oksa = replace(ss(zd["sample"]),"--",ss(zd["phrase"]))
                          oksa = replace(oksa,"~",ss(zd["phrase"]))
                          var okxs = splitlines(wordwrap(oksa,tw-20))
                          #print the first line
                          printLnBiCol("{:>7}{} {}".fmt("Sample",sep,okxs[0]),sep,lightcoral,termwhite)
                          for x in 1.. <okxs.len   :
                            # here pad 10 blanks on left
                            okxs[x] = align(okxs[x],10 + okxs[x].len)
                            printLn("{}".fmt(okxs[x]),termwhite)
                      hline(tw,black)


            proc relati(data:JsonNode) =
                  var dx = data["kateglo"]["all_relation"]
                  if isNil(dx) == false:
                    try:
                      var maxsta = dx.len-1
                      if maxsta > 0:
                          if maxsta > 20: maxsta = 20  # limit data rows to abt 20
                          printLn("Related Phrases",yellowgreen)
                          echo()
                          var mm = "{:>5} {:<14} {}".fmt("No.","Type","Phrase")
                          print(mm,mm,yellow,styled = {styleUnderscore})
                          decho(2)
                          for zd in 0.. <maxsta:
                            try:
                              var trsin = ""
                              var rphr = ss(dx[zd]["related_phrase"])
                              var rtyp = ss(dx[zd]["rel_type_name"])
                              if rtyp == "Sinonim" or rtyp == "Turunan" or rtyp == "Antonim":
                                # TODO : check that we only pass a single word rather than a phrase
                                #        to avoid errors and slow down

                                var phrdata = getData2(rphr)
                                if wflag2 == false:

                                    var phdx = phrdata["kateglo"]["translations"]
                                    if phdx.len > 0:
                                        trsin =  ss(phdx[0]["translation"])
                                        printLnBiCol("{:>4}{} {:<14}: {}".fmt($(zd+1),":",ss(dx[zd]["rel_type_name"]),ss(dx[zd]["related_phrase"])),sep,lightcoral,termwhite)
                                        var okxs = splitlines(wordwrap(trsin,tw - 40))
                                        # print trans first line
                                        printLnBiCol("{:>20}{} {}".fmt("Trans",":",okxs[0]),sep,powderblue,termwhite)
                                        if okxs.len > 1:
                                            for x in 1.. <okxs.len :
                                                # here pad 22 blanks on left
                                                okxs[x] = align(okxs[x],22 + okxs[x].len)
                                                printLn("{}".fmt(okxs[x]),termwhite)




                                # need a sleep here or we hit the kateglo server too hard
                                # if too many crashes like
                                # Error: unhandled exception: 503 Service Temporarily Unavailable [HttpRequestError]
                                # then increase waiting secs --> see getData2 we wait one sec for next request
                                # in case of error and this seems to remove most crashes
                                sleepy(0.5)

                              else:
                                printLnBiCol("{:>4}{} {:<14}: {}".fmt($zd,":",rtyp,rphr),sep,lightcoral,termwhite)

                            except:
                                   discard


                    except:
                      discard


            proc transl(data:JsonNode) =
                  var dx = data["kateglo"]["translations"]
                  printLn("Translation",yellowgreen)
                  echo()
                  for zd in 0.. <dx.len:
                      printLnBiCol("{:>8}{} {}".fmt(ss(dx[zd]["ref_source"]),":",ss(dx[zd]["translation"])),sep,lightcoral,termwhite)
                  hline(tw,green)


            proc proverbi(data:JsonNode) =
                  var dx = data["kateglo"]["proverbs"]
                  if isNil(dx) == false:
                      var maxsta = dx.len-1
                      if maxsta > 0:
                          if maxsta > 20: maxsta = 20  # limit data to abt 20
                          printLn("Proverbs",yellowgreen)
                          echo()
                          for zd in 0.. <dx.len:
                              printLnBiCol("{:>4} Prov {} {}".fmt($(zd+1),":",ss(dx[zd]["proverb"])),sep,lightcoral,termwhite)
                              printLnBiCol("{:>4} Mean {} {}".fmt($(zd+1),":",ss(dx[zd]["meaning"])),sep,lightcoral,termwhite)
                              hline(tw,black)


            # main display loop
            transl(data)
            decho(1)
            defini(data)
            decho(1)
            proverbi(data)
            decho(1)
            relati(data)


doFinish()



#############################################################################
# OUTPUT EXAMPLE OF THIS PROGRAM  (ACTUAL OUTPUT IS COLORIZED)              #
#############################################################################




################################################################
# Kateglo Indonesian - Indonesian Dictionary   Data for : bila #
################################################################
#
# Translation
#   ebsoft: 1 when. 2 when, if.
#   gkamus: 1 when. 2 when, if.
# --------------------------------------------------------------------------------------------
# Definitions
#       1: bila
#     Def: kata tanya untuk menanyakan waktu; kapan
#  Sample: bila Saudara berangkat?
# --------------------------------------------------------------------------------------------
#       2: bila
#     Def: kalau; jika; apabila
#  Sample: ia baru menjawab bila ditanya
# --------------------------------------------------------------------------------------------
#       3: bila
#     Def: melakukan tindakan balas dendam (di Aceh)
# --------------------------------------------------------------------------------------------
# Proverbs
# --------------------------------------------------------------------------------------------
# Related Phrases
#   No. Type           Phrase
#    2: Sinonim       : apabila
#                Trans: (Lit.) when (esp. in indirect questions)
#    3: Sinonim       : asalkan
#                Trans: so long as
#    4: Sinonim       : bilamana
#                Trans: (Lit.) when.
#    6: Sinonim       : jika
#                Trans: if,in case,would be if
#    7: Sinonim       : kalau
#                Trans: 1 if. 2 when (future). 3 as for..., in the case
#                       of... 4 (Coll.) whether (introducing an indirect
#                       question). 5 (Coll.) that (introducing an indirect
#                       statement).
#    8: Sinonim       : kapan
#                Trans: 1. when ? kapan-saja 1) any time whatsoever. 2)
#                       exactly when. 2. shroud of unbleached cotton. 3.
#                       (Jakarta) because, as you well know...
#    9: Sinonim       : ketika
#                Trans: 1. 1) point in time, moment. 2) when (at a certain
#                       point in time). se-ketika an instant, for a moment.
#                       2. see KARTIKA.
#   11: Sinonim       : masa
#                Trans: 1. 1) time, period. 2) during. 3) phase. 2. see
#                       MASAK 1.
#   14: Sinonim       : saat
#                Trans: /sa'at/ 1 moment. 2 instant. 3 at the moment that,
#                       when.
#   15: Sinonim       : seandainya
#                Trans: if only,in the event that
#   16: Sinonim       : sekiranya
#                Trans: if perhaps, in case.
#   17: Sinonim       : semisal
#                Trans: be like.
#   18: Sinonim       : seumpama
#                Trans: 1 like, equal. 2 supposing.
#   19: Sinonim       : sukat
#                Trans: 1 unit of measure of four gantang or 12.6 liters. 2
#                       measure.
#   20: Sinonim       : waktu
#                Trans: 1 time. 2 when. 3 while. 4 time zone.
#   22: Gabungan kata : barang bila
#
#   23: Gabungan kata : bila mungkin
#
#   24: Gabungan kata : bila perlu
#
#   25: Gabungan kata : bila saja
#
#
#
