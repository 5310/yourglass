Yourglass: A Game of Giving
===========================


Yourglass is a game of giving. What that means is, as a real gentleman, you must excersize your duty by giving all you've got. Everything.

In coarser terms, you must **rotate the hourglass** (or _yourglass_, as it is essentially; certainly not _mine_) and **empty your half** of all the... err, sand.

Then you win. Bravo! Such breadth of heart! A show of a true gentleman.


How do I play?
--------------

The Blue gentleman has controls over the `left`, `right` and `down` **navigation keys**.
While the Red gentleman peruses the `a`, `s`, `d` **letter keys** in that order.

Turning `left`/`a` or `right`/`d` will rotate the glass, ever so slightly if you merely lolligag.
However, if you wish to make an impression upon the oppositi-- I mean, the _needy_, you will have to really _insist_.
Which you can do by holding the `down`/`s` button. Insisting too much is frowned upon, be polite.


Running the Game
----------------

The **beta** is here. Which, in our rugged world-view, is the same as a stable release.  
** The downloads are on top of this page.**  
Your options are as follows:

If you are on **Windows**:

1. 	Download [**`yourglass.zip`**][1].
2. 	Extract to anywhere, let's say... the Desktop, yes.
3. 	Open the folder `yourglass`.
4. 	Double-click `yourglass.exe` to play.

If you are on **Windows**, like **standalone executable** and can do **without the pretty icon**:

1. 	Download the standalone [**`yourglass.exe`**][2]. I cannot, for the love of the Queen, add the icon.
2. 	Double-click to play!

If you are on **Linux**, **OSX** or **elsewhere**, or, perhaps if you are as rugged and handsome as we are, you shall do the following:

1. 	First, install [LÖVE][3] for you system, if you haven't.
2. 	Download [**`yourglass.love`**][4], the gentlemanly love package.
3. 	Double-click to play!

Can't download the files? Oh dear me. Are you sure the burly `download` button up there doesn't work either?


Rugged-Manly Stuff
------------------

The following should not interest you if your only intents are playing. However, should you be, as we said, an adventurous individual, you will do well to read it.  
Or not, perhaps.

### Gitting Stuff

Keep forgetting git? This section may help. Or you may try the [cheat-sheet][5].

-	`git add .` will add all files from the working directory to the index.
-	**`git add -u` will update your tracked files to the index, effectively taking a snapshot.**
-	`git diff` and `git cheackout` will diff from revert you to the index.
-	**`git commit -a -m "Commit message."` will update all your tracked changes to the index, and then commit it to the local repo.**
-	`git commit -m "Commit message."` will commit the current index to the local repo.
-	`git diff HEAD` and `git checkout HEAD` will diff from and revert you to the local-repo.
-	`git stash save "Stash message."` will stash your current working directory.
-	**`git push`** will push your local repo's last commit to the remote repo, if it's fresh!
-	**`git pull origin master` will get merge the remote repo's current state to your working directory.**


### Packaging for Windows

Not as easy as the [wiki][6] makes it sound. Though the unpacked `.dll`s are just as easily included with the `.exe`, we would rather have ONE singular file.

Instead, we follow this [fine and helpful post][7] first:

1. 	`tar cvf yourglass.tar love.exe DevIL.dll openal32.dll SDL.dll yourglass.love`
2. 	`bzip2 -9 yourglass.tar`
3. 	`pack -i yourglass.tar.bz2 -o yourglass.exe -a love yourglass.love`

There you go, a standalone Windows binary `yourglass.exe`. Yes, you can have it.



- - -

[1]: http://dl.dropbox.com/u/164058/yourglass/yourglass.love			"Windows Executable Zip"
[2]: http://dl.dropbox.com/u/164058/yourglass/yourglass.exe			"Standalone Iconless .exe"
[3]: http://love2d.org/										"LÖVE"
[4]: http://dl.dropbox.com/u/164058/yourglass/yourglass.zip			"Universal .love"
[5]: http://help.github.com/git-cheat-sheets/						"Github Git Cheat-sheet"
[6]: http://love2d.org/wiki/Game_Distribution						"LÖVE Wiki Article on Distribution"
[7]: http://love2d.org/forums/viewtopic.php?f=3&t=1428&p=19103&hilit=.exe+.dll#p19103
