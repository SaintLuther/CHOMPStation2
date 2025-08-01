/*
 *	These absorb the functionality of the plant bag, ore satchel, etc.
 *	They use the use_to_pickup, quick_gather, and quick_empty functions
 *	that were already defined in weapon/storage, but which had been
 *	re-implemented in other classes.
 *
 *	Contains:
 *		Generic non-item
 *		Trash Bag
 *		Plastic Bag
 *		Mining Satchel
 *		Plant Bag
 *		Sheet Snatcher
 *		Sheet Snatcher (Cyborg)
 *		Cash Bag
 *		Chemistry Bag
 *		Food Bag
 *		Food Bag (Service Hound)
 *		Evidence Bag
 *
 *	-Sayu
 */


// -----------------------------
//          Generic non-item
// -----------------------------
/obj/item/storage/bag
	allow_quick_gather = 1
	allow_quick_empty = 1
	display_contents_with_number = 0 // UNStABLE AS FuCK, turn on when it stops crashing clients
	use_to_pickup = TRUE
	slot_flags = SLOT_BELT
	drop_sound = 'sound/items/drop/backpack.ogg'
	pickup_sound = 'sound/items/pickup/backpack.ogg'

// -----------------------------
//          Trash bag
// -----------------------------
/obj/item/storage/bag/trash
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "trashbag0"
	item_state_slots = list(slot_r_hand_str = "trashbag", slot_l_hand_str = "trashbag")
	drop_sound = 'sound/items/drop/wrapper.ogg'
	pickup_sound = 'sound/items/pickup/wrapper.ogg'

	w_class = ITEMSIZE_LARGE
	max_w_class = ITEMSIZE_SMALL
	max_storage_space = ITEMSIZE_SMALL * 21
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)

/obj/item/storage/bag/trash/update_icon()
	if(contents.len == 0)
		icon_state = "trashbag0"
	else if(contents.len < 9)
		icon_state = "trashbag1"
	else if(contents.len < 18)
		icon_state = "trashbag2"
	else icon_state = "trashbag3"

/obj/item/storage/bag/trash/holding
	name = "trash bag of holding"
	desc = "The latest and greatest in custodial convenience, a trashbag that is capable of holding vast quantities of garbage."
	icon_state = "bluetrashbag"
	origin_tech = list(TECH_BLUESPACE = 3)
	max_w_class = ITEMSIZE_NORMAL
	max_storage_space = ITEMSIZE_COST_NORMAL * 10 // Slightly less than BoH

/obj/item/storage/bag/trash/holding/update_icon()
	return

// -----------------------------
//        Plastic Bag
// -----------------------------
/obj/item/storage/bag/plasticbag
	name = "plastic bag"
	desc = "It's a very flimsy, very noisy alternative to a bag."
	icon = 'icons/obj/trash.dmi'
	icon_state = "plasticbag"
	drop_sound = 'sound/items/drop/wrapper.ogg'
	pickup_sound = 'sound/items/pickup/wrapper.ogg'

	w_class = ITEMSIZE_LARGE
	max_w_class = ITEMSIZE_SMALL
	can_hold = list() // any
	cant_hold = list(/obj/item/disk/nuclear)

// -----------------------------
//        Mining Satchel
// -----------------------------
/*
 * Mechoid - Orebags are the most common quick-gathering thing, and also have tons of lag associated with it.
 * Their checks are going to be hyper-simplified due to this, and their INCREDIBLY singular target contents.
 */
