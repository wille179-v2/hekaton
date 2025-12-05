local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")
local planet_catalogue_hekaton = require("__space-age__.prototypes.planet.procession-catalogue-Vulcanus")
local effects = require("__core__.lualib.surface-render-parameter-effects")
local tile_sounds = require("__base__/prototypes/tile/tile-sounds")
local decorative_trigger_effects = require("__base__/prototypes/decorative/decorative-trigger-effects")
local base_decorative_sprite_priority = "extra-high"
local hit_effects = require("__base__/prototypes/entity/hit-effects")
local sounds = require("__base__/prototypes/entity/sounds")
local base_sounds = require("__base__/prototypes/entity/sounds")

-- Note to Self: Anything with #art-setting is something I can freely customize over time to design the planet

-- see #pegalos-autoplace-controls

data:extend({ -- Planet generation settings in the UI at the start of the game. These specific ones are Hekaton-only
	{
		type = "autoplace-control",
		name = "hekaton-cliffs",
		category = "cliff",
		can_be_disabled = true,
		order = "c-z-d"
	},
	{
		type = "autoplace-control",
		name = "hekaton-infinite-calcite",
		category = "resource",
		richness = false,
		order = "a-h-c"
	},
	{
		type = "autoplace-control",
		name = "hekaton-infinite-tungsten-ore",
		category = "resource",
		richness = false,
		order = "a-h-t"
	},
	{
		type = "autoplace-control",
		name = "hekaton-infinite-sulfur",
		category = "resource",
		richness = false,
		order = "a-h-s"
	},
})

-- 
local function MapGen_Hekaton()
	local map = { -- see https://lua-api.factorio.com/latest/types/PlanetPrototypeMapGenSettings.html for more details.
		aux_climate_control = false,
		moisture_climate_control = false,
		property_expression_names = {
			elevation = "hekaton_elevation", --TODO: Noise expression
			aux = "nauvis_aux",
			cliffiness = "cliffiness_basic",
			cliff_elevation = "cliff_elevation_from_elevation",
			--TODO: Define these noise expressions:
			["entity:hekaton-infinite-tungsten-ore:probability"] = "hekaton_infinite_tungsten_ore_probability",
			["entity:hekaton-infinite-calcite:probability"] = "hekaton_infinite_calcite_probability",
			["entity:hekaton-infinite-sulfur:probability"] = "hekaton_infinite_sulfur_probability",
		},
		cliff_settings = {
			name = "cliff-vulcanus",
			autoplace_control = "hekaton-cliffs",
			cliff_smoothing = 0, --1 is default "on"
			richness = .4 -- Between 0 and 1, bigger = more connected cliffs
		},
		autoplace_controls = {
			["hekaton-infinite-calcite"] = {
				frequency = 4,
				size = 1.5,
				richness = 3,
			},
			["hekaton-infinite-tungsten-ore"] = {
				frequency = 3,
				size = 1.6,
				richness = 2,
			},
			["hekaton-infinite-sulfur"] = {
				frequency = 2,
				size = 1.8,
				richness = 3,
			}
		},
		--[[ -- See also: https://github.com/wube/factorio-data/blob/master/space-age/prototypes/planet/planet-map-gen.lua
		autoplace_settings = { -- Defines all the tiles, entities, and decoratives used in world generation.
			["tile"] = {
				settings = {
					--Example:
					--["lava"] = {}
				}
			},
			["decorative"] = {
				settings = {

				}
			},
			["entity"] = {

			}
		},
		]]
		--terrain_segmentation = 
		-- territory_settings = {}, -- Demolisher Territory definition

	} 
	return map
end

PlanetsLib:extend({
	{
		type = "planet",
		name = "hekaton",
		label_orientation = 0.15,
		orbit = {
			parent = {
				type = "space-location",
				name = "star"
			},
			distance = 12, -- Between Vulcanus's 10 and Nauvis's 15
			orientation = 0.385 -- SE on space map, more south than fulgora's 0.325
		},
		is_satellite = false, -- No effect in PlanetLib but may be useful for other mod compatibility
		subgroup = "planets",
		icon = "__planet-hekaton__/graphics/icons/hekaton_planet_icon.png",
		icon_size = 64,
		starmap_icon = "__planet-hekaton__/graphics/hekaton_starmap.png",
		starmap_icon_size = 2048,
		map_gen_settings = MapGen_Hekaton(),
		draw_orbit = true,
		magnitude = 1.8,
		gravity_pull = 10,
		--pollutant_type = nil, --Hekaton has no enemies to deal with pollution on, but Cottus will have "pollution".
		order = "d[hekaton]-a[planet]", -- The moons will be d[hekaton]-b[moon]-[briareus/cottus/gyges]
		surface_properties = {
			["day-night-cycle"] = 8 * minute, --8 minutes times 3600 ticks per minute
			["magnetic-field"] = 110,
			["solar-power"] = 350,
			pressure = 3000, -- Bots energy is determined by gravity / pressure x 100, so this should make bots use 50% the normal energy instead of 1x (or aquilo's 5x)
			gravity = 15,
			temperature = 327 -- warmer than anywhere except Vulcanus.
		},
		--surface_render_parameters = {}, -- TODO: sets the atmosphere (clouds, fog, day/night tints, etc.)
		-- Pegalos's version is copied below at ctrl-F #pegalos_surface_render_parameters
		solar_power_in_space = 420,
		platform_procession_set = { -- IDK why this is but the vanilla planets have it so...
			arrival = { "planet-to-platform-b" },
			departure = { "platform-to-planet-a" },
		},
		planet_procession_set = {
			arrival = { "platform-to-planet-b" },
			departure = { "planet-to-platform-a" },
		},
		procession_graphic_catalogue = planet_catalogue_hekaton, -- Uses space-age's clouds for Vulcanus when landing on Hekaton. Might create custom darker clouds for cottus.
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_vulcanus, 0.9),
	}
})

