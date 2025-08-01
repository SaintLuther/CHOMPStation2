/**
 * Stuff having to do with inter-round persistence.
 */

// Minds represent IC characters.
// Therefore it is the MIND we actually want to track here to find out
// what "character" a mob is.
// However right now minds don't keep track of what save file & slot they came from.
// So that is what we need to add!  Whenever a mind is initialized from a save file slot,
// we record that so we can save it back when persisting!

/datum/mind
	var/loaded_from_ckey = null
	var/loaded_from_slot = null

// Handle people leaving due to round ending.
/hook/roundend/proc/persist_locations()
	for(var/mob/living/carbon/human/Player in GLOB.human_mob_list)
		if(!Player.mind || isnewplayer(Player))
			continue // No mind we can do nothing, new players we care not for
		else if(Player.stat == DEAD)
			if(isobserver(Player))
				var/mob/observer/dead/O = Player
				if(O.started_as_observer)
					continue // They are just a pure observer, ignore
			// Died and were not cloned - Respawn at centcomm
			persist_interround_data(Player, using_map.spawnpoint_died)
		else
			var/turf/playerTurf = get_turf(Player)
			if(!playerTurf)
				log_debug("Player [Player.name] ([Player.ckey]) playing as [Player.species] was in nullspace at round end.")
				continue
			if(isAdminLevel(playerTurf.z))
				// Evac'd - Next round they arrive on the shuttle.
				persist_interround_data(Player, using_map.spawnpoint_left)
			else
				// Stayed on station, go to dorms
				persist_interround_data(Player, using_map.spawnpoint_stayed)
	return 1

/**
 * Prep for save: returns a preferences object if we're ready and allowed to save this mob.
 */
/proc/prep_for_persist(var/mob/persister)
	if(!istype(persister))
		stack_trace("Persist (P4P): Given non-mob [persister].")
		return

	// Find out of this mob is a proper mob!
	if (persister.mind && persister.mind.loaded_from_ckey)
		if(ckey(persister.mind.key) != persister.mind.loaded_from_ckey) //CHOMPAdd
			warning("Persist (P4P): [persister.mind] was loaded from ckey [persister.mind.loaded_from_ckey] mismatching the current ckey [ckey(persister.mind.key)].")
			return //CHOMPAdd End
		// Okay this mob has a real loaded-from-savefile mind in it!
		var/datum/preferences/prefs = preferences_datums[persister.mind.loaded_from_ckey]
		if(!prefs)
			warning("Persist (P4P): [persister.mind] was loaded from ckey [persister.mind.loaded_from_ckey] but no prefs datum found.")
			return

		// Okay, lets do a few checks to see if we should really save tho!
		if(!prefs.load_character(persister.mind.loaded_from_slot))
			warning("Persist (P4P): [persister.mind] was loaded from slot [persister.mind.loaded_from_slot] but loading prefs failed.")
			return // Failed to load character

		// For now as a safety measure we will only save if the name matches.
		if(prefs.real_name != persister.real_name)
			log_debug("Persist (P4P): Skipping [persister] because ORIG:[persister.real_name] != CURR:[prefs.real_name].")
			return

		return prefs

/**
 * Called when mob despawns early (via cryopod)!
 */
/hook/despawn/proc/persist_despawned_mob(var/mob/occupant, var/obj/machinery/cryopod/pod)
	ASSERT(istype(pod))
	ASSERT(ispath(pod.spawnpoint_type, /datum/spawnpoint))
	persist_interround_data(occupant, pod.spawnpoint_type)
	return 1

/proc/persist_interround_data(var/mob/occupant, var/datum/spawnpoint/new_spawn_point_type)
	if(!istype(occupant))
		stack_trace("Persist (PID): Given non-mob [occupant].")
		return

	var/datum/preferences/prefs = prep_for_persist(occupant)
	if(!prefs)
		warning("Persist (PID): Skipping [occupant] for persisting, as they have no prefs.")
		return

	//This one doesn't rely on persistence prefs
	if(ishuman(occupant) && occupant.stat != DEAD)
		persist_nif_data(occupant, prefs)

	if(!prefs.persistence_settings)
		return // Persistence disabled by preference settings

	// Okay we can start saving the data
	if(new_spawn_point_type && prefs.persistence_settings & PERSIST_SPAWN)
		prefs.update_preference_by_type(/datum/preference/choiced/living/spawnpoint, initial(new_spawn_point_type.display_name))
	if(ishuman(occupant) && occupant.stat != DEAD)
		var/mob/living/carbon/human/H = occupant
		testing("Persist (PID): Saving stuff from [H] to [prefs] (\ref[prefs]).")
		if(prefs.persistence_settings & PERSIST_ORGANS)
			apply_organs_to_prefs(H, prefs)
		if(prefs.persistence_settings & PERSIST_MARKINGS)
			apply_markings_to_prefs(H, prefs)
		if(prefs.persistence_settings & PERSIST_WEIGHT)
			resolve_excess_nutrition(H)
			prefs.weight_vr = H.weight
		if(prefs.persistence_settings & PERSIST_SIZE)
			prefs.size_multiplier = H.size_multiplier

	prefs.save_character()
	prefs.save_preferences()

