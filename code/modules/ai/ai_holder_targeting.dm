// Used for assigning a target for attacking.

/datum/ai_holder
	var/hostile = FALSE						// Do we try to hurt others?
	var/retaliate = FALSE					// Attacks whatever struck it first. Mobs will still attack back if this is false but hostile is true.
	var/mauling = FALSE						// Attacks unconscious mobs
	var/unconscious_vore = FALSE			//VOREStation Add - allows a mob to go for unconcious targets IF their vore prefs align
	var/handle_corpse = FALSE				// Allows AI to acknowledge corpses (e.g. nurse spiders)
	var/vore_hostile = FALSE				// The same as hostile, but with vore pref checks
	var/micro_hunt = FALSE					// Will target mobs at or under the micro_hunt_size size, requires vore_hostile to be true
	var/micro_hunt_size = 0.25
	var/belly_attack = TRUE					//Mobs attack if they are in a belly!
	var/guard_limit = FALSE					//Mobs will not acquire targets unless they are in front of them.

	var/atom/movable/target = null			// The thing (mob or object) we're trying to kill.
	var/atom/movable/preferred_target = null// If set, and if given the chance, we will always prefer to target this over other options.
	var/turf/target_last_seen_turf = null 	// Where the mob last observed the target being, used if the target disappears but the mob wants to keep fighting.

	var/vision_range = 7					// How far the targeting system will look for things to kill. Note that values higher than 7 are 'offscreen' and might be unsporting.
	var/respect_alpha = TRUE				// If true, mobs with a sufficently low alpha will be treated as invisible.
	var/alpha_vision_threshold = FAKE_INVIS_ALPHA_THRESHOLD	// Targets with an alpha less or equal to this will be considered invisible. Requires above var to be true.

	var/lose_target_time = 0				// world.time when a target was lost.
	var/lose_target_timeout = 5 SECONDS		// How long until a mob 'times out' and stops trying to find the mob that disappeared.

	var/list/attackers = list()				// List of strings of names of people who attacked us before in our life.
											// This uses strings and not refs to allow for disguises, and to avoid needing to use weakrefs.
	var/destructive = FALSE					// Will target 'neutral' structures/objects and not just 'hostile' ones.

	var/forgive_resting = TRUE				//VOREStation add - If TRUE on a RETALIATE mob, then mob will drop target if it becomes hostile to you but hasn't taken damage

// A lot of this is based off of /TG/'s AI code.

//CHOMPEdit Begin
// Step 1, find out what we can see.
/datum/ai_holder/proc/list_targets()
	. = hearers(vision_range, holder) - holder // Remove ourselves to prevent suicidal decisions. ~ SRC is the ai_holder.

	var/static/list/hostile_machines = typecacheof(list(/obj/machinery/porta_turret, /obj/mecha))
	var/static/list/ignore = typecacheof(list(/mob/observer))

	for(var/HM in typecache_filter_list(range(vision_range, holder), hostile_machines))
		if(can_see(holder, HM, vision_range))
			. += HM
	. = typecache_filter_list_reverse(., ignore)
//CHOMPEdit End

// Step 2, filter down possible targets to things we actually care about.
/datum/ai_holder/proc/find_target(var/list/possible_targets, var/has_targets_list = FALSE)
	ai_log("find_target() : Entered.", AI_LOG_TRACE)
	if(!hostile) // So retaliating mobs only attack the thing that hit it.
		return null
	. = list()
	if(!has_targets_list)
		possible_targets = list_targets()
	for(var/atom/possible_target as anything in possible_targets)
		if(guard_limit)
			if((holder.dir == 1 && holder.y >= possible_target.y) || (holder.dir == 2 && holder.y <= possible_target.y) || (holder.dir == 4 && holder.x >= possible_target.x) || (holder.dir == 8 && holder.x <= possible_target.x)) //Ignore targets that are behind you
				continue
		if(can_attack(possible_target)) // Can we attack it?
			. += possible_target

	var/new_target = pick_target(.)
	give_target(new_target)
	return new_target

