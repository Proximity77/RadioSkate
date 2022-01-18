GM.Version = "1.0"
GM.Name = "Radio Skate"
GM.Author = "McDunkinY"

include( "player_class/rs_player_class.lua" )

DeriveGamemode( "base" )

RS = {

	Color = {

		Color( 48, 48, 48 ),
		Color( 72, 72, 72 ),
		Color( 236, 240, 241 ),
		Color( 189, 195, 199 ),
		Color( 241, 196, 15 )

	},
	Player = {

		Model = {

			"male01",
			"male02",
			"male03",
			"male04",
			"male05",
			"male06",
			"male07",
			"male08",
			"male09"

		},
		Physics = { 

			Brake = 0.05,
			Vertical = 10,
			MaximumVelocity = 3500,
			FallDamage = 40,
			SkidSound = "physics/plastic/plastic_box_scrape_rough_loop1.wav",
			RollSound = "physics/metal/metal_box_scrape_smooth_loop1.wav",
			RailSound = "physics/metal/metal_box_scrape_rough_loop2.wav"

		},
		DefaultWorth = 100

	},
	Currency = {

		Name = "RC",
		MusicQueue = 10,
		MusicQueueSpecial = 5,
		SkateColor = 30,
		SkateColorSpecial = 15,
		Special = {

			"vip",
			"member",
			"legend",
			"developer",
			"owner"

		}

	},
	CoolDown = 15

}

function GM:Initialize()

	self.BaseClass.Initialize( self )
	
end

function CalculateVelocity( Units )

	return Units * ( 15 / 352 )

end

team.SetUp( 1, "Free Skate", Color( 155, 89, 182 ) )
team.SetUp( 2, "Deathmatch", Color( 231, 76, 60 ) )
team.SetUp( 3, "Tag", Color( 46, 204, 113 ) )
team.SetUp( 4, "Hunter", Color( 52, 152, 219 ) )