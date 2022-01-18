include( "shared.lua" )

local PaddingX = 32
local PaddingY = 32

RS.Music = { }
RS.Queue = { }
RS.InnerPadding = 4
RS.TeamMenu = false
RS.UITeamMenu = RS.UITeamMenu or nil
RS.UIAvatar = RS.UIAvatar or nil

local RSMusicVolume = CreateConVar( "rs_music_volume", "1", { FCVAR_ARCHIVE } )

for k = 1, 8 do

	surface.CreateFont( "Roboto" .. k, {
		
		font = "Roboto",
		size = 10 + ( k * 2 ),
		weight = 800
		
	} )

end

function SecondsToClock( Seconds )

	local Seconds = tonumber( Seconds )

	if ( Seconds <= 0 ) then

		return "00:00"

	end

	local Minutes = string.format( "%02.f", math.floor( Seconds / 60 ) )
	local Seconds = string.format( "%02.f", math.floor( Seconds - Minutes * 60 ) )

	return Minutes .. ":" .. Seconds

end

local GradientU = surface.GetTextureID( "vgui/gradient-u" )

function DrawRectangle( x, y, Wide, Tall, Color, Glow )

	local x = math.floor( x )
	local y = math.floor( y )
	local Wide = math.max( math.floor( Wide ), 0 )
	local Tall = math.floor( Tall )

	surface.SetDrawColor( Color )
	surface.DrawRect( x, y, Wide, Tall )

	surface.SetDrawColor( 255, 255, 255, Color.a - ( 255 - 12 ) )
	surface.DrawOutlinedRect( x + 1, y + 1, Wide - 2, Tall - 2 )

	surface.SetDrawColor( 0, 0, 0, 255 / ( Glow and 1.25 or 1.5 ) )
	surface.SetTexture( GradientU )
	surface.DrawTexturedRect( x + 1, y + 1, Wide - 2, Tall - 2 )

end

function DrawText( Text, Font, x, y, __Color, xAlign, yAlign )

	local x = math.floor( x )
	local y = math.floor( y )

	if ( type( Font ) == "number" ) then

		Font = "Roboto" .. Font

	end

	draw.SimpleTextOutlined( Text, Font, x, y, __Color, xAlign or 0, yAlign or 0, 2, Color( 0, 0, 0, __Color.a - ( 255 - 24 ) ) )

end

function DrawMusicVolume( x, y, Wide, Tall )

	local __Wide = ( Wide - RS.InnerPadding * 2 ) * RSMusicVolume:GetFloat()

	DrawRectangle( x, y, Wide, Tall, RS.Color[ 1 ] )
	DrawRectangle( x + Wide - __Wide - RS.InnerPadding, y + RS.InnerPadding, __Wide, Tall - RS.InnerPadding * 2, LocalPlayer():GetSkateColor() )

	DrawText( math.Round( RSMusicVolume:GetFloat() * 100, 1 ) .. "%", "Roboto6", x - RS.InnerPadding, y + Tall / 2 + 1, RS.Color[ 3 ], 2, 1 )

end

