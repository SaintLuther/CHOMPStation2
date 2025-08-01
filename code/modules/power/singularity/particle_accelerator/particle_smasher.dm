/*
 * Contains the particle smasher and its recipes.
 */

#define PS_RESULT_STACK		"stack"
#define PS_RESULT_ITEM		"item"

/obj/machinery/particle_smasher
	name = "Particle Focus"
	desc = "A strange device used to create exotic matter."
	icon = 'icons/obj/machines/particle_smasher.dmi'
	icon_state = "smasher"
	anchored = FALSE
	density = TRUE
	use_power = USE_POWER_OFF

	var/successful_craft = FALSE	// Are we waiting to be emptied?
	var/image/material_layer	// Holds the image used for the filled overlay.
	var/image/material_glow		// Holds the image used for the glow overlay.
	var/image/reagent_layer		// Holds the image used for showing a contained beaker.
	var/energy = 0				// How many 'energy' units does this have? Acquired by a Particle Accelerator like a Singularity.
	var/max_energy = 600
	var/obj/item/stack/material/target	// The material being bombarded.
	var/obj/item/reagent_containers/reagent_container		// Holds the beaker. The process will consume ALL reagents inside it.
	var/beaker_type = /obj/item/reagent_containers/glass/beaker
	var/list/storage		// Holds references to items allowed to be used in the fabrication phase.
	var/max_storage = 3	// How many items can be jammed into it?
	var/list/recipes	// The list containing the Particle Smasher's recipes.

/obj/machinery/particle_smasher/Initialize(mapload)
	. = ..()
	storage = list()
	update_icon()
	prepare_recipes()

/obj/machinery/particle_smasher/Destroy()
	for(var/datum/particle_smasher_recipe/D in recipes)
		qdel(D)
	recipes.Cut()
	. = ..()

/obj/machinery/particle_smasher/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += span_notice("\The [src] contains:")
		for(var/obj/item/I in contents)
			. += span_notice("\the [I]")

/obj/machinery/particle_smasher/atmosanalyze(var/mob/user)
	return list(span_notice("\The [src] reads an energy level of [energy]."))

/obj/machinery/particle_smasher/attackby(obj/item/W as obj, mob/user as mob)
	if(W.type == /obj/item/analyzer)
		return
	else if(istype(W, /obj/item/stack/material))
		var/obj/item/stack/material/M = W
		if(M.uses_charge)
			to_chat(user, span_notice("You cannot fill \the [src] with a synthesizer!"))
			return
		target = M.split(1)
		target.forceMove(src)
		update_icon()
	else if(istype(W, beaker_type))
		if(reagent_container)
			to_chat(user, span_notice("\The [src] already has a container attached."))
			return
		if(isrobot(user) && istype(W.loc, /obj/item/gripper))
			var/obj/item/gripper/G = W.loc
			G.drop_item()
		else
			user.drop_from_inventory(W)
		reagent_container = W
		reagent_container.forceMove(src)
		to_chat(user, span_notice("You add \the [reagent_container] to \the [src]."))
		update_icon()
		return
	else if(W.has_tool_quality(TOOL_WRENCH))
		anchored = !anchored
		playsound(src, W.usesound, 75, 1)
		if(anchored)
			user.visible_message("[user.name] secures [src.name] to the floor.", \
				"You secure the [src.name] to the floor.", \
				"You hear a ratchet.")
		else
			user.visible_message("[user.name] unsecures [src.name] from the floor.", \
				"You unsecure the [src.name] from the floor.", \
				"You hear a ratchet.")
		update_icon()
		return
	else if(istype(W, /obj/item/card/id))
		to_chat(user, span_notice("Swiping \the [W] on \the [src] doesn't seem to do anything..."))
		return ..()
	else if(((isrobot(user) && istype(W.loc, /obj/item/gripper)) || (!isrobot(user) && W.canremove)) && storage.len < max_storage)
		if(isrobot(user) && istype(W.loc, /obj/item/gripper))
			var/obj/item/gripper/G = W.loc
			G.drop_item()
		else
			user.drop_from_inventory(W)
		W.forceMove(src)
		storage += W
	else
		return ..()

