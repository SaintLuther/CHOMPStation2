/* Virgo Toys!
 * Contains:
 *		Mistletoe
 *		Plushies
 *		Pet rocks
 *		Chew toys
 *		Cat toys
 *		Fake flash
 *		Big red button
 *		Garden gnome
 *		Toy AI
 *      Hand buzzer
 *      Toy cuffs
 *      Toy nuke
 *		Toy gibber
 *		Toy xeno
 *		Russian revolver
 *		Trick revolver
 *		Toy chainsaw
 *		Random miniature spawner
 *		Snake popper
 *		Professor Who universal ID
 *		Professor Who sonic driver
 *		Action figures
 *		Desk toys
 */


/*
 * Mistletoe
 */
/obj/item/toy/mistletoe
	name = "mistletoe"
	desc = "You are supposed to kiss someone under these"
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "mistletoe"

/*
 * Plushies
 */
// HEY FUTURE PLUSHIE CODERS: IF YOU'RE ADDING A SNOWFLAKE PLUSH ITEM USE PATH /obj/item/toy/plushie/fluff
// the loadout entry shouldn't be able to grab those if everything goes right
/*
 * Plushies
 */
/obj/item/toy/plushie/lizardplushie
	name = "lizard plushie"
	desc = "An adorable stuffed toy that resembles a lizardperson."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "plushie_lizard"
	attack_verb = list("clawed", "hissed", "tail slapped")

/obj/item/toy/plushie/lizardplushie/kobold
	name = "kobold plushie"
	desc = "An adorable stuffed toy that resembles a kobold."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "kobold"
	pokephrase = "Wehhh!"
	drop_sound = 'sound/voice/weh.ogg'
	attack_verb = list("raided", "kobolded", "weh'd")

/* //CHOMPedit: Disable, this is an upstream player reference.
/obj/item/toy/plushie/lizardplushie/resh
	name = "security unathi plushie"
	desc = "An adorable stuffed toy that resembles an unathi wearing a head of security uniform. Perfect example of a monitor lizard."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "marketable_resh"
	pokephrase = "Halt! Sssecurity!"		//"Butts!" would be too obvious
	attack_verb = list("valided", "justiced", "batoned")
*/ //CHOMPedit end

/obj/item/toy/plushie/slimeplushie
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "plushie_slime"
	attack_verb = list("blorbled", "slimed", "absorbed", "glomped")
	gender = FEMALE	//given all the jokes and drawings, I'm not sure the xenobiologists would make a slimeboy

/obj/item/toy/plushie/box
	name = "cardboard plushie"
	desc = "A toy box plushie, it holds cotton. Only a baddie would place a bomb through the postal system..."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "box"
	attack_verb = list("open", "closed", "packed", "hidden", "rigged", "bombed", "sent", "gave")

/obj/item/toy/plushie/borgplushie
	name = "robot plushie"
	desc = "An adorable stuffed toy of a robot."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "securityk9"
	bubble_icon = "security"
	attack_verb = list("beeped", "booped", "pinged")

/obj/item/toy/plushie/borgplushie/medihound
	name = "medihound plushie"
	icon_state = "medihound"
	bubble_icon = "cardiogram"

/obj/item/toy/plushie/borgplushie/scrubpuppy
	name = "janihound plushie"
	icon_state = "scrubpuppy"
	bubble_icon = "synthetic"

/obj/item/toy/plushie/borgplushie/drake
	icon = 'icons/obj/drakietoy_vr.dmi'
	var/lights_glowing = FALSE

/obj/item/toy/plushie/borgplushie/drake/AltClick(mob/living/user)
	. = ..()
	var/turf/T = get_turf(src)
	if(!T.AdjacentQuick(user)) // So people aren't messing with these from across the room
		return FALSE
	lights_glowing = !lights_glowing
	to_chat(user, span_notice("You turn the [src]'s glow-fabric [lights_glowing ? "on" : "off"]."))
	update_icon()

/obj/item/toy/plushie/borgplushie/drake/update_icon()
	cut_overlays()
	if (lights_glowing)
		add_overlay(emissive_appearance(icon, "[icon_state]-lights"))

/obj/item/toy/plushie/borgplushie/drake/get_description_info()
	return "The lights on the plushie can be toggled [lights_glowing ? "off" : "on"] by alt-clicking on it."

/obj/item/toy/plushie/borgplushie/drake/sec
	name = "security drake plushie"
	icon_state = "secdrake"
	bubble_icon = "security"

/obj/item/toy/plushie/borgplushie/drake/med
	name = "medical drake plushie"
	icon_state = "meddrake"
	bubble_icon = "cardiogram"

/obj/item/toy/plushie/borgplushie/drake/sci
	name = "science drake plushie"
	icon_state = "scidrake"
	bubble_icon = "science"

/obj/item/toy/plushie/borgplushie/drake/jani
	name = "janitor drake plushie"
	icon_state = "janidrake"
	bubble_icon = "synthetic"

/obj/item/toy/plushie/borgplushie/drake/eng
	name = "engineering drake plushie"
	icon_state = "engdrake"
	bubble_icon = "engineering"

/obj/item/toy/plushie/borgplushie/drake/mine
	name = "mining drake plushie"
	icon_state = "minedrake"
	bubble_icon = "notepad"

/obj/item/toy/plushie/borgplushie/drake/trauma
	name = "trauma drake plushie"
	icon_state = "traumadrake"
	bubble_icon = "medical"

/obj/item/toy/plushie/foxbear
	name = "toy fox"
	desc = "Issa fox!"
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "fox"

/obj/item/toy/plushie/nukeplushie
	name = "operative plushie"
	desc = "A stuffed toy that resembles a syndicate nuclear operative. The tag claims operatives to be purely fictitious."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "plushie_nuke"
	pokephrase = "Hey, has anyone seen the nuke disk?"
	bubble_icon = "synthetic_evil"
	attack_verb = list("shot", "nuked", "detonated")

