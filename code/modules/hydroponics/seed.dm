/datum/plantgene
	var/genetype    // Label used when applying trait.
	var/list/list/values // Values to copy into the target seed datum.

/datum/seed
	//Tracking.
	var/uid                        // Unique identifier.
	var/name                       // Index for global list.
	var/seed_name                  // Plant name for seed packet.
	var/seed_noun = "seeds"        // Descriptor for packet.
	var/display_name               // Prettier name.
	var/roundstart                 // If set, seed will not display variety number.
	var/mysterious                 // Only used for the random seed packets.
	var/can_self_harvest = 0       // Mostly used for living mobs.
	var/growth_stages = 0          // Number of stages the plant passes through before it is mature.
	var/list/traits = list()       // Initialized in New()
	var/list/mutants               // Possible predefined mutant varieties, if any.
	var/list/chems                 // Chemicals that plant produces in products/injects into victim.
	var/list/consume_gasses        // The plant will absorb these gasses during its life.
	var/list/exude_gasses          // The plant will exude these gasses during its life.
	var/kitchen_tag                // Used by the reagent grinder.
	var/trash_type                 // Garbage item produced when eaten.
	var/splat_type = /obj/effect/decal/cleanable/fruit_smudge // Graffiti decal.
	var/has_mob_product            // Mob products. (Dionaea, Walking Mushrooms, Angry Tomatoes)
	var/apply_color_to_mob = TRUE  // Do we color the mob to match the plant?
	var/has_item_product           // Item products. (Eggy)
	var/force_layer
	var/harvest_sound = null		//Vorestation edit - sound the plant makes when harvested
	var/wiki_flag = 0

// Making the assumption anything in HYDRO-ponics is capable of processing water, and nutrients commonly associated with it, leaving us with the below to be tweaked.
	var/list/beneficial_reagents   // Reagents considered uniquely 'beneficial' by a plant.
	var/list/mutagenic_reagents    // Reagents considered uniquely 'mutagenic' by a plant.
	var/list/toxic_reagents        // Reagents considered uniquely 'toxic' by a plant.

/datum/seed/New()

	set_trait(TRAIT_IMMUTABLE,            0)            // If set, plant will never mutate. If -1, plant is highly mutable.
	set_trait(TRAIT_HARVEST_REPEAT,       0)            // If 1, this plant will fruit repeatedly.
	set_trait(TRAIT_PRODUCES_POWER,       0)            // Can be used to make a battery.
	set_trait(TRAIT_JUICY,                0)            // When thrown, causes a splatter decal.
	set_trait(TRAIT_EXPLOSIVE,            0)            // When thrown, acts as a grenade.
	set_trait(TRAIT_CARNIVOROUS,          0)            // 0 = none, 1 = eat pests in tray, 2 = eat living things  (when a vine).
	set_trait(TRAIT_PARASITE,             0)            // 0 = no, 1 = gain health from weed level.
	set_trait(TRAIT_STINGS,               0)            // Can cause damage/inject reagents when thrown or handled.
	set_trait(TRAIT_YIELD,                0)            // Amount of product.
	set_trait(TRAIT_SPREAD,               0)            // 0 limits plant to tray, 1 = creepers, 2 = vines.
	set_trait(TRAIT_MATURATION,           0)            // Time taken before the plant is mature.
	set_trait(TRAIT_PRODUCTION,           0)            // Time before harvesting can be undertaken again.
	set_trait(TRAIT_TELEPORTING,          0)            // Uses the bluespace tomato effect.
	set_trait(TRAIT_BIOLUM,               0)            // Plant is bioluminescent.
	set_trait(TRAIT_ALTER_TEMP,           0)            // If set, the plant will periodically alter local temp by this amount.
	set_trait(TRAIT_PRODUCT_ICON,         0)            // Icon to use for fruit coming from this plant.
	set_trait(TRAIT_PLANT_ICON,           0)            // Icon to use for the plant growing in the tray.
	set_trait(TRAIT_PRODUCT_COLOUR,       0)            // Colour to apply to product icon.
	set_trait(TRAIT_BIOLUM_COLOUR,        0)            // The colour of the plant's radiance.
	set_trait(TRAIT_POTENCY,              1)            // General purpose plant strength value.
	set_trait(TRAIT_REQUIRES_NUTRIENTS,   1)            // The plant can starve.
	set_trait(TRAIT_REQUIRES_WATER,       1)            // The plant can become dehydrated.
	set_trait(TRAIT_WATER_CONSUMPTION,    3)            // Plant drinks this much per tick.
	set_trait(TRAIT_LIGHT_TOLERANCE,      3)            // Departure from ideal that is survivable.
	set_trait(TRAIT_TOXINS_TOLERANCE,     5)            // Resistance to poison.
	set_trait(TRAIT_PEST_TOLERANCE,       5)            // Threshold for pests to impact health.
	set_trait(TRAIT_WEED_TOLERANCE,       5)            // Threshold for weeds to impact health.
	set_trait(TRAIT_IDEAL_LIGHT,          5)            // Preferred light level in luminosity.
	set_trait(TRAIT_HEAT_TOLERANCE,       20)           // Departure from ideal that is survivable.
	set_trait(TRAIT_LOWKPA_TOLERANCE,     25)           // Low pressure capacity.
	set_trait(TRAIT_ENDURANCE,            100)          // Maximum plant HP when growing.
	set_trait(TRAIT_HIGHKPA_TOLERANCE,    200)          // High pressure capacity.
	set_trait(TRAIT_IDEAL_HEAT,           293)          // Preferred temperature in Kelvin.
	set_trait(TRAIT_NUTRIENT_CONSUMPTION, 0.25)         // Plant eats this much per tick.
	set_trait(TRAIT_PLANT_COLOUR,         "#46B543")    // Colour of the plant icon.
	set_trait(TRAIT_SPORING,              0)            // Is the plant able to periodically produce spores when in a tray. 1, plant produces chem clouds, 0 it does not.
	set_trait(TRAIT_BENEFICIAL_REAG,      null)         // Reagents considered uniquely 'beneficial' by a plant. This should be an associated list of lists, or null. Examples in tray.dm. nested list: health, yield, mut
	set_trait(TRAIT_MUTAGENIC_REAG,       null)         // Reagents considered uniquely 'mutagenic' by a plant. This should be an associated list, or null. Examples in tray.dm
	set_trait(TRAIT_TOXIC_REAG,           null)         // Reagents considered uniquely 'toxic' by a plant. This should be an associated list, or null. Examples in tray.dm

	spawn(5)
		sleep(-1)
		update_growth_stages()