// Saves mob's current coloration state to prefs
// This basically needs to be the reverse of /datum/category_item/player_setup_item/general/body/copy_to_mob() ~Leshana
/proc/apply_coloration_to_prefs(var/mob/living/carbon/human/character, var/datum/preferences/prefs)
	if(!istype(character)) return
	prefs.h_style	= character.h_style

	prefs.update_preference_by_type(/datum/preference/color/human/eyes_color, rgb(character.r_eyes, character.g_eyes, character.b_eyes))
	prefs.update_preference_by_type(/datum/preference/color/human/hair_color, rgb(character.r_hair, character.g_hair, character.b_hair))
	prefs.update_preference_by_type(/datum/preference/color/human/facial_color, rgb(character.r_facial, character.g_facial, character.b_facial))
	prefs.update_preference_by_type(/datum/preference/color/human/skin_color, rgb(character.r_skin, character.g_skin, character.b_skin))

	prefs.f_style	= character.f_style
	prefs.s_tone	= character.s_tone
	prefs.h_style	= character.h_style
	prefs.f_style	= character.f_style
	prefs.b_type	= character.dna ? character.dna.b_type : DEFAULT_BLOOD_TYPE

// Saves mob's current custom species, ears, tail, wings and digitigrade legs state to prefs
// This basically needs to be the reverse of /datum/category_item/player_setup_item/vore/ears/copy_to_mob() ~Leshana
/proc/apply_ears_to_prefs(var/mob/living/carbon/human/character, var/datum/preferences/prefs)
	if(character.ear_style) prefs.ear_style = character.ear_style.name
	if(character.tail_style) prefs.tail_style = character.tail_style.name
	if(character.wing_style) prefs.wing_style = character.wing_style.name

	prefs.update_preference_by_type(/datum/preference/color/human/ears_color1, rgb(character.r_ears, character.g_ears, character.b_ears))
	prefs.update_preference_by_type(/datum/preference/color/human/ears_color2, rgb(character.r_ears2, character.g_ears2, character.b_ears2))
	prefs.update_preference_by_type(/datum/preference/color/human/ears_color3, rgb(character.r_ears3, character.g_ears3, character.b_ears3))
	prefs.update_preference_by_type(/datum/preference/numeric/human/ears_alpha, character.a_ears)

	// secondary ears
	prefs.ear_secondary_style = character.ear_secondary_style?.name
	prefs.ear_secondary_colors = character.ear_secondary_colors

	prefs.update_preference_by_type(/datum/preference/color/human/tail_color1, rgb(character.r_tail, character.g_tail, character.b_tail))
	prefs.update_preference_by_type(/datum/preference/color/human/tail_color2, rgb(character.r_tail2, character.g_tail2, character.b_tail2))
	prefs.update_preference_by_type(/datum/preference/color/human/tail_color3, rgb(character.r_tail3, character.g_tail3, character.b_tail3))
	prefs.update_preference_by_type(/datum/preference/numeric/human/tail_alpha, character.a_tail)

	// TODO: This will break if update_preference_by_type starts to respect is_accessible
	prefs.update_preference_by_type(/datum/preference/color/human/wing_color1, rgb(character.r_wing, character.g_wing, character.b_wing))
	prefs.update_preference_by_type(/datum/preference/color/human/wing_color2, rgb(character.r_wing2, character.g_wing2, character.b_wing2))
	prefs.update_preference_by_type(/datum/preference/color/human/wing_color3, rgb(character.r_wing3, character.g_wing3, character.b_wing3))
	prefs.update_preference_by_type(/datum/preference/numeric/human/wing_alpha, character.a_wing)

	prefs.custom_species	= character.custom_species
	prefs.digitigrade		= character.digitigrade