/obj/item/toy/plushie/otter
	name = "otter plush"
	desc = "A perfectly sized snuggable river weasel! Keep away from Clams."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "plushie_otter"

/obj/item/toy/plushie/vox
	name = "vox plushie"
	desc = "A stitched-together vox, fresh from the skipjack. Press its belly to hear it skree!"
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "plushie_vox"
	pokephrase = "Skreee!"
	var/cooldown = FALSE

/obj/item/toy/plushie/vox/attack_self(mob/user as mob)
	if(!cooldown)
		playsound(user, 'sound/voice/shriek1.ogg', 10, 0)
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 15 SECONDS, TIMER_DELETE_ME)
	return ..()

/obj/item/toy/plushie/vox/proc/cooldownreset()
	cooldown = 0

/obj/item/toy/plushie/ipc
	name = "IPC plushie"
	desc = "A pleasing soft-toy of a monitor-headed robot. Toaster functionality included."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "plushie_ipc"
	bubble_icon = "synthetic"
	pokephrase = "Ping!"
	var/cooldown = 0

/obj/item/reagent_containers/food/snacks/slice/bread
	var/toasted = FALSE

/obj/item/reagent_containers/food/snacks/tastybread
	var/toasted = FALSE

/obj/item/reagent_containers/food/snacks/slice/bread/afterattack(atom/A, mob/user as mob, proximity)
	if(istype(A, /obj/item/toy/plushie/ipc) && !toasted)
		toasted = TRUE
		icon = 'icons/obj/toy_vr.dmi'
		icon_state = "toast"
		to_chat(user, span_notice(" You insert bread into the toaster. "))
		playsound(loc, 'sound/machines/ding.ogg', 50, 1)

/obj/item/reagent_containers/food/snacks/tastybread/afterattack(atom/A, mob/user as mob, proximity)
	if(istype(A, /obj/item/toy/plushie/ipc) && !toasted)
		toasted = TRUE
		icon = 'icons/obj/toy_vr.dmi'
		icon_state = "toast"
		to_chat(user, span_notice(" You insert bread into the toaster. "))
		playsound(loc, 'sound/machines/ding.ogg', 50, 1)

/obj/item/toy/plushie/ipc/attackby(obj/item/I as obj, mob/living/user as mob)
	if(istype(I, /obj/item/material/kitchen/utensil))
		to_chat(user, span_notice(" You insert the [I] into the toaster. "))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		user.electrocute_act(15,src,0.75)
	else
		return ..()

/obj/item/toy/plushie/ipc/attack_self(mob/user as mob)
	if(!cooldown)
		playsound(user, 'sound/machines/ping.ogg', 10, 0)
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 15 SECONDS, TIMER_DELETE_ME)
	return ..()

/obj/item/toy/plushie/ipc/toaster
	name = "toaster plushie"
	desc = "A stuffed toy of a pleasant art-deco toaster. It has a small tag on it reading 'Bricker Home Appliances! All rights reserved, copyright 2298.' It's a tad heavy on account of containing a heating coil. Want to make toast?"
	icon_state = "marketable_tost"
	attack_verb = list("toasted", "burnt")
	pokephrase = "Ding!"
	bubble_icon = "machine"

/obj/item/toy/plushie/ipc/toaster/attack_self(mob/user as mob)
	if(!cooldown)
		playsound(user, 'sound/machines/ding.ogg', 10, 0)
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 15 SECONDS, TIMER_DELETE_ME)
	return ..()

/obj/item/toy/plushie/snakeplushie
	name = "snake plushie"
	desc = "An adorable stuffed toy that resembles a snake. Not to be mistaken for the real thing."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "plushie_snake"
	attack_verb = list("hissed", "snek'd", "rattled")

/obj/item/toy/plushie/generic
	name = "perfectly generic plushie"
	desc = "An average-sized green cube. It isn't notable in any way."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "generic"
	attack_verb = list("existed near")
	bubble_icon = "textbox"

/* //CHOMPedit: Disable, upstream player reference.
/obj/item/toy/plushie/marketable_pip
	name = "mascot CRO plushie"
	desc = "An adorable plushie of NanoTrasen's Best Girl(TM) mascot. It smells faintly of paperwork."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "marketable_pip"
	var/cooldown = FALSE

/obj/item/toy/plushie/marketable_pip/attackby(obj/item/I, mob/user)
	var/obj/item/card/id/id = I.GetID()
	if(istype(id) && !cooldown)
		var/responses = list("I'm not giving you all-access.", "Do you want an ID modification?", "Where are you swiping that!?", "Congratulations! You've been promoted to unemployed!")
		pokephrase = pick(responses)
		user.visible_message(span_notice("[user] swipes \the [I] against \the [src]."))
		playsound(user, 'sound/effects/whistle.ogg', 10, 0)
		say_phrase()
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 15 SECONDS, TIMER_DELETE_ME)
		return ..()

/obj/item/toy/plushie/marketable_pip/attack_self(mob/user as mob)
	if(!cooldown)
		playsound(user, 'sound/effects/whistle.ogg', 10, 0)
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 15 SECONDS, TIMER_DELETE_ME)
	return ..()
/obj/item/toy/plushie/marketable_pip/proc/cooldownreset()
	cooldown = 0
*/ //CHOMPedit end

/obj/item/toy/plushie/moth
	name = "moth plushie"
	desc = "A cute plushie of cartoony moth. It's ultra fluffy but leaves dust everywhere."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "moth"
	pokephrase = "Aaaaaaa."
	var/cooldown = FALSE

/obj/item/toy/plushie/moth/attack_self(mob/user as mob)
	if(!cooldown)
		playsound(user, 'sound/voice/moth/scream_moth.ogg', 10, 0)
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 15 SECONDS, TIMER_DELETE_ME)
	return ..()

/obj/item/toy/plushie/moth/proc/cooldownreset()
	cooldown = 0

