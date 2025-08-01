/obj/var/list/req_access
/obj/var/list/req_one_access

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	return check_access(M?.GetIdCard())

/atom/movable/proc/GetAccess()
	var/obj/item/card/id/id = GetIdCard()
	return id ? id.GetAccess() : list()

/obj/proc/GetID()
	return null

/obj/proc/check_access(obj/item/I)
	return check_access_list(I ? I.GetAccess() : null)

/obj/proc/check_access_list(var/list/L)
	// We don't require access
	if(!LAZYLEN(req_access) && !LAZYLEN(req_one_access))
		return TRUE

	// They passed nothing, but we are something that requires access
	if(!LAZYLEN(L))
		return FALSE

	// Run list comparisons
	return has_access(req_access, req_one_access, L)

/proc/has_access(var/list/req_access, var/list/req_one_access, var/list/accesses)
	// req_access list has priority if set
	// Requires at least every access in list
	for(var/req in req_access)
		if(!(req in accesses))
			return FALSE

	// req_one_access is secondary if set
	// Requires at least one access in list
	if(LAZYLEN(req_one_access))
		for(var/req in req_one_access)
			if(req in accesses)
				return TRUE
		return FALSE

	return TRUE

/proc/get_centcom_access(job)
	switch(job)
		if("VIP Guest")
			return list(access_cent_general)
		if("Custodian")
			return list(access_cent_general, access_cent_living, access_cent_storage)
		if("Thunderdome Overseer")
			return list(access_cent_general, access_cent_thunder)
		if("Intel Officer")
			return list(access_cent_general, access_cent_living)
		if("Medical Officer")
			return list(access_cent_general, access_cent_living, access_cent_medical)
		if("Death Commando")
			return list(access_cent_general, access_cent_specops, access_cent_living, access_cent_storage)
		if("Research Officer")
			return list(access_cent_general, access_cent_specops, access_cent_medical, access_cent_teleporter, access_cent_storage)
		if("BlackOps Commander")
			return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_living, access_cent_storage, access_cent_creed)
		if("Supreme Commander")
			return get_all_centcom_access()

/var/list/datum/access/priv_all_access_datums
/proc/get_all_access_datums()
	if(!priv_all_access_datums)
		priv_all_access_datums = init_subtypes(/datum/access)
		priv_all_access_datums = dd_sortedObjectList(priv_all_access_datums)

	return priv_all_access_datums

/var/list/datum/access/priv_all_access_datums_id
/proc/get_all_access_datums_by_id()
	if(!priv_all_access_datums_id)
		priv_all_access_datums_id = list()
		for(var/datum/access/A in get_all_access_datums())
			priv_all_access_datums_id["[A.id]"] = A

	return priv_all_access_datums_id

/var/list/datum/access/priv_all_access_datums_region
/proc/get_all_access_datums_by_region()
	if(!priv_all_access_datums_region)
		priv_all_access_datums_region = list()
		for(var/datum/access/A in get_all_access_datums())
			if(!priv_all_access_datums_region[A.region])
				priv_all_access_datums_region[A.region] = list()
			priv_all_access_datums_region[A.region] += A

	return priv_all_access_datums_region

/proc/get_access_ids(var/access_types = ACCESS_TYPE_ALL)
	var/list/L = new()
	for(var/datum/access/A in get_all_access_datums())
		if(A.access_type & access_types)
			L += A.id
	return L

/var/list/priv_all_access
/proc/get_all_accesses()
	RETURN_TYPE(/list)
	if(!priv_all_access)
		priv_all_access = get_access_ids()

	return priv_all_access.Copy()

/var/list/priv_station_access
/proc/get_all_station_access()
	RETURN_TYPE(/list)
	if(!priv_station_access)
		priv_station_access = get_access_ids(ACCESS_TYPE_STATION)

	return priv_station_access.Copy()

/var/list/priv_centcom_access
/proc/get_all_centcom_access()
	RETURN_TYPE(/list)
	if(!priv_centcom_access)
		priv_centcom_access = get_access_ids(ACCESS_TYPE_CENTCOM)

	return priv_centcom_access.Copy()