function DrawMusic( x, y, Wide, Tall )

	local Music = RS.Queue[ 1 ]

	if ( Music and RS.CurrentMusic ) then

		local Table = string.Explode( ":", RS.Queue[ 1 ].duration )
		local Time = Table[ 1 ] * 60 + Table[ 2 ]

		if ( Time > ( CurTime() - RS.CurrentMusicTime ) ) then

			local __Wide = math.Clamp( ( Wide - RS.InnerPadding * 2 ) / Time * ( CurTime() - RS.CurrentMusicTime ), 0, Wide - RS.InnerPadding / 2 )

			DrawRectangle( x, y, Wide, Tall, RS.Color[ 1 ] )
			DrawRectangle( x + Wide - __Wide - RS.InnerPadding, y + RS.InnerPadding, __Wide, Tall - RS.InnerPadding * 2, LocalPlayer():GetSkateColor() )

			DrawText( SecondsToClock( Time ), "Roboto8", x + Tall / 3, y + Tall / 2, RS.Color[ 3 ], 0, 1 )
			DrawText( SecondsToClock( math.Clamp( CurTime() - RS.CurrentMusicTime, 0, Time ) ), "Roboto8", x + Wide - Tall / 3, y + Tall / 2, RS.Color[ 3 ], 2, 1 )
			DrawText( string.upper( Music.title .. " by " .. Music.artist ), "Roboto2", x + Wide / 2, y + Tall / 2, RS.Color[ 3 ], 1, 1 )

			DrawMusicVolume( x + Wide / 2, y + Tall + RS.InnerPadding, math.floor( Wide / 2 ), math.floor( Tall / 2 ), Music )

		else

			RS.CurrentMusic:Stop()
			RS.CurrentMusic = nil

		end

	end

end

local LastHealth = 0

function DrawHealth( x, y, Wide, Tall )

	local MaximumHealth = LocalPlayer():GetMaxHealth()
	local Health = math.min( LocalPlayer():Health(), MaximumHealth )

	LastHealth = LastHealth + ( Health - LastHealth ) * 4 * FrameTime()

	local __Wide = math.Clamp( ( Wide - RS.InnerPadding * 2 ) / MaximumHealth * LastHealth, 0, Wide - RS.InnerPadding * 2 )

	DrawRectangle( x, y, Wide, Tall, RS.Color[ 1 ] )
	DrawRectangle( x + RS.InnerPadding, y + RS.InnerPadding, __Wide, Tall - RS.InnerPadding * 2, LocalPlayer():GetSkateColor(), true )

	DrawText( LocalPlayer():Health() .. "%", "Roboto6", x + Wide + RS.InnerPadding, y + Tall / 2 + 1, RS.Color[ 3 ], 0, 1 )

end

local LastVelocity = 0

function DrawVelocity( x, y, Tall )

	local Wide = ScrW() / 4

	local MaximumVelocity = CalculateVelocity( RS.Player.Physics.MaximumVelocity )
	local Velocity = math.min( CalculateVelocity( LocalPlayer():GetVelocity():Length() ), MaximumVelocity )

	LastVelocity = LastVelocity + ( Velocity - LastVelocity ) * 4 * FrameTime()

	local __Wide = math.Clamp( ( Wide - RS.InnerPadding * 2 ) / MaximumVelocity * LastVelocity, 0, Wide - RS.InnerPadding * 2 )

	DrawRectangle( x, y, Wide, Tall, RS.Color[ 1 ] )
	DrawRectangle( x + RS.InnerPadding, y + RS.InnerPadding, __Wide, Tall - RS.InnerPadding * 2, LocalPlayer():GetSkateColor(), true )

	DrawText( string.format( "%03d", math.floor( Velocity ) ), "Roboto8", x + Tall / 3, y + Tall / 2, RS.Color[ 3 ], 0, 1 )
	DrawText( "MPH", "Roboto8", x + Wide - Tall / 3, y + Tall / 2, RS.Color[ 3 ], 2, 1 )

	if ( LocalPlayer():Team() == 3 or LocalPlayer():Team() == 4 ) then

		local Team = LocalPlayer():Team()
		local MinigameStatus = LocalPlayer():GetMinigameStatus()

		local Status = Team == 3 and ( MinigameStatus == 1 and "Tagger" or "Tagged" ) or Team == 4 and ( MinigameStatus == 1 and "Hunted" or "Hunter" )

		DrawText( string.upper( Status ), "Roboto2", x + Wide / 2, y + Tall / 2, RS.Color[ 3 ], 1, 1 )

	end

	DrawHealth( x, y + Tall + RS.InnerPadding, math.floor( Wide / 2 ), math.floor( Tall / 2 ) )
	DrawMusic( ScrW() - Wide - 40, y, Wide, Tall )