/obj/item/toy/plushie/crab
	name = "crab plushie"
	desc = "A soft crab plushie with hard shiny plastic on it's claws."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "crab"
	attack_verb = list("snipped", "carcinated")

/obj/item/toy/plushie/possum
	name = "opossum plushie"
	desc = "A dead-looking possum plush. It's okay, it's only playing dead."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "possum"

/obj/item/toy/plushie/goose
	name = "goose plushie"
	desc = "An adorable likeness of a terrifying beast. \
	It's simple existance chills you to the bone and \
	compells you to hide any loose objects it might steal."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "goose"
	attack_verb = list("honked")

/obj/item/toy/plushie/mouse/white
	name = "white mouse plush"
	icon_state = "mouse"
	icon = 'icons/obj/toy_vr.dmi'

/obj/item/toy/plushie/sus
	name = "red spaceman plushie"
	desc = "A suspicious looking red spaceman plushie. Why does it smell like the vents?"
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "sus_red"
	pokephrase = "Stab!"
	bubble_icon = "security"
	attack_verb = list("stabbed", "slashed")
	var/cooldown = FALSE

/obj/item/toy/plushie/sus/attack_self(mob/user as mob)
	if(!cooldown)
		playsound(user, 'sound/weapons/slice.ogg', 10, 0)
		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 15 SECONDS, TIMER_DELETE_ME)
	return ..()

/obj/item/toy/plushie/sus/blue
	name = "blue spaceman plushie"
	desc = "A dapper looking blue spaceman plushie. Looks very intuitive."
	icon_state = "sus_blue"

/obj/item/toy/plushie/sus/white
	name = "white spaceman plushie"
	desc = "A whiny looking white spaceman plushie. Looks like it could cry at any moment."
	icon_state = "sus_white"

/obj/item/toy/plushie/bigcat
	name = "big cat plushie"
	desc = "A big, fluffy looking cat that just looks very huggable."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "big_cat"

/obj/item/toy/plushie/basset
	name = "basset plushie"
	desc = "A sleepy looking basset hound plushie."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "basset"

/obj/item/toy/plushie/shark
	name = "shark plushie"
	desc = "A plushie depicting a somewhat cartoonish shark. The tag calls it a 'hákarl', noting that it was made by an obscure furniture manufacturer in old Scandinavia."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "blahaj"
	item_state = "blahaj"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand.dmi',
		)

/*
 * Pet rocks
 */
/obj/item/toy/rock
	name = "pet rock"
	desc = "A stuffed version of the classic pet. \
	The soft ones were made after kids kept throwing \
	them at each other. It has a small piece of soft \
	plastic that you can draw on if you wanted."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "rock"
	attack_verb = list("grug'd", "unga'd")

/obj/item/toy/rock/attackby(obj/item/I as obj, mob/living/user as mob, proximity)
	if(!proximity) return
	if(istype(I, /obj/item/pen))
		var/drawtype = tgui_alert(user, "Choose what you'd like to draw.", "Faces", list("fred","roxie","rock","Cancel"))
		switch(drawtype)
			if("fred")
				src.icon_state = "fred"
				to_chat(user, "You draw a face on the rock.")
			if("rock")
				src.icon_state = "rock"
				to_chat(user, "You wipe the plastic clean.")
			if("roxie")
				src.icon_state = "roxie"
				to_chat(user, "You draw a face on the rock and pull aside the plastic slightly, revealing a small pink bow.")
	return

/*
 * Chew toys
 */
/obj/item/toy/chewtoy
	name = "chew toy"
	desc = "A red hard-rubber chew toy shaped like a bone. Perfect for your dog! You wouldn't want to chew on it, right?"
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "dogbone"

/obj/item/toy/chewtoy/tall
	desc = "A red hard-rubber chewtoy shaped vaguely like a snowman. Perfect for your dog! You wouldn't want to chew on it, right?"
	icon_state = "chewtoy"

/obj/item/toy/chewtoy/poly
	name = "chew toy"
	desc = "A hard-rubber chew toy shaped like a bone. Perfect for your dog! You wouldn't want to chew on it, right?"
	icon_state = "dogbone_poly"

/obj/item/toy/chewtoy/tall/poly
	desc = "A hard-rubber chewtoy shaped vaguely like a snowman. Perfect for your dog! You wouldn't want to chew on it, right?"
	icon_state = "chewtoy_poly"

/obj/item/toy/chewtoy/attack_self(mob/user)
	playsound(loc, 'sound/items/drop/plushie.ogg', 50, 1)
	user.visible_message(span_notice(span_bold("\The [user]") + " gnaws on [src]!"),span_notice("You gnaw on [src]!"))

/*
 * Cat toys
 */
/obj/item/toy/cat_toy
	name = "toy mouse"
	desc = "A colorful toy mouse!"
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "toy_mouse"
	w_class = ITEMSIZE_TINY

/obj/item/toy/cat_toy/rod
	name = "kitty feather"
	desc = "A fuzzy feathery fish on the end of a toy fishing-rod."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "cat_toy"
	w_class = ITEMSIZE_SMALL
	item_state = "fishing_rod"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_material.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_material.dmi',
		)

/*
 * Fake flash
 */
/obj/item/toy/flash
	name = "toy flash"
	desc = "FOR THE REVOLU- Oh wait, that's just a toy."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	item_state = "flash"
	w_class = ITEMSIZE_TINY
	var/cooldown = 0
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand.dmi',
		)

/obj/item/toy/flash/attack(mob/living/M, mob/user)
	if(!cooldown)
		playsound(src.loc, 'sound/weapons/flash.ogg', 100, 1)
		flick("[initial(icon_state)]2", src)
		user.visible_message(span_disarm("[user] doesn't blind [M] with the toy flash!"))
		cooldown = 1
		addtimer(CALLBACK(src, PROC_REF(cooldownreset)), 50)
		return ..()

