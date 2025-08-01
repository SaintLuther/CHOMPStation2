/mob/living/carbon/Initialize(mapload)
	. = ..()
	//setup reagent holders
	bloodstr = new/datum/reagents/metabolism/bloodstream(500, src)
	ingested = new/datum/reagents/metabolism/ingested(500, src)
	touching = new/datum/reagents/metabolism/touch(500, src)
	reagents = bloodstr
	if (!default_language && species_language)
		default_language = GLOB.all_languages[species_language]

	AddElement(/datum/element/footstep, custom_footstep, 1, -6)

/mob/living/carbon/Life()
	..()

	// Increase germ_level regularly
	if(germ_level < GERM_LEVEL_AMBIENT && prob(30))	//if you're just standing there, you shouldn't get more germs beyond an ambient level
		germ_level++

/mob/living/carbon/Destroy()
	QDEL_NULL(ingested)
	QDEL_NULL(touching)
	// We don't qdel(bloodstr) because it's the same as qdel(reagents)
	bloodstr = null
	return ..()

/mob/living/carbon/rejuvenate()
	bloodstr.clear_reagents()
	ingested.clear_reagents()
	touching.clear_reagents()
	..()
/* VOREStation Edit - Duplicated in our code
/mob/living/carbon/Moved(atom/old_loc, direction, forced = FALSE)
	. = ..()
	if(src.nutrition && src.stat != 2)
		adjust_nutrition(-DEFAULT_HUNGER_FACTOR / 10)
		if(src.m_intent == I_RUN)
			adjust_nutrition(-DEFAULT_HUNGER_FACTOR / 10)

	if((FAT in src.mutations) && src.m_intent == I_RUN && src.bodytemperature <= 360)
		src.bodytemperature += 2

	// Moving around increases germ_level faster
	if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
		germ_level++
*/
/mob/living/carbon/gib()
	for(var/mob/M in src)
		M.loc = src.loc
		for(var/mob/N in viewers(src, null))
			if(N.client)
				N.show_message(span_bolddanger("[M] bursts out of [src]!"), 2)
	..()

