/// from /datum/emote/living/pray/run_emote(): (message)
#define COMSIG_CARBON_PRAY "carbon_prayed"
	/// Prevents the carbon's patron from hearing this prayer.
	#define CARBON_PRAY_CANCEL (1<<0)

///from base of /mob/living/carbon/regenerate_limbs(): (excluded_limbs)
#define COMSIG_CARBON_REGENERATE_LIMBS "living_regen_limbs"
///from base of /mob/living/carbon/regenerate_limb(), before the new limb attaches: (obj/item/bodypart/new_limb)
#define COMSIG_CARBON_LIMB_REGENERATED "carbon_limb_regenerated"