/datum/seed/proc/get_trait(var/trait)
	return traits["[trait]"]

/datum/seed/proc/get_trash_type()
	return trash_type

/datum/seed/proc/set_trait(var/trait,var/nval,var/ubound,var/lbound, var/degrade)
	if(!isnull(degrade)) nval *= degrade
	if(!isnull(ubound))  nval = min(nval,ubound)
	if(!isnull(lbound))  nval = max(nval,lbound)
	traits["[trait]"] =  nval

/datum/seed/proc/create_spores(var/turf/T)
	if(!T)
		return
	if(!istype(T))
		T = get_turf(T)
	if(!T)
		return

	var/datum/reagents/R = new/datum/reagents(100)
	if(chems && chems.len)
		for(var/rid in chems)
			var/injecting = min(5,max(1,get_trait(TRAIT_POTENCY)/3))
			R.add_reagent(rid,injecting)

	var/datum/effect/effect/system/smoke_spread/chem/spores/S = new(src)
	S.attach(T)
	S.set_up(R, round(get_trait(TRAIT_POTENCY)/4), 0, T)
	S.start()

// Does brute damage to a target.
/datum/seed/proc/do_thorns(var/mob/living/carbon/human/target, var/obj/item/fruit, var/target_limb)

	if(!get_trait(TRAIT_CARNIVOROUS))
		return

	if(!istype(target))
		if(istype(target, /mob/living/simple_mob/animal/passive/mouse))
			new /obj/effect/decal/remains/mouse(get_turf(target))
			qdel(target)
		else if(istype(target, /mob/living/simple_mob/animal/passive/lizard))
			new /obj/effect/decal/remains/lizard(get_turf(target))
			qdel(target)
		return

	if(!target_limb) target_limb = pick(BP_ALL)
	var/blocked = target.run_armor_check(target_limb, "melee")
	var/soaked = target.get_armor_soak(target_limb, "melee")

	if(blocked >= 100)
		return

	var/obj/item/organ/external/affecting = target.get_organ(target_limb)
	var/damage = 0
	var/has_edge = 0
	if(get_trait(TRAIT_CARNIVOROUS) >= 2)
		damage = max(5, round(15*get_trait(TRAIT_POTENCY)/100, 1))
		has_edge = prob(get_trait(TRAIT_POTENCY)/2)

		if(affecting)
			to_chat(target, span_danger("\The [fruit]'s thorns pierce your [affecting.name] greedily!"))
			target.apply_damage(damage, BRUTE, target_limb, blocked, soaked, TRUE, has_edge)
		else
			to_chat(target, span_danger("\The [fruit]'s thorns pierce your flesh greedily!"))
			target.adjustBruteLoss(damage)
	else
		damage = max(1, round(5*get_trait(TRAIT_POTENCY)/100, 1))
		has_edge = prob(get_trait(TRAIT_POTENCY)/5)
		if(affecting)
			to_chat(target, span_danger("\The [fruit]'s thorns dig deeply into your [affecting.name]!"))
			target.apply_damage(damage, BRUTE, target_limb, blocked, soaked, TRUE, has_edge)
		else
			to_chat(target, span_danger("\The [fruit]'s thorns dig deeply into your flesh!"))
			target.adjustBruteLoss(damage)

// Adds reagents to a target.
/datum/seed/proc/do_sting(var/mob/living/carbon/human/target, var/obj/item/fruit)
	if(!get_trait(TRAIT_STINGS))
		return
	if(chems && chems.len)

		var/body_coverage = HEAD|FACE|EYES|CHEST|LEGS|FEET|ARMS|HANDS

		for(var/obj/item/clothing/clothes in target)
			if(target.item_is_in_hands(clothes))
				continue
			if(clothes.item_flags & THICKMATERIAL)
				body_coverage &= ~(clothes.body_parts_covered)

		if(!body_coverage)
			return

		var/obj/item/organ/external/E = target.get_organ(target.hand ? BP_L_HAND : BP_R_HAND)
		if(istype(E) && E.robotic < ORGAN_ROBOT && fruit)
			var/injecting = min(5,max(1,get_trait(TRAIT_POTENCY)/5))
			to_chat(target, span_danger("You are stung by \the [fruit]!"))
			for(var/chem in chems)
				target.reagents.add_reagent(chem,injecting)
				if (fruit.reagents)
					fruit.reagents.remove_reagent(chem, injecting)

