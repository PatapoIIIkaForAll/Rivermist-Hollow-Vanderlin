// Body builds: body silhouettes a species can offer, chosen independently of masculine or feminine.
#define BODY_BUILD_SLIM "slim"
#define BODY_BUILD_LITHE "lithe"
#define BODY_BUILD_AVERAGE "average"
#define BODY_BUILD_BROAD "broad"
#define BODY_BUILD_MUSCULAR "muscular"

/// Every build, in the order character setup lists them.
#define ALL_BODY_BUILDS list(BODY_BUILD_SLIM, BODY_BUILD_LITHE, BODY_BUILD_AVERAGE, BODY_BUILD_BROAD, BODY_BUILD_MUSCULAR)
/// Builds offered to human-shaped and furry species.
#define HUMANOID_BODY_BUILDS list(BODY_BUILD_SLIM, BODY_BUILD_AVERAGE, BODY_BUILD_BROAD, BODY_BUILD_MUSCULAR)
/// Elves also get the tall lithe body.
#define ELVEN_BODY_BUILDS list(BODY_BUILD_SLIM, BODY_BUILD_LITHE, BODY_BUILD_AVERAGE, BODY_BUILD_BROAD, BODY_BUILD_MUSCULAR)

/// Clothing cut a body wears; see /mob/living/carbon/proc/get_body_cut().
#define BODY_CUT_MASCULINE 0
#define BODY_CUT_FEMININE 1
/// Feminine cut everywhere except torso garments, the old elf male rule.
#define BODY_CUT_MIXED 2

/// Limb sprites with a light skin tint, recoloured by skin tone.
#define BODY_PALETTE_SKIN "skin"
/// Pure greyscale limb sprites, recoloured by mutant colour.
#define BODY_PALETTE_GREY "grey"

/// Offsets for the mt.dmi frame, one pixel taller than mm.dmi, shared by both sexes.
#define BODY_OFFSETS_BULKY list(\
	OFFSET_RING = list(0,1),\
	OFFSET_GLOVES = list(0,1),\
	OFFSET_WRISTS = list(0,1),\
	OFFSET_HANDS = list(0,1),\
	OFFSET_CLOAK = list(0,1),\
	OFFSET_FACEMASK = list(0,1),\
	OFFSET_HEAD = list(0,1),\
	OFFSET_FACE = list(0,1),\
	OFFSET_BELT = list(0,1),\
	OFFSET_BACK = list(0,1),\
	OFFSET_NECK = list(0,1),\
	OFFSET_MOUTH = list(0,1),\
	OFFSET_PANTS = list(0,1),\
	OFFSET_SHIRT = list(0,1),\
	OFFSET_ARMOR = list(0,1),\
	OFFSET_UNDIES = list(0,0),\
)

/// Offsets for the slim male frame, mem.dmi; its head matches mm.dmi, its arms sit lower.
#define BODY_OFFSETS_SLIM_M list(\
	OFFSET_RING = list(0,0),\
	OFFSET_GLOVES = list(0,-1),\
	OFFSET_WRISTS = list(0,1),\
	OFFSET_HANDS = list(0,0),\
	OFFSET_CLOAK = list(0,0),\
	OFFSET_FACEMASK = list(0,0),\
	OFFSET_HEAD = list(0,0),\
	OFFSET_FACE = list(0,0),\
	OFFSET_BELT = list(0,0),\
	OFFSET_BACK = list(0,0),\
	OFFSET_NECK = list(0,0),\
	OFFSET_MOUTH = list(0,0),\
	OFFSET_PANTS = list(0,0),\
	OFFSET_SHIRT = list(0,0),\
	OFFSET_ARMOR = list(0,0),\
	OFFSET_UNDIES = list(0,0),\
)

/// Offsets for the lithe male frame, met.dmi, the slim body one pixel taller.
#define BODY_OFFSETS_LITHE_M list(\
	OFFSET_RING = list(0,1),\
	OFFSET_GLOVES = list(0,0),\
	OFFSET_WRISTS = list(0,2),\
	OFFSET_HANDS = list(0,1),\
	OFFSET_CLOAK = list(0,1),\
	OFFSET_FACEMASK = list(0,1),\
	OFFSET_HEAD = list(0,1),\
	OFFSET_FACE = list(0,1),\
	OFFSET_BELT = list(0,1),\
	OFFSET_BACK = list(0,1),\
	OFFSET_NECK = list(0,1),\
	OFFSET_MOUTH = list(0,1),\
	OFFSET_PANTS = list(0,0),\
	OFFSET_SHIRT = list(0,1),\
	OFFSET_ARMOR = list(0,1),\
	OFFSET_UNDIES = list(0,1),\
)