// Saves mob's current organ state to prefs.
// This basically needs to be the reverse of /datum/category_item/player_setup_item/general/body/copy_to_mob() ~Leshana
/proc/apply_organs_to_prefs(var/mob/living/carbon/human/character, var/datum/preferences/prefs)
	if(!istype(character) || !character.species) return
	// Checkify the limbs!
	for(var/name in character.species.has_limbs)
		var/obj/item/organ/external/O = character.organs_by_name[name]
		if(!O)
			if(name in GLOB.storable_amputated_organs)
				prefs.organ_data[name] = "amputated"
			else
				prefs.rlimb_data.Remove(name) // Missing limb and not in the global list means default model
		else if(O.robotic >= ORGAN_ROBOT)
			prefs.organ_data[name] = "cyborg"
			if(O.model)
				prefs.rlimb_data[name] = O.model
			else
				prefs.rlimb_data.Remove(name) // Missing rlimb_data entry means default model
		else
			prefs.organ_data.Remove(name) // Misisng organ_data entry means normal

	// Internal organs also
	for(var/name in character.species.has_organ)
		var/obj/item/organ/I = character.internal_organs_by_name[name]
		if(I)
			if(istype(I, /obj/item/organ/internal/mmi_holder/robot))
				prefs.organ_data[name] = "digital" // Need a better way to detect this special type
			else if(I.robotic == ORGAN_ASSISTED)
				prefs.organ_data[name] = "assisted"
			else if(I.robotic >= ORGAN_ROBOT)
				prefs.organ_data[name] = "mechanical"
			else
				prefs.organ_data.Remove(name) // Missing organ_data entry means normal

// Saves mob's current body markings state to prefs.
// This basically needs to be the reverse of /datum/category_item/player_setup_item/general/body/copy_to_mob() ~Leshana
/proc/apply_markings_to_prefs(var/mob/living/carbon/human/character, var/datum/preferences/prefs)
	if(!istype(character)) return
	prefs.body_markings = character.get_prioritised_markings() // Overwrite with new list!

/**
* Resolve any surplus/deficit in nutrition's effet on weight all at once.
* Normally this would slowly apply during the round; once we get to the end
* we need to apply it all at once.
*/
/proc/resolve_excess_nutrition(var/mob/living/carbon/C)
	if(C.stat == DEAD)
		return // You don't metabolize if dead
	if(!C.metabolism || !C.species || !C.species.hunger_factor)
		return // You don't metabolize if you have no metabolism or your species doesn't eat!
	// Each Life() tick, you gain/lose weight proportional to your metabolism, and lose species.hunger_factor nutrition
	var/weight_per_nutrition = C.metabolism / C.species.hunger_factor

	if(C.nutrition > MIN_NUTRITION_TO_GAIN && C.weight < MAX_MOB_WEIGHT && C.weight_gain)
		// Weight Gain!
		var/gain = (C.nutrition - MIN_NUTRITION_TO_GAIN) * weight_per_nutrition * C.weight_gain/100
		C.weight = min(MAX_MOB_WEIGHT, C.weight + gain)
	else if(C.nutrition <= MAX_NUTRITION_TO_LOSE && C.weight > MIN_MOB_WEIGHT && C.weight_loss)
		// Weight Loss!
		var/loss = (MAX_NUTRITION_TO_LOSE - C.nutrition) * weight_per_nutrition * C.weight_loss/100
		C.weight = max(MIN_MOB_WEIGHT, C.weight - loss)

/**
* Persist any NIF data that needs to be persisted. It's stored in a list to make it more malleable
* towards future shenanigans such as upgradable NIFs or different types or things of that nature,
* without invoking the need for a bunch of different save file variables.
*/
/proc/persist_nif_data(mob/living/carbon/human/H)
	SIGNAL_HANDLER
	if(!istype(H))
		stack_trace("Persist (NIF): Given a nonhuman: [H]")
		return

	var/obj/item/nif/nif = H.nif

	if(nif && H.ckey != nif.owner_key)
		return

	var/slot = H?.mind?.loaded_from_slot
	if(isnull(slot))
		warning("Persist (NIF): [H] has no mind slot, skipping")
		return

	var/datum/json_savefile/savefile = new /datum/json_savefile(nif_savefile_path(H.ckey))
	var/list/save_data = savefile.get_entry("character[slot]", list())

	//If they have one, and if it's not installing without an owner, because
	//Someone who joins and immediately leaves again (wrong job choice, maybe)
	//should keep it even though it was probably doing the quick-calibrate, and their
	//owner will have been pre-set during the constructor.
	var/nif_path
	var/nif_durability
	var/nif_savedata
	if(nif && !(nif.stat == NIF_INSTALLING && !nif.owner))
		nif_path = nif.type
		nif_durability = nif.durability
		nif_savedata = nif.save_data.Copy()
	else
		nif_path = null
		nif_durability = null
		nif_savedata = null

	save_data["nif_path"] = nif_path
	save_data["nif_durability"] = nif_durability
	save_data["nif_savedata"] = nif_savedata

	savefile.set_entry("character[slot]", save_data)
	savefile.save()

	// If they still have the same character loaded, update prefs
	if(H?.client?.prefs?.default_slot == slot)
		var/datum/category_group/player_setup_category/vore_cat = H.client.prefs.player_setup.categories_by_name["General"]
		var/datum/category_item/player_setup_item/general/nif/nif_prefs = vore_cat.items_by_name["NIF Data"]
		nif_prefs.load_character()
