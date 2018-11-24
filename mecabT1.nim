
import pythonize

# Old example, may not work on newer setups
# needs python2.7 and full Mecab installation
# Example of running mecab via python with Nim  
# Note : This needs to be redone for python3 and using the newer nimpy library

var nimkata = ""
var mecab = ""
echo()
echo()
var jtext = "打力全盛の高校野球、投手の逆襲に期待"

echo "Mixed kanji , hiragana text " , " -->  ",jtext
echo()

proc doMecab(b:string):auto =
        pythonEnvironment["text"] = b
        execPython("mecab = MeCab.Tagger('-Oyomi')")
        execPython("kata  = mecab.parse(text)")
        nimkata = pythonEnvironment["kata"].depythonify(string)
        execPython("hira = kata2hira(kata)")
        execPython("mecab = MeCab.Tagger ()")
        execPython("print mecab.parse(text)")
             
        result = pythonEnvironment["hira"].depythonify(string)
        

# set up for japanese
execPython("import MeCab")
execPython("from jcconv import kata2hira")

echo "Hiragana : ", doMecab(jtext)
echo "katakana : ", nimkata
echo "Nim speaks japanese , with a little help from python"
echo()