//Splatter a turf.
/datum/seed/proc/splatter(var/turf/T,var/obj/item/thrown)
	if(splat_type && !(locate(/obj/effect/plant) in T))
		var/obj/effect/plant/splat = new splat_type(T, src)
		if(!istype(splat)) // Plants handle their own stuff.
			splat.name = "[thrown.name] [pick("smear","smudge","splatter")]"
			if(get_trait(TRAIT_BIOLUM))
				var/clr
				if(get_trait(TRAIT_BIOLUM_COLOUR))
					clr = get_trait(TRAIT_BIOLUM_COLOUR)
				//VOREStation Edit Start - Tons of super bright super long range lights everywhere is annoying and laggy, so let's limit it a bit.
				var/blight = get_trait(TRAIT_BIOLUM)
				if(blight >= 5)
					blight = 5
				splat.set_light(blight, 0.5, l_color = clr)
				//VOREStation Edit End
			var/flesh_colour = get_trait(TRAIT_FLESH_COLOUR)
			if(!flesh_colour) flesh_colour = get_trait(TRAIT_PRODUCT_COLOUR)
			if(flesh_colour) splat.color = get_trait(TRAIT_PRODUCT_COLOUR)

	if(chems && chems.len)
		for(var/mob/living/M in T.contents)
			if(!M.reagents)
				continue
			var/body_coverage = HEAD|FACE|EYES|CHEST|LEGS|FEET|ARMS|HANDS
			for(var/obj/item/clothing/clothes in M)
				if(M.item_is_in_hands(clothes))
					continue
				body_coverage &= ~(clothes.body_parts_covered)
			if(!body_coverage)
				continue
			var/datum/reagents/R = M.reagents
			var/mob/living/carbon/human/H = M
			if(istype(H))
				R = H.touching
			if(istype(R))
				for(var/chem in chems)
					R.add_reagent(chem,min(5,max(1,get_trait(TRAIT_POTENCY)/3)))

//Applies an effect to a target atom.
/datum/seed/proc/thrown_at(var/obj/item/thrown,var/atom/target, var/force_explode)

	var/splatted
	var/turf/origin_turf = get_turf(target)

	if(force_explode || get_trait(TRAIT_EXPLOSIVE))

		create_spores(origin_turf)

		var/flood_dist = min(10,max(1,get_trait(TRAIT_POTENCY)/15))
		var/list/open_turfs = list()
		var/list/closed_turfs = list()
		var/list/valid_turfs = list()
		open_turfs |= origin_turf

		// Flood fill to get affected turfs.
		// NOTE: Halfass bugfix implemented using air_blocked() but this really should be redone completely ~Leshana
		while(open_turfs.len)
			var/turf/T = pick(open_turfs)
			open_turfs -= T
			closed_turfs |= T
			valid_turfs |= T

			for(var/dir in GLOB.alldirs)
				var/turf/neighbor = get_step(T,dir)
				if(!neighbor || (neighbor in closed_turfs) || (neighbor in open_turfs))
					continue
				if(neighbor.density || get_dist(neighbor,origin_turf) > flood_dist || istype(neighbor,/turf/space))
					closed_turfs |= neighbor
					continue
				// Check for windows.
				var/no_los
				var/turf/last_turf = origin_turf
				for(var/turf/target_turf in getline(origin_turf,neighbor))
					if(SSair.air_blocked(last_turf, target_turf))
						no_los = 1
						break
					last_turf = target_turf
				if(!no_los && SSair.air_blocked(origin_turf, neighbor))
					no_los = 1
				if(no_los)
					closed_turfs |= neighbor
					continue
				open_turfs |= neighbor

		for(var/turf/T in valid_turfs)
			for(var/mob/living/M in T.contents)
				apply_special_effect(M)
			splatter(T,thrown)
		if(origin_turf)
			origin_turf.visible_message(span_danger("The [thrown.name] explodes!"))
		qdel(thrown)
		return

	if(isliving(target))
		splatted = apply_special_effect(target,thrown)
	else if(istype(target,/turf))
		splatted = 1
		for(var/mob/living/M in target.contents)
			apply_special_effect(M)

	if(get_trait(TRAIT_JUICY) && splatted)
		splatter(origin_turf,thrown)
		if(origin_turf)
			origin_turf.visible_message(span_danger("The [thrown.name] splatters against [target]!"))
		qdel(thrown)

/datum/seed/proc/handle_environment(var/turf/current_turf, var/datum/gas_mixture/environment, var/light_supplied, var/check_only)

	var/health_change = 0
	// Handle gas consumption.
	if(consume_gasses && consume_gasses.len)
		var/missing_gas = 0
		for(var/gas in consume_gasses)
			if(environment && environment.gas && environment.gas[gas] && \
				environment.gas[gas] >= consume_gasses[gas])
				if(!check_only)
					environment.adjust_gas(gas,-consume_gasses[gas],1)
			else
				missing_gas++

		if(missing_gas > 0)
			health_change += missing_gas * HYDRO_SPEED_MULTIPLIER

	// Process it.
	var/pressure = environment.return_pressure()
	if(pressure < get_trait(TRAIT_LOWKPA_TOLERANCE)|| pressure > get_trait(TRAIT_HIGHKPA_TOLERANCE))
		health_change += rand(1,3) * HYDRO_SPEED_MULTIPLIER

	if(abs(environment.temperature - get_trait(TRAIT_IDEAL_HEAT)) > get_trait(TRAIT_HEAT_TOLERANCE))
		health_change += rand(1,3) * HYDRO_SPEED_MULTIPLIER

	// Handle gas production.
	if(!check_only)
		if(exude_gasses && exude_gasses.len)
			for(var/gas in exude_gasses)
				environment.adjust_gas(gas, max(1,round((exude_gasses[gas]*(get_trait(TRAIT_POTENCY)/5))/exude_gasses.len)))

		if(get_trait(TRAIT_SPORING))
			var/can_spore = TRUE
			var/obj/machinery/portable_atmospherics/hydroponics/hometray = locate(/obj/machinery/portable_atmospherics/hydroponics) in current_turf

			if(health_change > 2 || (hometray && hometray.closed_system))
				can_spore = FALSE

			if(can_spore && prob(5))
				create_spores(current_turf)

	// Handle light requirements.
	if(!light_supplied)
		light_supplied = current_turf.get_lumcount() * 5
	if(light_supplied)
		if(abs(light_supplied - get_trait(TRAIT_IDEAL_LIGHT)) > get_trait(TRAIT_LIGHT_TOLERANCE))
			health_change += rand(1,3) * HYDRO_SPEED_MULTIPLIER

	return health_change