/mob/living/carbon/attack_hand(mob/M as mob)
	if(touch_reaction_flags & SPECIES_TRAIT_THORNS)
		if(src != M)
			if(istype(M,/mob/living))
				var/mob/living/L = M
				L.apply_damage(3, BRUTE)
				L.visible_message( \
					span_warning("[L] is hurt by sharp body parts when touching [src]!"), \
					span_warning("[src] is covered in sharp bits and it hurt when you touched them!"), )

	if(!istype(M, /mob/living/carbon)) return

	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if (H.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(H, span_warning("You can't use your [temp.name]"))
			return

	return

//EMP vulnerability for non-synth carbons. could be useful for diona, vox, or others
//the species' emp_sensitivity var needs to be greater than 0 for this to proc, and it defaults to 0 - shouldn't stack with prosthetics/fbps in most cases
//higher sensitivity values incur additional effects, starting with confusion/blinding/knockdown and ending with increasing amounts of damage
//the degree of damage and duration of effects can be tweaked up or down based on the species emp_dmg_mod and emp_stun_mod vars (default 1) on top of tuning the random ranges
/mob/living/carbon/emp_act(severity)
	//pregen our stunning stuff, had to do this seperately or else byond complained. remember that severity falls off with distance based on the source, so we don't need to do any extra distance calcs here.
	var/agony_str = ((rand(4,6)*15)-(15*severity))*species.emp_stun_mod //big ouchies at high severity, causes 0-75 halloss/agony; shotgun beanbags and revolver rubbers do 60
	var/deafen_dur = (rand(9,16)-severity)*species.emp_stun_mod //5-15 deafen, on par with a flashbang
	var/confuse_dur = (rand(4,11)-severity)*species.emp_stun_mod //0-10 wobbliness, on par with a flashbang
	var/weaken_dur = (rand(2,4)-severity)*species.emp_stun_mod //0-3 knockdown, on par with.. you get the idea
	var/blind_dur = (rand(3,6)-severity)*species.emp_stun_mod //0-5 blind
	if(species.emp_sensitivity) //receive warning message and basic effects
		to_chat(src, span_bolddanger("*BZZZT*"))
		switch(severity)
			if(1)
				to_chat(src, span_danger("DANGER: Extreme EM flux detected!"))
			if(2)
				to_chat(src, span_danger("Danger: High EM flux detected!"))
			if(3)
				to_chat(src, span_danger("Warning: Moderate EM flux detected!"))
			if(4)
				to_chat(src, span_danger("Warning: Minor EM flux detected!"))
		if(prob(90-(10*severity))) //50-80% chance to fire an emote. most are harmless, but vomit might reduce your nutrition level which could suck (so the whole thing is padded out with extras)
			src.emote(pick("twitch", "twitch_v", "choke", "pale", "blink", "blink_r", "shiver", "sneeze", "vomit", "gasp", "cough", "drool"))
		//stun effects block, effects vary wildly
		if(species.emp_sensitivity & EMP_PAIN)
			to_chat(src, span_danger("A wave of intense pain washes over you."))
			src.adjustHalLoss(agony_str)
		if(species.emp_sensitivity & EMP_BLIND)
			if(blind_dur >= 1) //don't flash them unless they actually roll a positive blind duration
				src.flash_eyes(3)	//3 allows it to bypass any tier of eye protection, necessary or else sec sunglasses/etc. protect you from this
			Blind(max(0,blind_dur))
		if(species.emp_sensitivity & EMP_DEAFEN)
			src.ear_damage += rand(0,deafen_dur) //this will heal pretty quickly, but spamming them at someone could cause serious damage
			src.ear_deaf = max(src.ear_deaf,deafen_dur)
			src.deaf_loop.start() // CHOMPStation Add: Ear Ringing/Deafness
		if(species.emp_sensitivity & EMP_CONFUSE)
			if(confuse_dur >= 1)
				to_chat(src, span_danger("Oh god, everything's spinning!"))
			Confuse(max(0,confuse_dur))
		if(species.emp_sensitivity & EMP_WEAKEN)
			if(weaken_dur >= 1)
				to_chat(src, span_danger("Your limbs go slack!"))
			Weaken(max(0,weaken_dur))
		//physical damage block, deals (minor-4) 5-15, 10-20, 15-25, 20-30 (extreme-1) of *each* type
		if(species.emp_sensitivity & EMP_BRUTE_DMG)
			src.adjustBruteLoss(rand(25-(severity*5),35-(severity*5)) * species.emp_dmg_mod)
		if(species.emp_sensitivity & EMP_BURN_DMG)
			src.adjustFireLoss(rand(25-(severity*5),35-(severity*5)) * species.emp_dmg_mod)
		if(species.emp_sensitivity & EMP_TOX_DMG)
			src.adjustToxLoss(rand(25-(severity*5),35-(severity*5)) * species.emp_dmg_mod)
		if(species.emp_sensitivity & EMP_OXY_DMG)
			src.adjustOxyLoss(rand(25-(severity*5),35-(severity*5)) * species.emp_dmg_mod)
	..()

/mob/living/carbon/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/def_zone = null, var/stun = 1)
	if(SEND_SIGNAL(src, COMSIG_BEING_ELECTROCUTED, shock_damage, source, siemens_coeff, def_zone, stun) & COMPONENT_CARBON_CANCEL_ELECTROCUTE)
		return 0	// Cancelled by a component
	if(def_zone == BP_L_HAND || def_zone == BP_R_HAND) //Diona (And any other potential plant people) hands don't get shocked.
		if(species.flags & IS_PLANT)
			return 0
	shock_damage *= siemens_coeff
	if (shock_damage<1)
		return 0

	src.apply_damage(0.2 * shock_damage, BURN, def_zone) //shock the target organ
	src.apply_damage(0.4 * shock_damage, BURN, BP_TORSO) //shock the torso more
	src.apply_damage(0.2 * shock_damage, BURN, null) //shock a random part!
	src.apply_damage(0.2 * shock_damage, BURN, null) //shock a random part!

	playsound(src, "sparks", 50, 1, -1)
	if (shock_damage > 15)
		src.visible_message(
			span_warning("[src] was electrocuted[source ? " by the [source]" : ""]!"), \
			span_danger("You feel a powerful shock course through your body!"), \
			span_warning("You hear a heavy electrical crack.") \
		)
	else
		src.visible_message(
			span_warning("[src] was shocked[source ? " by the [source]" : ""]."), \
			span_warning("You feel a shock course through your body."), \
			span_warning("You hear a zapping sound.") \
		)

	if(stun)
		switch(shock_damage)
			if(16 to 20)
				Stun(2)
			if(21 to 25)
				Weaken(2)
			if(26 to 30)
				Weaken(5)
			if(31 to INFINITY)
				Weaken(10) //This should work for now, more is really silly and makes you lay there forever

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, loc)
	s.start()

	return shock_damage

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if (health >= get_crit_point() || on_fire)
		if(src == M && ishuman(src))
			var/mob/living/carbon/human/H = src
			var/datum/gender/T = GLOB.gender_datums[H.get_visible_gender()]
			visible_message( \
				span_notice("[src] examines [T.himself]."), \
				span_notice("You check yourself for injuries.") \
				)

			for(var/obj/item/organ/external/org in H.organs)
				var/list/status = list()
				var/brutedamage = org.brute_dam
				var/burndamage = org.burn_dam
				/*
				if(halloss > 0) //Makes halloss show up as actual wounds on self examine.
					if(prob(30))
						brutedamage += halloss
					if(prob(30))
						burndamage += halloss
				*/
				switch(brutedamage)
					if(1 to 20)
						status += "bruised"
					if(20 to 40)
						status += "wounded"
					if(40 to INFINITY)
						status += "mangled"

				switch(burndamage)
					if(1 to 10)
						status += "numb"
					if(10 to 40)
						status += "blistered"
					if(40 to INFINITY)
						status += "peeling away"

				if(org.is_stump())
					status += "MISSING"
				if(org.status & ORGAN_MUTATED)
					status += "weirdly shapen"
				if(org.dislocated == 1) //VOREStation Edit Bugfix
					status += "dislocated"
				if(org.status & ORGAN_BROKEN)
					status += "hurts when touched"
				if(org.status & ORGAN_DEAD)
					status += "is bruised and necrotic"
				if(!org.is_usable() || org.is_dislocated())
					status += "dangling uselessly"
				if(status.len)
					src.show_message("My [org.name] is " + span_warning("[english_list(status)]."),1)
				else
					src.show_message("My [org.name] is " + span_notice("OK."),1)

			if((SKELETON in H.mutations) && (!H.w_uniform) && (!H.wear_suit))
				H.play_xylophone()
		else if (on_fire)
			playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			if (M.on_fire)
				M.visible_message(span_warning("[M] tries to pat out [src]'s flames, but to no avail!"),
				span_warning("You try to pat out [src]'s flames, but to no avail! Put yourself out first!"))
			else
				M.visible_message(span_warning("[M] tries to pat out [src]'s flames!"),
				span_warning("You try to pat out [src]'s flames! Hot!"))
				if(do_mob(M, src, 15))
					src.adjust_fire_stacks(-0.5)
					if (prob(10) && (M.fire_stacks <= 0))
						M.adjust_fire_stacks(1)
					M.IgniteMob()
					if (M.on_fire)
						M.visible_message(span_danger("The fire spreads from [src] to [M]!"),
						span_danger("The fire spreads to you as well!"))
					else
						src.adjust_fire_stacks(-0.5) //Less effective than stop, drop, and roll - also accounting for the fact that it takes half as long.
						if (src.fire_stacks <= 0)
							M.visible_message(span_warning("[M] successfully pats out [src]'s flames."),
							span_warning("You successfully pat out [src]'s flames."))
							src.ExtinguishMob()
							src.fire_stacks = 0
		else
			if (ishuman(src) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)

			var/show_ssd
			var/mob/living/carbon/human/H = src
			var/datum/gender/T = GLOB.gender_datums[H.get_visible_gender()] // make sure to cast to human before using get_gender() or get_visible_gender()!
			if(istype(H)) show_ssd = H.species.show_ssd
			if(show_ssd && !client && !teleop)
				M.visible_message(span_notice("[M] shakes [src] trying to wake [T.him] up!"), \
				span_notice("You shake [src], but [T.he] [T.does] not respond... Maybe [T.he] [T.has] S.S.D?"))
			else if(lying || src.sleeping)
				AdjustSleeping(-5)
				if(src.sleeping == 0)
					src.resting = 0
				if(H) H.in_stasis = 0 //VOREStation Add - Just In Case
				M.visible_message(span_notice("[M] shakes [src] trying to wake [T.him] up!"), \
									span_notice("You shake [src] trying to wake [T.him] up!"))
			else
				var/mob/living/carbon/human/hugger = M
				var/datum/gender/TM = GLOB.gender_datums[M.get_visible_gender()]
				if(M.resting == 1) //Are they resting on the ground?
					M.visible_message(span_notice("[M] grabs onto [src] and pulls [TM.himself] up"), \
							span_notice("You grip onto [src] and pull yourself up off the ground!"))
					if(M.fire_stacks >= (src.fire_stacks + 3)) //Fire checks.
						src.adjust_fire_stacks(1)
						M.adjust_fire_stacks(-1)
					if(M.on_fire)
						src.IgniteMob()
					M.resting = 0 //Hoist yourself up up off the ground. No para/stunned/weakened removal.
					update_canmove()
				else if(istype(hugger))
					hugger.species.hug(hugger,src)
				else
					M.visible_message(span_notice("[M] hugs [src] to make [T.him] feel better!"), \
								span_notice("You hug [src] to make [T.him] feel better!"))
				if(M.fire_stacks >= (src.fire_stacks + 3))
					src.adjust_fire_stacks(1)
					M.adjust_fire_stacks(-1)
				if(M.on_fire)
					src.IgniteMob()
			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)

			playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/mob/living/carbon/proc/eyecheck()
	return 0