/var/list/priv_syndicate_access
/proc/get_all_syndicate_access()
	RETURN_TYPE(/list)
	if(!priv_syndicate_access)
		priv_syndicate_access = get_access_ids(ACCESS_TYPE_SYNDICATE)

	return priv_syndicate_access.Copy()

/var/list/priv_private_access
/proc/get_all_private_access()
	RETURN_TYPE(/list)
	if(!priv_private_access)
		priv_private_access = get_access_ids(ACCESS_TYPE_PRIVATE)

	return priv_syndicate_access.Copy()

/var/list/priv_region_access
/proc/get_region_accesses(var/code)
	if(code == ACCESS_REGION_ALL)
		return get_all_station_access()

	if(!priv_region_access)
		priv_region_access = list()
		for(var/datum/access/A in get_all_access_datums())
			if(!priv_region_access["[A.region]"])
				priv_region_access["[A.region]"] = list()
			priv_region_access["[A.region]"] += A.id

	var/list/L = priv_region_access["[code]"]
	return L.Copy()

/proc/get_region_accesses_name(var/code)
	switch(code)
		if(ACCESS_REGION_ALL)
			return "All"
		if(ACCESS_REGION_SECURITY) //security
			return "Security"
		if(ACCESS_REGION_MEDBAY) //medbay
			return "Medbay"
		if(ACCESS_REGION_RESEARCH) //research
			return "Research"
		if(ACCESS_REGION_ENGINEERING) //engineering and maintenance
			return "Engineering"
		if(ACCESS_REGION_COMMAND) //command
			return "Command"
		if(ACCESS_REGION_GENERAL) //station general
			return "Station General"
		if(ACCESS_REGION_SUPPLY) //supply
			return "Supply"

/proc/get_access_desc(id)
	var/list/AS = get_all_access_datums_by_id()
	var/datum/access/A = AS["[id]"]

	return A ? A.desc : ""

/proc/get_centcom_access_desc(A)
	return get_access_desc(A)

/proc/get_access_by_id(id)
	var/list/AS = get_all_access_datums_by_id()
	return AS["[id]"]

/proc/get_all_jobs()
	var/list/all_jobs = list()
	var/list/all_datums = typesof(/datum/job)
	all_datums -= GLOB.exclude_jobs
	var/datum/job/jobdatum
	for(var/jobtype in all_datums)
		jobdatum = new jobtype
		all_jobs.Add(jobdatum.title)
	return all_jobs

/proc/get_all_centcom_jobs()
	return list("VIP Guest",
		"Custodian",
		"Thunderdome Overseer",
		"Intel Officer",
		"Medical Officer",
		"Death Commando",
		"Research Officer",
		"BlackOps Commander",
		"Supreme Commander",
		"Emergency Response Team",
		"Emergency Response Team Leader")

/atom/movable/proc/GetIdCard()
	return null

/mob/living/bot/GetIdCard()
	return botcard

/mob/living/carbon/human/GetIdCard()
	if(get_active_hand())
		var/obj/item/I = get_active_hand()
		var/id = I.GetID()
		if(id)
			return id
	if(wear_id)
		var/id = wear_id.GetID()
		if(id)
			return id

/mob/living/silicon/GetIdCard()
	return idcard

/proc/FindNameFromID(var/mob/living/carbon/human/H)
	ASSERT(istype(H))
	var/obj/item/card/id/C = H.GetIdCard()
	if(C)
		return C.registered_name

/proc/get_all_job_icons() //For all existing HUD icons
	return GLOB.joblist + GLOB.alt_titles_with_icons + list("Prisoner")

/obj/proc/GetJobName() //Used in secHUD icon generation
	var/obj/item/card/id/I = GetID()

	if(I)
		if(istype(I,/obj/item/card/id/centcom))
			return "Centcom"

		var/job_icons = get_all_job_icons()
		if(I.assignment	in job_icons) //Check if the job has a hud icon
			return I.assignment
		if(I.rank in job_icons)
			return I.rank

		var/centcom = get_all_centcom_jobs()
		if(I.assignment	in centcom) //Return with the NT logo if it is a CentCom job
			return "CentCom"
		if(I.rank in centcom)
			return "CentCom"
	else
		return

	return "Unknown" //Return unknown if none of the above apply