/datum/seed/proc/apply_special_effect(var/mob/living/target,var/obj/item/thrown)

	var/impact = 1
	do_sting(target,thrown)
	do_thorns(target,thrown)

	// Bluespace tomato code copied over from grown.dm.
	if(get_trait(TRAIT_TELEPORTING))

		//Plant potency determines radius of teleport.
		var/outer_teleport_radius = get_trait(TRAIT_POTENCY)/5
		var/inner_teleport_radius = get_trait(TRAIT_POTENCY)/15

		var/list/turfs = list()
		if(inner_teleport_radius > 0)
			for(var/turf/T in orange(target,outer_teleport_radius))
				if(get_dist(target,T) >= inner_teleport_radius)
					turfs |= T

		if(turfs.len)
			// Moves the mob, causes sparks.
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, get_turf(target))
			s.start()
			var/turf/picked = get_turf(pick(turfs))                      // Just in case...
			new/obj/effect/decal/cleanable/molten_item(get_turf(target)) // Leave a pile of goo behind for dramatic effect...
			target.loc = picked                                          // And teleport them to the chosen location.

			impact = 1

	return impact

/datum/seed/proc/generate_name()
	var/prefix = ""
	var/name = ""
	if(prob(50)) //start with a prefix.
		//These are various plant/mushroom genuses.
		//I realize these might not be entirely accurate, but it could facilitate RP.
		var/list/possible_prefixes
		if(seed_noun == "cuttings" || seed_noun == "seeds" || (seed_noun == "nodes" && prob(50)))
			possible_prefixes = list("amelanchier", "saskatoon",
										"magnolia", "angiosperma", "osmunda", "scabiosa", "spigelia", "psydrax", "chastetree",
										"strychnos", "treebine", "caper", "justica", "ragwortus", "everlasting", "combretum",
										"loganiaceae", "gelsemium", "logania", "sabadilla", "neuburgia", "canthium", "rytigynia",
										"chaste", "vitex", "cissus", "capparis", "senecio", "curry", "cycad", "liverwort", "charophyta",
										"glaucophyte", "pinidae", "vascular", "embryophyte", "lillopsida")
		else
			possible_prefixes = list("bisporus", "bitorquis", "campestris", "crocodilinus", "agaricus",
									"armillaria", "matsutake", "mellea", "ponderosa", "auricularia", "auricala",
									"polytricha", "boletus", "badius", "edulis", "mirabilis", "zelleri",
									"calvatia", "gigantea", "clitopilis", "prumulus", "entoloma", "abortivum",
									"suillus", "tuber", "aestivum", "volvacea", "delica", "russula", "rozites")

		possible_prefixes |= list("butter", "shad", "sugar", "june", "wild", "rigus", "curry", "hard", "soft", "dark", "brick", "stone", "red", "brown",
								"black", "white", "paper", "slippery", "honey", "bitter")
		prefix = pick(possible_prefixes)

	var/num = rand(2,5)
	var/list/possible_name = list("rhon", "cus", "quam", "met", "eget", "was", "reg", "zor", "fra", "rat", "sho", "ghen", "pa",
								"eir", "lip", "sum", "lor", "em", "tem", "por", "invi", "dunt", "ut", "la", "bore", "mag", "na",
								"al", "i", "qu", "yam", "er", "at", "sed", "di", "am", "vol", "up", "tua", "at", "ve", "ro", "eos",
								"et", "ac", "cus")
	for(var/i in 1 to num)
		var/syl = pick(possible_name)
		possible_name -= syl
		name += syl

	if(prefix)
		name = "[prefix] [name]"
	seed_name = name
	display_name = name

