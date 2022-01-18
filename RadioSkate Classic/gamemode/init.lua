AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

resource.AddFile( "materials/radioskate_logo.png" )

DEFINE_BASECLASS( "gamemode_base" )

RS.Music = { }
RS.Queue = { }

function GM:Initialize()

	local Command = {

		[ "sv_friction" ] = 0,
		[ "sv_accelerate" ] = 48,
		[ "sv_airaccelerate" ] = 2048

	}

	for Key, Value in pairs( Command ) do

		RunConsoleCommand( Key, Value )

	end

	util.AddNetworkString( "RSNetMusicTable" )
	util.AddNetworkString( "RSNetQueueTable" )
	util.AddNetworkString( "RSNetMusic" )
	util.AddNetworkString( "RSNetSkateColor" )

	http.Fetch( "http://clients.rootwerk.systems/sean/server/music.php", function( Body )

		RS.Music = util.JSONToTable( Body )

	end,
	function( Error )

		RS.Notificate( nil, "There was an error loading the music list." )

	end )

end
timer.Simple( 10, GM.Initialize )

function GM:ShutDown()

	for k, Player in pairs( player.GetAll() ) do

		player_manager.RunClass( Player, "Disconnected" )

	end

end

function GM:Think()

	for k, Player in pairs( player.GetAll() ) do

		player_manager.RunClass( Player, "Think" )

		if ( ( Player:Team() == 3 or Player:Team() == 4 ) and Player:GetMinigameStatus() == 1 and Player:Alive() ) then

			for k, Target in pairs( player.GetAll() ) do

				if ( Target ~= Player and Target:Team() == Player:Team() and Target:Alive() ) then

					local Distance = Player:GetPos():Distance( Target:GetPos() )

					if ( Distance < 128 ) then

						if ( Player:Team() == 3 and Target:GetMinigameStatus() == 0 ) then

							Target:TakeDamage( Target:Health(), Player, Player )
							Target:SetMinigameStatus( 1 )

							Player:SetMinigameStatus( 0 )

						elseif ( Player:Team() == 4 and Target:GetMinigameStatus() == 0 ) then

							Target:SetMinigameStatus( 1 )

							Player:TakeDamage( Player:Health(), Target, Target )
							Player:SetMinigameStatus( 0 )

						end

					end

				end

			end

		end

	end

end

function GM:PlayerInitialSpawn( Player )

	player_manager.SetPlayerClass( Player, "rs_player_class" )

	player_manager.RunClass( Player, "InitialSpawn" )

end

function GM:PlayerDisconnected( Player )

	player_manager.RunClass( Player, "Disconnected" )

	RS.SetMinigameTarget( Player )

end

function GM:PlayerSpawn( Player )

	player_manager.SetPlayerClass( Player, "rs_player_class" )

	BaseClass.PlayerSpawn( self, Player )

end

function GM:PlayerSetModel( Player )

end

function GM:PlayerLoadout( Player )

	BaseClass.PlayerLoadout( self, Player )

end

function GM:KeyPress( Player, Key )

	player_manager.RunClass( Player, "KeyPress", Key )

end

function GM:GetFallDamage( Player, Speed )

	return Speed / RS.Player.Physics.FallDamage

end

function GM:PlayerDeath( Player, Inflictor, Attacker )

	if ( Player ~= Attacker and Attacker:IsPlayer() ) then

		local Amount = math.random( 1, 2 )

		Player:AddWorth( Amount )
		RS.Notificate( Attacker, "You have received " .. Amount .. " " .. RS.Currency.Name .. " for killing " .. Player:Name() )

	elseif ( Player == Attacker and Player:Team() == 3 or Player:Team() == 4 ) then

		RS.SetMinigameTarget( Player )

	end

end