end

local LastTeamMenu = 0

function DrawTeamMenu( x, y )

	if ( not ( RS.UITeamMenu ) ) then

		return

	end

	local Wide = RS.UITeamMenu:GetWide()

	local Target

	if ( RS.TeamMenu ) then

		Target = x

	else

		Target = -Wide

	end

	LastTeamMenu = LastTeamMenu + ( Target - LastTeamMenu ) * 4 * FrameTime()

	RS.UITeamMenu:SetPos( math.floor( LastTeamMenu ), y )

end

function DrawAvatar( x, y )

	local Size = 64

	DrawRectangle( x, y, Size, Size, RS.Color[ 1 ] )

	if ( not ( RS.UIAvatar ) ) then

		RS.UIAvatar = vgui.Create( "AvatarImage" )
		RS.UIAvatar:SetPos( x, y )
		RS.UIAvatar:SetSize( Size, Size )
		RS.UIAvatar:SetPlayer( LocalPlayer(), Size )

	end

	DrawText( LocalPlayer():GetWorth() .. " " .. RS.Currency.Name, "Roboto8", x, y + Size, RS.Color[ 3 ] )

	DrawVelocity( x + Size + RS.InnerPadding, y, Size / 2 + RS.InnerPadding * 2 )
	DrawTeamMenu( x, ScrH() - 40 - y )

end

function RSHookHUDPaint()

	for k, Player in pairs( player.GetAll() ) do

		if ( LocalPlayer() ~= Player and LocalPlayer():Team() == Player:Team() and Player:Alive() ) then

			local Position = ( Player:GetPos() + Vector( 0, 0, 80 ) ):ToScreen()
			local x = math.floor( Position.x )
			local y = math.floor( Position.y )

			local Velocity = CalculateVelocity( Player:GetVelocity():Length() )

			local Text = Player:Name()
			local Font = "Roboto5"

			surface.SetFont( Font )
			local Wide, Tall = surface.GetTextSize( Text )
			local Wide = math.max( Wide, 72 )

			local __Color = team.GetColor( Player:Team() )

			if ( Player:GetMinigameStatus() == 1 ) then

				__Color = RS.Color[ 5 ]

			end

			DrawText( Text, Font, x, y, __Color, 1, 1 )
			DrawText( string.format( "%03d", math.floor( Velocity ) ), Font, x - Wide / 2, y + Tall, RS.Color[ 3 ], 0, 1 )
			DrawText( "MPH", Font, x + Wide / 2, y + Tall, RS.Color[ 3 ], 2, 1 )

		end

	end

	if ( LocalPlayer():Team() == 2 ) then

		DrawText( "=", "Roboto8", ScrW() / 2, ScrH() / 2, LocalPlayer():GetSkateColor(), 1, 1 )

	end

	DrawAvatar( PaddingX, PaddingY )

end
hook.Add( "HUDPaint", "RSHookHUDPaint", RSHookHUDPaint )

local __Element = {

	CHudHealth = false,
	CHudSuitPower = false,
	CHudBattery = false,
	CHudAmmo = false,
	CHudSecondaryAmmo = false,
	CHudCrosshair = false,
	CHudDamageIndicator = false

}

function RSHookHUDShouldDraw( Element )
	
	return __Element[ Element ]

end
hook.Add( "HUDShouldDraw", "RSHookHUDShouldDraw", RSHookHUDShouldDraw )

function GM:Think()

	if ( IsValid( LocalPlayer() ) ) then

		player_manager.RunClass( LocalPlayer(), "Think" )

		if ( not ( LocalPlayer().WallRunning ) ) then

			LocalPlayer().WallRunning = 0

		end

		if ( not ( LocalPlayer().SkidSound ) ) then

			LocalPlayer().SkidSound = CreateSound( LocalPlayer(), RS.Player.Physics.SkidSound )
			LocalPlayer().SkidSound:Play()

		end

		if ( not ( LocalPlayer().RollSound ) ) then

			LocalPlayer().RollSound = CreateSound( LocalPlayer(), RS.Player.Physics.RollSound )
			LocalPlayer().RollSound:Play()

		end

	end