//Creates a random seed. MAKE SURE THE LINE HAS DIVERGED BEFORE THIS IS CALLED.
/datum/seed/proc/randomize()

	roundstart = 0
	mysterious = 1
	seed_noun = pick("spores","nodes","cuttings","seeds","pits")

	set_trait(TRAIT_POTENCY,rand(5,30),200,0)
	set_trait(TRAIT_PRODUCT_ICON,pick(SSplants.accessible_product_sprites))
	set_trait(TRAIT_PLANT_ICON,pick(SSplants.accessible_plant_sprites))
	set_trait(TRAIT_PLANT_COLOUR,get_random_colour(0,75,190))
	set_trait(TRAIT_PRODUCT_COLOUR,get_random_colour(0,75,190))
	update_growth_stages()

	if(prob(20))
		set_trait(TRAIT_HARVEST_REPEAT,1)

	if(prob(15))
		if(prob(15))
			set_trait(TRAIT_JUICY,2)
		else
			set_trait(TRAIT_JUICY,1)

	if(prob(5))
		set_trait(TRAIT_STINGS,1)

	if(prob(5))
		set_trait(TRAIT_PRODUCES_POWER,1)

	if(prob(1))
		set_trait(TRAIT_EXPLOSIVE,1)
	else if(prob(1))
		set_trait(TRAIT_TELEPORTING,1)

	if(prob(5))
		consume_gasses = list()
		var/gas = pick(GAS_O2,GAS_N2,GAS_PHORON,GAS_CO2)
		consume_gasses[gas] = rand(3,9)

	if(prob(5))
		exude_gasses = list()
		var/gas = pick(GAS_O2,GAS_N2,GAS_PHORON,GAS_CO2)
		exude_gasses[gas] = rand(3,9)

	chems = list()
	if(prob(80))
		chems[REAGENT_ID_NUTRIMENT] = list(rand(1,10),rand(10,20))

	var/additional_chems = rand(0,5)

	if(additional_chems)

		for(var/x=1;x<=additional_chems;x++)

			var/new_chem = pick(SSchemistry.chemical_reagents)
			var/list/currently_banned_chems = list()
			currently_banned_chems += GLOB.obtainable_chemical_blacklist
			if(new_chem in currently_banned_chems)
				continue
			currently_banned_chems += new_chem
			chems[new_chem] = list(rand(1,10),rand(10,20))

	if(prob(5))
		var/unique_beneficial_count = rand(1, 5)
		if(!beneficial_reagents)
			beneficial_reagents = list()
		for(var/x = 1 to unique_beneficial_count)
			beneficial_reagents[pick(SSchemistry.chemical_reagents)] = list(round(rand(-100, 100) / 10), round(rand(-100, 100) / 10), round(rand(-100, 100) / 10))
		set_trait(TRAIT_BENEFICIAL_REAG, beneficial_reagents)

	if(prob(5))
		var/unique_mutagenic_count = rand(1, 5)
		if(!mutagenic_reagents)
			mutagenic_reagents = list()
		for(var/x = 1 to unique_mutagenic_count)
			mutagenic_reagents[pick(SSchemistry.chemical_reagents)] = rand(0, 20)
		set_trait(TRAIT_MUTAGENIC_REAG, mutagenic_reagents)

	if(prob(5))
		var/unique_toxic_count = rand(1, 5)
		if(!toxic_reagents)
			toxic_reagents = list()
		for(var/x = 1 to unique_toxic_count)
			toxic_reagents[pick(SSchemistry.chemical_reagents)] = round(rand(-100, 100) / 10)
		set_trait(TRAIT_TOXIC_REAG, toxic_reagents)

	if(prob(90))
		set_trait(TRAIT_REQUIRES_NUTRIENTS,1)
		set_trait(TRAIT_NUTRIENT_CONSUMPTION,rand(25)/25)
	else
		set_trait(TRAIT_REQUIRES_NUTRIENTS,0)

	if(prob(90))
		set_trait(TRAIT_REQUIRES_WATER,1)
		set_trait(TRAIT_WATER_CONSUMPTION,rand(10))
	else
		set_trait(TRAIT_REQUIRES_WATER,0)

	set_trait(TRAIT_IDEAL_HEAT,       rand(100,400))
	set_trait(TRAIT_HEAT_TOLERANCE,   rand(10,30))
	set_trait(TRAIT_IDEAL_LIGHT,      rand(2,10))
	set_trait(TRAIT_LIGHT_TOLERANCE,  rand(2,7))
	set_trait(TRAIT_TOXINS_TOLERANCE, rand(2,7))
	set_trait(TRAIT_PEST_TOLERANCE,   rand(2,7))
	set_trait(TRAIT_WEED_TOLERANCE,   rand(2,7))
	set_trait(TRAIT_LOWKPA_TOLERANCE, rand(10,50))
	set_trait(TRAIT_HIGHKPA_TOLERANCE,rand(100,300))

	if(prob(5))
		set_trait(TRAIT_ALTER_TEMP,rand(-5,5))

	if(prob(1))
		set_trait(TRAIT_IMMUTABLE,-1)

	var/carnivore_prob = rand(100)
	if(carnivore_prob < 5)
		set_trait(TRAIT_CARNIVOROUS,2)
	else if(carnivore_prob < 10)
		set_trait(TRAIT_CARNIVOROUS,1)

	if(prob(10))
		set_trait(TRAIT_PARASITE,1)

	var/vine_prob = rand(100)
	if(vine_prob < 5)
		set_trait(TRAIT_SPREAD,2)
	else if(vine_prob < 10)
		set_trait(TRAIT_SPREAD,1)

	if(prob(5))
		set_trait(TRAIT_BIOLUM,1)
		set_trait(TRAIT_BIOLUM_COLOUR,get_random_colour(0,75,190))

	if(prob(3))
		set_trait(TRAIT_SPORING,1)

	if(prob(5))
		if(prob(30))
			has_mob_product = pickweight(GLOB.plant_mob_products)
		else
			has_item_product = pickweight(GLOB.plant_item_products)

	set_trait(TRAIT_ENDURANCE,rand(60,100))
	set_trait(TRAIT_YIELD,rand(3,15))
	set_trait(TRAIT_MATURATION,rand(5,15))
	set_trait(TRAIT_PRODUCTION,get_trait(TRAIT_MATURATION)+rand(2,5))

	generate_name()

//Returns a key corresponding to an entry in the global seed list.
/datum/seed/proc/get_mutant_variant()
	if(!mutants || !mutants.len || get_trait(TRAIT_IMMUTABLE) > 0) return 0
	return pick(mutants)