/mob/living/carbon/flash_eyes(intensity = FLASH_PROTECTION_MODERATE, override_blindness_check = FALSE, affect_silicon = FALSE, visual = FALSE, type = /obj/screen/fullscreen/flash)
	if(eyecheck() < intensity || override_blindness_check)
		return ..()

// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(var/datum/dna/newDNA)
	dna = newDNA

// ++++ROCKDTBEN++++ MOB PROCS //END

/mob/living/carbon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/temp_inc = max(min(BODYTEMP_HEATING_MAX*(1-get_heat_protection()), exposed_temperature - bodytemperature), 0)
	bodytemperature += temp_inc

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && istype(buckled, /obj/structure/bed/nest)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if (handcuffed)
		return 1
	return

/mob/living/carbon/u_equip(obj/item/W as obj)
	if(!W)	return 0

	else if (W == handcuffed)
		handcuffed = null
		update_handcuffed()
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()

	else if (W == legcuffed)
		legcuffed = null
		update_inv_legcuffed()
	else
		..()


//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(var/method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/Bump(atom/A)
	if(now_pushing)
		return
	..()
	if(istype(A, /mob/living/carbon) && prob(10))
		var/mob/living/carbon/human/H = A
		for(var/datum/disease/D in GetViruses())
			if(D.spread_flags & DISEASE_SPREAD_CONTACT)
				H.ContractDisease(D)

