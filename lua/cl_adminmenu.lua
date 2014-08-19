local ClockyIcon = Material( 'clocky/clocky_icon.png', "noclamp" )
local PlayersTime = {}
local LastShow = CurTime()
local TimeDifference = 0
local canconfig = false

net.Receive("SendClockyAdmin", function(length, client)
	PlayersTime = von.deserialize(net.ReadString())
end)

usermessage.Hook( "ClockyCanConfig", function()
	canconfig = true
end)

local Absender= surface.CreateFont( "Absender", {
	font = "absender1",
	size = 24,
	weight = 900,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
} )

local function ShowClockyMenu()

	local MainPanel = vgui.Create( "DFrame" )
	MainPanel:SetPos( ScrW()/2-300, ScrH()/2-200 )
	MainPanel:SetSize( 600, 400 )
	MainPanel:SetTitle('')
	MainPanel:SetSkin("clocky_skin")
	MainPanel:SetDraggable( true )
	MainPanel:SetSizable( false )
	MainPanel:MakePopup()

	local NameLabel = vgui.Create( "DLabel", MainPanel )
	NameLabel:SetPos( 34, 4 )
	NameLabel:SetColor( Color( 133, 160, 209, 255 ) )
	NameLabel:SetFont("Absender")
	NameLabel:SetSize( 400, 26 )
	NameLabel:SetText("Clocky - Administration Panel")

	local ClockyImage = vgui.Create( "DImage", MainPanel )
	ClockyImage:SetImage( 'clocky/clocky_icon.png' )
	ClockyImage:SetSize( 26, 26 )
	ClockyImage:SetPos( 4, 4 )

	local PanelTabs = vgui.Create( "DPropertySheet", MainPanel )
	PanelTabs:SetPos( 4, 32 )
	PanelTabs:SetSize( 592, 364 )

	if #PlayersTime > 0 then

		local PlayersList = vgui.Create( "DListView" )
		PlayersList:SetMultiSelect( false )
		PlayersList:AddColumn( "Nickname" )
		PlayersList:AddColumn( "SteamID" )
		PlayersList:AddColumn( "Time Played" )

		TimeDifference = CurTime() - LastShow
		LastShow = CurTime()

		for k,v in pairs(PlayersTime) do
			local timeformat = string.FormattedTime(math.ceil(tonumber(v['t'])) + TimeDifference)
			PlayersList:AddLine( v['n'], v['id'], timeformat['h'] .. ' hours ' .. timeformat['m'] .. ' minutes' )
		end

		PanelTabs:AddSheet("Players", PlayersList, "gui/silkicons/user", false, false, "List of players with time played")

	end

	local ConfigTab = vgui.Create( "DPanel" )

	local ShowUIConfig = vgui.Create( "DCheckBoxLabel", ConfigTab )
	ShowUIConfig:SetPos( 4, 4 )
	ShowUIConfig:SetText( "Show UI" )
	ShowUIConfig:SetConVar( "clocky_showui" )
	ShowUIConfig:SetValue( GetConVar("clocky_showui"):GetInt() )
	ShowUIConfig:SizeToContents()
	ShowUIConfig:SetTextColor( color_black )

	if canconfig then

		local SaveTypeLabel = vgui.Create( "DLabel", ConfigTab )
		SaveTypeLabel:SetPos( 4, 50 )
		SaveTypeLabel:SetText( "Save data as:" )
		SaveTypeLabel:SizeToContents()
		SaveTypeLabel:SetTextColor( color_black )

		local SaveTypeChooser = vgui.Create( "DComboBox", ConfigTab )
		SaveTypeChooser:SetPos( 94, 50 )
		SaveTypeChooser:SetSize( 100, 16 )
		SaveTypeChooser:AddChoice( "PData" )
		SaveTypeChooser:AddChoice( "File" )	
		SaveTypeChooser:AddChoice( "PData + File" )
		SaveTypeChooser:SetTextColor( color_black )

		local SaveFolderLabel = vgui.Create( "DLabel", ConfigTab )
		SaveFolderLabel:SetPos( 4, 76 )
		SaveFolderLabel:SetText( "Save to folder:" )
		SaveFolderLabel:SizeToContents()
		SaveFolderLabel:SetTextColor( color_black )

		local SaveFolderEntry = vgui.Create( "DTextEntry", ConfigTab )
		SaveFolderEntry:SetPos( 94, 76 )
		SaveFolderEntry:SetSize( 100, 16 )
		SaveFolderEntry:SetText( "Relative to data/" )

		local AutoSave = vgui.Create( "DCheckBoxLabel", ConfigTab )
		AutoSave:SetPos( 4, 102 )
		AutoSave:SetText( "Enable autosaving" )
		AutoSave:SetValue( true )
		AutoSave:SizeToContents()
		AutoSave:SetTextColor( color_black )

		local AutoSaveDelayLabel = vgui.Create( "DLabel", ConfigTab )
		AutoSaveDelayLabel:SetPos( 4, 128 )
		AutoSaveDelayLabel:SetText( "Autosave delay (in seconds):" )
		AutoSaveDelayLabel:SizeToContents()
		AutoSaveDelayLabel:SetTextColor( color_black )

		local AutoSaveDelay = vgui.Create( "Slider", ConfigTab )
		AutoSaveDelay:SetPos( 0, 135 )
		AutoSaveDelay:SetWide( 194 )
		AutoSaveDelay:SetMin( 180 )
		AutoSaveDelay:SetMax( 1200 )
		AutoSaveDelay:SetDecimals( 0 )

	end

	PanelTabs:AddSheet("Config", ConfigTab, "gui/silkicons/wrench", false, false, "Edit Clocky config")

end

concommand.Add('clocky_menu', ShowClockyMenu)

local SKIN = {}

function SKIN:PaintFrame( panel )

	surface.SetDrawColor( 157, 192, 224, 255 )
	surface.DrawRect( 0, 30, panel:GetWide(), panel:GetTall()-30 )

	surface.SetDrawColor( 198, 231, 255, 255 )
	surface.DrawRect( 4, 34, panel:GetWide()-8, panel:GetTall()-38 )
       
	surface.SetDrawColor( 157, 192, 224, 255 )
	surface.DrawRect( 0, 0, panel:GetWide(), 30 )

end

derma.DefineSkin( "clocky_skin", "clockyskin", SKIN )