// Step 3, pick among the possible, attackable targets.
/datum/ai_holder/proc/pick_target(list/targets)
	if(target) // If we already have a target, but are told to pick again, calculate the lowest distance between all possible, and pick from the lowest distance targets.
		targets = target_filter_distance(targets)
	else
		targets = target_filter_closest(targets)
	if(!targets.len) // We found nothing.
		return

	var/chosen_target
	if(preferred_target && (preferred_target in targets))
		chosen_target = preferred_target
	else
		chosen_target = pick(targets)
	return chosen_target

// Step 4, give us our selected target.
/datum/ai_holder/proc/give_target(new_target, urgent = FALSE)
	ai_log("give_target() : Given '[new_target]', urgent=[urgent].", AI_LOG_TRACE)

	if(target)
		remove_target()

	target = new_target

	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(remove_target))

	if(target != null)
		lose_target_time = 0
		track_target_position()
		if(should_threaten() && !urgent)
			set_stance(STANCE_ALERT)
		else
			set_stance(STANCE_FIGHT)
		last_target_time = world.time
		return TRUE

// Filters return one or more 'preferred' targets.

// This one is for targets closer than our current one.
/datum/ai_holder/proc/target_filter_distance(list/targets)
	var/target_dist = get_dist(holder, target)
	var/list/better_targets = list()
	for(var/possible_target in targets)
		var/atom/A = possible_target
		var/possible_target_distance = get_dist(holder, A)
		if(possible_target_distance < target_dist)
			better_targets += A
	return better_targets

// Returns the closest target and anything tied with it for distance
/datum/ai_holder/proc/target_filter_closest(list/targets)
	var/lowest_distance = 1e6 //fakely far
	var/list/closest_targets = list()
	for(var/possible_target in targets)
		var/atom/A = possible_target
		var/current_distance = get_dist(holder, A)
		if(current_distance < lowest_distance)
			closest_targets.Cut()
			lowest_distance = current_distance
			closest_targets += A
		else if(current_distance == lowest_distance)
			closest_targets += A
	return closest_targets

/datum/ai_holder/proc/can_attack(atom/movable/the_target, var/vision_required = TRUE)
	//CHOMP Removal (optimizing by making most intense check last)
	if(!belly_attack)
		if(isbelly(holder.loc))
			return FALSE
	if(isliving(the_target))
		var/mob/living/L = the_target
		if(holder.IIsAlly(L))
			return FALSE
		if(ishuman(L) || issilicon(L))
			if(L.key && !L.client)	// SSD players get a pass
				return FALSE
		if(L.stat)
			if(L.stat == DEAD && !handle_corpse) // Leave dead things alone
				return FALSE
			if(L.stat == UNCONSCIOUS)	// Do we have mauling? Yes? Then maul people who are sleeping but not SSD
				if(mauling)
					return TRUE
				//VOREStation Add Start
				else if(unconscious_vore && L.allowmobvore)
					var/mob/living/simple_mob/vore/eater = holder
					if(eater.will_eat(L))
						return TRUE
					else
						return FALSE
				//VOREStation Add End
				else
					return FALSE
		//VOREStation add start
		else if(forgive_resting && !isbelly(holder.loc))	//Doing it this way so we only think about the other conditions if the var is actually set
			if((holder.health == holder.getMaxHealth()) && !hostile && (L.resting || L.weakened || L.stunned))	//If our health is full, no one is fighting us, we can forgive
				var/mob/living/simple_mob/vore/eater = holder
				if(!eater.will_eat(L))		//We forgive people we can eat by eating them
					set_stance(STANCE_IDLE)
					return FALSE	//Forgiven
		//VOREStation add end
		return TRUE

	if(istype(the_target, /obj/mecha))
		var/obj/mecha/M = the_target
		if(M.occupant)
			return can_attack(M.occupant)
		return destructive // Empty mechs are 'neutral'.

	if(istype(the_target, /obj/machinery/porta_turret))
		var/obj/machinery/porta_turret/P = the_target
		if(P.stat & BROKEN)
			return FALSE // Already dead.
		if(P.faction == holder.faction)
			return FALSE // Don't shoot allied turrets.
		if(!P.raised && !P.raising)
			return FALSE // Turrets won't get hurt if they're still in their cover.
		return TRUE

	if(istype(the_target, /obj/structure/blob)) // Blob mobs are always blob faction, but the blob can anger other things.
		var/obj/structure/blob/Blob = the_target
		if(holder.faction == Blob.faction)
			return FALSE

	return TRUE