/mob/living/carbon/cannot_use_vents()
	return

/mob/living/carbon/slip(var/slipped_on,stun_duration=8)
	if(buckled)
		return 0
	stop_pulling()
	to_chat(src, span_warning("You slipped on [slipped_on]!"))
	playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
	if(slip_reflex && !lying) //CHOMPEdit Start
		if(world.time >= next_emote)
			src.emote("sflip")
			return 1 //CHOMPEdit End
	Weaken(FLOOR(stun_duration/2, 1))
	return 1

/mob/living/carbon/proc/add_chemical_effect(var/effect, var/magnitude = 1)
	if(effect in chem_effects)
		chem_effects[effect] += magnitude
	else
		chem_effects[effect] = magnitude

/mob/living/carbon/proc/remove_chemical_effect(var/effect, var/magnitude)
	if(effect in chem_effects)
		chem_effects[effect] = magnitude ? max(0,chem_effects[effect]-magnitude) : 0

/mob/living/carbon/get_default_language()
	if(default_language)
		if(can_speak(default_language))
			return default_language
		else
			return GLOB.all_languages[LANGUAGE_GIBBERISH]

	if(!species)
		return GLOB.all_languages[LANGUAGE_GIBBERISH]

	return species.default_language ? GLOB.all_languages[species.default_language] : GLOB.all_languages[LANGUAGE_GIBBERISH]

/mob/living/carbon/proc/should_have_organ(var/organ_check)
	return 0

/mob/living/carbon/can_feel_pain(var/check_organ)
	if(!species) //CHOMPEdit
		return 0
	if(isSynthetic())
		return 0
	return !(species.flags & NO_PAIN)

