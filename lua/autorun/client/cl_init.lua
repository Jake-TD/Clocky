--[[ 
	This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
]]

local ply = LocalPlayer()
ply.ClockyTimePlayed = 0
ply.TimeFormatted = string.FormattedTime(ply.ClockyTimePlayed)
local ClockyIcon = Material( 'clocky/clocky_icon.png', "noclamp" )
local ScreenW = ScrW()
local ScreenH = ScrH()

net.Receive("SendClockyTime", function(length, client)
	ply.ClockyTimePlayed = net.ReadUInt(16)
	ply.TimeFormatted = string.FormattedTime(ply.ClockyTimePlayed)
end )

timer.Create('ClockyClientsideTimer', 1, 0, function()
	ply.ClockyTimePlayed = ply.ClockyTimePlayed + 1
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

	surface.SetDrawColor( 157, 192, 224, 255 )
	surface.DrawRect( ScreenW - 96, 18, 80, 42 )

	surface.SetDrawColor( 192, 227, 247, 255 )
	surface.DrawRect( ScreenW - 96, 20, 78, 38 )

	surface.SetMaterial( ClockyIcon )
	surface.SetDrawColor( 255,255,255,255 )
	surface.DrawTexturedRect( ScreenW - 140, 16, 46, 46 )

	draw.DrawText("Hours: " .. ply.TimeFormatted['h'], mainfont, ScreenW - 90, 24, Color(106, 130, 150, 255), TEXT_ALIGN_LEFT)	
	draw.DrawText("Min: " .. ply.TimeFormatted['m'], mainfont, ScreenW - 90, 40, Color(106, 130, 150, 255), TEXT_ALIGN_LEFT)

end)