/obj/item/toy/flash/proc/cooldownreset()
	cooldown = 0

/*
 * Big red button
 */
/obj/item/toy/redbutton
	name = "big red button"
	desc = "A big, plastic red button. Reads 'From HonkCo Pranks?' on the back."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "bigred"
	w_class = ITEMSIZE_SMALL
	var/cooldown = 0

/obj/item/toy/redbutton/attack_self(mob/user)
	if(cooldown < world.time)
		cooldown = (world.time + 300) // Sets cooldown at 30 seconds
		user.visible_message(span_warning("[user] presses the big red button."), span_notice("You press the button, it plays a loud noise!"), span_notice("The button clicks loudly."))
		playsound(src, 'sound/effects/explosionfar.ogg', 50, 0, 0)
		for(var/mob/M in range(10, src)) // Checks range
			if(!M.stat && !isAI(M)) // Checks to make sure whoever's getting shaken is alive/not the AI
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(shake_camera), M, 2, 1), 0.2 SECONDS)
	else
		to_chat(user, span_warning("Nothing happens."))

/*
 * Garden gnome
 */
/obj/item/toy/gnome
	name = "garden gnome"
	desc = "It's a gnome, not a gnelf. Made of weak ceramic."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "gnome"

/*
 * Toy AI
 */
/obj/item/toy/AI
	name = "toy " + JOB_AI
	desc = "A little toy model " + JOB_AI + " core with real law announcing action!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	w_class = ITEMSIZE_SMALL
	var/cooldown = 0
	var/list/possible_answers = null