/mob/living/carbon/needs_to_breathe()
	if(does_not_breathe)
		return FALSE
	return ..()

/mob/living/carbon/proc/update_handcuffed()
	if(handcuffed)
		drop_l_hand()
		drop_r_hand()
		stop_pulling()
		throw_alert("handcuffed", /obj/screen/alert/restrained/handcuffed, new_master = handcuffed)
	else
		clear_alert("handcuffed")
	update_mob_action_buttons() //some of our action buttons might be unusable when we're handcuffed.
	update_inv_handcuffed()

// Clears blood overlays
/mob/living/carbon/wash(clean_types)
	. = ..()
	if(src.r_hand)
		src.r_hand.wash(clean_types)
	if(src.l_hand)
		src.l_hand.wash(clean_types)
	if(src.back)
		if(src.back.wash(clean_types))
			src.update_inv_back(0)

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/washgloves = 1
		var/washshoes = 1
		var/washmask = 1
		var/washears = 1
		var/washglasses = 1

		if(H.wear_suit)
			washgloves = !(H.wear_suit.flags_inv & HIDEGLOVES)
			washshoes = !(H.wear_suit.flags_inv & HIDESHOES)

		if(H.head)
			washmask = !(H.head.flags_inv & HIDEMASK)
			washglasses = !(H.head.flags_inv & HIDEEYES)
			washears = !(H.head.flags_inv & HIDEEARS)

		if(H.wear_mask)
			if (washears)
				washears = !(H.wear_mask.flags_inv & HIDEEARS)
			if (washglasses)
				washglasses = !(H.wear_mask.flags_inv & HIDEEYES)

		if(H.head)
			if(H.head.wash(clean_types))
				H.update_inv_head()

		if(H.wear_suit)
			if(H.wear_suit.wash(clean_types))
				H.update_inv_wear_suit()

		else if(H.w_uniform)
			if(H.w_uniform.wash(clean_types))
				H.update_inv_w_uniform()

		if(H.gloves && washgloves)
			if(H.gloves.wash(clean_types))
				H.update_inv_gloves(0)

		if(H.shoes && washshoes)
			if(H.shoes.wash(clean_types))
				H.update_inv_shoes(0)

		if(H.wear_mask && washmask)
			if(H.wear_mask.wash(clean_types))
				H.update_inv_wear_mask(0)

		if(H.glasses && washglasses)
			if(H.glasses.wash(clean_types))
				H.update_inv_glasses(0)

		if(H.l_ear && washears)
			if(H.l_ear.wash(clean_types))
				H.update_inv_ears(0)

		if(H.r_ear && washears)
			if(H.r_ear.wash(clean_types))
				H.update_inv_ears(0)

		if(H.belt)
			if(H.belt.wash(clean_types))
				H.update_inv_belt(0)

	else
		if(src.wear_mask)						//if the mob is not human, it cleans the mask without asking for bitflags
			if(src.wear_mask.wash(clean_types))
				src.update_inv_wear_mask(0)

/mob/living/carbon/proc/food_preference(var/allergen_type) //RS edit

	if(allergen_type in species.food_preference)
		return species.food_preference_bonus
	return 0

/mob/living/carbon/handle_diseases()
	for(var/thing in GetViruses())
		var/datum/disease/D = thing
		if(prob(D.infectivity))
			D.spread()

		if(stat != DEAD || global_flag_check(D.virus_modifiers, SPREAD_DEAD))
			D.stage_act()

/mob/living/carbon/vv_get_dropdown()
	. = ..()
	/*
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_BODYPART, "Modify bodypart")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_ORGANS, "Modify organs")
	VV_DROPDOWN_OPTION(VV_HK_MARTIAL_ART, "Give Martial Arts")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_TRAUMA, "Give Brain Trauma")
	VV_DROPDOWN_OPTION(VV_HK_CURE_TRAUMA, "Cure Brain Traumas")
	*/