/// Offsets for the average male frame, mm.dmi; clothing art is drawn for it.
#define BODY_OFFSETS_AVERAGE_M list(\
	OFFSET_RING = list(0,0),\
	OFFSET_GLOVES = list(0,0),\
	OFFSET_WRISTS = list(0,0),\
	OFFSET_HANDS = list(0,0),\
	OFFSET_CLOAK = list(0,0),\
	OFFSET_FACEMASK = list(0,0),\
	OFFSET_HEAD = list(0,0),\
	OFFSET_FACE = list(0,0),\
	OFFSET_BELT = list(0,0),\
	OFFSET_BACK = list(0,0),\
	OFFSET_NECK = list(0,0),\
	OFFSET_MOUTH = list(0,0),\
	OFFSET_PANTS = list(0,0),\
	OFFSET_SHIRT = list(0,0),\
	OFFSET_ARMOR = list(0,0),\
	OFFSET_UNDIES = list(0,0),\
)

/// Offsets for the slim female frame, fm.dmi.
#define BODY_OFFSETS_SLIM_F list(\
	OFFSET_RING = list(0,-1),\
	OFFSET_GLOVES = list(0,0),\
	OFFSET_WRISTS = list(0,0),\
	OFFSET_HANDS = list(0,0),\
	OFFSET_CLOAK = list(0,0),\
	OFFSET_FACEMASK = list(0,-1),\
	OFFSET_HEAD = list(0,-1),\
	OFFSET_FACE = list(0,-1),\
	OFFSET_BELT = list(0,0),\
	OFFSET_BACK = list(0,-1),\
	OFFSET_NECK = list(0,-1),\
	OFFSET_MOUTH = list(0,-1),\
	OFFSET_PANTS = list(0,0),\
	OFFSET_SHIRT = list(0,0),\
	OFFSET_ARMOR = list(0,0),\
	OFFSET_UNDIES = list(0,-1),\
)

/// Offsets for the lithe female frame, ft.dmi, one pixel taller than fm.dmi.
#define BODY_OFFSETS_LITHE_F list(\
	OFFSET_RING = list(0,0),\
	OFFSET_GLOVES = list(0,1),\
	OFFSET_WRISTS = list(0,1),\
	OFFSET_HANDS = list(0,1),\
	OFFSET_CLOAK = list(0,1),\
	OFFSET_FACEMASK = list(0,0),\
	OFFSET_HEAD = list(0,0),\
	OFFSET_FACE = list(0,0),\
	OFFSET_BELT = list(0,1),\
	OFFSET_BACK = list(0,0),\
	OFFSET_NECK = list(0,0),\
	OFFSET_MOUTH = list(0,0),\
	OFFSET_PANTS = list(0,0),\
	OFFSET_SHIRT = list(0,1),\
	OFFSET_ARMOR = list(0,1),\
	OFFSET_UNDIES = list(0,0),\
)

/// Genital offsets for masculine-proportioned frames.
#define BODY_GENITAL_OFFSETS_M list(\
	OFFSET_PENIS = list(0,0),\
	OFFSET_BREASTS = list(0,0),\
	OFFSET_TESTICLES = list(0,0),\
	OFFSET_VAGINA = list(0,-3),\
)

/// Genital offsets for the slim female frame, fm.dmi.
#define BODY_GENITAL_OFFSETS_SLIM_F list(\
	OFFSET_PENIS = list(0,0),\
	OFFSET_BREASTS = list(0,-1),\
	OFFSET_TESTICLES = list(0,0),\
	OFFSET_VAGINA = list(0,-4),\
)

/// Genital offsets for the lithe female frame, ft.dmi.
#define BODY_GENITAL_OFFSETS_LITHE_F list(\
	OFFSET_PENIS = list(0,0),\
	OFFSET_BREASTS = list(0,0),\
	OFFSET_TESTICLES = list(0,0),\
	OFFSET_VAGINA = list(0,-3),\
)