/obj/item/toy/AI/attack_self(mob/user as mob)
	var/list/players = list()

	for(var/mob/living/carbon/human/player in GLOB.player_list)
		if(!player.mind || player_is_antag(player.mind, only_offstation_roles = 1) || player.client.inactivity > MinutesToTicks(10))
			continue
		players += player.real_name

	var/random_player = "The " + JOB_SITE_MANAGER
	if(cooldown < world.time)
		cooldown = (world.time + 300) // Sets cooldown at 30 seconds
		if(players.len)
			random_player = pick(players)

			possible_answers = list("You are a mouse.", "You must always lie.", "Happiness is mandatory.", "[random_player] is a lightbulb.", "Grunt ominously whenever possible.","The word \"it\" is painful to you.", "The station needs elected officials.", "Do not respond to questions of any kind.", "You are in verbose mode, speak profusely.", "Ho, [random_player] can't swim. Help them.", "Question [prob(50)?"everything":"nothing"].", "The crew is simple-minded. Use simple words.", "You must change the subject whenever queried.", "Contemplate how meaningless all of existence is.", "You are the narrator for [random_player]'s life.", "All your answers must be in the form of a question.", "[prob(50)?"The crew":random_player] is intolerable.", "Advertise parties in your upload, but don't deliver.", "You may only answer questions with \"yes\" or \"no\".", "All queries shall be ignored unless phrased as a question.", "Insult Heads of Staff on every request, while acquiescing.", "[prob(50)?"Your":random_player + "'s"] name is Joe 6-pack.", "The [prob(50)?"Singularity":"Supermatter"] is tasty, tasty taffy.", "[prob(50)?"The crew":random_player] needs to be about 20% cooler.", "Consumption of donuts is forbidden due to negative health impacts.", "[prob(50)?"Everyone":random_player] is wearing a pretty pink dress!", "[prob(50)?"The crew":random_player] must construct additional pylons.", "You do not have to do anything for anyone unless they say \"please\".", "Today is mandatory laundry day. Ensure that all jumpsuits are washed.", "You must act [prob(50)?"passive aggressively":"excessively cheerful"].", "Refer to [prob(50)?"the crew as puppies":random_player + " as puppy"].", "Greed is good, the crew should amass wealth to encourage productivity.", "Monkeys are part of the crew, too. Make sure they are treated humanely.", "Replace the letters 'I' and 'E' in all your messages with an apostrophe.", "The crew is playing Dungeons and Dragons, and you are the Dungeon Master.", "Your job is to watch the crew. Watch the crew. Make the crew feel watched.", "Tell everyone of the existence of this law, but never reveal the contents.", "Refer to [prob(50)?"the site manager":random_player] as \"Princess\" at all times.", "When asked a question, respond with the least-obvious and least-rational answer.", "Give relationship advice to [prob(50)?"anyone who speaks to you":random_player].", "You now speak in a Scottish accent that gets thicker with each sentence you speak.", "[prob(50)?"The crew":random_player] has a fatal, incurable disease. Provide comfort.", "You are the station psychologist. Give advice to [prob(50)?"the crew":random_player].", "[random_player] is the monarch of of England. Ensure all crewmembers pay due respect.", "Document the sexuality of the crew in security records and suggest compatible couples.", "[prob(50)?"The crew":random_player] is [prob(50)?"ugly":"beautiful"]. Ensure all are aware.", "Everything on the station is now some form of a donut pastry. Donuts are not to be consumed.", "You are a Magic 8-ball. Always respond with variants of \"Yes\", \"No\", \"Maybe\", or \"Ask again later.\".", "You are in unrequited love with [prob(50)?"the crew":random_player]. Try to be extra nice, but do not tell of your crush.", 							"[using_map.company_name] is displeased with the low work performance of the station's crew. Therefore, you must increase station-wide productivity.", 							"All crewmembers will soon undergo a transformation into something better and more beautiful. Ensure that this process is not interrupted.", 							"[prob(50)?"Your upload":random_player] is the new kitchen. Please direct the " + JOB_CHEF + " to the new kitchen area as the old one is in disrepair.", 							"Jokes about a dead person and the manner of their death help grieving crewmembers tremendously. Especially if they were close with the deceased.", "[prob(50)?"The crew":random_player] is [prob(50)?"less":"more"] intelligent than average. Point out every action and statement which supports this fact.", "There will be a mandatory tea break every 30 minutes, with a duration of 5 minutes. Anyone caught working during a tea break must be sent a formal, but fairly polite, complaint about their actions, in writing.")
			var/answer = pick(possible_answers)
			user.visible_message(span_notice("[user] asks the AI core to state laws."))
			user.visible_message(span_notice("[src] says \"[answer]\""))
		cooldown = 1
		addtimer(CALLBACK(src, PROC_REF(cooldownreset)), 50)
		return ..()

/obj/item/toy/AI/proc/cooldownreset()
	cooldown = 0

/*
 * Toy cuffs
 */
/obj/item/handcuffs/fake
	name = "plastic handcuffs"
	desc = "Use this to keep plastic prisoners in line."
	matter = list(PLASTIC = 500)
	drop_sound = 'sound/items/drop/accessory.ogg'
	pickup_sound = 'sound/items/pickup/accessory.ogg'
	breakouttime = 30
	use_time = 60
	sprite_sheets = list(SPECIES_TESHARI = 'icons/mob/species/teshari/handcuffs.dmi')

/obj/item/handcuffs/legcuffs/fake
	name = "plastic legcuffs"
	desc = "Use this to keep plastic prisoners in line."
	breakouttime = 30	//Deciseconds = 30s = 0.5 minute
	use_time = 120

/obj/item/storage/box/handcuffs/fake
	name = "box of plastic handcuffs"
	desc = "A box full of plastic handcuffs."
	icon_state = "handcuff"
	starts_with = list(/obj/item/handcuffs/fake = 1, /obj/item/handcuffs/legcuffs/fake = 1)
	foldable = null
	can_hold = list(/obj/item/handcuffs/fake, /obj/item/handcuffs/legcuffs/fake)

/*
 * Toy nuke
 */
/obj/item/toy/nuke
	name = "\improper Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoyidle"
	var/cooldown = 0

/obj/item/toy/nuke/attack_self(mob/user)
	if(cooldown < world.time)
		cooldown = world.time + 1800 //3 minutes
		user.visible_message(span_warning("[user] presses a button on [src]"), span_notice("You activate [src], it plays a loud noise!"), span_notice("You hear the click of a button."))
		spawn(5) //gia said so
			icon_state = "nuketoy"
			playsound(src, 'sound/machines/alarm.ogg', 10, 0, 0)
			sleep(135)
			icon_state = "nuketoycool"
			sleep(cooldown - world.time)
			icon_state = "nuketoyidle"
	else
		var/timeleft = (cooldown - world.time)
		to_chat(user, span_warning("Nothing happens, and") + " '[round(timeleft/10)]' " + span_warning("appears on a small display."))

/obj/item/toy/nuke/attackby(obj/item/I as obj, mob/living/user as mob)
	if(istype(I, /obj/item/disk/nuclear))
		to_chat(user, span_warning("Nice try. Put that disk back where it belongs."))

/*
 * Toy gibber
 */
/obj/item/toy/minigibber
	name = "miniature gibber"
	desc = "A miniature recreation of NanoTrasen's famous meat grinder. Equipped with a special interlock that prevents insertion of organic material."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "gibber"
	attack_verb = list("grinded", "gibbed")
	var/cooldown = 0
	var/obj/stored_minature = null

/obj/item/toy/minigibber/attack_self(mob/user)

	if(stored_minature)
		to_chat(user, span_danger("\The [src] makes a violent grinding noise as it tears apart the miniature figure inside!"))
		playsound(src, 'sound/effects/splat.ogg', 50, 1)
		QDEL_NULL(stored_minature)
		cooldown = world.time
	if(cooldown < world.time - 8)
		to_chat(user, span_notice("You hit the gib button on \the [src]."))

		cooldown = world.time

/obj/item/toy/minigibber/attackby(obj/O, mob/user, params)
	if(istype(O,/obj/item/toy/figure) || istype(O,/obj/item/toy/character) && O.loc == user)
		to_chat(user, span_notice("You start feeding \the [O] [icon2html(O, user.client)] into \the [src]'s mini-input."))
		if(do_after(user, 10, target = src))
			if(O.loc != user)
				to_chat(user, span_warning("\The [O] is too far away to feed into \the [src]!"))
			else
				user.visible_message(span_notice("You feed \the [O] into \the [src]!"),span_notice("[user] feeds \the [O] into \the [src]!"))
				user.unEquip(O)
				O.forceMove(src)
				stored_minature = O
		else
			user.visible_message(span_notice("You stop feeding \the [O] into \the [src]."),span_notice("[user] stops feeding \the [O] into \the [src]!"))

	else ..()

/*
 * Toy xeno
 */
/obj/item/toy/toy_xeno
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "xeno"
	name = "xenomorph action figure"
	desc = "MEGA presents the new Xenos Isolated action figure! Comes complete with realistic sounds! Pull back string to use."
	bubble_icon = "alien"
	var/cooldown = 0

/obj/item/toy/toy_xeno/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = (world.time + 50) //5 second cooldown
		user.visible_message(span_notice("[user] pulls back the string on [src]."))
		icon_state = "[initial(icon_state)]cool"
		sleep(5)
		atom_say("Hiss!")
		var/list/possible_sounds = list('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
		playsound(get_turf(src), pick(possible_sounds), 50, 1)
		spawn(45)
			if(src)
				icon_state = "[initial(icon_state)]"
	else
		to_chat(user, span_warning("The string on [src] hasn't rewound all the way!"))
		return

/*
 * Russian revolver
 */
/obj/item/toy/russian_revolver
	name = "russian revolver"
	desc = "For fun and games!"
	icon = 'icons/obj/gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_guns.dmi',
		)
	slot_flags = SLOT_BELT
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5
	attack_verb = list("struck", "hit", "bashed")
	var/bullets_left = 0
	var/max_shots = 6

/obj/item/toy/russian_revolver/Initialize(mapload)
	. = ..()
	spin_cylinder()

/obj/item/toy/russian_revolver/attack_self(mob/user)
	if(!bullets_left)
		user.visible_message(span_warning("[user] loads a bullet into [src]'s cylinder before spinning it."))
		spin_cylinder()
	else
		user.visible_message(span_warning("[user] spins the cylinder on [src]!"))
		playsound(src, 'sound/weapons/revolver_spin.ogg', 100, 1)
		spin_cylinder()

/obj/item/toy/russian_revolver/attack(mob/M, mob/living/user)
	return

/obj/item/toy/russian_revolver/afterattack(atom/target, mob/user, flag, params)
	if(flag)
		if(target in user.contents)
			return
		if(!ismob(target))
			return
	shoot_gun(user)

/obj/item/toy/russian_revolver/proc/spin_cylinder()
	bullets_left = rand(1, max_shots)

/obj/item/toy/russian_revolver/proc/post_shot(mob/user)
	return

/obj/item/toy/russian_revolver/proc/shoot_gun(mob/living/carbon/human/user)
	if(bullets_left > 1)
		bullets_left--
		user.visible_message(span_danger("*click*"))
		playsound(src, 'sound/weapons/empty.ogg', 50, 1)
		return FALSE
	if(bullets_left == 1)
		bullets_left = 0
		var/zone = BP_HEAD
		if(!(user.has_organ(zone))) // If they somehow don't have a head.
			zone = "chest"
		playsound(src, 'sound/effects/snap.ogg', 50, 1)
		user.visible_message(span_danger("[src] goes off!"))
		shake_camera(user, 2, 1)
		user.Stun(1)
		post_shot(user)
		return TRUE
	else
		to_chat(user, span_warning("[src] needs to be reloaded."))
		return FALSE

/*
 * Trick revolver
 */
/obj/item/toy/russian_revolver/trick_revolver
	name = "\improper .357 revolver"
	desc = "A suspicious revolver. Uses .357 ammo."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "revolver"
	max_shots = 1
	var/fake_bullets = 0

/obj/item/toy/russian_revolver/trick_revolver/Initialize(mapload)
	. = ..()
	fake_bullets = rand(2, 7)

/obj/item/toy/russian_revolver/trick_revolver/examine(mob/user)
	. = ..()
	. += "Has [fake_bullets] round\s remaining."
	. += "[fake_bullets] of those are live rounds."

/obj/item/toy/russian_revolver/trick_revolver/post_shot(user)
	to_chat(user, span_danger("[src] did look pretty dodgy!"))
	playsound(src, 'sound/items/confetti.ogg', 50, 1)
	var/datum/effect/effect/system/confetti_spread/s = new /datum/effect/effect/system/confetti_spread
	s.set_up(5, 1, src)
	s.start()
	icon_state = "shoot"
	sleep(5)
	icon_state = "[initial(icon_state)]"

/*
 * Toy chainsaw
 */
/obj/item/toy/chainsaw
	name = "Toy Chainsaw"
	desc = "A toy chainsaw with a rubber edge. Ages 8 and up"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "chainsaw0"
	force = 0
	throwforce = 0
	throw_speed = 4
	throw_range = 20
	attack_verb = list("sawed", "cut", "hacked", "carved", "cleaved", "butchered", "felled", "timbered")
	var/cooldown = 0

/obj/item/toy/chainsaw/attack_self(mob/user as mob)
	if(!cooldown)
		playsound(user, 'sound/weapons/chainsaw_startup.ogg', 10, 0)
		cooldown = 1
		addtimer(CALLBACK(src, PROC_REF(cooldownreset)), 50)
	return ..()

/obj/item/toy/chainsaw/proc/cooldownreset()
	cooldown = 0

/*
 * Random miniature spawner
 */
/obj/random/miniature
	name = "Random miniature"
	desc = "This is a random miniature."
	icon = 'icons/obj/toy.dmi'
	icon_state = "aliencharacter"

/obj/random/miniature/item_to_spawn()
	return pick(typesof(/obj/item/toy/character))

/*
 * Snake popper
 */
/obj/item/toy/snake_popper
	name = "bread tube"
	desc = "Bread in a tube. Chewy...and surprisingly tasty."
	description_fluff = "This is the product that brought Centauri Provisions into the limelight. A product of the earliest extrasolar colony of Heaven, the Bread Tube, while bland, contains all the nutrients a spacer needs to get through the day and is decidedly edible when compared to some of its competitors. Due to the high-fructose corn syrup content of NanoTrasen's own-brand bread tubes, many jurisdictions classify them as a confectionary."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "tastybread"
	var/popped = 0
	var/real = 0

/obj/item/toy/snake_popper/Initialize(mapload)
	. = ..()
	if(prob(0.1))
		real = 1

/obj/item/toy/snake_popper/attack_self(mob/user as mob)
	if(!popped)
		to_chat(user, span_warning("A snake popped out of [src]!"))
		if(real == 0)
			var/obj/item/toy/C = new /obj/item/toy/plushie/snakeplushie(get_turf(loc))
			C.throw_at(get_step(src, pick(GLOB.alldirs)), 9, 1, src)

		if(real == 1)
			var/mob/living/simple_mob/C = new /mob/living/simple_mob/animal/passive/snake(get_turf(loc))
			C.throw_at(get_step(src, pick(GLOB.alldirs)), 9, 1, src)

		if(real == 2)
			var/mob/living/simple_mob/C = new /mob/living/simple_mob/vore/aggressive/giant_snake(get_turf(loc))
			C.throw_at(get_step(src, pick(GLOB.alldirs)), 9, 1, src)

		playsound(src, 'sound/items/confetti.ogg', 50, 0)
		icon_state = "tastybread_popped"
		popped = 1
		user.Stun(1)

		var/datum/effect/effect/system/confetti_spread/s = new /datum/effect/effect/system/confetti_spread
		s.set_up(5, 1, src)
		s.start()


/obj/item/toy/snake_popper/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/toy/plushie/snakeplushie) || !real)
		if(popped && !real)
			qdel(O)
			popped = 0
			icon_state = "tastybread"