//Mutates the plant overall (randomly).
/datum/seed/proc/mutate(var/degree,var/turf/source_turf)

	if(!degree || get_trait(TRAIT_IMMUTABLE) > 0) return

	source_turf.visible_message(span_infoplain(span_bold("\The [display_name]") + " quivers!"))

	//This looks like shit, but it's a lot easier to read/change this way.
	var/total_mutations = rand(1,1+degree)
	for(var/i = 0;i<total_mutations;i++)
		switch(rand(0,11))
			if(0) //Plant cancer!
				set_trait(TRAIT_ENDURANCE,get_trait(TRAIT_ENDURANCE)-rand(10,20),null,0)
				source_turf.visible_message(span_danger("\The [display_name] withers rapidly!"))
			if(1)
				set_trait(TRAIT_NUTRIENT_CONSUMPTION,get_trait(TRAIT_NUTRIENT_CONSUMPTION)+rand(-(degree*0.1),(degree*0.1)),5,0)
				set_trait(TRAIT_WATER_CONSUMPTION,   get_trait(TRAIT_WATER_CONSUMPTION)   +rand(-degree,degree),50,0)
				set_trait(TRAIT_JUICY,              !get_trait(TRAIT_JUICY))
				set_trait(TRAIT_STINGS,             !get_trait(TRAIT_STINGS))
			if(2)
				set_trait(TRAIT_IDEAL_HEAT,          get_trait(TRAIT_IDEAL_HEAT) +      (rand(-5,5)*degree),800,70)
				set_trait(TRAIT_HEAT_TOLERANCE,      get_trait(TRAIT_HEAT_TOLERANCE) +  (rand(-5,5)*degree),800,70)
				set_trait(TRAIT_LOWKPA_TOLERANCE,    get_trait(TRAIT_LOWKPA_TOLERANCE)+ (rand(-5,5)*degree),80,0)
				set_trait(TRAIT_HIGHKPA_TOLERANCE,   get_trait(TRAIT_HIGHKPA_TOLERANCE)+(rand(-5,5)*degree),500,110)
				set_trait(TRAIT_EXPLOSIVE,1)
			if(3)
				set_trait(TRAIT_IDEAL_LIGHT,         get_trait(TRAIT_IDEAL_LIGHT)+(rand(-1,1)*degree),30,0)
				set_trait(TRAIT_LIGHT_TOLERANCE,     get_trait(TRAIT_LIGHT_TOLERANCE)+(rand(-2,2)*degree),10,0)
			if(4)
				set_trait(TRAIT_TOXINS_TOLERANCE,    get_trait(TRAIT_TOXINS_TOLERANCE)+(rand(-2,2)*degree),10,0)
				if(prob(degree*3))
					var/unique_toxic_count = rand(1, 5)
					if(!toxic_reagents)
						toxic_reagents = list()
					for(var/x = 1 to unique_toxic_count)
						toxic_reagents[pick(SSchemistry.chemical_reagents)] = round(rand(-100, 100) / 10)
					set_trait(TRAIT_TOXIC_REAG, toxic_reagents)
			if(5)
				set_trait(TRAIT_WEED_TOLERANCE,      get_trait(TRAIT_WEED_TOLERANCE)+(rand(-2,2)*degree),10, 0)
				if(prob(degree*5))
					set_trait(TRAIT_CARNIVOROUS,     get_trait(TRAIT_CARNIVOROUS)+rand(-degree,degree),2, 0)
					if(get_trait(TRAIT_CARNIVOROUS))
						source_turf.visible_message(span_infoplain(span_bold("\The [display_name]") + " shudders hungrily."))
			if(6)
				set_trait(TRAIT_WEED_TOLERANCE,      get_trait(TRAIT_WEED_TOLERANCE)+(rand(-2,2)*degree),10, 0)
				if(prob(degree*5))
					set_trait(TRAIT_PARASITE,!get_trait(TRAIT_PARASITE))
			if(7)
				if(get_trait(TRAIT_YIELD) != -1)
					set_trait(TRAIT_YIELD,           get_trait(TRAIT_YIELD)+(rand(-2,2)*degree),10,0)
				if(prob(degree*3))
					var/unique_mutagenic_count = rand(1, 5)
					if(!mutagenic_reagents)
						mutagenic_reagents = list()
					for(var/x = 1 to unique_mutagenic_count)
						mutagenic_reagents[pick(SSchemistry.chemical_reagents)] = rand(0, 20)
					set_trait(TRAIT_MUTAGENIC_REAG, mutagenic_reagents)
			if(8)
				set_trait(TRAIT_ENDURANCE,           get_trait(TRAIT_ENDURANCE)+(rand(-5,5)*degree),100,10)
				set_trait(TRAIT_PRODUCTION,          get_trait(TRAIT_PRODUCTION)+(rand(-1,1)*degree),10, 1)
				set_trait(TRAIT_POTENCY,             get_trait(TRAIT_POTENCY)+(rand(-20,20)*degree),200, 0)
				if(prob(degree*5))
					set_trait(TRAIT_SPREAD,          get_trait(TRAIT_SPREAD)+rand(-1,1),2, 0)
					source_turf.visible_message(span_infoplain(span_bold("\The [display_name]") + " spasms visibly, shifting in the tray."))
				if(prob(degree*3))
					set_trait(TRAIT_SPORING,        !get_trait(TRAIT_SPORING))
			if(9)
				set_trait(TRAIT_MATURATION,          get_trait(TRAIT_MATURATION)+(rand(-1,1)*degree),30, 0)
				if(prob(degree*5))
					set_trait(TRAIT_HARVEST_REPEAT, !get_trait(TRAIT_HARVEST_REPEAT))
				if(prob(degree*3))
					var/unique_beneficial_count = rand(1, 5)
					if(!beneficial_reagents)
						beneficial_reagents = list()
					for(var/x = 1 to unique_beneficial_count)
						beneficial_reagents[pick(SSchemistry.chemical_reagents)] = list(round(rand(-100, 100) / 10), round(rand(-100, 100) / 10), round(rand(-100, 100) / 10))
					set_trait(TRAIT_BENEFICIAL_REAG, beneficial_reagents)
			if(10)
				if(prob(degree*2))
					set_trait(TRAIT_BIOLUM,         !get_trait(TRAIT_BIOLUM))
					if(get_trait(TRAIT_BIOLUM))
						source_turf.visible_message(span_infoplain(span_bold("\The [display_name]") + " begins to glow!"))
						if(prob(degree*2))
							set_trait(TRAIT_BIOLUM_COLOUR,get_random_colour(0,75,190))
							source_turf.visible_message(span_notice("\The [display_name]'s glow") + " <font color='[get_trait(TRAIT_BIOLUM_COLOUR)]'>changes colour</font>!")
					else
						source_turf.visible_message(span_notice("\The [display_name]'s glow dims..."))
			if(11)
				set_trait(TRAIT_TELEPORTING,1)

	return

