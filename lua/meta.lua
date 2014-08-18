--[[ 
	Clocky by Jake AKA Breny
	This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
]]

local meta = FindMetaTable("Player")

function meta:LoadClockySQL()

	if #self.ClockySQLTime > 0 then

		self.ClockySQLTime = von.deserialize(self.ClockySQLTime)

		if IsValid(self.ClockySQLTime[Clocky.SQL.Servername]) then
			self.ClockyCurrentTime = self.ClockySQLTime[Clocky.SQL.Servername]
		end

		print('++Clocky - FINISHED++')

	else

		local shouldOverrideSQL = true

		if Clocky.SQL.Module == 'mysqloo' and ClockyDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
			ClockyDB:connect()
			ClockyDB:wait()
			if ClockyDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
				shouldOverrideSQL = false
			else --If connection has been reestablished, try saving again
				Clocky:GetData(self) --This is probably really inefficient :(
			return end
		end

		if !shouldOverrideSQL then return end --Don't want to accidently override the SQL

		local newSave = {}
		newSave[Clocky.SQL.Servername] = 0
		newSave = von.serialize(newSave)

		query("INSERT INTO clocky_userinfo (steamid, timeplayed) VALUES ('" .. self:SteamID() .. "','" .. newSave .. "')")
		print('++Clocky generated new user++')

		if Clocky.SQL.Standalone then
			self.ClockyCurrentTime = 0
		end

	end

end

function meta:LoadClocky()

	if !Clocky.SQL.Standalone then
		if Clocky.Save.Type == 'file' then

			if !file.Exists(Clocky.Save.Folder .. '/' .. self:SteamID64() .. '.txt', 'DATA') then

				local clockyPData = self:GetPData("ClockyTimePlayed", 0)
				self.ClockyCurrentTime = clockyPData

			else

				self.ClockyCurrentTime = Clocky:LoadFile(self:SteamID64())

			end

		else

			local clockyPData = self:GetPData("ClockyTimePlayed", 0)
			self.ClockyCurrentTime = clockyPData

			if self.ClockyCurrentTime == 0 and file.Exists(Clocky.Save.Folder .. '/' .. self:SteamID64() .. '.txt', 'DATA') then
				self.ClockyCurrentTime = Clocky:LoadFile(self:SteamID64())
			end

		end
	end

	if !Clocky.SQL.Enabled then return end

	Clocky:GetData(self)

end

function meta:SaveClocky()

	self.ClockyCurrentTime = self:GetClocky()

	if Clocky.SQL.Enabled then --Save to MySQL

		if self.ClockyCurrentTime == nil then return end
		if !(#self.ClockySQLTime > 0) then return end

		local timeplayed = self.ClockySQLTime[1]['timeplayed']
		timeplayed = von.deserialize(timeplayed)
		timeplayed[Clocky.SQL.Servername] = self.ClockyCurrentTime
		timeplayed = von.serialize(timeplayed)

		if Clocky.SQL.Module == 'mysqloo' and ClockyDB:status() == mysqloo.DATABASE_NOT_CONNECTED then
			ClockyDB:connect()
			ClockyDB:wait()
			if ClockyDB:status() == mysqloo.DATABASE_NOT_CONNECTED then return end
			query("UPDATE clocky_userinfo SET timeplayed='" .. timeplayed .. "' WHERE steamid='" .. self:SteamID() .. "'")
		else
			query("UPDATE clocky_userinfo SET timeplayed='" .. timeplayed .. "' WHERE steamid='" .. self:SteamID() .. "'")
		end

		print('++Clocky saved disconnecting user++')

	end

	if Clocky.SQL.Standalone then return end --Stop if only saving to MySQL

	if Clocky.Save.Type == 'PData' then --Saving to PData
		
		self:SetPData('ClockyTimePlayed', self.ClockyCurrentTime) --Save to PData
		print('++Clocky saved user to PData++')

	elseif Clocky.Save.Type == 'file' then --Saving to a file

		Clocky:SaveFile(tostring(self:SteamID64()), tostring(self.ClockyCurrentTime)) --Save to file
		print('++Clocky saved user to file++')

	else --Not sure why anyone would want to save to file and PData, but keeping it in here

		self:SetPData('ClockyTimePlayed', self.ClockyCurrentTime) --Save to PData
		Clocky:SaveFile(tostring(self:SteamID64()), tostring(self.ClockyCurrentTime)) --Save to file
		print('++Clocky saved user to PData and file++')

	end

end

function meta:GetClocky()
	return (self.ClockyCurrentTime + math.ceil(self:TimeConnected() - self.ClockyLastSave))
end

function meta:SendClocky()
	net.Start("SendClockyTime")
		net.WriteInt(math.ceil(self:GetClocky()), 16)
	net.Send(self)
end