/obj/item/storage/bag/ore
	name = "mining satchel"
	desc = "This little bugger can be used to store and transport ores."
	icon = 'icons/obj/mining.dmi'
	icon_state = "satchel"
	slot_flags = SLOT_BELT | SLOT_POCKET
	w_class = ITEMSIZE_NORMAL
	max_storage_space = ITEMSIZE_COST_NORMAL * 25
	max_w_class = ITEMSIZE_NORMAL
	allow_quick_empty = FALSE
	can_hold = list(/obj/item/ore)
	var/current_capacity = 0
	var/max_pickup = 100 //How much ore can be picked up in one go. There to prevent someone from walking on a turf with 10000 ore and making the server cry.
	var/list/stored_ore = list(
		ORE_SAND = 0,
		ORE_HEMATITE = 0,
		ORE_CARBON = 0,
		ORE_COPPER = 0,
		ORE_TIN = 0,
		ORE_VOPAL = 0,
		ORE_PAINITE = 0,
		ORE_QUARTZ = 0,
		ORE_BAUXITE = 0,
		ORE_PHORON = 0,
		ORE_SILVER = 0,
		ORE_GOLD = 0,
		ORE_MARBLE = 0,
		ORE_URANIUM = 0,
		ORE_DIAMOND = 0,
		ORE_PLATINUM = 0,
		ORE_LEAD = 0,
		ORE_MHYDROGEN = 0,
		ORE_VERDANTIUM = 0,
		ORE_RUTILE = 0)
	var/last_update = 0

/obj/item/storage/bag/ore/holding
	name = "mining satchel of holding"
	desc = "Like a mining satchel, but when you put your hand in, you're pretty sure you can feel time itself."
	icon_state = "satchel_bspace"
	max_storage_space = ITEMSIZE_COST_NORMAL * 15000 // This should never, ever, ever be reached.

/obj/item/storage/bag/ore/attackby(obj/item/W as obj, mob/user as mob)
	if(current_capacity >= max_storage_space)
		to_chat(user, span_notice("\the [src] is too full to possibly fit anything else inside of it."))
		return

	if (istype(W, /obj/item/ore) && !istype(W, /obj/item/ore/slag))
		var/obj/item/ore/ore = W
		stored_ore[ore.material]++
		current_capacity++
		user.remove_from_mob(W)
		qdel(ore)

/obj/item/storage/bag/ore/remove_from_storage(obj/item/W as obj, atom/new_location)
	if(!istype(W)) return 0

	if(new_location)
		if(ismob(loc))
			W.dropped(usr)
		if(ismob(new_location))
			W.hud_layerise()
		else
			W.reset_plane_and_layer()
		W.forceMove(new_location)
	else
		W.forceMove(get_turf(src))

	W.on_exit_storage(src)
	update_icon()
	return 1

/obj/item/storage/bag/ore/gather_all(turf/T as turf, mob/user as mob, var/silent = 0)
	var/success = 0
	var/failure = 0
	var/current_pickup = 0
	var/max_pickup_reached = 0
	for(var/obj/item/ore/O in T) //Only ever grabs ores. Doesn't do any extraneous checks, as all ore is the same size. Tons of checks means it causes hanging for up to three seconds.
		if(current_capacity >= max_storage_space)
			failure = 1
			break
		if(current_pickup >= max_pickup)
			max_pickup_reached = 1
			break
		if(istype(O, /obj/item/ore/slag))
			continue
		var/obj/item/ore/ore = O
		stored_ore[ore.material]++
		current_capacity++
		current_pickup++
		qdel(ore)
		success = 1
	if(!silent) //Let's do a single check and then do more instead of a bunch at once.
		if(success && !failure && !max_pickup_reached) //Picked stuff up, did not reach capacity, did not reach max_pickup.
			to_chat(user, span_notice("You put everything in [src]."))
		else if(success && failure) //Picked stuff up to capacity.
			to_chat(user, span_notice("You fill the [src]."))
		else if(success && max_pickup_reached) //Picked stuff up to the max_pickup
			to_chat(user, span_notice("You fill the [src] with as much as you can grab in one go."))
		else //Failed. The bag is full.
			to_chat(user, span_notice("You fail to pick anything up with \the [src]."))
	if(istype(user.pulling, /obj/structure/ore_box)) //Bit of a crappy way to do this, as it doubles spam for the user, but it works. //Then let me fix it. ~CL.
		var/obj/structure/ore_box/OB = user.pulling
		for(var/ore in stored_ore)
			if(stored_ore[ore] > 0)
				var/ore_amount = stored_ore[ore]	// How many ores does the satchel have?
				OB.stored_ore[ore] += ore_amount	// Add the ore to the box
				stored_ore[ore] = 0 				// Set the value of the ore in the satchel to 0.
				current_capacity = 0				// Set the amount of ore in the satchel to 0.
	current_pickup = 0

