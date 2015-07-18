import os,terminal,private,strutils

# The absolute must have gnu !


proc gnuMe(j:int):string =
      eraseScreen()
      cursorUp(80)
      rainbow("\n WWWWWW||WWWWWW\n  W W W||W W W \n       || \n     ( OO )__________  \n      /  |          \\ \n     /o o| Niminator  \\ \n     \\___/||_||__||_||-*  \n         || ||  || || \n         _||_|| _||_|| \n        (__|__|(__|__| ") 
      decho(2)
      rainbow("   Gnu sightings :  ")
      echo j
      sleepy(0.15)
     

for j in 0.. 60:
    discard gnuMe(j.int)
    
echo()