end

function GM:OnPlayerChat( Player, String, Team, Dead )

	local Table = { }

	if ( Dead ) then

		table.insert( Table, RS.Color[ 1 ] )
		table.insert( Table, "DEAD" )

		table.insert( Table, RS.Color[ 3 ] )
		table.insert( Table, " : " )

	end

	if ( Team ) then

		table.insert( Table, RS.Color[ 1 ] )
		table.insert( Table, "TEAM" )

		table.insert( Table, RS.Color[ 3 ] )
		table.insert( Table, " : " )

	end

	if ( IsValid( Player ) ) then

		table.insert( Table, RS.Color[ 3 ] )
		table.insert( Table, string.upper( string.sub( Player:GetUserGroup(), 1, 1 ) ) .. string.sub( Player:GetUserGroup(), 2 ) )

		table.insert( Table, RS.Color[ 3 ] )
		table.insert( Table, " | " )

		table.insert( Table, Player:GetSkateColor() )
		table.insert( Table, Player:GetName() )

	else

		table.insert( Table, "Console" )

	end

	table.insert( Table, RS.Color[ 3 ] )
	table.insert( Table, " : " )

	for Value in string.gmatch( String, "([^ ]+)" ) do

		local __Player

		for k, __Player2 in pairs( player.GetAll() ) do

			if ( Value == __Player2:Name() ) then

				__Player = __Player2

				break

			end

		end

		if ( type( tonumber( Value ) ) == "number" or Value == RS.Currency.Name or __Player ) then

			local Color = RS.Color[ 3 ]

			if ( __Player ) then

				Color = __Player:GetSkateColor()

			else

				Color = IsValid( Player ) and Player:GetSkateColor() or RS.Color[ 3 ]

			end

			table.insert( Table, Color )
			table.insert( Table, Value .. " " )

		else

			table.insert( Table, RS.Color[ 3 ] )
			table.insert( Table, Value .. " " )

		end

	end

	chat.AddText( unpack( Table ) )
	chat.PlaySound()

	return true

end

function RSNetMusicPlay( Data )

	local URL = Data:ReadString()

	if ( not ( URL ) ) then

		return

	end

	sound.PlayURL( URL, "mono", function( Music )

		if ( not ( IsValid( Music ) ) ) then

			return

		end

		if ( RS.CurrentMusic ) then

			RS.CurrentMusic:Stop()
			RS.CurrentMusic = nil

		end

		RS.CurrentMusic = Music
		RS.CurrentMusic:Play()
		RS.CurrentMusic:SetVolume( RSMusicVolume:GetFloat() )
		RS.CurrentMusicTime = CurTime()

	end )

end
usermessage.Hook( "RSNetMusicPlay", RSNetMusicPlay )

local RSLogo = Material( "radioskate_logo.png", "smooth" )

local Transparency = 255

function RSNetInitialSpawn()

	local Last = CurTime() + 5

	local Frame = vgui.Create( "DFrame" )
	Frame:SetSize( ScrW(), ScrH() )
	Frame:SetPos( 0, 0 )
	Frame:SetTitle( "" )
	Frame:MakePopup()
	Frame:ShowCloseButton( false )
	Frame:SetDraggable( false )

	function Frame:Paint( Wide, Tall )

		surface.SetDrawColor( 32, 32, 32, Transparency )
		surface.DrawRect( 0, 0, Wide, Tall )

		local RSColor3 = Color( RS.Color[ 3 ].r, RS.Color[ 3 ].g, RS.Color[ 3 ].b, Transparency )

		local Size = math.Clamp( 1024, 0, ScrH() )

		surface.SetMaterial( RSLogo )
		surface.SetDrawColor( 255, 255, 255, Transparency )
		surface.DrawTexturedRect( ScrW() / 2 - Size / 2, ScrH() / 2 - Size / 2, Size, Size )

		if ( CurTime() > Last ) then

			Transparency = Transparency + ( 0 - Transparency ) * 4 * FrameTime()

			if ( Transparency < 1 ) then

				self:Remove()

			end

		end

	end