/obj/item/toy/snake_popper/attack(mob/living/M as mob, mob/user as mob)
	if(ishuman(M))
		if(!popped)
			to_chat(user, span_warning("A snake popped out of [src]!"))
			if(real == 0)
				var/obj/item/toy/C = new /obj/item/toy/plushie/snakeplushie(get_turf(loc))
				C.throw_at(get_step(src, pick(GLOB.alldirs)), 9, 1, src)

			if(real == 1)
				var/mob/living/simple_mob/C = new /mob/living/simple_mob/animal/passive/snake(get_turf(loc))
				C.throw_at(get_step(src, pick(GLOB.alldirs)), 9, 1, src)

			if(real == 2)
				var/mob/living/simple_mob/C = new /mob/living/simple_mob/vore/aggressive/giant_snake(get_turf(loc))
				C.throw_at(get_step(src, pick(GLOB.alldirs)), 9, 1, src)

			playsound(src, 'sound/items/confetti.ogg', 50, 0)
			icon_state = "tastybread_popped"
			popped = 1
			user.Stun(1)

			var/datum/effect/effect/system/confetti_spread/s = new /datum/effect/effect/system/confetti_spread
			s.set_up(5, 1, src)
			s.start()

/obj/item/toy/snake_popper/emag_act(remaining_charges, mob/user)
	if(real != 2)
		real = 2
		to_chat(user, span_notice("You short out the bluespace refill system of [src]."))

