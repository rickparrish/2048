2048
====

![screenshot](https://raw.githubusercontent.com/rickparrish/2048/master/Screenshot.png)

2048 is a single-player bbs door game in which the objective is to slide tiles on a grid to combine them and create a 
tile with the number 2048<br />
<br />
NOTE: If you run Synchronet, you might want to have a look at <a href="https://github.com/Kirkman/Doubles">Doubles</a>.

<hr />

Based on <a href="http://gabrielecirulli.github.io/2048/">2048 by Gabriele Cirulli</a>, 
which is based on <a href="https://itunes.apple.com/us/app/1024!/id823499224">1024 by Veewo Studio</a>, 
which are conceptually similar to <a href="http://asherv.com/threes/">Threes by Asher Vollmer</a>.<br />
<br />
ANSI board & tiles are borrowed, with permission, from <a href="https://github.com/Kirkman/Doubles">Doubles</a>.  Thanks Kirkman!

<hr />

NOTE: While the <a href="https://github.com/gabrielecirulli/2048">source to 2048 by Gabriele Cirulli</a> is available 
on GitHub, this version is a complete rewrite in Pascal for bbs door usage, not a port of his javascript version.  
So if you find differences, it's probably because I guessed wrong about certain implementation details (some I looked up, 
like chance of a new tile with value of 4 instead of 2, but most I just guessed based on observations made while playing 
the original).

<hr />

TODO List<br />

- Make it look nicer (add some colour, etc)
- Help screen
- Arrow key support (in RMDoor)
- InterBBS support (in RMDoor)
  - Top score from all connected systems
  - Chat with users from any connected system
- Personal high score