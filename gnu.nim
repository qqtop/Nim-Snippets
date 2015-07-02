import os,terminal,private

# The absolute must have gnu !

proc gnuMe():string =
      eraseScreen()
      cursorUp(80)
      rainbow("\nWWWWWW||WWWWWW\n W W W||W W W \n      || \n    ( OO )__________  \n     /  |          \\ \n    /o o| Niminator  \\ \n    \\___/||_||__||_||-* \n         || ||  || || \n        _||_|| _||_|| \n       (__|__|(__|__| ") 
      decho(2)
      sleepy(1)
     

for j in (0.. 10):
    discard gnuMe()

echo()