/obj/item/storage/bag/ore/equipped(mob/user)
	..()
	user.AddComponent(/datum/component/recursive_move)
	RegisterSignal(user, COMSIG_OBSERVER_MOVED, /obj/item/storage/bag/ore/proc/autoload, user)

/obj/item/storage/bag/ore/dropped(mob/user)
	..()
	UnregisterSignal(user, COMSIG_OBSERVER_MOVED)

/obj/item/storage/bag/ore/proc/autoload(mob/user)
	SIGNAL_HANDLER
	var/obj/item/ore/O = locate() in get_turf(src)
	if(O)
		gather_all(get_turf(src), user)

/obj/item/storage/bag/ore/proc/rangedload(atom/A, mob/user)
	var/obj/item/ore/O = locate() in get_turf(A)
	if(O)
		gather_all(get_turf(A), user)

/obj/item/storage/bag/ore/examine(mob/user)
	. = ..()

	if(!Adjacent(user)) //Can only check the contents of ore bags if you can physically reach them.
		return .

	if(isliving(user))
		add_fingerprint(user)

	. += span_notice("It holds:")
	var/has_ore = 0
	for(var/ore in stored_ore)
		if(stored_ore[ore] > 0)
			. += span_notice("- [stored_ore[ore]] [ore]")
			has_ore = 1
	if(!has_ore)
		. += "Nothing."

/obj/item/storage/bag/ore/open(mob/user as mob) //No opening it for the weird UI of having shit-tons of ore inside it.
	user.examinate(src)

// -----------------------------
//          Plant bag
// -----------------------------
/obj/item/storage/bag/plants
	name = "plant bag"
	icon = 'icons/obj/hydroponics_machines_vr.dmi'
	icon_state = "plantbag"
	desc = "A sturdy bag used to transport fresh produce with ease."
	max_storage_space = ITEMSIZE_COST_NORMAL * 25
	max_w_class = ITEMSIZE_NORMAL
	w_class = ITEMSIZE_SMALL
	can_hold = list(/obj/item/reagent_containers/food/snacks/grown,/obj/item/seeds,/obj/item/grown)

/obj/item/storage/bag/plants/large
	name = "large plant bag"
	icon_state = "large_plantbag"
	desc = "A large and sturdy bag used to transport fresh produce with ease."
	max_storage_space = ITEMSIZE_COST_NORMAL * 50

// -----------------------------
//        Sheet Snatcher
// -----------------------------
// Because it stacks stacks, this doesn't operate normally.
// However, making it a storage/bag allows us to reuse existing code in some places. -Sayu

/obj/item/storage/bag/sheetsnatcher
	name = "sheet snatcher"
	icon = 'icons/obj/mining.dmi'
	icon_state = "sheetsnatcher"
	desc = "A patented storage system designed for any kind of mineral sheet."

	var/capacity = 500 //the number of sheets it can carry.
	w_class = ITEMSIZE_NORMAL
	storage_slots = 7

	allow_quick_empty = 1 // this function is superceded

/obj/item/storage/bag/sheetsnatcher/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(!istype(W,/obj/item/stack/material))
		if(!stop_messages)
			to_chat(usr, "The snatcher does not accept [W].")
		return 0
	var/current = 0
	for(var/obj/item/stack/material/S in contents)
		current += S.get_amount()
	if(capacity == current)//If it's full, you're done
		if(!stop_messages)
			to_chat(usr, span_warning("The snatcher is full."))
		return 0
	return 1