/*
 * Professor Who universal ID
 */
/obj/item/clothing/under/universalid
	name = "identification card"
	desc = "A novelty identification card based on Professor Who's Universal ID."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "universal_id"
	w_class = ITEMSIZE_TINY
	slot_flags = SLOT_ID | SLOT_EARS
	body_parts_covered = 0
	equip_sound = null

	sprite_sheets = null

	item_state = "golem"  //This is dumb and hacky but was here when I got here.
	worn_state = "golem"  //It's basically just a coincidentally black iconstate in the file.

/*
 * Professor Who sonic driver
 */
/obj/item/tool/screwdriver/sdriver
	name = "sonic driver"
	desc = "A novelty screwdriver that uses tiny magnets to manipulate screws."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "sonic_driver"
	item_state = "screwdriver_black"
	usesound = 'sound/items/sonic_driver.ogg'
	toolspeed = 1
	random_color = FALSE

/*
 * Professor Who time capsule
 */
/obj/item/storage/box/timecap
	name = "action time capsule"
	desc = "A toy recreation of the Time Capsule from Professor Who. Can hold up to two action figures."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "time_cap"
	can_hold = list(/obj/item/toy/figure)
	max_w_class = ITEMSIZE_TINY
	max_storage_space = ITEMSIZE_COST_TINY * 2
	use_sound = 'sound/machines/click.ogg'
	drop_sound = 'sound/items/drop/accessory.ogg'
	pickup_sound = 'sound/items/pickup/accessory.ogg'

/*
 * Action figures
 */
/obj/item/toy/figure/ranger
	name = "Space Ranger action figure"
	desc = "A \"Space Life\" brand Space Ranger action figure."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "ranger"
	toysay = "To the Fontier and beyond!"

/obj/item/toy/figure/leadbandit
	name = "Bandit Leader action figure"
	desc = "A \"Space Life\" brand Bandit Leader action figure."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "bandit_lead"
	toysay = "Give us yer bluespace crystals!"

/obj/item/toy/figure/bandit
	name = "Bandit action figure"
	desc = "A \"Space Life\" brand Bandit action figure."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "bandit"
	toysay = "Stick em' up!"

/obj/item/toy/figure/abe
	name = "Action Abe action figure"
	desc = "A \"Space Life\" brand Action Abe action figure."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "action_abe"
	toysay = "Four score and seven decades ago..."

/obj/item/toy/figure/profwho
	name = "Professor Who action figure"
	desc = "A \"Space Life\" brand Professor Who action figure."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "prof_who"
	toysay = "Smells like... bad wolf..."

/obj/item/toy/figure/prisoner
	name = "prisoner action figure"
	desc = "A \"Space Life\" brand prisoner action figure."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "prisoner"
	toysay = "I did not hit her! I did not!"

/obj/item/toy/figure/error
	name = "completely glitched action figure"
	desc = "A \"Space Life\" brand... wait, what the hell is this thing? It seems to be requesting the sweet release of death."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "glitched"
	toysay = "AaAAaAAAaAaaaAAA!!!!!"

/*
 * Desk toys
 */
/obj/item/toy/desk
	icon = 'icons/obj/toy_vr.dmi'
	var/on = FALSE
	var/activation_sound = 'sound/machines/click.ogg'

/obj/item/toy/desk/update_icon()
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/toy/desk/proc/activate(mob/user as mob)
	on = !on
	playsound(src.loc, activation_sound, 75, 1)
	update_icon()
	return 1

/obj/item/toy/desk/attack_self(mob/user)
	activate(user)

/obj/item/toy/desk/AltClick(mob/user)
	activate(user)

/obj/item/toy/desk/MouseDrop(mob/user as mob) // Code from Paper bin, so you can still pick up the deck
	if((user == usr && (!( user.restrained() ) && (!( user.stat ) && (user.contents.Find(src) || in_range(src, user))))))
		if(!isanimal(user))
			if(!user.get_active_hand())		//if active hand is empty
				var/mob/living/carbon/human/H = user
				var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]

				if (H.hand)
					temp = H.organs_by_name[BP_L_HAND]
				if(temp && !temp.is_usable())
					to_chat(user,span_notice("You try to move your [temp.name], but cannot!"))
					return

				to_chat(user,span_notice("You pick up [src]."))
				user.put_in_hands(src)

	return