//	return FALSE

//CHOMPEdit Begin
//It may seem a bit funny to define a proc above and then immediately override it in the same file
//But this is basically layering the checks so that the vision check will always come last
/datum/ai_holder/can_attack(atom/movable/the_target, var/vision_required = TRUE)
	if(!..())
		return FALSE
	if(vision_required && !can_see_target(the_target))
		return FALSE
	return TRUE
//CHOMPEdit End

// 'Soft' loss of target. They may still exist, we still have some info about them maybe.
/datum/ai_holder/proc/lose_target()
	ai_log("lose_target() : Entering.", AI_LOG_TRACE)
	if(target)
		ai_log("lose_target() : Had a target, setting to null and LTT.", AI_LOG_DEBUG)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(remove_target))
		target = null
		lose_target_time = world.time

	if(target_last_seen_turf && intelligence_level >= AI_NORMAL)
		ai_log("lose_target() : Going into 'engage unseen enemy' mode.", AI_LOG_INFO)
		return engage_unseen_enemy() //We're still working on it
	else
		ai_log("lose_target() : Can't chase target, so giving up.", AI_LOG_INFO)
		remove_target()
		return find_target() //Returns if we found anything else to do

// 'Hard' loss of target. Clean things up and return to idle.
/datum/ai_holder/proc/remove_target()
	SIGNAL_HANDLER
	ai_log("remove_target() : Entering.", AI_LOG_TRACE)
	if(target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(remove_target))
		target = null

	lose_target_time = 0
	give_up_movement()
	lose_target_position()
	set_stance(STANCE_IDLE)
	return TRUE

// Check if target is visible to us.
/datum/ai_holder/proc/can_see_target(atom/movable/the_target, view_range = vision_range)
	ai_log("can_see_target() : Entering.", AI_LOG_TRACE)

	if(!the_target) // Nothing to target.
		ai_log("can_see_target() : There is no target. Exiting.", AI_LOG_WARNING)
		return FALSE

	if(holder.see_invisible < the_target.invisibility) // Real invis.
		ai_log("can_see_target() : Target ([the_target]) was invisible to holder. Exiting.", AI_LOG_TRACE)
		return FALSE

	if(respect_alpha && the_target.alpha <= alpha_vision_threshold) // Fake invis.
		ai_log("can_see_target() : Target ([the_target]) was sufficently transparent to holder and is hidden. Exiting.", AI_LOG_TRACE)
		return FALSE

	if(get_dist(holder, the_target) > view_range) // Too far away.
		ai_log("can_see_target() : Target ([the_target]) was too far from holder. Exiting.", AI_LOG_TRACE)
		return FALSE

	if(!can_see(holder, the_target, view_range))
		ai_log("can_see_target() : Target ([the_target]) failed can_see(). Exiting.", AI_LOG_TRACE)
		return FALSE

	ai_log("can_see_target() : Target ([the_target]) can be seen. Exiting.", AI_LOG_TRACE)
	return TRUE

// Updates the last known position of the target.
/datum/ai_holder/proc/track_target_position()
	if(!target)
		lose_target_position()

	if(last_turf_display && target_last_seen_turf)
		target_last_seen_turf.cut_overlay(last_turf_overlay)

	target_last_seen_turf = get_turf(target)

	if(last_turf_display)
		target_last_seen_turf.add_overlay(last_turf_overlay)

// Resets the last known position to null.
/datum/ai_holder/proc/lose_target_position()
	if(last_turf_display && target_last_seen_turf)
		target_last_seen_turf.cut_overlay(last_turf_overlay)
	ai_log("lose_target_position() : Last position is being reset.", AI_LOG_INFO)
	target_last_seen_turf = null

