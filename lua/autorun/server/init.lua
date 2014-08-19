--[[ 
	Clocky by Jake AKA Breny
	This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
]]

include('config.lua')
include('meta.lua')
include('von.lua')

if Clocky.Admin.Enabled then
	AddCSLuaFile('von.lua')
	util.AddNetworkString("SendClockyAdmin")
end

AddCSLuaFile('cl_adminmenu.lua') --This will be needed either way for a small config menu to let players hide/show UI
resource.AddFile('resource/fonts/absender1.ttf') --This too

resource.AddFile('materials/clocky/clocky_icon.png')

util.AddNetworkString("SendClockyTime")

if Clocky.SQL.Enabled then
	if Clocky.SQL.Module == 'mysqloo' then 
		require('mysqloo')
	elseif Clocky.SQL.Module == 'tmysql' then 
		require ('tmysql4')
	end
end

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
	
	if Clocky.SQL.Module == 'mysqloo' then
		if not mysqloo then error('mysqloo module is not active!') end
		
		if Clocky.SQL.Socket == "" then
			ClockyDB = mysqloo.connect(Clocky.SQL.Host, Clocky.SQL.Username, Clocky.SQL.Password, Clocky.SQL.Database, Clocky.SQL.Port)
		else
			ClockyDB = mysqloo.connect(Clocky.SQL.Host, Clocky.SQL.Username, Clocky.SQL.Password, Clocky.SQL.Database, Clocky.SQL.Port, Clocky.SQL.Socket)
		end

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
		
	elseif Clocky.SQL.Module == 'tmysql' then
		if not tmysql then error('tmysql module is not active!') end
		
		print('++Clocky connecting++')
		
		if Clocky.SQL.Socket == "" then
			ClockyDB, err = tmysql.initialize(Clocky.SQL.Host, Clocky.SQL.Username, Clocky.SQL.Password, Clocky.SQL.Database, Clocky.SQL.Port)
		else
			ClockyDB, err = tmysql.initialize(Clocky.SQL.Host, Clocky.SQL.Username, Clocky.SQL.Password, Clocky.SQL.Database, Clocky.SQL.Port, Clocky.SQL.Socket)
		end

		if ClockyDB then
			print('++Clocky connected to database++')
		elseif err then
			ErrorNoHalt('++Clocky failed to connect++\n  Error: ' .. err)
		end

		function Clocky:GetData(ply)

			local qs = "SELECT timeplayed FROM clocky_userinfo WHERE steamid = '" .. ply:SteamID() .. "' LIMIT 1"

			local function onCompleted(results, status, err)
				
				if status == QUERY_SUCCESS then
					ply.ClockySQLTime = data
					ply:LoadClockySQL()
				else
					ErrorNoHalt('++Clocky error loading user++\n  Error: ' .. err)
				end
				
			end
			
			ClockyDB:Query(qs, onCompleted)

		end

		function query(sql)

			local function onCompleted( results, status, err )
				
				if status == QUERY_SUCCESS then
					print('++Clocky query successful++')
				else
					ErrorNoHalt( err )
				end
				
			end

			ClockyDB:Query(sql, onCompleted)

		end

		timer.Create('ClockyCreateDatabase', 3, 1, function()
			query('CREATE TABLE IF NOT EXISTS clocky_userinfo(steamid TEXT, timeplayed TEXT)')
		end)
		
	end
end

/*
	Chat commands
*/

hook.Add( "PlayerSay", "ClockyOpenMenu", function(ply, text, team)
	if text == Clocky.MenuCommand then
		umsg.Start( "ClockyOpenMenu", ply )
			umsg.Bool( true )
		umsg.End()
		return false
	end
end)

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

	if !Clocky.Admin.Enabled or !istable(Clocky.Admin.Ranks) then return end
	
	local IsHighRank = ply:IsClockyHighRank()

	--Send the new data to admins

	for k,v in pairs(player.GetAll()) do
		if v == ply and IsHighRank then 
			v:ClockyCanConfig()
			v:SendClockyAdmin()
		elseif v:IsClockyRank() or v:IsClockyHighRank() then
			v:SendClockyAdmin()
		end
	end

end)

hook.Add("PlayerDisconnected", "ClockyPlayerLeave", function(ply)
	ply:SaveClocky()

	if !Clocky.Admin.Enabled or !istable(Clocky.Admin.Ranks) then return end

	--Send the new data to admins

	for k,v in pairs(player.GetAll()) do
		if v == ply then return end		
		if v:IsClockyRank() or v:IsClockyHighRank() then
			v:SendClockyAdmin()
		end
	end

end)

hook.Add("ShutDown", "ClockyShutdown", function()
	for k,v in pairs(player.GetAll()) do
		v:SaveClocky()
	end
end)

/*
	Extra for saving to file
*/

if Clocky.Save.Type == 'PData' or Clocky.SQL.Standalone then return end --Don't need these if PData

function Clocky:LoadFile(steamid)
	local filecontents = file.Read(Clocky.Save.Folder .. '/'  .. steamid .. '.txt', 'DATA')
	return filecontents
end

function Clocky:SaveFile(steamid, timeplayed)
	file.Write(Clocky.Save.Folder .. '/'  .. steamid .. '.txt', timeplayed)
end