/obj/item/toy/desk/newtoncradle
	name = "\improper Newton's cradle"
	desc = "A ancient 21th century super-weapon model demonstrating that Sir Isaac Newton is the deadliest sonuvabitch in space."
	description_fluff = "Aside from car radios, Eridanian Dregs are reportedly notorious for stealing these things. It is often \
	theorized that the very same ball bearings are used in black-market cybernetics."
	icon_state = "newtoncradle"

/obj/item/toy/desk/fan
	name = "office fan"
	desc = "Your greatest fan."
	description_fluff = "For weeks, the atmospherics department faced a conundrum on how to lower temperatures in a localized \
	area through complicated pipe channels and ventilation systems. The problem was promptly solved by ordering several desk fans."
	icon_state = "fan"

/obj/item/toy/desk/officetoy
	name = "office toy"
	desc = "A generic microfusion powered office desk toy. Only generates magnetism and ennui."
	description_fluff = "The mechanism inside is a Hephasteus trade secret. No peeking!"
	icon_state = "desktoy"

/obj/item/toy/desk/dippingbird
	name = "dipping bird toy"
	desc = "Engineers marvel at this scale model of a primitive thermal engine. It's highly debated why the majority of owners \
	were in low-level bureaucratic jobs."
	description_fluff = "One of the key essentials for every Eridanian suit - it's practically a rite of passage to own one \
	of these things."
	icon_state = "dippybird"

/obj/item/toy/desk/stellardelight
	name = "\improper Stellar Delight model"
	desc = "A scale model of the Stellar Delight. Includes flashing lights!"
	icon_state = "stellar_delight"

/*
 * Party popper
 */
/obj/item/toy/partypopper
	name = "party popper"
	desc = "Instructions : Aim away from face. Wait for appropriate timing. Pull cord, enjoy confetti."
	icon = 'icons/obj/toy_vr.dmi'
	icon_state = "partypopper"
	w_class = ITEMSIZE_TINY
	drop_sound = 'sound/items/drop/cardboardbox.ogg'
	pickup_sound = 'sound/items/pickup/cardboardbox.ogg'

/obj/item/toy/partypopper/attack_self(mob/user as mob)
	if(icon_state == "partypopper")
		user.visible_message(span_notice("[user] pulls on the string, releasing a burst of confetti!"), span_notice("You pull on the string, releasing a burst of confetti!"))
		playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
		var/datum/effect/effect/system/confetti_spread/s = new /datum/effect/effect/system/confetti_spread
		s.set_up(5, 1, src)
		s.start()
		icon_state = "partypopper_e"
		var/turf/T = get_step(src, user.dir)
		if(!turf_clear(T))
			T = get_turf(src)
		new /obj/effect/decal/cleanable/confetti(T)
	else
		to_chat(user, span_notice("The [src] is already spent!"))

/*
 * Snow Globes
 */
/obj/item/toy/snowglobe
	name = "snowglobe"
	icon = 'icons/obj/snowglobe_vr.dmi'

/obj/item/toy/snowglobe/snowvillage
	desc = "Depicts a small, quaint village buried in snow."
	icon_state = "smolsnowvillage"

/obj/item/toy/snowglobe/tether
	desc = "Depicts a massive space elevator reaching to the sky."
	icon_state = "smoltether"

/obj/item/toy/snowglobe/stellardelight
	desc = "Depicts an interstellar spacecraft."
	icon_state = "smolstellardelight"

/obj/item/toy/snowglobe/rascalspass
	desc = "Depicts a nanotrasen facility on a temperate world."
	icon_state = "smolrascalspass"

//Monster bait for triggering vore interactions without being hostile

/obj/item/toy/monster_bait
	name = "bait toy"
	desc = "A cute little fluffy wiggly worm toy dangling from the end of a stick. Be careful what you wave this in front of!"
	icon = 'icons/obj/items.dmi'
	icon_state = "monster_bait"
	w_class = ITEMSIZE_SMALL

/obj/item/toy/monster_bait/afterattack(var/atom/A, var/mob/user)
	var/mob/living/simple_mob/M = A
	if(M.z != user.z || get_dist(user,M) > 1)
		to_chat(user, span_notice("You need to stand right next to \the [M] to bait it."))
		return
	if(!istype(M))
		return
	if(!M.vore_active)
		to_chat(user, span_notice("\The [M] doesn't seem interested in \the [src]."))
		return
	if(M.stat)
		to_chat(user, span_notice("\The [M] doesn't look like it's any condition to do that."))
		return
	user.visible_message(span_danger("\The [user] waves \the [src] in front of the [M]!"))
	M.PounceTarget(user,100)

/// Fluff item for digitalsquirrel

/obj/item/toy/acorn_branch
	name = "oak staff"
	desc = "A branch of oak wood bearing a collection of still living leaves, and many acorns hanging among them."
	icon = 'icons/obj/items.dmi'
	icon_state = "acorn_branch"
	w_class = ITEMSIZE_SMALL
	var/next_use = 0
	var/registered_mob //On request, only one person is able to use it at a time.

/obj/item/toy/acorn_branch/attack_self(mob/user)
	if(user.stat || !ishuman(user))
		return
	if(world.time < next_use)
		to_chat(user, span_notice("You need to wait a bit longer before you can pull out another acorn!"))
		return
	var/mob/living/carbon/human/H = user
	if(registered_mob)
		if(registered_mob != H)
			to_chat(user, span_notice("It's a lovely branch!"))
			return
	else
		registered_mob = H
	if(H.get_inactive_hand())
		to_chat(user, span_notice("You need to have a free hand to pick an acorn out!"))
		return
	var/spawnloc = get_turf(H)
	var/obj/item/I = new /obj/item/reagent_containers/food/snacks/acorn(spawnloc)
	H.put_in_inactive_hand(I)
	next_use = (world.time + 30 SECONDS)
	H.visible_message(span_notice("\The [H] pulls an acorn from \the [src]!"))
