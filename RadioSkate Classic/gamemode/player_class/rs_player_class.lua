AddCSLuaFile()

DEFINE_BASECLASS( "player_default" )

local Player = FindMetaTable( "Player" )

function Player:GetWorth()

	return self:GetNWInt( "RSDataWorth" )

end

function Player:GetSkateColor()

	local Vector = self:GetNWVector( "RSDataSkateColor" )

	return Color( Vector.x, Vector.y, Vector.z )

end

function Player:GetRawSkateColor()

	local Vector = self:GetNWVector( "RSDataRawSkateColor" )

	return Vector.x, Vector.y, Vector.z

end

function Player:GetMinigameStatus()

	return self:GetNWInt( "RSDataMinigameStatus" )

end

function Player:GetSpecial()

	local Usergroup = string.lower( self:GetUserGroup() )

	for k = 1, #RS.Currency.Special do

		if ( Usergroup == string.lower( RS.Currency.Special[ k ] ) ) then

			return true

		end

	end

	return false

end

if ( SERVER ) then

	function Player:SetWorth( Amount )

		self:SetNWInt( "RSDataWorth", Amount )

	end

	function Player:AddWorth( Amount )

		self:SetNWInt( "RSDataWorth", self:GetNWInt( "RSDataWorth" ) + Amount )

	end

	function Player:SetSkateColor( h, s, v )

		local Color = HSVToColor( h, s, v )

		self:SetNWVector( "RSDataSkateColor", Vector( Color.r, Color.g, Color.b ) )

		self:SetPlayerColor( Vector( Color.r / 255, Color.g / 255, Color.b / 255 ) )

		if ( self.Trail ) then

			self.Trail:SetColor( Color )

		end

	end

	function Player:SetRawSkateColor( h, s, v )

		local h = math.Round( math.Clamp( tonumber( h ), 0, 360 ), 2 )
		local s = math.Round( math.Clamp( tonumber( s ), 0, 1 ), 2 )
		local v = math.Round( math.Clamp( tonumber( v ), 0, 1 ), 2 )

		self:SetNWVector( "RSDataRawSkateColor", Vector( h, s, v ) )

		self:SetSkateColor( h, s, v )

	end

	function Player:SetMinigameStatus( Status )

		self:SetNWInt( "RSDataMinigameStatus", Status )

	end

	function Player:SaveData()

		self:SetPData( "RSDataWorth", self:GetWorth() )

		local h, s, v = self:GetRawSkateColor()

		self:SetPData( "RSDataSkateColor", h .. " " .. s .. " " .. v )

	end

	function Player:LoadData()

		self:SetWorth( self:GetPData( "RSDataWorth", RS.Player.DefaultWorth ) )

		local Table = string.Explode( " ", self:GetPData( "RSDataSkateColor", "0 1 1" ) )
		local h = tonumber( Table[ 1 ] ) or 0
		local s = tonumber( Table[ 2 ] ) or 1
		local v = tonumber( Table[ 3 ] ) or 1

		self:SetRawSkateColor( h, s, v )

		net.Start( "RSNetMusicTable" )
		net.WriteTable( RS.Music )
		net.Send( self )

		net.Start( "RSNetQueueTable" )
		net.WriteTable( RS.Queue )
		net.Send( self )

	end

end

local Player = {
	
	DisplayName = "Radio Skate Player Class",
	WalkSpeed = 144,
	RunSpeed = 144,
	CrouchedWalkSpeed = 0.1,
	DuckSpeed = 0.3,
	UnDuckSpeed = 0.3,
	JumpPower = 304,
	CanUseFlashlight = false,
	MaxHealth = 100,
	StartHealth = 100,
	StartArmor = 0,
	DropWeaponOnDie = false,
	TeammateNoCollide = true,
	AvoidPlayers = true,
	UseVMHands = true,

} 

function Player:SetupDataTables()

	BaseClass.SetupDataTables( self )

end