function GM:EntityTakeDamage( Entity, DamageInfo )

	if ( Entity:IsPlayer() ) then

		local Attacker = DamageInfo:GetAttacker()

		if ( Attacker:IsPlayer() ) then

			if ( Entity:Team() == 1 or Entity:Team() ~= Attacker:Team() ) then

				DamageInfo:ScaleDamage( 0 )

			end

		end

	end

	return DamageInfo

end

function GM:ShowHelp( Player )

	umsg.Start( "RSNetShowHelp" )
	umsg.End()

end

function GM:ShowTeam( Player )

	umsg.Start( "RSNetShowTeam", Player )
	umsg.End()

end

function GM:ShowSpare1( Player )

	umsg.Start( "RSNetShowSpare1", Player )
	umsg.End()

end

function GM:ShowSpare2( Player )

	umsg.Start( "RSNetShowSpare2", Player )
	umsg.End()

end

function RS.HealthRegenerate()

	for k, Player in pairs( player.GetAll() ) do

		if ( Player:Alive() and Player:Health() < Player:GetMaxHealth() ) then

			Player:SetHealth( Player:Health() + 1 )

		end

	end

end
timer.Create( "RSTimeHealthRegenerate", 1, 0, RS.HealthRegenerate )

function RS.TipWorth()

	for k, Player in pairs( player.GetAll() ) do

		local Amount = math.random( 1, 5 )

		Player:AddWorth( Amount )
		RS.Notificate( Player, "You have received " .. Amount .. " " .. RS.Currency.Name .. " for playing on the server." )

	end

end
timer.Create( "RSTimeTipWorth", 60 * 5, 0, RS.TipWorth )

function RS.Notificate( Player, Notification )

	if ( IsValid( Player ) ) then

		umsg.Start( "RSNetNotificate", Player )
		umsg.String( Notification )
		umsg.End()

	else

		umsg.Start( "RSNetNotificate" )
		umsg.String( Notification )
		umsg.End()

	end

end

