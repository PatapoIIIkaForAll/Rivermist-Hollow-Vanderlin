// Hunting & Tracking pack - defines shared across the pack.
//
// This file must be included before hunting_footprints.dm, which uses the trait below. The .dme
// include block is kept alphabetical, and "hunting_defines" sorts ahead of "hunting_footprints",
// so the ordering holds even if the include list is regenerated.
//
// The trait is declared here rather than in code/__DEFINES/traits/definitions.dm, following the
// precedent of modular_rmh/code/modules/food/cicerone.dm (TRAIT_CICERONE). It is not listed in
// GLOB.traits_by_type (the admin trait listing, which lives in core); players reach it at
// character creation through /datum/quirk/positive/master_tracker in hunting_quirk.dm, since quirks
// are what the chargen picker is built from.

/// Always spots and fully analyzes tracks, regardless of Tracking skill.
#define TRAIT_PERFECT_TRACKER "Master Tracker"