// Responds to a hostile action against its mob.
/datum/ai_holder/proc/react_to_attack(atom/movable/attacker)
	if(holder.stat) // We're dead.
		ai_log("react_to_attack() : Was attacked by [attacker], but we are dead/unconscious.", AI_LOG_TRACE)
		return FALSE
	if(!hostile && !retaliate) // Not allowed to defend ourselves.
		ai_log("react_to_attack() : Was attacked by [attacker], but we are not allowed to attack back.", AI_LOG_TRACE)
		return FALSE
	if(!belly_attack)
		if(isbelly(holder.loc))
			return FALSE
	if(holder.IIsAlly(attacker)) // I'll overlook it THIS time...
		ai_log("react_to_attack() : Was attacked by [attacker], but they were an ally.", AI_LOG_TRACE)
		return FALSE
	if(target) // Already fighting someone. Switching every time we get hit would impact our combat performance.
		if(!retaliate)	// If we don't get to fight back, we don't fight back...
			ai_log("react_to_attack() : Was attacked by [attacker], but we already have a target.", AI_LOG_TRACE)
			on_attacked(attacker) // So we attack immediately and not threaten.
			return FALSE
		else if(check_attacker(attacker) && world.time > last_target_time + 3 SECONDS)	// Otherwise, let 'er rip
			ai_log("react_to_attack() : Was attacked by [attacker]. Can retaliate, waited 3 seconds.", AI_LOG_INFO)
			on_attacked(attacker) // So we attack immediately and not threaten.
			return give_target(attacker) // Also handles setting the appropiate stance.

	if(holder.resting)	// I can't kill someone while I'm laying down!
		ai_log("react_to_attack() : AI is resting. Getting up.", AI_LOG_TRACE)
		holder.lay_down()

	if(stance == STANCE_SLEEP) // If we're asleep, try waking up if someone's wailing on us.
		ai_log("react_to_attack() : AI is asleep. Waking up.", AI_LOG_TRACE)
		go_wake()

	ai_log("react_to_attack() : Was attacked by [attacker].", AI_LOG_INFO)
	on_attacked(attacker) // So we attack immediately and not threaten.
	return give_target(attacker, urgent = TRUE) // Also handles setting the appropiate stance.

// Sets a few vars so mobs that threaten will react faster to an attacker or someone who attacked them before.
/datum/ai_holder/proc/on_attacked(atom/movable/AM)
	last_conflict_time = world.time
	add_attacker(AM)

// Checks to see if an atom attacked us lately
/datum/ai_holder/proc/check_attacker(var/atom/movable/A)
	return (A.name in attackers)

// We were attacked by this thing recently
/datum/ai_holder/proc/add_attacker(var/atom/movable/A)
	attackers |= A.name

// Forgive this attacker
/datum/ai_holder/proc/remove_attacker(var/atom/movable/A)
	attackers -= A.name

// Causes targeting to prefer targeting the taunter if possible.
// This generally occurs if more than one option is within striking distance, including the taunter.
// Otherwise the default filter will prefer the closest target.
/datum/ai_holder/proc/receive_taunt(atom/movable/taunter, force_target_switch = FALSE)
	ai_log("receive_taunt() : Was taunted by [taunter].", AI_LOG_INFO)
	preferred_target = taunter
	if(force_target_switch)
		give_target(taunter)

/datum/ai_holder/proc/lose_taunt()
	ai_log("lose_taunt() : Resetting preferred_target.", AI_LOG_INFO)
	preferred_target = null

/datum/ai_holder/proc/vore_check(mob/living/L)
	if(isanimal(holder))
		var/mob/living/simple_mob/M = holder
		if(!M.voremob_loaded)	//init vore if it's not already
			M.init_vore(TRUE)
	if(!holder.vore_selected)	//We probably don't have a belly so don't even try
		return FALSE
	if(!isliving(L))	//We only want mob/living
		return FALSE
	if(!L.devourable || !L.allowmobvore)	//Check their prefs
		return FALSE
	if(micro_hunt && !(L.get_effective_size(TRUE) <= micro_hunt_size))	//Are they small enough to get?
		return FALSE
	return TRUE // Let's go!
