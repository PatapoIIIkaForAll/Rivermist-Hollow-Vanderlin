/// Recipe data for the faction technician. This intentionally does not inherit
/// from /datum/anvil_recipe: it has no skill checks, minigame or live player.
/datum/technician_recipe
	abstract_type = /datum/technician_recipe

	var/name = "Unnamed recipe"
	var/category = "Miscellaneous"
	var/desc = ""

	/// Output item type. Must be an /obj/item path.
	var/atom/created_item
	/// Number of output items created when the job finishes.
	var/output_amount = 1

	/// Associative list: resource ID = required integer quantity.
	var/list/resource_costs = list()

	/// Service fee paid from the workstation's own mammon budget.
	var/service_fee = 0

	/// Craft duration in deciseconds.
	var/craft_time = 10 SECONDS
