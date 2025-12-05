
require("prototypes.hekaton.hekaton-planet") -- Main Planet Definition


if mods["any-planet-start"] then
	APS.add_planet({
		name = "hekaton",
		filename = "__planet-hekaton__/aps.lua",
		technology = "planet-discovery-hekaton",
	})
end