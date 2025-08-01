SUBSYSTEM_DEF(radiation)
	name = "Radiation"
	wait = 2 SECONDS
	flags = SS_NO_INIT

	var/list/sources = list()			// all radiation source datums
	var/list/sources_assoc = list()		// Sources indexed by turf for de-duplication.
	var/list/resistance_cache = list()	// Cache of turf's radiation resistance.

	var/tmp/list/current_sources   = list()
	var/tmp/list/current_res_cache = list()
	var/tmp/list/listeners         = list()

/datum/controller/subsystem/radiation/fire(resumed = FALSE)
	if (!resumed)
		current_sources = sources.Copy()
		current_res_cache = resistance_cache.Copy()
		listeners = GLOB.living_mob_list.Copy()

	while(current_sources.len)
		var/datum/radiation_source/S = current_sources[current_sources.len]
		current_sources.len--

		if(QDELETED(S))
			sources -= S
		else if(S.decay)
			S.update_rad_power(S.rad_power - CONFIG_GET(number/radiation_decay_rate))
		if (MC_TICK_CHECK)
			return

	while(current_res_cache.len)
		var/turf/T = current_res_cache[current_res_cache.len]
		current_res_cache.len--

		if(QDELETED(T))
			resistance_cache -= T
		else if((length(T.contents) + 1) != resistance_cache[T])
			resistance_cache -= T // If its stale REMOVE it! It will get added if its needed.
		if (MC_TICK_CHECK)
			return

	if(!sources.len)
		listeners.Cut()

	while(listeners.len)
		var/atom/A = listeners[listeners.len]
		listeners.len--

		if(!QDELETED(A))
			var/turf/T = get_turf(A)
			var/rads = get_rads_at_turf(T)
			if(rads)
				A.rad_act(rads)
		if (MC_TICK_CHECK)
			return

/datum/controller/subsystem/radiation/stat_entry(msg)
	msg = "S:[sources.len], RC:[resistance_cache.len]"
	return ..()

// Ray trace from all active radiation sources to T and return the strongest effect.
/datum/controller/subsystem/radiation/proc/get_rads_at_turf(var/turf/T)
	. = 0
	if(!istype(T))
		return

	for(var/datum/radiation_source/source as anything in sources)
		if(source.rad_power < .)
			continue // Already being affected by a stronger source

		if(source.source_turf.z != T.z)
			continue // Radiation is not multi-z

		if(source.respect_maint)
			var/area/A = T.loc
			if(A.flag_check(RAD_SHIELDED))
				continue // In shielded area

		var/dist = get_dist(source.source_turf, T)
		if(dist > source.range)
			continue // Too far to possibly affect

		if(source.flat)
			. += source.rad_power
			continue // No need to ray trace for flat field

		// Okay, now ray trace to find resistence!
		var/turf/origin = source.source_turf
		var/working = source.rad_power
		while(origin != T)
			origin = get_step_towards(origin, T) //Raytracing
			if(!resistance_cache[origin]) //Only get the resistance if we don't already know it.
				origin.calc_rad_resistance()

			if(origin.cached_rad_resistance)
				if(CONFIG_GET(flag/radiation_resistance_calc_mode) == RAD_RESIST_CALC_DIV)
					working = round((working / (origin.cached_rad_resistance * CONFIG_GET(number/radiation_resistance_multiplier))), 0.01)
				else if(CONFIG_GET(flag/radiation_resistance_calc_mode) == RAD_RESIST_CALC_SUB)
					working = round((working - (origin.cached_rad_resistance * CONFIG_GET(number/radiation_resistance_multiplier))), 0.01)

			if(working <= CONFIG_GET(number/radiation_lower_limit)) // Too far from this source
				working = 0 // May as well be 0
				break

		// Accumulate radiation from all sources in range, not just the biggest.
		// Shouldn't really ever have practical uses, but standing in a room literally made from uranium is more dangerous than standing next to a single uranium vase
		. += working / (dist ** 2)

	if(. <= CONFIG_GET(number/radiation_lower_limit))
		. = 0

// Add a radiation source instance to the repository.  It will override any existing source on the same turf.
/datum/controller/subsystem/radiation/proc/add_source(var/datum/radiation_source/S)
	if(!isturf(S.source_turf))
		return
	var/datum/radiation_source/existing = sources_assoc[S.source_turf]
	if(existing)
		qdel(existing)
	sources += S
	sources_assoc[S.source_turf] = S

// Creates a temporary radiation source that will decay
/datum/controller/subsystem/radiation/proc/radiate(source, power) //Sends out a radiation pulse, taking walls into account
	if(!(source && power)) //Sanity checking
		return
	var/datum/radiation_source/S = new()
	S.source_turf = get_turf(source)
	S.update_rad_power(power)
	add_source(S)

// Sets the radiation in a range to a constant value.
/datum/controller/subsystem/radiation/proc/flat_radiate(source, power, range, var/respect_maint = TRUE)	//VOREStation edit; Respect shielded areas by default please.
	if(!(source && power && range))
		return
	var/datum/radiation_source/S = new()
	S.flat = TRUE
	S.range = range
	S.respect_maint = respect_maint
	S.source_turf = get_turf(source)
	S.update_rad_power(power)
	add_source(S)

// Irradiates a full Z-level. Hacky way of doing it, but not too expensive.
/datum/controller/subsystem/radiation/proc/z_radiate(var/atom/source, power, var/respect_maint = TRUE)	//VOREStation edit; Respect shielded areas by default please.
	if(!(power && source))
		return
	var/turf/epicentre = locate(round(world.maxx / 2), round(world.maxy / 2), source.z)
	flat_radiate(epicentre, power, world.maxx, respect_maint)
