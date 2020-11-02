Config              = {}
Config.DrawDistance = 100.0
Config.MaxDelivery	= 15    
Config.Locale       = 'en'   
Config.BagPay       = 25     
Config.MulitplyBags = true   

Config.Trucks = {
	"Boxville2", -- postipaku
}

Config.Zones = {
	VehicleSpawner = {
			Pos   = {x = 68.93, y = 127.56, z = 78.21}, --OK
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 0, g = 206, b = 209},
			Type  = 1
		},

	VehicleSpawnPoint = {
			Pos   = {x = 66.78, y = 121.31, z = 78.10}, --OK
			Size  = {x = 3.0, y = 3.0, z = 1.0},
			Color = {r = 0, g = 206, b = 209},
			Type  = -1
		},

	Cloakrooms = {
			Pos   = {x = 78.70, y = 111.88, z = 80.16}, --OK
			Size  = { x = 1.5, y = 1.5, z = 1.0 },
			Color = {r = 0, g = 206, b = 209},
			Type  = 1,
		},

}
Config.DumpstersAvaialbe = { -- ite postilaatikot
    "prop_postbox_01a",
    "prop_letterbox_01",
	"prop_letterbox_02",
	"prop_letterbox_03"
}


Config.Livraison = {
		
	RetourCamion = { -- autopalautus kohta
			Pos   = {x = 60.53, y = 127.51, z = 78.21}, 
			Color = {r = 0, g = 206, b = 209},
			Size  = {x = 3.0, y = 3.0, z = 1.5},
			Type  = 1,
			Paye = 0
		},
	
	AnnulerMission = { -- keskeytys
			Pos   = {x = 74.88, y = 123.10, z = 78.20}, 
			Color = {r = 0, g = 206, b = 209},
			Size  = {x = 3.0, y = 3.0, z = 1.5},
			Type  = 1,
			Paye = 0
		},

	Paikka1 = {
		Pos   = {x = -2999.75, y = 660.049, z = 20.50}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka2 = {
		Pos   = {x = -3193.355, y = 1157.301, z = 8.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka3 = {
		Pos   = {x = -189.86, y = -1423.14, z = 30.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka4 = {
		Pos   = {x = -1296.66, y = -1157.369, z = 4.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka5 = {
		Pos   = {x = -252.587, y = -855.835, z = 29.50}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka6 = {
		Pos   = {x = 394.8, y = -977.795, z = 28.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka7 = {
		Pos   = {x = 28.22, y = 6651.8, z = 30.00},
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka8 = {
		Pos   = {x = 1339.969, y = -558.671, z = 72.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka9 = {
		Pos   = {x = 865.99, y = -563.77, z = 56.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka10 = {
		Pos   = {x = -1047.75, y = 767.71, z = 166.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka11 = {
		Pos   = {x = 2718.57, y = 4286.04, z = 46.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka12 = {
		Pos   = {x = 1437.79, y = 3684.03, z = 32.50}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka13 = {
		Pos   = {x = 1754.29, y = 3661.74, z = 33.00},
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka14 = {
		Pos   = {x = -923.30, y = -418.03, z = 36.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka15 = {
		Pos   = {x = 1082.13, y = -462.28, z = 63.50}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka16 = {
		Pos   = {x = -393.769, y = 6295.649, z = 28.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka17 = {
		Pos   = {x = -483.98, y = -96.52, z = 37.50},
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka18 = {
		Pos   = {x = -2550.04, y = 1908.43, z = 167.50}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},

	Paikka19 = {
		Pos   = {x = -1990.27, y = 449.72, z = 100.00}, 
		Color = {r = 0, g = 206, b = 209},
		Size  = {x = 2.5, y = 2.5, z = 2.5},
		Type  = 1,
		Paye = 500
	},
}