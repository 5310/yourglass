Yourglass: A Game of Giving
===========================


Controls
------------

Direction keys.
-	Left/right to rotate.
-	Down to be more insistent!


Running the Game
----------------

As the game is still _very_ much under-development, there is no `.love` package available.
Therefore, in order to run, do the following:

1.	First, install [LÖVE][1] for you system, if you haven't.
2.	From the `yourglass` directory run your system's relevant runner script; eg `run.sh` on Linux.
3.	Et voilà, it runs! Impressive eh?


Gitting Stuff
-------------

Keep forgetting git? This section may help. Or you may try the [cheat-sheet][2].

-	`git add .` will add all files from the working directory to the index.
-	**`git add -u` will update your tracked files to the index, effectively taking a snapshot.**
-	`git diff` and `git cheackout` will diff from revert you to the index.
-	**`git commit -a -m "Commit message."` will update all your tracked changes to the index, and then commit it to the local repo.**
-	`git commit -m "Commit message."` will commit the current index to the local repo.
-	`git diff HEAD` and `git checkout HEAD` will diff from and revert you to the local-repo.
-	`git stash save "Stash message."` will stash your current working directory.
-	**`git push`** will push your local repo's last commit to the remote repo, if it's fresh!
-	**`git pull origin master` will get merge the remote repo's current state to your working directory.**

- - -

[1]: http://love2d.org/								"LÖVE"
[2]: http://help.github.com/git-cheat-sheets/		"Github Git Cheat-sheet"