function Player:Think()

	local Physics = RS.Player.Physics
	local MaximumVelocity = Physics.MaximumVelocity / 4

	local Normal = self.Player:GetRight()

	local Velocity = self.Player:GetVelocity()
	local VelocityLength = Velocity:Length()

	local Lateral = Normal:Dot( Velocity:GetNormalized() ) * Normal
	local LateralLength = Lateral:Length()

	local LateralVelocity = LateralLength * math.Clamp( 1 / MaximumVelocity * VelocityLength, 0, 1 )

	if ( self.Player:OnGround() ) then

		if ( self.Player:KeyDown( IN_ATTACK2 ) ) then

			local Length = 4
			local Offset1 = 32
			local Offset2 = 16

			local TraceL = util.QuickTrace( self.Player:GetPos() - self.Player:GetRight() * Offset1, Vector( 0, 0, -Length ), self.Player )
			local TraceM1 = util.QuickTrace( self.Player:GetPos() - self.Player:GetRight() * Offset2 + Vector( 0, 0, -Length ), self.Player:GetRight() * Offset2 * 2, self.Player )
			local TraceM2 = util.QuickTrace( self.Player:GetPos() + self.Player:GetRight() * Offset2 + Vector( 0, 0, -Length ), -self.Player:GetRight() * Offset2 * 2, self.Player )
			local TraceR = util.QuickTrace( self.Player:GetPos() + self.Player:GetRight() * Offset1, Vector( 0, 0, -Length ), self.Player )

			if ( not ( TraceL.Hit ) and TraceM1.Hit and TraceM2.Hit and not ( TraceR.Hit ) ) then

				if ( math.random( 1, 100 - math.Clamp( 99 / MaximumVelocity * VelocityLength, 0, 99 ) ) == 1 ) then

					local Effect = EffectData()
					Effect:SetOrigin( self.Player:GetPos() )
					Effect:SetMagnitude( 1 )
					Effect:SetScale( 0.5 )
					Effect:SetRadius( 1 )
					util.Effect( "Sparks", Effect )

				end

				if ( self.Player.RailSound ) then

					self.Player.RailSound:ChangeVolume( math.Clamp( 1 / ( MaximumVelocity * 2 ) * VelocityLength, 0, 1 ), 0.1 )
					self.Player.RailSound:ChangePitch( 200 + math.Clamp( 1 / ( MaximumVelocity * 4 ) * VelocityLength, 0, 1 ) * 35 + math.abs( math.sin( CurTime() * math.random( 2, 3 ) ) * 20 ), 0 )

				end

			else

				if ( self.Player.RailSound ) then

					self.Player.RailSound:ChangeVolume( 0, 0 )
					self.Player.RailSound:ChangePitch( 0, 0 )

				end

				self.Player:SetVelocity( Velocity * -Physics.Brake )

			end

		else

			if ( self.Player.RailSound ) then

				self.Player.RailSound:ChangeVolume( 0, 0 )
				self.Player.RailSound:ChangePitch( 0, 0 )

			end

		end

		if ( self.Player.SkidSound ) then

			self.Player.SkidSound:ChangeVolume( LateralVelocity, 0 )
			self.Player.SkidSound:ChangePitch( 75 + 75 * LateralVelocity, 0 )

		end

		if ( self.Player.RollSound ) then

			self.Player.RollSound:ChangeVolume( math.Clamp( 1 / MaximumVelocity * VelocityLength, 0, 0.5 ), 0 )
			self.Player.RollSound:ChangePitch( 20 + math.Clamp( 40 / MaximumVelocity * VelocityLength, 0, 100 ), 0.2 )

		end

		self.Player.WallRunning = 0

	else

		if ( self.Player:KeyDown( IN_ATTACK2 ) ) then

			local Length = 24

			local TraceL = util.QuickTrace( self.Player:GetShootPos(), ( -self.Player:GetRight() * Length ), self.Player )
			local TraceR = util.QuickTrace( self.Player:GetShootPos(), ( self.Player:GetRight() * Length ), self.Player )

			if ( TraceL.Hit or TraceR.Hit ) then

				if ( TraceL.Hit ) then

					self.Player.WallRunning = 1

				elseif ( TraceR.Hit ) then

					self.Player.WallRunning = -1

				else

					self.Player.WallRunning = 0

				end

				self.Player:SetVelocity( Vector( 0, 0, math.Clamp( Physics.Vertical / MaximumVelocity * VelocityLength, 0, Physics.Vertical ) ) )

				if ( self.Player.SkidSound ) then

					self.Player.SkidSound:ChangeVolume( math.Clamp( 1 / MaximumVelocity * VelocityLength * 3, 0, 0.5 ), 0 )
					self.Player.SkidSound:ChangePitch( 20 + math.Clamp( 100 / MaximumVelocity * VelocityLength, 0, 100 ), 0 )

				end

				if ( self.Player.RollSound ) then

					self.Player.RollSound:ChangeVolume( math.Clamp( 1 / MaximumVelocity * VelocityLength * 3, 0, 0.5 ), 0 )
					self.Player.RollSound:ChangePitch( 20 + math.Clamp( 100 / MaximumVelocity * VelocityLength, 0, 100 ), 0.2 )

				end

			else

				if ( self.Player.SkidSound ) then

					self.Player.SkidSound:ChangeVolume( 0, 0 )
					self.Player.SkidSound:ChangePitch( 0, 0 )

				end

				if ( self.Player.RollSound ) then

					self.Player.RollSound:ChangeVolume( 0, 1 )
					self.Player.RollSound:ChangePitch( 0, 1 )

				end

				self.Player.WallRunning = 0

			end

		else

			if ( self.Player.SkidSound ) then

				self.Player.SkidSound:ChangeVolume( 0, 0 )
				self.Player.SkidSound:ChangePitch( 0, 0 )

			end

			if ( self.Player.RollSound ) then

				self.Player.RollSound:ChangeVolume( 0, 1 )
				self.Player.RollSound:ChangePitch( 0, 1 )

			end

			self.Player.WallRunning = 0

		end

		if ( self.Player.RailSound ) then

			self.Player.RailSound:ChangeVolume( 0, 0 )
			self.Player.RailSound:ChangePitch( 0, 0 )

		end

	end

