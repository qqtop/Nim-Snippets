import nimcx

# English number speller


proc doit(anumber:string) =
    try:
        if anumber.contains("."):
           printlnBiCol(anumber & " : " & spellFloat(parseFloat(anumber)))  
        else:    
           printlnBiCol(anumber & " : " & spellInteger(parseInt(anumber)))
    except:
        printLnErrorMsg("Sorry, cannot spell " & anumber)


if paramCount() > 0:
    doit(paramStr(1))
else:
    doit(readLineFromStdin("Enter a number : "))
    
    
    
decho(2)
doFinish()


# Example output

# 930097870000.95 : nine hundred thirty billion ninety seven million eight hundred seventy thousand dot nine five  


