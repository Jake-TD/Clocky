--[[ 
	Clocky by Jake AKA Breny
	This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
]]

include('cl_adminmenu.lua')
include('von.lua')

CreateClientConVar( "clocky_showui", "1", true, false )

local ClockyTimePlayed = 0
local TimeFormatted = string.FormattedTime(ClockyTimePlayed)
local ClockyIcon = Material( 'clocky/clocky_icon.png', "noclamp" )
local ScreenW = ScrW()

net.Receive("SendClockyTime", function(length, client)
	ClockyTimePlayed = net.ReadInt(16)
	TimeFormatted = string.FormattedTime(ClockyTimePlayed)
end )

usermessage.Hook( "ClockyTimeChanged", function( data )
	ClockyTimePlayed = data:ReadLong()	
	TimeFormatted = string.FormattedTime(ClockyTimePlayed)
end)

timer.Create('ClockyUpdateFormatted', 60, 0, function()	
	ClockyTimePlayed = ClockyTimePlayed + 60
	TimeFormatted = string.FormattedTime(ClockyTimePlayed)
end)

local mainfont = surface.CreateFont( "clockyfont", {
	font = "Trebuchet MS",
	size = 10,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false
} )

hook.Add("HUDPaint", "ClockyHUDPaint", function()

	if GetConVar("clocky_showui"):GetInt() == 0 then return end

	surface.SetDrawColor( 157, 192, 224, 255 )
	surface.DrawRect( ScreenW - 96, 18, 80, 42 )

	surface.SetDrawColor( 192, 227, 247, 255 )
	surface.DrawRect( ScreenW - 96, 20, 78, 38 )

	surface.SetMaterial( ClockyIcon )
	surface.SetDrawColor( 255,255,255,255 )
	surface.DrawTexturedRect( ScreenW - 140, 16, 46, 46 )

	draw.DrawText("Hours: " .. TimeFormatted['h'], mainfont, ScreenW - 90, 24, Color(106, 130, 150, 255), TEXT_ALIGN_LEFT)	
	draw.DrawText("Minutes: " .. TimeFormatted['m'], mainfont, ScreenW - 90, 40, Color(106, 130, 150, 255), TEXT_ALIGN_LEFT)

end)