/// Dark and light end of each tentacle palette. Grey 0 becomes the first colour, grey 255 the second.
GLOBAL_LIST_INIT(tentacle_palettes, list(
	TENTACLE_PALETTE_PINK = list("#281264", "#FF6896"),
	TENTACLE_PALETTE_CAVE = list("#101638", "#B2ACD0"),
	TENTACLE_PALETTE_GROUND = list("#340A1A", "#D88864"),
	TENTACLE_PALETTE_GRASS = list("#08262A", "#A0BC46"),
	TENTACLE_PALETTE_COLONY = list("#3A0C60", "#FFBEE8"),
	TENTACLE_PALETTE_VINE = list("#2C1808", "#889A38"),
))

/// Colour matrices built from the palettes, one per palette name.
GLOBAL_LIST_EMPTY(tentacle_palette_matrices)

/// Returns the colour matrix that maps a greyscale sprite onto the two colours of a palette.
/proc/tentacle_palette_matrix(palette)
	var/list/colour_matrix = GLOB.tentacle_palette_matrices[palette]
	if(colour_matrix)
		return colour_matrix
	var/list/ends = GLOB.tentacle_palettes[palette] || GLOB.tentacle_palettes[TENTACLE_PALETTE_PINK]
	var/list/dark = rgb2num(ends[1])
	var/list/light = rgb2num(ends[2])
	// The sheets are grey, so the red row alone carries the value; the last row adds the dark colour.
	colour_matrix = list(
		(light[1] - dark[1]) / 255, (light[2] - dark[2]) / 255, (light[3] - dark[3]) / 255, 0,
		0, 0, 0, 0,
		0, 0, 0, 0,
		0, 0, 0, 1,
		dark[1] / 255, dark[2] / 255, dark[3] / 255, 0,
	)
	GLOB.tentacle_palette_matrices[palette] = colour_matrix
	return colour_matrix

/// Picks the palette for a tentacle that stands on this turf.
/proc/tentacle_palette_for_turf(turf/ground)
	if(!ground)
		return TENTACLE_PALETTE_PINK
	if(locate(/obj/structure/tentacle_growth/floor) in ground)
		return TENTACLE_PALETTE_COLONY
	if(istype(ground, /turf/open/floor/grass))
		return TENTACLE_PALETTE_GRASS
	if(istype(ground, /turf/open/floor/dirt))
		return TENTACLE_PALETTE_GROUND
	var/static/list/cave_floors = typecacheof(list(
		/turf/open/floor/naturalstone,
		/turf/open/floor/sand,
		/turf/open/floor/cobblerock,
		/turf/open/floor/volcanic,
	))
	if(cave_floors[ground.type])
		return TENTACLE_PALETTE_CAVE
	return TENTACLE_PALETTE_PINK

/// Tints a greyscale tentacle sprite with a palette. A fade time blends from the present colour.
/atom/proc/apply_tentacle_palette(palette, fade = 0)
	var/old_colour = color
	add_atom_colour(tentacle_palette_matrix(palette), FIXED_COLOUR_PRIORITY)
	if(fade <= 0 || !old_colour)
		return
	var/new_colour = color
	color = old_colour
	animate(src, color = new_colour, time = fade, flags = ANIMATION_PARALLEL)