// Modified handle_item_insertion.  Would prefer not to, but...
/obj/item/storage/bag/sheetsnatcher/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	var/obj/item/stack/material/S = W
	if(!istype(S)) return 0

	var/amount
	var/inserted = 0
	var/current = 0
	for(var/obj/item/stack/material/S2 in contents)
		current += S2.get_amount()
	if(capacity < current + S.get_amount())//If the stack will fill it up
		amount = capacity - current
	else
		amount = S.get_amount()

	for(var/obj/item/stack/material/sheet in contents)
		if(S.type == sheet.type)
			// we are violating the amount limitation because these are not sane objects
			sheet.set_amount(sheet.get_amount() + amount, TRUE)
			S.use(amount) // will qdel() if we use it all
			inserted = 1
			break

	if(!inserted)
		if(capacity < current + S.get_amount())
			var/obj/item/stack/F = S.split(amount)
			F.loc = src
		else
			usr.remove_from_mob(S)
			if (usr.client && usr.s_active != src)
				usr.client.screen -= S
			S.dropped(usr)
			S.loc = src

	orient2hud(usr)
	if(usr.s_active)
		usr.s_active.show_to(usr)
	update_icon()
	return 1

// Sets up numbered display to show the stack size of each stored mineral
// NOTE: numbered display is turned off currently because it's broken
/obj/item/storage/bag/sheetsnatcher/orient2hud(mob/user as mob)
	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/stack/material/I in contents)
			adjusted_contents++
			var/datum/numbered_display/D = new/datum/numbered_display(I)
			D.number = I.get_amount()
			numbered_contents.Add( D )

	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if (adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	src.slot_orient_objs(row_num, col_count, numbered_contents)
	return

// Modified quick_empty verb drops appropriate sized stacks
/obj/item/storage/bag/sheetsnatcher/quick_empty()
	var/location = get_turf(src)
	for(var/obj/item/stack/material/S in contents)
		var/cur_amount = S.get_amount()
		var/full_stacks = round(cur_amount / S.max_amount) // Floor of current/max is amount of full stacks we make
		var/remainder = cur_amount % S.max_amount // Current mod max is remainder after full sheets removed
		for(var/i = 1 to full_stacks)
			new S.type(location, S.max_amount)
		if(remainder)
			new S.type(location, remainder)
		S.set_amount(0)
	orient2hud(usr)
	if(usr.s_active)
		usr.s_active.show_to(usr)
	update_icon()

// Instead of removing
/obj/item/storage/bag/sheetsnatcher/remove_from_storage(obj/item/W as obj, atom/new_location)
	var/obj/item/stack/material/S = W
	if(!istype(S)) return 0

	//I would prefer to drop a new stack, but the item/attack_hand code
	// that calls this can't recieve a different object than you clicked on.
	//Therefore, make a new stack internally that has the remainder.
	// -Sayu

	if(S.get_amount() > S.max_amount)
		var/newstack_amt = S.get_amount() - S.max_amount
		new S.type(src, newstack_amt) // The one we'll keep to replace the one we give
		S.set_amount(S.max_amount) // The one we hand to the clicker

	return ..(S,new_location)

// -----------------------------
//    Sheet Snatcher (Bluespace)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/holding
	name = "sheet snatcher of holding"
	icon_state = "sheetsnatcher_bspace"
	desc = "A patented storage system designed for any kind of mineral sheet, this one has been upgraded with bluespace technology to allow it to carry ten times as much."

	capacity = 5000 //Should be far more than enough.

// -----------------------------
//    Sheet Snatcher (Cyborg)
// -----------------------------

/obj/item/storage/bag/sheetsnatcher/borg
	name = "sheet snatcher 9000"
	desc = null
	capacity = 700//Borgs get more because >specialization

// -----------------------------
//           Cash Bag
// -----------------------------

/obj/item/storage/bag/cash
	name = "cash bag"
	icon = 'icons/obj/storage.dmi'
	icon_state = "cashbag"
	desc = "A bag for carrying lots of cash. It's got a big dollar sign printed on the front."
	max_storage_space = ITEMSIZE_COST_NORMAL * 25
	max_w_class = ITEMSIZE_NORMAL
	w_class = ITEMSIZE_SMALL
	can_hold = list(/obj/item/coin,/obj/item/spacecash,/obj/item/spacecasinocash)

// -----------------------------
//         Chemistry Bag
// -----------------------------
/obj/item/storage/bag/chemistry
	name = "chemistry bag"
	icon = 'icons/obj/storage_vr.dmi'
	icon_state = "chembag"
	desc = "A bag for storing pills, patches, and bottles."
	max_storage_space = 200
	w_class = ITEMSIZE_LARGE
	slowdown = 1 //you probably shouldn't be running with chemicals
	can_hold = list(/obj/item/reagent_containers/pill,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/hypospray/autoinjector/) // CHOMPEdit - Adds autoinjectors to the bag

// -----------------------------
//           Xeno Bag
// -----------------------------
/obj/item/storage/bag/xeno
	name = "xenobiology bag"
	icon = 'icons/obj/storage_vr.dmi'
	icon_state = "xenobag"
	desc = "A bag for storing various slime products."
	max_storage_space = ITEMSIZE_COST_SMALL * 12
	max_w_class = ITEMSIZE_NORMAL
	w_class = ITEMSIZE_SMALL
	can_hold = list(/obj/item/slime_extract,/obj/item/slimepotion, /obj/item/reagent_containers/food/snacks/monkeycube)

// -----------------------------
//         Virology Bag
// -----------------------------
/obj/item/storage/bag/virology
	name = "virology bag"
	icon = 'icons/obj/storage_vr.dmi'
	icon_state = "biobag"
	desc = "A bag for storing various biological products."
	max_storage_space = ITEMSIZE_COST_SMALL * 12
	max_w_class = ITEMSIZE_NORMAL
	w_class = ITEMSIZE_SMALL
	can_hold = list(/obj/item/reagent_containers/glass/beaker/vial/)

// -----------------------------
//           Food Bag
// -----------------------------
/obj/item/storage/bag/food
	name = "food bag"
	icon = 'icons/obj/storage_vr.dmi'
	icon_state = "foodbag"
	desc = "A bag for storing foods of all kinds."
	max_storage_space = ITEMSIZE_COST_NORMAL * 25
	max_w_class = ITEMSIZE_NORMAL
	w_class = ITEMSIZE_SMALL
	can_hold = list(/obj/item/reagent_containers/food/snacks,/obj/item/reagent_containers/food/condiment)

// -----------------------------
//    Food Bag (Service Hound)
// -----------------------------
/obj/item/storage/bag/serviceborg
	name = "service bag"
	icon = 'icons/obj/storage_vr.dmi'
	icon_state = "foodbag"
	desc = "An intergrated bag for storing things of all kinds."
	max_storage_space = ITEMSIZE_COST_NORMAL * 25
	max_w_class = ITEMSIZE_NORMAL
	w_class = ITEMSIZE_SMALL
	can_hold = list(/obj/item/reagent_containers/food/snacks,/obj/item/reagent_containers/food/condiment,
	/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/glass/bottle,/obj/item/coin,/obj/item/spacecash,
	/obj/item/reagent_containers/food/snacks/grown,/obj/item/seeds,/obj/item/grown,/obj/item/reagent_containers/pill)

// -----------------------------
//           Evidence Bag
// -----------------------------
/obj/item/storage/bag/detective
	name = "secure satchel"
	icon = 'icons/obj/storage_vr.dmi'
	icon_state = "detbag"
	desc = "A bag for storing investigation things. You know, securely."
	max_storage_space = ITEMSIZE_COST_NORMAL * 15
	max_w_class = ITEMSIZE_NORMAL
	w_class = ITEMSIZE_SMALL
	can_hold = list(/obj/item/forensics/swab,/obj/item/sample/print,/obj/item/sample/fibers,/obj/item/evidencebag)