/obj/machinery/particle_smasher/update_icon()
	cut_overlays()
	if(!material_layer)
		material_layer = image(icon, "[initial(icon_state)]-material")
	if(!material_glow)
		material_glow = image(icon, "[initial(icon_state)]-material-glow")
		material_glow.plane = PLANE_LIGHTING_ABOVE
	if(!reagent_layer)
		reagent_layer = image(icon, "[initial(icon_state)]-reagent")
	if(anchored)
		icon_state = "[initial(icon_state)]-o"
		if(target)
			material_layer.color = target.material.icon_colour
			add_overlay(material_layer)
			if(successful_craft)
				material_glow.color = target.material.icon_colour
				add_overlay(material_glow)
		if(reagent_container)
			add_overlay(reagent_layer)
	else
		icon_state = initial(icon_state)

	if(target && energy)
		var/power_percent = round((energy / max_energy) * 100)
		light_color = target.material.icon_colour
		switch(power_percent)
			if(0 to 25)
				light_range = 1
			if(26 to 50)
				light_range = 2
			if(51 to 75)
				light_range = 3
			if(76 to INFINITY)
				light_range = 4
		set_light(light_range, 2, light_color)
	else
		set_light(0, 0, "#FFFFFF")

/obj/machinery/particle_smasher/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj, /obj/item/projectile/beam))
		if(Proj.damage >= 50)
			TryCraft()
	return 0

/obj/machinery/particle_smasher/process()
	if(!src.anchored)	// Rapidly loses focus.
		if(energy)
			SSradiation.radiate(src, round(((src.energy-150)/50)*5,1))
			energy = max(0, energy - 30)
			update_icon()
		return

	if(energy)
		SSradiation.radiate(src, round(((src.energy-150)/50)*5,1))
		energy = CLAMP(energy - 5, 0, max_energy)

	return

/obj/machinery/particle_smasher/proc/prepare_recipes()
	if(!recipes)
		recipes = list()
		for(var/D in subtypesof(/datum/particle_smasher_recipe))
			recipes += new D
	else
		for(var/datum/particle_smasher_recipe/D in recipes)
			qdel(D)
		recipes.Cut()
		for(var/D in subtypesof(/datum/particle_smasher_recipe))
			recipes += new D

/obj/machinery/particle_smasher/proc/TryCraft()

	if(!recipes || !recipes.len)
		recipes = typesof(/datum/particle_smasher_recipe)

	if(!target)	// You are just blasting an empty machine.
		visible_message(span_infoplain(span_bold("\The [src]") + " shudders."))
		update_icon()
		return

	if(successful_craft)
		visible_message(span_warning("\The [src] fizzles."))
		if(prob(33))	// Why are you blasting it after it's already done!
			SSradiation.radiate(src, 10 + round(src.energy / 60, 1))
			energy = max(0, energy - 30)
		update_icon()
		return

	var/list/possible_recipes = list()
	var/max_prob = 0
	for(var/datum/particle_smasher_recipe/R in recipes)	// Only things for the smasher. Don't get things like the chef's cake recipes.
		if(R.probability)	// It's actually a recipe you're supposed to be able to make.
			if(!(R.required_material) || istype(target, R.required_material))
				if(energy >= R.required_energy_min && energy <= R.required_energy_max)	// The machine has enough Vaguely Defined 'Energy'.
					var/turf/T = get_turf(src)
					var/datum/gas_mixture/environment = T.return_air()
					if(environment.temperature >= R.required_atmos_temp_min && environment.temperature <= R.required_atmos_temp_max)	// Too hot, or too cold.
						if(R.reagents && R.reagents.len)
							if(!reagent_container || R.check_reagents(reagent_container.reagents) == -1)	// It doesn't have a reagent storage when it needs it, or it's lacking what is needed.
								continue
						if(R.items && R.items.len)
							if(!(storage && storage.len) || R.check_items(src) == -1)	// It's empty, or it doesn't contain what is needed.
								continue
						possible_recipes += R
						max_prob += R.probability

	if(possible_recipes.len)
		var/local_prob = rand(0, max_prob - 1)%max_prob
		var/cumulative = 0
		for(var/datum/particle_smasher_recipe/R in possible_recipes)
			cumulative += R.probability
			if(local_prob < cumulative)
				successful_craft = TRUE
				DoCraft(R)
				break
	update_icon()

