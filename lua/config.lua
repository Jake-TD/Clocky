--[[ 
	Clocky by Jake AKA Breny
	This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
]]

/*
	Clocky keeps track of how long players have played, via PData or files and optionally using MySQL for cross-server.

	Some things you need for MySQL integration:
	-A database,
	-Enabled remote SQL access from your server,
	-A (preferably seperate) user for Clocky. Clocky will need select, create, insert and update.

	If the savetype is set to 'both', Clocky will save both as file and PData but will ALWAYS load PData!
*/

Clocky 		= {}
Clocky.Save 	= {}
Clocky.Admin	= {}
Clocky.SQL 	= {}

-- Config

Clocky.MenuCommand 	= "!clocky" 	--What to say in chat to open the menu?
Clocky.SendResources 	= false		--resource.AddFile the materials and font automatically?

Clocky.Save.Type 	= "PData" 	--'PData', 'file' or 'both'
Clocky.Save.Folder 	= "Clocky" 	--What folder in DATA to save to, if savetype is file
Clocky.Save.Autosave 	= true 		--Enable autosave?
Clocky.Save.Interval 	= 300 		--How often to autosave

Clocky.Admin.Enabled 	= true 				--Enable the admin menu?
Clocky.Admin.Ranks 	= {'admin', 'superadmin'} 	--What ranks can use the admin panel? These will not have access to config
Clocky.Admin.HighRanks 	= {'superadmin'} 		--These ranks will also have access to config

Clocky.SQL.Enabled 	= false 	--Change this to true to enable SQL, fill in the required stuff below if true!
Clocky.SQL.Module 	= "mysqloo" 	--Choose between "mysqloo" and "tmysql"
Clocky.SQL.Standalone 	= false 	--Do you want it to save only to MySQL or still use PData/file alongside MySQL?
Clocky.SQL.Servername 	= "SERVER" 	--This is how Clocky will keep track of how long players have played on this specific server, for example 'TTT#1'

Clocky.SQL.Host 	= "" 	--IP
Clocky.SQL.Port 	= 3306 	--Port
Clocky.SQL.Database 	= "" 	--Name of the database
Clocky.SQL.Username 	= "" 	--The username used to connect to the database
Clocky.SQL.Password 	= "" 	--Password of the above user
Clocky.SQL.Socket	= "" 	--Database socketing; leave blank unless you are not using default
