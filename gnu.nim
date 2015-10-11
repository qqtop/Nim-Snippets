import private,strutils

# The absolute must have gnu !


proc gnuMe(j:int):string =
      clearup()
      rainbow("\n WWWWWW||WWWWWW\n  W W W||W W W \n       || \n     ( OO )__________  \n      /  |          \\ \n     /o o| Niminator  \\ \n     \\___/||_||__||_||-*  \n         || ||  || || \n         _||_|| _||_|| \n        (__|__|(__|__| ") 
      decho(2)
      printB(" Professional Gnu sightings :  ")
      printLn($j,brightwhite,brightblue)
      sleepy(0.15)
     

for j in 0.. 60:
    discard gnuMe(j.int)
doFinish()

