/datum/quirk/neutral/scent_sensitivity
	name = "Mild Scent Sensitivity"
	desc = "My nose is a touch keener than most. When a sweating body comes within arm's reach, I know it by the smell alone, whether that smell is foul, plain or heavy."
	desc_hint = "For flavour alone: within a tile of someone with the Smell & Musk quirk I notice their sweat, without the dizziness, the wanting or the bonds that Musk Susceptibility brings."
	preview_render = FALSE

/mob/living/carbon/human/proc/notice_sweat(level, mob/living/carbon/human/source)
	var/datum/component/musk/musk = source?.get_musk()
	if(!musk || !can_smell_musk() || !get_musk_contact()?.claim_line(MUSK_LINE_SMELL))
		return FALSE
	var/list/lines = list(musk_notice_text(src, musk.get_scent_for(src), level))
	if(source in view(src))
		lines += musk_source_text(src, source)
	to_chat(src, span_notice(lines.Join(" ")))
	return TRUE