end
usermessage.Hook( "RSNetInitialSpawn", RSNetInitialSpawn )

function RSNetShowHelp()

end
usermessage.Hook( "RSNetShowHelp", RSNetShowHelp )

function RSNetShowTeam()

end
usermessage.Hook( "RSNetShowTeam", RSNetShowTeam )

function RSNetShowSpare1()

	local Frame = vgui.Create( "DFrame" )
	Frame:SetSize( math.Clamp( ScrW() / 4, 480, ScrW() ), math.Clamp( ScrH() / 4, 270, ScrH() ) )
	Frame:Center()
	Frame:SetTitle( "" )
	Frame:MakePopup()
	Frame:ShowCloseButton( false )

	function Frame:Paint( Wide, Tall )

		DrawRectangle( 0, 24, Wide, Tall - 24, RS.Color[ 1 ] )
		DrawText( "SKATE COLOR", "Roboto6", Wide / 2, 12, RS.Color[ 3 ], 1, 1 )

	end

	local Button = vgui.Create( "DButton", Frame )
	Button:SetSize( 24 - RS.InnerPadding, 24 - RS.InnerPadding )
	Button:SetPos( Frame:GetWide() - Button:GetTall(), 0 )
	Button:SetText( "" )

	function Button:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 1 ] )
		DrawText( "=", "Roboto2", Wide / 2, Tall / 2, LocalPlayer():GetSkateColor(), 1, 1 )

	end

	function Button:DoClick()

		Frame:Close()

	end

	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetSize( Frame:GetWide() - RS.InnerPadding * 2, Frame:GetTall() - 24 - RS.InnerPadding * 2 )
	Panel:SetPos( RS.InnerPadding, 24 + RS.InnerPadding )

	function Panel:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 4 ] )

	end

	local Tall = 32

	local h, s, v = LocalPlayer():GetRawSkateColor()
	h = math.floor( h )

	local Number1 = vgui.Create( "Slider", Panel )
	Number1:SetSize( Panel:GetWide() - RS.InnerPadding * 2, Tall )
	Number1:SetPos( RS.InnerPadding, RS.InnerPadding )
	Number1:SetMin( 0 )
	Number1:SetMax( 360 )
	Number1:SetValue( h )
	Number1:SetDecimals( 0 )

	function Number1:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 1 ] )
		DrawRectangle( RS.InnerPadding, RS.InnerPadding, Wide - RS.InnerPadding * 2, Tall - RS.InnerPadding * 2, RS.Color[ 3 ] )

	end

	local Number2 = vgui.Create( "Slider", Panel )
	Number2:SetSize( Panel:GetWide() - RS.InnerPadding * 2, Tall )
	Number2:SetPos( RS.InnerPadding, Tall + RS.InnerPadding * 2 )
	Number2:SetMin( 0.25 )
	Number2:SetMax( 1 )
	Number2:SetValue( s )
	Number2:SetDecimals( 2 )

	function Number2:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 1 ] )
		DrawRectangle( RS.InnerPadding, RS.InnerPadding, Wide - RS.InnerPadding * 2, Tall - RS.InnerPadding * 2, RS.Color[ 3 ] )

	end

	local Number3 = vgui.Create( "Slider", Panel )
	Number3:SetSize( Panel:GetWide() - RS.InnerPadding * 2, Tall )
	Number3:SetPos( RS.InnerPadding, Tall * 2 + RS.InnerPadding * 3 )
	Number3:SetMin( 0.25 )
	Number3:SetMax( 1 )
	Number3:SetValue( v )
	Number3:SetDecimals( 2 )

	function Number3:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 1 ] )
		DrawRectangle( RS.InnerPadding, RS.InnerPadding, Wide - RS.InnerPadding * 2, Tall - RS.InnerPadding * 2, RS.Color[ 3 ] )

	end

	local Color = vgui.Create( "DPanel", Panel )
	Color:SetSize( Panel:GetWide() - RS.InnerPadding * 2, Panel:GetTall() - Tall * 4 - RS.InnerPadding * 6 )
	Color:SetPos( RS.InnerPadding, Tall * 3 + RS.InnerPadding * 4 )

	function Color:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 1 ] )
		DrawRectangle( RS.InnerPadding, RS.InnerPadding, Wide - RS.InnerPadding * 2, Tall - RS.InnerPadding * 2, HSVToColor( Number1:GetValue(), Number2:GetValue(), Number3:GetValue() ) )

	end

	local Button = vgui.Create( "DButton", Panel )
	Button:SetSize( Panel:GetWide() - RS.InnerPadding * 2, Tall )
	Button:SetPos( RS.InnerPadding, Panel:GetTall() - Tall - RS.InnerPadding )
	Button:SetText( "" )

	local Price = LocalPlayer():GetSpecial() and RS.Currency.SkateColorSpecial or RS.Currency.SkateColor

	function Button:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 1 ] )
		DrawRectangle( RS.InnerPadding, RS.InnerPadding, Wide - RS.InnerPadding * 2, Tall - RS.InnerPadding * 2, LocalPlayer():GetSkateColor(), not ( self.Hovered ) )
		DrawText( string.upper( "Purchase Skate Color ( " .. Price .. " " .. RS.Currency.Name .. " )" ), "Roboto3", Wide / 2, Tall / 2, RS.Color[ 3 ], 1, 1 )

	end

	function Button:DoClick()

		if ( LocalPlayer():GetWorth() - Price >= 0 ) then

			net.Start( "RSNetSkateColor" )
			net.WriteFloat( math.Clamp( Number1:GetValue(), 0, 360 ) )
			net.WriteFloat( math.Clamp( Number2:GetValue(), 0.25, 1 ) )
			net.WriteFloat( math.Clamp( Number3:GetValue(), 0.25, 1 ) )
			net.SendToServer()

			Frame:Close()

			RSNetNotificate( nil, "You have purchased a new skate color." )

		else

			RSNetNotificate( nil, "You do not have enough " .. RS.Currency.Name .. " to purchase a new skate color." )

		end

	end