/mob/living/carbon/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	/*
	if(href_list[VV_HK_MODIFY_BODYPART])
		if(!check_rights(R_SPAWN))
			return
		var/edit_action = tgui_alert(usr, "What would you like to do?","Modify Body Part", list("replace","remove"))
		if(!edit_action)
			return
		var/list/limb_list = list()
		if(edit_action == "remove")
			for(var/obj/item/bodypart/iter_part as anything in bodyparts)
				limb_list += iter_part.body_zone
				limb_list -= BODY_ZONE_CHEST
		else
			limb_list = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_CHEST)
		var/result = tgui_input_list(usr, "Please choose which bodypart to [edit_action]","[capitalize(edit_action)] Bodypart", sort_list(limb_list))
		if(result)
			var/obj/item/bodypart/part = get_bodypart(result)
			var/list/limbtypes = list()
			switch(result)
				if(BODY_ZONE_CHEST)
					limbtypes = typesof(/obj/item/bodypart/chest)
				if(BODY_ZONE_R_ARM)
					limbtypes = typesof(/obj/item/bodypart/arm/right)
				if(BODY_ZONE_L_ARM)
					limbtypes = typesof(/obj/item/bodypart/arm/left)
				if(BODY_ZONE_HEAD)
					limbtypes = typesof(/obj/item/bodypart/head)
				if(BODY_ZONE_L_LEG)
					limbtypes = typesof(/obj/item/bodypart/leg/left)
				if(BODY_ZONE_R_LEG)
					limbtypes = typesof(/obj/item/bodypart/leg/right)
			switch(edit_action)
				if("remove")
					if(part)
						part.drop_limb()
						admin_ticket_log("[key_name_admin(usr)] has removed [src]'s [part.plaintext_zone]")
					else
						to_chat(usr, span_boldwarning("[src] doesn't have such bodypart."))
						admin_ticket_log("[key_name_admin(usr)] has attempted to modify the bodyparts of [src]")
				if("replace")
					var/limb2add = tgui_input_list(usr, "Select a bodypart type to add", "Add/Replace Bodypart", sort_list(limbtypes))
					var/obj/item/bodypart/new_bp = new limb2add()
					if(new_bp.replace_limb(src, special = TRUE))
						admin_ticket_log("key_name_admin(usr)] has replaced [src]'s [part.type] with [new_bp.type]")
						qdel(part)
					else
						to_chat(usr, "Failed to replace bodypart! They might be incompatible.")
						admin_ticket_log("[key_name_admin(usr)] has attempted to modify the bodyparts of [src]")

	if(href_list[VV_HK_MODIFY_ORGANS])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/manipulate_organs, src)

	if(href_list[VV_HK_MARTIAL_ART])
		if(!check_rights(NONE))
			return
		var/list/artpaths = subtypesof(/datum/martial_art)
		var/list/artnames = list()
		for(var/i in artpaths)
			var/datum/martial_art/M = i
			artnames[initial(M.name)] = M
		var/result = tgui_input_list(usr, "Choose the martial art to teach","JUDO CHOP", sort_list(artnames, GLOBAL_PROC_REF(cmp_typepaths_asc))
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, span_boldwarning("Mob doesn't exist anymore."))
			return
		if(result)
			var/chosenart = artnames[result]
			var/datum/martial_art/MA = new chosenart(src)
			MA.teach(src)
			log_admin("[key_name(usr)] has taught [MA] to [key_name(src)].")
			message_admins(span_notice("[key_name_admin(usr)] has taught [MA] to [key_name_admin(src)]."))

	if(href_list[VV_HK_GIVE_TRAUMA])
		if(!check_rights(NONE))
			return
		var/list/traumas = subtypesof(/datum/brain_trauma)
		var/result = tgui_input_list(usr, "Choose the brain trauma to apply","Traumatize", sort_list(traumas, GLOBAL_PROC_REF(cmp_typepaths_asc)))
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!result)
			return
		var/datum/brain_trauma/BT = gain_trauma(result)
		if(BT)
			log_admin("[key_name(usr)] has traumatized [key_name(src)] with [BT.name]")
			message_admins(span_notice("[key_name_admin(usr)] has traumatized [key_name_admin(src)] with [BT.name]."))

	if(href_list[VV_HK_CURE_TRAUMA])
		if(!check_rights(NONE))
			return
		cure_all_traumas(TRAUMA_RESILIENCE_ABSOLUTE)
		log_admin("[key_name(usr)] has cured all traumas from [key_name(src)].")
		message_admins(span_notice("[key_name_admin(usr)] has cured all traumas from [key_name_admin(src)]."))
	*/