/obj/machinery/particle_smasher/proc/DoCraft(var/datum/particle_smasher_recipe/recipe)
	if(!successful_craft || !recipe)
		return

	qdel(target)
	target = null

	if(reagent_container)
		reagent_container.reagents.clear_reagents()

	if(recipe.items && recipe.items.len)
		for(var/obj/item/I in storage)
			for(var/item_type in recipe.items)
				if(istype(I, item_type) && prob(recipe.item_consume_chance))
					storage -= I
					qdel(I)
					break

	var/result = recipe.result
	if(recipe.recipe_type == PS_RESULT_STACK)
		var/obj/item/stack/material/M = new result(src)
		target = M
	else if(recipe.recipe_type == PS_RESULT_ITEM)
		new result(get_turf(src))
	update_icon()

/obj/machinery/particle_smasher/verb/eject_contents()
	set src in view(1)
	set category = "Object"
	set name = "Eject Particle Focus Contents"

	if(usr.incapacitated())
		return

	DumpContents()

/obj/machinery/particle_smasher/proc/DumpContents()
	target = null
	reagent_container = null
	successful_craft = FALSE
	var/turf/T = get_turf(src)
	for(var/obj/item/I in contents)
		if(I in storage)
			storage -= I
		I.forceMove(T)
	update_icon()

/*
 * The special recipe datums used for the particle smasher.
 */

/datum/particle_smasher_recipe
	var/display_name = ""
	var/list/reagents	// example: = list(REAGENT_ID_PACID = 5)
	var/list/items		// example: = list(/obj/item/tool/crowbar, /obj/item/welder) Place /foo/bar before /foo. Do not include fruit. Maximum of 3 items.
	var/recipe_type = PS_RESULT_STACK			// Are we producing a stack or an item?

	var/result = /obj/item/stack/material/iron		// The sheet this will produce.
	var/required_material = /obj/item/stack/material/iron	// The required material sheet.
	var/required_energy_min = 0			// The minimum energy this recipe can process at.
	var/required_energy_max = 600		// The maximum energy this recipe can process at.
	var/required_atmos_temp_min = 0		// The minimum ambient atmospheric temperature required, in kelvin.
	var/required_atmos_temp_max = 600	// The maximum ambient atmospheric temperature required, in kelvin.
	var/probability = 0					// The probability for the recipe to be produced. 0 will make it impossible.
	var/item_consume_chance = 100		// The probability for the items (not materials) used in the recipe to be consume.
	var/wiki_flag = NONE

/datum/particle_smasher_recipe/proc/check_items(var/obj/container as obj)
	. = 1
	if (items && items.len)
		var/list/checklist = list()
		checklist = items.Copy() // You should really trust Copy
		if(istype(container, /obj/machinery/particle_smasher))
			var/obj/machinery/particle_smasher/machine = container
			for(var/obj/O in machine.storage)
				if(istype(O,/obj/item/reagent_containers/food/snacks/grown))
					continue // Fruit is handled in check_fruit().
				var/found = 0
				for(var/i = 1; i < checklist.len+1; i++)
					var/item_type = checklist[i]
					if (istype(O,item_type))
						checklist.Cut(i, i+1)
						found = 1
						break
				if (!found)
					. = 0
		if (checklist.len)
			. = -1
	return .

/datum/particle_smasher_recipe/proc/check_reagents(var/datum/reagents/avail_reagents)
	. = 1
	for (var/r_r in reagents)
		var/aval_r_amnt = avail_reagents.get_reagent_amount(r_r)
		if (!(abs(aval_r_amnt - reagents[r_r])<0.5)) //if NOT equals
			if (aval_r_amnt>reagents[r_r])
				. = 0
			else
				return -1
	if ((reagents?(reagents.len):(0)) < avail_reagents.reagent_list.len)
		return 0
	return .

/datum/particle_smasher_recipe/deuterium_tritium
	display_name = MAT_TRITIUM + " from " + MAT_DEUTERIUM
	reagents = list(REAGENT_ID_HYDROGEN = 15)

	result = /obj/item/stack/material/tritium
	required_material = /obj/item/stack/material/deuterium

	required_energy_min = 200
	required_energy_max = 400

	required_atmos_temp_max = 200
	probability = 30

/datum/particle_smasher_recipe/verdantium_morphium
	display_name = MAT_MORPHIUM + " from " + MAT_VERDANTIUM
	result = /obj/item/stack/material/morphium
	required_material = /obj/item/stack/material/verdantium

	required_energy_min = 400
	required_energy_max = 500
	probability = 20