end
usermessage.Hook( "RSNetShowSpare1", RSNetShowSpare1 )

function RSNetShowSpare2()

	local Frame = vgui.Create( "DFrame" )
	Frame:SetSize( math.Clamp( ScrW() / 2, 960, ScrW() ), math.Clamp( ScrH() / 2, 540, ScrH() ) )
	Frame:Center()
	Frame:SetTitle( "" )
	Frame:MakePopup()
	Frame:ShowCloseButton( false )

	function Frame:Paint( Wide, Tall )

		DrawRectangle( 0, 24, Wide, Tall - 24, RS.Color[ 1 ] )
		DrawText( "MUSIC PLAYER", "Roboto6", Wide / 2, 12, RS.Color[ 3 ], 1, 1 )

	end

	local Button = vgui.Create( "DButton", Frame )
	Button:SetSize( 24 - RS.InnerPadding, 24 - RS.InnerPadding )
	Button:SetPos( Frame:GetWide() - Button:GetTall(), 0 )
	Button:SetText( "" )

	function Button:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 1 ] )
		DrawText( "=", "Roboto2", Wide / 2, Tall / 2, LocalPlayer():GetSkateColor(), 1, 1 )

	end

	function Button:DoClick()

		Frame:Close()

	end

	local Panel = vgui.Create( "DPanel", Frame )
	Panel:SetSize( Frame:GetWide() - RS.InnerPadding * 2, Frame:GetTall() - 24 - RS.InnerPadding * 2 )
	Panel:SetPos( RS.InnerPadding, 24 + RS.InnerPadding )

	function Panel:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 4 ] )

	end

	local Button = vgui.Create( "DButton", Panel )
	Button:SetSize( Panel:GetWide() - RS.InnerPadding * 2, 32 )
	Button:SetPos( RS.InnerPadding, Panel:GetTall() - Button:GetTall() - RS.InnerPadding )
	Button:SetText( "" )

	local Price = LocalPlayer():GetSpecial() and RS.Currency.MusicQueueSpecial or RS.Currency.MusicQueue

	function Button:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 1 ] )
		DrawRectangle( RS.InnerPadding, RS.InnerPadding, Wide - RS.InnerPadding * 2, Tall - RS.InnerPadding * 2, LocalPlayer():GetSkateColor(), self.Hovered )

		DrawText( string.upper( "Add To Music Queue ( " .. Price .. " " .. RS.Currency.Name .. " )" ), "Roboto3", Wide / 2, Tall / 2, RS.Color[ 3 ], 1, 1 )

	end

	local Slider = vgui.Create( "Slider", Panel )
	Slider:SetSize( Panel:GetWide() - RS.InnerPadding * 2, 32 )
	Slider:SetPos( RS.InnerPadding, Panel:GetTall() - Button:GetTall() - Slider:GetTall() - RS.InnerPadding * 2 )
	Slider:SetMin( 0 )
	Slider:SetMax( 1 )
	Slider:SetValue( RSMusicVolume:GetFloat() )
	Slider:SetDecimals( 2 )

	function Slider:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 1 ] )
		DrawRectangle( RS.InnerPadding, RS.InnerPadding, Wide - RS.InnerPadding * 2, Tall - RS.InnerPadding * 2, RS.Color[ 3 ] )

	end

	function Slider:OnValueChanged( Value )

		local Value = math.Clamp( Value, self:GetMin(), self:GetMax() )

		if ( RS.CurrentMusic ) then

			RS.CurrentMusic:SetVolume( Value )

		end

		RunConsoleCommand( "rs_music_volume", Value )

	end

	local List1 = vgui.Create( "DListView", Panel )
	List1:SetSize( Panel:GetWide() / 2 - RS.InnerPadding * 1.5, Panel:GetTall() - RS.InnerPadding * 2 - Button:GetTall() - Slider:GetTall() - RS.InnerPadding * 2 )
	List1:SetPos( RS.InnerPadding, RS.InnerPadding )
	List1:SetMultiSelect( false )
	List1:AddColumn( "Title" )
	List1:AddColumn( "Artist" )
	List1:AddColumn( "Album" )
	List1:AddColumn( "Duration" )

	function Button:DoClick()

		if ( List1:GetSelectedLine() ) then

			if ( LocalPlayer():GetWorth() - Price >= 0 ) then

				net.Start( "RSNetMusic" )
				net.WriteFloat( List1:GetSelectedLine() )
				net.SendToServer()

				Frame:Close()

			else

				RSNetNotificate( nil, "You do not have enough " .. RS.Currency.Name .. " to add to the music queue." )

			end


		end

	end

	function List1:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 3 ] )

	end

	for k = 1, #RS.Music do

		local Music = RS.Music[ k ]

		List1:AddLine( Music.title, Music.artist, Music.album, Music.duration )

	end

	local List2 = vgui.Create( "DListView", Panel )
	List2:SetSize( List1:GetWide(), List1:GetTall() )
	List2:SetPos( Panel:GetWide() / 2 + RS.InnerPadding / 2, RS.InnerPadding )
	List2:SetMultiSelect( false )
	List2:AddColumn( "Title" )
	List2:AddColumn( "Artist" )
	List2:AddColumn( "Added By" )

	function List2:Paint( Wide, Tall )

		DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 3 ] )

	end

	for k = 1, #RS.Queue do

		local Music = RS.Queue[ k ]

		List2:AddLine( Music.title, Music.artist, Music.Player )

	end

