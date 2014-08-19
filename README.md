Clocky
======

An addon for Garry's Mod to keep track of how long users have played on your server(s)

If you want to use the MySQL saving, you'll need MySQLOO, found here: http://facepunch.com/showthread.php?t=1357773

Clocky is something I made because I couldn't find something to keep track of playtime on multiple servers at once.
What it does is keep track of how long you play, and depending on the config save it to MySQL.

Each server can be assigned a name, such as 'TTT #1' and 'TTT #2'.
They will then be stored in a table, which is then turned into a string using vON and stored to MySQL.
This allows you to easily keep track of individual servers, though if wanted they can be added to get the total playtime on all.
If you wish to just count them all together, you can assign each server the same name so that they will share the data.

Without MySQL it will store playtime to PData, file or both PData and file.

I've added some reasonable config options to let server owners decide how they want to save, how often they want to save, etc.