//Mutates a specific trait/set of traits.
/datum/seed/proc/apply_gene(var/datum/plantgene/gene)

	if(!gene || !gene.values || get_trait(TRAIT_IMMUTABLE) > 0) return

	// Splicing products has some detrimental effects on yield and lifespan.
	// We handle this before we do the rest of the looping, as normal traits don't really include lists.
	switch(gene.genetype)
		if(GENE_BIOCHEMISTRY)
			for(var/trait in list(TRAIT_YIELD, TRAIT_ENDURANCE))
				if(get_trait(trait) > 0) set_trait(trait,get_trait(trait),null,1,0.85)

			if(!chems) chems = list()

			var/list/gene_value = gene.values["[TRAIT_CHEMS]"]
			for(var/rid in gene_value)

				var/list/gene_chem = gene_value[rid]

				if(!chems[rid])
					chems[rid] = gene_chem.Copy()
					continue

				for(var/i=1;i<=gene_chem.len;i++)

					if(isnull(gene_chem[i])) gene_chem[i] = 0

					var/list/chems_rid = chems[rid]
					if(istype(chems_rid) && (chems_rid.len < i)) //YW Edit: allows plants whose reagents have not been defined uniformly to splice properly
						continue

					if(chems[rid][i])
						chems[rid][i] = max(1,round((gene_chem[i] + chems[rid][i])/2))
					else
						chems[rid][i] = gene_chem[i]

			var/list/new_gasses = gene.values["[TRAIT_EXUDE_GASSES]"]
			if(islist(new_gasses))
				if(!exude_gasses) exude_gasses = list()
				exude_gasses |= new_gasses
				for(var/gas in exude_gasses)
					exude_gasses[gas] = max(1,round(exude_gasses[gas]*0.8))

			set_trait(TRAIT_BENEFICIAL_REAG, gene.values["[TRAIT_BENEFICIAL_REAG]"]?.Copy() || list())

			set_trait(TRAIT_MUTAGENIC_REAG, gene.values["[TRAIT_MUTAGENIC_REAG]"]?.Copy() || list())

			set_trait(TRAIT_TOXIC_REAG, gene.values["[TRAIT_TOXIC_REAG]"]?.Copy() || list())

			gene.values["[TRAIT_EXUDE_GASSES]"] = null
			gene.values["[TRAIT_CHEMS]"] = null
			gene.values["[TRAIT_BENEFICIAL_REAG]"] = null
			gene.values["[TRAIT_MUTAGENIC_REAG]"] = null
			gene.values["[TRAIT_TOXIC_REAG]"] = null

		if(GENE_DIET)
			var/list/new_gasses = gene.values["[TRAIT_CONSUME_GASSES]"]
			consume_gasses |= new_gasses
			gene.values["[TRAIT_CONSUME_GASSES]"] = null
		if(GENE_METABOLISM)
			has_mob_product = gene.values["mob_product"]
			has_item_product = gene.values["item_product"]
			gene.values["mob_product"] = null

	for(var/trait in gene.values)
		set_trait(trait,gene.values["[trait]"])

	update_growth_stages()

//Returns a list of the desired trait values.
/datum/seed/proc/get_gene(var/genetype)

	if(!genetype) return 0

	var/list/traits_to_copy
	var/datum/plantgene/P = new()
	P.genetype = genetype
	P.values = list()

	switch(genetype)
		if(GENE_BIOCHEMISTRY)
			P.values["[TRAIT_CHEMS]"] =        chems
			P.values["[TRAIT_EXUDE_GASSES]"] = exude_gasses
			traits_to_copy = list(TRAIT_POTENCY, TRAIT_BENEFICIAL_REAG, TRAIT_MUTAGENIC_REAG, TRAIT_TOXIC_REAG)
		if(GENE_OUTPUT)
			traits_to_copy = list(TRAIT_PRODUCES_POWER,TRAIT_BIOLUM,TRAIT_SPORING)
		if(GENE_ATMOSPHERE)
			traits_to_copy = list(TRAIT_HEAT_TOLERANCE,TRAIT_LOWKPA_TOLERANCE,TRAIT_HIGHKPA_TOLERANCE)
		if(GENE_HARDINESS)
			traits_to_copy = list(TRAIT_TOXINS_TOLERANCE,TRAIT_PEST_TOLERANCE,TRAIT_WEED_TOLERANCE,TRAIT_ENDURANCE)
		if(GENE_METABOLISM)
			P.values["mob_product"] = has_mob_product
			P.values["item_product"] = has_item_product
			traits_to_copy = list(TRAIT_REQUIRES_NUTRIENTS,TRAIT_REQUIRES_WATER,TRAIT_ALTER_TEMP)
		if(GENE_VIGOUR)
			traits_to_copy = list(TRAIT_PRODUCTION,TRAIT_MATURATION,TRAIT_YIELD,TRAIT_SPREAD)
		if(GENE_DIET)
			P.values["[TRAIT_CONSUME_GASSES]"] = consume_gasses
			traits_to_copy = list(TRAIT_CARNIVOROUS,TRAIT_PARASITE,TRAIT_NUTRIENT_CONSUMPTION,TRAIT_WATER_CONSUMPTION)
		if(GENE_ENVIRONMENT)
			traits_to_copy = list(TRAIT_IDEAL_HEAT,TRAIT_IDEAL_LIGHT,TRAIT_LIGHT_TOLERANCE)
		if(GENE_PIGMENT)
			traits_to_copy = list(TRAIT_PLANT_COLOUR,TRAIT_PRODUCT_COLOUR,TRAIT_BIOLUM_COLOUR)
		if(GENE_STRUCTURE)
			traits_to_copy = list(TRAIT_PLANT_ICON,TRAIT_PRODUCT_ICON,TRAIT_HARVEST_REPEAT)
		if(GENE_FRUIT)
			traits_to_copy = list(TRAIT_STINGS,TRAIT_EXPLOSIVE,TRAIT_FLESH_COLOUR,TRAIT_JUICY)
		if(GENE_SPECIAL)
			traits_to_copy = list(TRAIT_TELEPORTING)

	for(var/trait in traits_to_copy)
		P.values["[trait]"] = get_trait(trait)
	return (P ? P : 0)