end
usermessage.Hook( "RSNetShowSpare2", RSNetShowSpare2 )

function RSNetNotificate( Data, Notification )

	local Notification = Data and Data:ReadString() or Notification

	if ( not ( Notification ) ) then

		return

	end

	local Table = { }

	for Value in string.gmatch( Notification, "([^ ]+)" ) do

		local Player

		for k, __Player in pairs( player.GetAll() ) do

			if ( Value == __Player:Name() ) then

				Player = __Player

				break

			end

		end

		if ( type( tonumber( Value ) ) == "number" or Value == RS.Currency.Name or Player ) then

			local Color = RS.Color[ 3 ]

			if ( Player ) then

				Color = Player:GetSkateColor()

			else

				Color = LocalPlayer():GetSkateColor() 

			end

			table.insert( Table, Color )
			table.insert( Table, Value .. " " )

		else

			table.insert( Table, RS.Color[ 3 ] )
			table.insert( Table, Value .. " " )

		end

	end

	chat.AddText( unpack( Table ) )
	surface.PlaySound( "garrysmod/content_downloaded.wav" )

end
usermessage.Hook( "RSNetNotificate", RSNetNotificate )

function RSNetMusicTable()

	local Table = net.ReadTable()

	if ( not ( Table ) ) then

		return

	end

	RS.Music = Table