/datum/particle_smasher_recipe/plasteel_morphium
	display_name = MAT_MORPHIUM + " from Alien Junk"
	items = list(/obj/item/prop/alien/junk)

	result = /obj/item/stack/material/morphium
	required_material = /obj/item/stack/material/plasteel

	required_energy_min = 100
	required_energy_max = 300
	probability = 10

/datum/particle_smasher_recipe/osmium_lead
	display_name = MAT_OSMIUM + " from " + MAT_LEAD
	reagents = list(REAGENT_ID_TUNGSTEN = 10)

	result = /obj/item/stack/material/lead
	required_material = /obj/item/stack/material/osmium

	required_energy_min = 200
	required_energy_max = 400

	required_atmos_temp_min = 1000
	required_atmos_temp_max = 8000
	probability = 50

/datum/particle_smasher_recipe/phoron_valhollide
	display_name = MAT_VALHOLLIDE + " from " + MAT_PHORON
	reagents = list(REAGENT_ID_PHORON = 10, REAGENT_ID_PACID = 10)

	result = /obj/item/stack/material/valhollide
	required_material = /obj/item/stack/material/phoron

	required_energy_min = 300
	required_energy_max = 500

	required_atmos_temp_min = 1
	required_atmos_temp_max = 100
	probability = 10

/datum/particle_smasher_recipe/valhollide_supermatter
	display_name = MAT_SUPERMATTER + " from " + MAT_VALHOLLIDE
	reagents = list(REAGENT_ID_PHORON = 300)

	result = /obj/item/stack/material/supermatter
	required_material = /obj/item/stack/material/valhollide

	required_energy_min = 575
	required_energy_max = 600

	required_atmos_temp_min = 3000
	required_atmos_temp_max = 10000
	probability = 1

/datum/particle_smasher_recipe/donkpockets_coal
	display_name = "Ruined Donkpocket"
	items = list(/obj/item/reagent_containers/food/snacks/donkpocket)

	recipe_type = PS_RESULT_ITEM

	result = /obj/item/ore/coal
	required_material = null

	required_energy_min = 1
	required_energy_max = 500

	required_atmos_temp_min = 400
	required_atmos_temp_max = 20000
	probability = 90

/datum/particle_smasher_recipe/donkpockets_ascend
	display_name = "Ascended Donkpocket"
	items = list(/obj/item/reagent_containers/food/snacks/donkpocket)
	reagents = list(REAGENT_ID_PHORON = 120)

	recipe_type = PS_RESULT_ITEM

	result = /obj/item/reagent_containers/food/snacks/donkpocket/ascended
	required_material = /obj/item/stack/material/uranium

	required_energy_min = 501
	required_energy_max = 700

	required_atmos_temp_min = 400
	required_atmos_temp_max = 20000
	probability = 20

/datum/particle_smasher_recipe/glamour
	display_name = "Synthesize " + MAT_GLAMOUR
	items = list(/obj/item/glamour_unstable)

	result = /obj/item/stack/material/glamour
	required_material = /obj/item/stack/material/phoron

	required_energy_min = 500
	required_energy_max = 600

	required_atmos_temp_min = 0
	required_atmos_temp_max = 50
	probability = 100
	item_consume_chance = 10 //Allows only a few unstable glamour to be given out to get lots of stable ones.

/datum/particle_smasher_recipe/platinum_lead
	display_name = MAT_LEAD + " from " + MAT_PLATINUM
	reagents = list(REAGENT_ID_TUNGSTEN = 10)

	result = /obj/item/stack/material/lead
	required_material = /obj/item/stack/material/platinum

	required_energy_min = 100
	required_energy_max = 300

	required_atmos_temp_min = 2000
	required_atmos_temp_max = 6000
	probability = 50

/datum/particle_smasher_recipe/uranium_lead
	display_name = MAT_LEAD + " from " + MAT_URANIUM
	reagents = list(REAGENT_ID_TUNGSTEN = 10)

	result = /obj/item/stack/material/lead
	required_material = /obj/item/stack/material/uranium

	required_energy_min = 50
	required_energy_max = 600

	required_atmos_temp_min = 1000
	required_atmos_temp_max = 10000
	probability = 70

/datum/particle_smasher_recipe/uranium_platinum
	display_name = MAT_PLATINUM + " from " + MAT_URANIUM
	reagents = list(REAGENT_ID_TUNGSTEN = 10)

	result = /obj/item/stack/material/platinum
	required_material = /obj/item/stack/material/uranium

	required_energy_min = 600
	required_energy_max = 650

	required_atmos_temp_min = 6000
	required_atmos_temp_max = 10000
	probability = 30