data:extend({
	{
		type = "space-connection",
		name = "nauvis-hekaton",
		subgroup = "planet-connections",
		from = "nauvis",
		to = "hekaton",
		order = "d[hekaton]-a[planet]",
		length = 15000,
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_vulcanus)
	},
	{
		type = "space-connection",
		name = "fulgora-hekaton",
		subgroup = "planet-connections",
		from = "fulgora",
		to = "hekaton",
		order = "d[hekaton]-a[planet]",
		length = 13000,
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
	},
	--TODO: Enable once the moons are defined.
	--[[
	{
		type = "space-connection",
		name = "hekaton-briareus",
		subgroup = "planet-connections",
		from = "hekaton",
		to = "briareus",
		order = "d[hekaton]-b[planet-to-moon]",
		length = 800,
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
	},
	{
		type = "space-connection",
		name = "hekaton-",
		subgroup = "planet-connections",
		from = "hekaton",
		to = "",
		order = "d[hekaton]-b[planet-to-moon]",
		length = 800,
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
	},
	{
		type = "space-connection",
		name = "hekaton-",
		subgroup = "planet-connections",
		from = "hekaton",
		to = "",
		order = "d[hekaton]-b[planet-to-moon]",
		length = 800,
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
	},
	{
		type = "space-connection",
		name = "briareus-cottus",
		subgroup = "planet-connections",
		from = "briareus",
		to = "cottus",
		order = "d[hekaton]-c[moon-to-moon]",
		length = 1400,
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
	},
	{
		type = "space-connection",
		name = "cottus-gyges",
		subgroup = "planet-connections",
		from = "cottus",
		to = "gyges",
		order = "d[hekaton]-c[moon-to-moon]",
		length = 1400,
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
	},
	{
		type = "space-connection",
		name = "gyges-briareus",
		subgroup = "planet-connections",
		from = "gyges",
		to = "briareus",
		order = "d[hekaton]-c[moon-to-moon]",
		length = 1400,
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.vulcanus_gleba)
	},
	]]
})







----------- Reference Shit --------

-- #pegalos-autoplace-controls

--Copied from Pegalos
--[[
data:extend({
	{
		type = "autoplace-control", -- https://lua-api.factorio.com/latest/prototypes/AutoplaceControl.html
		name = "pelagos_rocks",
		localised_name = { "entity-name.pelagos-big-rock" },
		richness = false,
		order = "a[doodad]-a[rock]-b",
		category = "resource",
		hidden = true,
	},
})
]]


-- #pegalos_surface_render_parameters
--[[
surface_render_parameters = {
			clouds = {
				shape_noise_texture = {
					filename = "__core__/graphics/clouds-noise.png",
					size = 2048,
				},
				detail_noise_texture = {
					filename = "__core__/graphics/clouds-detail-noise.png",
					size = 2048,
				},

				warp_sample_1 = { scale = 0.8 / 16 },
				warp_sample_2 = { scale = 3.75 * 0.8 / 32, wind_speed_factor = 0 },
				warped_shape_sample = { scale = 2 * 0.18 / 32 },
				-- zmniejszone zagęszczenie
				additional_density_sample = { scale = 0.5 * 0.18 / 32, wind_speed_factor = 1.77 },
				detail_sample_1 = { scale = 1.709 / 32, wind_speed_factor = 0.2 / 1.709 },
				detail_sample_2 = { scale = 2.179 / 32, wind_speed_factor = 0.2 / 2.179 },

				scale = 0.6, -- mniejsze chmury
				movement_speed_multiplier = 0.5, -- wolniejsze przesuwanie
				opacity = 0.15, -- bardziej przezroczyste
				shape_warp_strength = 0.06,
				shape_warp_weight = 0.4,
				detail_sample_morph_duration = 256,
			},

			persistent_ambient_sounds = {
				base_ambience = { filename = "__base__/sound/world/world_base_wind.ogg", volume = 0.3 },
				wind = { filename = "__base__/sound/wind/wind.ogg", volume = 0.8 },
				crossfade = {
					order = { "wind", "base_ambience" },
					curve_type = "cosine",
					from = { control = 0.35, volume_percentage = 0.0 },
					to = { control = 2, volume_percentage = 100.0 },
				},
			},
			-- Should be based on the default day/night times, ie
			-- sun starts to set at 0.25
			-- sun fully set at 0.45
			-- sun starts to rise at 0.55
			-- sun fully risen at 0.75
			day_night_cycle_color_lookup = {
				{ 0.00, "__space-age__/graphics/lut/gleba-1-noon.png" },
				{ 0.15, "__space-age__/graphics/lut/gleba-2-afternoon.png" },
				{ 0.25, "__space-age__/graphics/lut/gleba-3-late-afternoon.png" },
				{ 0.35, "__space-age__/graphics/lut/gleba-4-sunset.png" },
				{ 0.45, "__space-age__/graphics/lut/gleba-5-after-sunset.png" },
				{ 0.55, "__space-age__/graphics/lut/gleba-6-before-dawn.png" },
				{ 0.65, "__space-age__/graphics/lut/gleba-7-dawn.png" },
				{ 0.75, "__space-age__/graphics/lut/gleba-8-morning.png" },
			},
		},

]]