end
net.Receive( "RSNetMusicTable", RSNetMusicTable )

function RSNetQueueTable()

	local Table = net.ReadTable()

	if ( not ( Table ) ) then

		return

	end

	RS.Queue = Table

end
net.Receive( "RSNetQueueTable", RSNetQueueTable )

function RSShowTeamMenu()

	if ( not ( RS.UITeamMenu ) ) then

		local Wide = ScrW() - PaddingX * 2
		local Tall = 40

		RS.UITeamMenu = vgui.Create( "DPanel" )
		RS.UITeamMenu:SetSize( Wide, Tall )
		RS.UITeamMenu:SetPos( -Wide, 0 )

		function RS.UITeamMenu:Paint( Wide, Tall )

			DrawRectangle( 0, 0, Wide, Tall, RS.Color[ 1 ] )

		end

		for k = 1, 4 do

			local Wide = math.floor( ( Wide - RS.InnerPadding * 1 ) / 4 ) - RS.InnerPadding

			local Button = vgui.Create( "DButton", RS.UITeamMenu )
			Button:SetSize( Wide, Tall - RS.InnerPadding * 2 )
			Button:SetPos( RS.InnerPadding + ( Wide + RS.InnerPadding ) * ( k - 1 ), RS.InnerPadding )
			Button:SetText( "" )

			function Button:Paint( Wide, Tall )

				DrawRectangle( 0, 0, Wide, Tall, LocalPlayer():GetSkateColor(), not ( self.Hovered ) )
				DrawText( string.upper( team.GetName( k ) ), "Roboto4", Wide / 2, Tall / 2, RS.Color[ 3 ], 1, 1 )

			end

			function Button:DoClick()

				RunConsoleCommand( "rs_join_team", k )

			end

		end

	end

	RS.TeamMenu = true

	gui.EnableScreenClicker( RS.TeamMenu )

end
concommand.Add( "+menu", RSShowTeamMenu )

function RSHideTeamMenu()

	RS.TeamMenu = false

	gui.EnableScreenClicker( RS.TeamMenu )

end
concommand.Add( "-menu", RSHideTeamMenu )