//Place the plant products at the feet of the user.
/datum/seed/proc/harvest(var/mob/user,var/yield_mod,var/harvest_sample,var/force_amount,var/reagent_mod,var/reagent_mod_amount)

	if(!user)
		return

	if(get_trait(TRAIT_SPORING) && prob(round(30 * yield_mod)))
		var/turf/T = get_turf(user)
		create_spores(T)

	if(harvest_sound)//Vorestation edit
		var/turf/M = get_turf(user)
		playsound(M, harvest_sound, 50, 1, -1)

	if(!force_amount && get_trait(TRAIT_YIELD) == 0 && !harvest_sample)
		if(istype(user))
			to_chat(user, span_danger("You fail to harvest anything useful."))
	else
		if(istype(user))
			to_chat(user, span_filter_notice("You [harvest_sample ? "take a sample" : "harvest"] from the [display_name]."))

		//This may be a new line. Update the global if it is.
		if(name == "new line" || !(name in SSplants.seeds))
			uid = SSplants.seeds.len + 1
			name = "[uid]"
			SSplants.seeds[name] = src

		if(harvest_sample)
			var/obj/item/seeds/seeds = new(get_turf(user))
			seeds.seed_type = name
			seeds.update_seed()
			return

		var/total_yield = 0
		if(!isnull(force_amount))
			total_yield = force_amount
		else
			if(get_trait(TRAIT_YIELD) > -1)
				if(isnull(yield_mod) || yield_mod < 1)
					yield_mod = 0
					total_yield = get_trait(TRAIT_YIELD)
				else
					total_yield = get_trait(TRAIT_YIELD) + rand(yield_mod)
				total_yield = max(1,total_yield)

		for(var/i = 0;i<total_yield;i++)
			var/obj/item/product
			if(has_mob_product)
				product = new has_mob_product(get_turf(user),name)
			else if(has_item_product)
				product = new has_item_product(get_turf(user))
			else
				product = new /obj/item/reagent_containers/food/snacks/grown(get_turf(user),name)
			if (get_trait(TRAIT_PRODUCT_COLOUR))
				if (istype(product,/obj/item/reagent_containers/food))
					var/obj/item/reagent_containers/food/food = product
					food.filling_color = get_trait(TRAIT_PRODUCT_COLOUR)

			if(reagent_mod && reagent_mod_amount)
				product.reagents.add_reagent(reagent_mod,reagent_mod_amount)

			if(mysterious)
				product.name += "?"
				product.desc += " On second thought, something about this one looks strange."

			if(get_trait(TRAIT_BIOLUM))
				var/clr
				if(get_trait(TRAIT_BIOLUM_COLOUR))
					clr = get_trait(TRAIT_BIOLUM_COLOUR)
				//VOREStation Edit Start - Tons of super bright super long range lights everywhere is annoying and laggy, so let's limit it a bit.
				var/blight = get_trait(TRAIT_BIOLUM)
				if(blight >= 5)
					blight = 5
				product.set_light(blight, 0.5, l_color = clr)
				//VOREStation Edit End
			if(get_trait(TRAIT_STINGS))
				product.force = 1

			//Handle spawning in living, mobile products (like dionaea).
			if(isliving(product))
				product.visible_message(span_notice("The pod disgorges [product]!"))
				handle_living_product(product)

// When the seed in this machine mutates/is modified, the tray seed value
// is set to a new datum copied from the original. This datum won't actually
// be put into the global datum list until the product is harvested, though.
/datum/seed/proc/diverge(var/modified)

	if(get_trait(TRAIT_IMMUTABLE) > 0) return

	//Set up some basic information.
	var/datum/seed/new_seed = new
	new_seed.name =            "new line"
	new_seed.uid =              0
	new_seed.roundstart =       0
	new_seed.can_self_harvest = can_self_harvest
	new_seed.kitchen_tag =      kitchen_tag
	new_seed.trash_type =       trash_type
	new_seed.has_mob_product =  has_mob_product
	new_seed.has_item_product = has_item_product

	//Copy over everything else.
	if(mutants)        new_seed.mutants = mutants.Copy()
	if(chems)          new_seed.chems = chems.Copy()
	if(consume_gasses) new_seed.consume_gasses = consume_gasses.Copy()
	if(exude_gasses)   new_seed.exude_gasses = exude_gasses.Copy()

	new_seed.seed_name =            "[(roundstart ? "[(modified ? "modified" : "mutant")] " : "")][seed_name]"
	new_seed.display_name =         "[(roundstart ? "[(modified ? "modified" : "mutant")] " : "")][display_name]"
	new_seed.seed_noun =            seed_noun
	new_seed.traits = traits.Copy()
	new_seed.update_growth_stages()
	return new_seed

/datum/seed/proc/update_growth_stages()
	if(get_trait(TRAIT_PLANT_ICON))
		growth_stages = SSplants.plant_sprites[get_trait(TRAIT_PLANT_ICON)]
	else
		growth_stages = 0
