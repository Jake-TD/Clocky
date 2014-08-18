--[[ 
	Clocky by Jake AKA Breny
	This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
]]

require('mysqloo')

include('config.lua')
include('meta.lua')
include('von.lua')

resource.AddFile('materials/clocky/clocky_icon.png')

util.AddNetworkString("SendClockyTime")

if (Clocky.Save.Type == 'file' or Clocky.Save.Type == 'both') and !file.Exists(Clocky.Save.Folder, 'DATA') then
	file.CreateDir(Clocky.Save.Folder) --Check if directory exists in data, if not make one
	print('++Clocky generated savefolder++')
end

if !(Clocky.Save.Type == 'file') and !(Clocky.Save.Type == 'both') and !(Clocky.Save.Type == 'PData') then
	Clocky.Save.Type = 'PData' --Check if no valid Savestyle is defined, if so change to PData
end

/*
	Database stuff
*/

if Clocky.SQL.Enabled then

	ClockyDB = mysqloo.connect(Clocky.SQL.Host, Clocky.SQL.Username, Clocky.SQL.Password, Clocky.SQL.Database, Clocky.SQL.Port)
	ClockyDBQueue = {}

	print('++Clocky connecting++')

	function ClockyDB:onConnected()

		print('++Clocky connected to database++')

		for k, v in pairs( ClockyDBQueue ) do
			query( v[1], v[2] )
		end

		ClockyDBQueue = {}

	end

	function ClockyDB:onConnectionFailed(err)
		print('++Clocky failed to connect++\n  Error: ' .. err)
	end

	ClockyDB:connect()

	function Clocky:GetData(ply)

		local qs = "SELECT timeplayed FROM clocky_userinfo WHERE steamid = '" .. ply:SteamID() .. "' LIMIT 1"
		local q = ClockyDB:query(qs)

		function q:onSuccess(data)

			ply.ClockySQLTime = data
			ply:LoadClockySQL()

		end
		
		function q:onError(err)

			print('++Clocky error loading user++\n  Error: ' .. err)

			if ClockyDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
				print('++Clocky not connected while fetching data, refreshing++')
				ClockyDB:connect() --This stops it from timing out for dumb reasons and not getting the data properly by reconnecting and redoing it if needed
				ClockyDB:wait()
				print('++Clocky attempting to fetch data++')
				Clocky:GetData(ply)
				return
			end

		end
		
		q:start()

	end

	function query(sql)


		local q = ClockyDB:query(sql)

		function q:onSuccess( data )

			print('++Clocky query successful++')

		end

		function q:onError(err)

			if ClockyDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
				table.insert( ClockyDBQueue, sql )
				print('++Clocky not connected, refreshing++')
				ClockyDB:connect()
				return
			end

			print('++Clocky query errored++\n  Error: ' .. err)

		end

		q:start()

	end

	--Made this into a timer because it will error if the ClockyDB is not yet connected, so giving it some time to

	timer.Create('ClockyCreateDatabase', 3, 1, function()
		query('CREATE TABLE IF NOT EXISTS clocky_userinfo(steamid TEXT, timeplayed TEXT)')
	end)
	
end

/*
	Saving, loading etc
*/

--Autosaving

if Clocky.Save.Autosave then
	timer.Create('ClockyAutoSave', Clocky.Save.Interval, 0, function()
		for k,v in pairs(player.GetAll()) do
			v:SaveClocky()
			v.ClockyLastSave = v:TimeConnected()
		end
	end)
end

hook.Add("PlayerInitialSpawn", "ClockyPlayerJoin", function(ply)
	ply:LoadClocky()
	ply:SendClocky()
	if Clocky.Save.Autosave then
		ply.ClockyLastSave = 0
	end
end)

hook.Add("PlayerDisconnected", "ClockyPlayerLeave", function(ply)
	ply:SaveClocky()
end)

hook.Add("ShutDown", "ClockyShutdown", function(ply)
	ply:SaveClocky()
end)

/*
	Extra for saving to file
*/

if Clocky.Save.Type == 'PData' then return end --Don't need these if PData

function Clocky:LoadFile(steamid)
	local filecontents = file.Read(Clocky.Save.Folder .. '/'  .. steamid .. '.txt', 'DATA')
	return filecontents
end

function Clocky:SaveFile(steamid, timeplayed)
	file.Write(Clocky.Save.Folder .. '/'  .. steamid .. '.txt', timeplayed)
end