function RS.SetQueue()

	if ( #RS.Queue > 0 ) then

		RS.Notificate( nil, 'Now playing "' .. RS.Queue[ 1 ].title .. '" by "' .. RS.Queue[ 1 ].artist .. '"' )

		local URL = table.concat( string.Explode( " ", RS.Queue[ 1 ].url ), "%20" )

		umsg.Start( "RSNetMusicPlay" )
		umsg.String( URL )
		umsg.End()

		local Table = string.Explode( ":", RS.Queue[ 1 ].duration )
		local Time = Table[ 1 ] * 60 + Table[ 2 ]

		timer.Simple( Time, function()

			RS.SubQueue( 1 )
			RS.SetQueue()

		end )

	end

end

function RS.AddQueue( Music )

	table.insert( RS.Queue, Music )

	net.Start( "RSNetQueueTable" )
	net.WriteTable( RS.Queue )
	net.Broadcast()

	if ( #RS.Queue == 1 ) then

		RS.SetQueue()

	end

end

function RS.SubQueue( Index )

	table.remove( RS.Queue, Index )

	net.Start( "RSNetQueueTable" )
	net.WriteTable( RS.Queue )
	net.Broadcast()

end

function RS.NetMusic( Length, Player )

	if ( not ( IsValid( Player ) ) ) then

		return

	end

	local Index = net.ReadFloat()

	if ( not ( Index ) ) then

		RS.Notificate( nil, Player:Name() .. " has attempted to cheat, report them! Code 0x00" )

		return

	end

	if ( not ( RS.Music[ Index ] ) ) then

		RS.Notificate( nil, Player:Name() .. " has attempted to cheat, report them! Code 0x01" )

		return

	end

	local Music = RS.Music[ Index ]

	local Add = true

	for k = 1, #RS.Queue do

		if ( RS.Queue[ k ].title == Music.title ) then

			Add = false

			break

		end

	end

	if ( not ( Add ) ) then

		RS.Notificate( Player, '"' .. Music.title .. '" by "' .. Music.artist .. '" is already in the music queue.' )

		return

	end

	Music.Player = Player:Name()

	local Price = Player:GetSpecial() and RS.Currency.MusicQueueSpecial or RS.Currency.MusicQueue

	if ( Player:GetWorth() - Price < 0 ) then

		RS.Notificate( nil, Player:Name() .. " has attempted to cheat, report them! Code 0x02" )

		return

	end

	Player:AddWorth( -Price )

	RS.Notificate( nil, Player:Name() .. ' has added "' .. Music.title .. '" by "' .. Music.artist .. '" to the music queue.' )

	RS.AddQueue( Music )

end
net.Receive( "RSNetMusic", RS.NetMusic )

function RS.NetSkateColor( Length, Player )

	if ( not ( IsValid( Player ) ) ) then

		return

	end

	local h = net.ReadFloat()

	if ( not ( h ) ) then

		RS.Notificate( nil, Player:Name() .. " has attempted to cheat, report them! Code 0x03" )

		return

	end

	local s = net.ReadFloat()

	if ( not ( s ) ) then

		RS.Notificate( nil, Player:Name() .. " has attempted to cheat, report them! Code 0x04" )

		return

	end

	local v = net.ReadFloat()

	if ( not ( v ) ) then

		RS.Notificate( nil, Player:Name() .. " has attempted to cheat, report them! Code 0x05" )

		return

	end

	if ( h < 0 or h > 360 ) then

		RS.Notificate( nil, Player:Name() .. " has attempted to cheat, report them! Code 0x06" )

		return

	end

	if ( s < 0.25 or s > 1 ) then

		RS.Notificate( nil, Player:Name() .. " has attempted to cheat, report them! Code 0x07" )

		return

	end

	if ( v < 0.25 or v > 1 ) then

		RS.Notificate( nil, Player:Name() .. " has attempted to cheat, report them! Code 0x08" )

		return

	end

	local Price = Player:GetSpecial() and RS.Currency.SkateColorSpecial or RS.Currency.SkateColor

	if ( Player:GetWorth() - Price < 0 ) then

		RS.Notificate( nil, Player:Name() .. " has attempted to cheat, report them! Code 0x09" )

		return

	end

	Player:AddWorth( -Price )
	Player:SetRawSkateColor( h, s, v )

end
net.Receive( "RSNetSkateColor", RS.NetSkateColor )

function RS.JoinTeam( Player, Command, Argument )

	local Team = math.Clamp( math.floor( tonumber( Argument[ 1 ] or 1 ) ), 1, 4 )

	if ( Player:Team() ~= Team ) then

		if ( CurTime() > Player.LastTeamJoin + 5 ) then

			RS.SetMinigameTarget( Player )

			Player:SetTeam( Team )
			Player:Spawn()

			Player.LastTeamJoin = CurTime()

			RS.Notificate( nil, Player:Name() .. ' has joined the minigame "' .. team.GetName( Team ) .. '"' )

		else

			local Time = 5 - math.ceil( CurTime() - Player.LastTeamJoin )
			local Second = Time == 1 and "second" or "seconds"

			RS.Notificate( Player, "You must wait another " .. Time .. " " .. Second .. " before joining another team." )

		end

	end

end
concommand.Add( "rs_join_team", RS.JoinTeam )

function RS.GetMinigameTarget( Player )

	local Target = { }

	for k, __Player in pairs( player.GetAll() ) do

		if ( Player ~= __Player and Player:Team() == __Player:Team() ) then

			table.insert( Target, __Player )

		end

	end

	local Target = Target[ math.random( 1, #Target ) ]

	return Target

end

function RS.SetMinigameTarget( Player )

	if ( Player:Team() == 3 or Player:Team() == 4 and Player:GetMinigameStatus() == 1 ) then

		local Target = RS.GetMinigameTarget( Player )

		Player:SetMinigameStatus( 0 )

		if ( Target ) then

			Target:SetMinigameStatus( 1 )

		end

	end

end