/datum/particle_smasher_recipe/platinum_uranium
	display_name = MAT_URANIUM + " from " + MAT_PLATINUM
	reagents = list(REAGENT_ID_SILICON = 10)

	result = /obj/item/stack/material/uranium
	required_material = /obj/item/stack/material/platinum

	required_energy_min = 600
	required_energy_max = 700

	required_atmos_temp_min = 8000
	required_atmos_temp_max = 12000
	probability = 40

/datum/particle_smasher_recipe/iron_copper
	display_name = MAT_COPPER + " from " + MAT_IRON
	reagents = list(REAGENT_ID_LITHIUM = 10)

	result = /obj/item/stack/material/copper
	required_material = /obj/item/stack/material/iron

	required_energy_min = 100
	required_energy_max = 300

	required_atmos_temp_min = 2000
	required_atmos_temp_max = 6000
	probability = 40

/* Currently missing Tin reagent
/datum/particle_smasher_recipe/copper_gold
	display_name = MAT_GOLD + " from " + MAT_COPPER
	reagents = list(REAGENT_ID_TIN = 10)

	result = /obj/item/stack/material/gold
	required_material = /obj/item/stack/material/copper

	required_energy_min = 200
	required_energy_max = 400

	required_atmos_temp_min = 5000
	required_atmos_temp_max = 8000
	probability = 40
*/

/datum/particle_smasher_recipe/hydrogen_deuterium
	display_name = MAT_DEUTERIUM + " from " + MAT_GRAPHITE
	reagents = list(REAGENT_ID_HYDROGEN = 10)

	result = /obj/item/stack/material/deuterium
	required_material = /obj/item/stack/material/graphite

	required_energy_min = 0
	required_energy_max = 100

	required_atmos_temp_min = 1000
	required_atmos_temp_max = 3000
	probability = 20

/datum/particle_smasher_recipe/carbon_titanium
	display_name = MAT_TITANIUM + " from " + MAT_GRAPHITE
	reagents = list(REAGENT_ID_SULFUR = 10)

	result = /obj/item/stack/material/titanium
	required_material = /obj/item/stack/material/graphite

	required_energy_min = 300
	required_energy_max = 600

	required_atmos_temp_min = 3000
	required_atmos_temp_max = 8000
	probability = 40

/datum/particle_smasher_recipe/tritium_mhydrogen
	display_name = MAT_METALHYDROGEN + " from " + MAT_TRITIUM
	reagents = list(REAGENT_ID_RADIUM = 300)

	result = /obj/item/stack/material/mhydrogen
	required_material = /obj/item/stack/material/tritium

	required_energy_min = 500
	required_energy_max = 550

	required_atmos_temp_min = 7000
	required_atmos_temp_max = 12000
	probability = 20

/datum/particle_smasher_recipe/osmium_platinum
	display_name = MAT_PLATINUM + " from " + MAT_OSMIUM
	reagents = list(REAGENT_ID_TUNGSTEN = 10)

	result = /obj/item/stack/material/platinum
	required_material = /obj/item/stack/material/osmium

	required_energy_min = 400
	required_energy_max = 500

	required_atmos_temp_min = 8000
	required_atmos_temp_max = 10000
	probability = 20

/datum/particle_smasher_recipe/aluminium_iron
	display_name = MAT_IRON + " from " + MAT_ALUMINIUM
	reagents = list(REAGENT_ID_ALUMINIUM = 50)

	result = /obj/item/stack/material/iron
	required_material = /obj/item/stack/material/aluminium

	required_energy_min = 200
	required_energy_max = 300

	required_atmos_temp_min = 1000
	required_atmos_temp_max = 5000
	probability = 30

/datum/particle_smasher_recipe/lead_silver
	display_name = MAT_SILVER + " from " + MAT_LEAD
	reagents = list(REAGENT_ID_RADIUM = 50)

	result = /obj/item/stack/material/silver
	required_material = /obj/item/stack/material/lead

	required_energy_min = 600
	required_energy_max = 700

	required_atmos_temp_min = 8000
	required_atmos_temp_max = 10000
	probability = 30

#undef PS_RESULT_STACK
#undef PS_RESULT_ITEM