end

function Player:InitialSpawn()

	self.Player:SetTeam( 1 )
	self.Player:LoadData()

	RS.Notificate( nil, self.Player:Name() .. " has joined the server." )

	umsg.Start( "RSNetInitialSpawn", self.Player )
	umsg.End()

end

function Player:Disconnected()

	self.Player:SaveData()

	RS.Notificate( nil, self.Player:Name() .. " has left the server." )

end

function Player:Spawn()

	BaseClass.Spawn( self )

	self.Player.LastTeamJoin = CurTime()

	if ( self.Player:Team() == 2 ) then

		self.Player:SetMinigameStatus( 0 )

		self.Player:SetPos( Vector( math.random( -7888, -10520 ), math.random( 2468, -168 ), -11100 ) )

	elseif ( self.Player:Team() == 3 ) then

		local Tagger = true

		for k, __Player in pairs( player.GetAll() ) do

			if ( __Player:Team() == 3 and __Player:GetMinigameStatus() == 1 ) then

				Tagger = false

				break

			end

		end

		if ( Tagger ) then

			self.Player:SetMinigameStatus( 1 )

		end

	elseif ( self.Player:Team() == 4 ) then

		local Hunted = true

		for k, __Player in pairs( player.GetAll() ) do

			if ( __Player:Team() == 4 and __Player:GetMinigameStatus() == 1 ) then

				Hunted = false

				break

			end

		end

		if ( Hunted ) then

			self.Player:SetMinigameStatus( 1 )

		end

	end

	if ( not ( self.Player.SkidSound ) ) then

		self.Player.SkidSound = CreateSound( self.Player, RS.Player.Physics.SkidSound )

	end

	if ( not ( self.Player.RollSound ) ) then

		self.Player.RollSound = CreateSound( self.Player, RS.Player.Physics.RollSound )

	end

	if ( not ( self.Player.RailSound ) ) then

		self.Player.RailSound = CreateSound( self.Player, RS.Player.Physics.RailSound )

	end

	self.Player.SkidSound:Play()
	self.Player.RollSound:Play()
	self.Player.RailSound:Play()

	local StartSize = 64
	local EndSize = 0
	local Length = 4

	if ( self.Player.Trail ) then

		self.Player.Trail:Remove()

	end

	self.Player.Trail = util.SpriteTrail( self.Player, 0, self.Player:GetSkateColor(), false, StartSize, EndSize, Length, 1 / ( StartSize + EndSize ) / 2, "trails/laser.vmt" )

	local Hands = self.Player:GetHands()

	if ( IsValid( Hands ) ) then

		Hands:Remove()

	end

	local Model = RS.Player.Model[ math.random( 1, #RS.Player.Model ) ]

	local Hands = ents.Create( "gmod_hands" )

	if ( IsValid( Hands ) ) then

		self.Player:SetHands( Hands )

		Hands:SetOwner( self.Player )

		local PlayerManager = player_manager.TranslatePlayerHands( Model )

		if ( PlayerManager ) then

			Hands:SetModel( PlayerManager.model )
			Hands:SetSkin( PlayerManager.skin )
			Hands:SetBodyGroups( PlayerManager.body )

		end

		local ViewModel = self.Player:GetViewModel( 0 )

		Hands:AttachToViewmodel( ViewModel )

		ViewModel:DeleteOnRemove( Hands )

		self.Player:DeleteOnRemove( Hands )

		Hands:Spawn()

	end

	self.Player:SetModel( player_manager.TranslatePlayerModel( Model ) )

end

function Player:Loadout()

	self.Player:StripWeapons()
	self.Player:StripAmmo()

	if ( self.Player:Team() == 2 ) then

		local Table = {

			{ "weapon_crowbar" },
			{ "weapon_pistol", "pistol" },
			{ "weapon_smg1", "smg1" },
			{ "weapon_shotgun", "buckshot" }

		}

		for k = 1, #Table do

			self.Player:Give( Table[ k ][ 1 ] )

			if ( Table[ k ][ 2 ] ) then

				self.Player:GiveAmmo( 9999, Table[ k ][ 2 ] )

			end

		end

	end

end

function Player:KeyPress( Key )

	if ( self.Player:OnGround() ) then

		if ( Key == IN_JUMP and self.Player:Alive() ) then

			self.Player:EmitSound( "npc/footsteps/hardboot_generic" .. math.random( 1, 6 ) .. ".wav", 75, math.random( 128, 136 ) )

		end

	end

end

local PitchAngle = 0
local RollAngle = 0

function Player:CalcView( View )

	local Multiplier = self.Player.WallRunning and self.Player.WallRunning or 0

	PitchAngle = PitchAngle + ( self.Player:GetVelocity():Length() / 1000 * ( self.Player:OnGround() and 1 or 0 ) - PitchAngle ) * 5 * FrameTime()
	RollAngle = RollAngle + ( 10 * Multiplier - RollAngle ) * 5 * FrameTime()

	View.origin = View.origin + Vector( 0, 0, math.sin( CurTime() * 8 ) * PitchAngle )
	View.angles = View.angles + Angle( 0, 0, RollAngle + math.cos( CurTime() * 8 ) * PitchAngle / 2 )

	return View

end

function Player:PostDrawViewModel( ViewModel, Weapon )

	if ( Weapon.UseHands or not ( Weapon:IsScripted() ) ) then

		local Hands = self.Player:GetHands()

		if ( IsValid( Hands ) ) then

			Hands:DrawModel()

		end

	end

end

player_manager.RegisterClass( "rs_player_class", Player, "player_default" )