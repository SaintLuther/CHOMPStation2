// Eyes
/datum/gear/eyes
	display_name = "eyepatch"
	path = /obj/item/clothing/glasses/eyepatch
	slot = slot_glasses
	sort_category = "Glasses and Eyewear"

/datum/gear/eyes/eyepatchwhite
	display_name = "eyepatch (recolorable)"
	path = /obj/item/clothing/glasses/eyepatchwhite
	slot = slot_glasses
	sort_category = "Glasses and Eyewear"

/datum/gear/eyes/eyepatchwhite/New()
	..()
	gear_tweaks += gear_tweak_free_color_choice

/datum/gear/eyes/blindfold
	display_name = "blindfold"
	path = /obj/item/clothing/glasses/sunglasses/blindfold

/datum/gear/eyes/whiteblindfold //I may have lost my sight, but at least these folks can see my RAINBOW BLINDFOLD
	display_name = "blindfold, white (recolorable)"
	path = /obj/item/clothing/glasses/sunglasses/blindfold/whiteblindfold

/datum/gear/eyes/whiteblindfold/New()
	..()
	gear_tweaks += gear_tweak_free_color_choice

/datum/gear/eyes/thinblindfold
	display_name = "blindfold, thin white (recolorable)"
	path = /obj/item/clothing/glasses/sunglasses/thinblindfold

/datum/gear/eyes/thinblindfold/New()
	..()
	gear_tweaks += gear_tweak_free_color_choice

/datum/gear/eyes/glasses
	display_name = "Glasses, prescription"
	path = /obj/item/clothing/glasses/regular

/datum/gear/eyes/glasses/green
	display_name = "Glasses, green"
	path = /obj/item/clothing/glasses/gglasses

/datum/gear/eyes/glasses/prescriptionhipster
	display_name = "Glasses, hipster"
	path = /obj/item/clothing/glasses/regular/hipster

/datum/gear/eyes/glasses/threedglasses
	display_name = "Glasses, 3D"
	path = /obj/item/clothing/glasses/threedglasses

/datum/gear/eyes/glasses/monocle
	display_name = "monocle"
	path = /obj/item/clothing/glasses/monocle

/datum/gear/eyes/goggles
	display_name = "plain goggles"
	path = /obj/item/clothing/glasses/goggles

/datum/gear/eyes/goggles/scanning
	display_name = "scanning goggles"
	path = /obj/item/clothing/glasses/regular/scanners

/datum/gear/eyes/goggles/science
	display_name = "Science Goggles"
	path = /obj/item/clothing/glasses/science

/datum/gear/eyes/security
	display_name = "Security HUD selector"
	description = "Select from a range of Security HUD eyepieces that can display the ID status and security records of people in line of sight."
	path = /obj/item/clothing/glasses/hud/security
	allowed_roles = list(JOB_SECURITY_OFFICER,JOB_HEAD_OF_SECURITY,JOB_WARDEN, JOB_DETECTIVE, JOB_BLUESHIELD_GUARD, JOB_SECURITY_PILOT) //YW ADDITIONS

/datum/gear/eyes/security/New()
	..()
	var/list/selector_uniforms = list(
		"standard security HUD"=/obj/item/clothing/glasses/hud/security,
		"prescription security HUD"=/obj/item/clothing/glasses/hud/security/prescription,
		"security HUD sunglasses"=/obj/item/clothing/glasses/sunglasses/sechud,
		"security HUD aviators"=/obj/item/clothing/glasses/sunglasses/sechud/aviator,
		"security HUD aviators (prescription)"=/obj/item/clothing/glasses/sunglasses/sechud/aviator/prescription,
		"security HUD eyepatch, mark I"=/obj/item/clothing/glasses/hud/security/eyepatch,
		"security HUD eyepatch, mark II"=/obj/item/clothing/glasses/hud/security/eyepatch2,
		"tactical security visor"=/obj/item/clothing/glasses/sunglasses/sechud/tactical_sec_vis
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/medical
	display_name = "Medical HUD selector"
	description = "Select from a range of Medical HUD eyepieces that can display the health status of people in line of sight."
	path = /obj/item/clothing/glasses/hud/health
	allowed_roles = list(JOB_MEDICAL_DOCTOR,JOB_CHIEF_MEDICAL_OFFICER,JOB_CHEMIST,JOB_PARAMEDIC,JOB_GENETICIST, JOB_PSYCHIATRIST,JOB_FIELD_MEDIC) //CHOMP keep explo

/datum/gear/eyes/medical/New()
	..()
	var/list/selector_uniforms = list(
		"standard medical HUD"=/obj/item/clothing/glasses/hud/health,
		"prescription medical HUD"=/obj/item/clothing/glasses/hud/health/prescription,
		"medical HUD aviators"=/obj/item/clothing/glasses/hud/health/aviator,
		"medical HUD aviators (prescription)"=/obj/item/clothing/glasses/hud/health/aviator/prescription,
		"medical HUD eyepatch"=/obj/item/clothing/glasses/hud/health/eyepatch
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/janitor
	display_name = "Contaminant HUD"
	description = "A heads-up display that scans the environment for contaminations. Can be taken with or without prescription lenses."
	path = /obj/item/clothing/glasses/hud/janitor
	allowed_roles = list(JOB_JANITOR)

/datum/gear/eyes/janitor/New()
	..()
	var/list/selector_uniforms = list(
		"standard Contaminant HUD"=/obj/item/clothing/glasses/hud/health,
		"prescription Contaminant HUD"=/obj/item/clothing/glasses/hud/janitor/prescription
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/meson
	display_name = "Optical Meson Scanners selection"
	description = "Select from a range of meson-projection eyewear. Note: not all of these items are atmospherically sealed."
	path = /obj/item/clothing/glasses/meson
	allowed_roles = list(JOB_ENGINEER,JOB_CHIEF_ENGINEER,JOB_ATMOSPHERIC_TECHNICIAN, JOB_SCIENTIST, JOB_RESEARCH_DIRECTOR)

/datum/gear/eyes/meson/New()
	..()
	var/list/selector_uniforms = list(
		"standard meson goggles"=/obj/item/clothing/glasses/meson,
		"prescription meson goggles"=/obj/item/clothing/glasses/meson/prescription,
		"meson retinal projector"=/obj/item/clothing/glasses/omnihud/eng/meson,
		"meson aviator glasses"=/obj/item/clothing/glasses/meson/aviator,
		"meson aviator glasses (prescription)"=/obj/item/clothing/glasses/meson/aviator/prescription
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/material
	display_name = "Optical Material Scanners"
	path = /obj/item/clothing/glasses/material
	allowed_roles = list(JOB_SHAFT_MINER,JOB_QUARTERMASTER)

/datum/gear/eyes/glasses/fakesun
	display_name = "Sunglasses, stylish"
	path = /obj/item/clothing/glasses/fakesunglasses

/datum/gear/eyes/glasses/fakeaviator
	display_name = "Sunglasses, stylish aviators"
	path = /obj/item/clothing/glasses/fakesunglasses/aviator

/datum/gear/eyes/sun
	display_name = "functional sunglasses selector"
	description = "Select from a range of polarized sunglasses that can block flashes whilst still looking classy."
	path = /obj/item/clothing/glasses/sunglasses
	allowed_roles = list(JOB_SECURITY_OFFICER,JOB_HEAD_OF_SECURITY,JOB_WARDEN,JOB_SITE_MANAGER,JOB_HEAD_OF_PERSONNEL,JOB_QUARTERMASTER,JOB_INTERNAL_AFFAIRS_AGENT,JOB_DETECTIVE,JOB_BLUESHIELD_GUARD,JOB_SECURITY_PILOT) //YW ADDITIONS

/datum/gear/eyes/sun/New()
	..()
	var/list/selector_uniforms = list(
		"sunglasses"=/obj/item/clothing/glasses/sunglasses,
		"extra large sunglasses"=/obj/item/clothing/glasses/sunglasses/big,
		"aviators"=/obj/item/clothing/glasses/sunglasses/aviator,
		"prescription sunglasses"=/obj/item/clothing/glasses/sunglasses/prescription
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/circuitry
	display_name = "goggles, circuitry (empty)"
	path = /obj/item/clothing/glasses/circuitry

/datum/gear/eyes/glasses/rimless
	display_name = "glasses, rimless"
	path = /obj/item/clothing/glasses/rimless

/datum/gear/eyes/glasses/prescriptionrimless
	display_name = "glasses, prescription rimless"
	path = /obj/item/clothing/glasses/regular/rimless

/datum/gear/eyes/glasses/thin
	display_name = "glasses, thin frame"
	path = /obj/item/clothing/glasses/thin

/datum/gear/eyes/glasses/prescriptionthin
	display_name = "glasses, prescription thin frame"
	path = /obj/item/clothing/glasses/regular/thin

/datum/gear/eyes/arglasses
	display_name = "AR glasses"
	path = /obj/item/clothing/glasses/omnihud

/datum/gear/eyes/arglasses/New()
	..()
	var/list/selector_uniforms = list(
		"standard AR glasses"=/obj/item/clothing/glasses/omnihud,
		"prescription AR glasses"=/obj/item/clothing/glasses/omnihud/prescription,
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/arglasses_visor
	display_name = "AR visor"
	path = /obj/item/clothing/glasses/omnihud/visor

/datum/gear/eyes/arglasses_visor/New()
	..()
	gear_tweaks = list(gear_tweak_free_color_choice)

/datum/gear/eyes/arglasses_sec
	display_name = "AR-Security glasses"
	path = /obj/item/clothing/glasses/omnihud/sec
	allowed_roles = list(JOB_SECURITY_OFFICER,JOB_HEAD_OF_SECURITY,JOB_WARDEN,JOB_DETECTIVE)

/datum/gear/eyes/arglasses_sec/New()
	..()
	var/list/selector_uniforms = list(
		"standard AR-Security glasses"=/obj/item/clothing/glasses/omnihud/sec,
		"prescription AR-Security glasses"=/obj/item/clothing/glasses/omnihud/sec/prescription
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/arglasses_sci
	display_name = "AR-Research glasses"
	path = /obj/item/clothing/glasses/omnihud/rnd
	allowed_roles = list(JOB_RESEARCH_DIRECTOR,JOB_SCIENTIST,JOB_XENOBIOLOGIST,JOB_XENOBOTANIST,JOB_ROBOTICIST)

/datum/gear/eyes/arglasses_sci/New()
	..()
	var/list/selector_uniforms = list(
		"standard AR-Research glasses"=/obj/item/clothing/glasses/omnihud/rnd,
		"prescription AR-Research glasses"=/obj/item/clothing/glasses/omnihud/rnd/prescription
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/arglasses_eng
	display_name = "AR-Engineering glasses"
	path = /obj/item/clothing/glasses/omnihud/eng
	allowed_roles = list(JOB_ENGINEER,JOB_CHIEF_ENGINEER,JOB_ATMOSPHERIC_TECHNICIAN)

/datum/gear/eyes/arglasses_eng/New()
	..()
	var/list/selector_uniforms = list(
		"standard AR-Engineering glasses"=/obj/item/clothing/glasses/omnihud/eng,
		"prescription AR-Engineering glasses"=/obj/item/clothing/glasses/omnihud/eng/prescription
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/arglasses_med
	display_name = "AR-Medical glasses"
	path = /obj/item/clothing/glasses/omnihud/med
	allowed_roles = list(JOB_MEDICAL_DOCTOR,JOB_CHIEF_MEDICAL_OFFICER,JOB_CHEMIST,JOB_PARAMEDIC,JOB_GENETICIST, JOB_PSYCHIATRIST,JOB_FIELD_MEDIC) //CHOMP keep explo

/datum/gear/eyes/arglasses_med/New()
	..()
	var/list/selector_uniforms = list(
		"standard AR-Medical glasses"=/obj/item/clothing/glasses/omnihud/med,
		"prescription AR-Medical glasses"=/obj/item/clothing/glasses/omnihud/med/prescription
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/arglasses_all
	display_name = "AR-Command glasses"
	path = /obj/item/clothing/glasses/omnihud/all
	cost = 2
	allowed_roles = list(JOB_SITE_MANAGER,JOB_HEAD_OF_PERSONNEL)

/datum/gear/eyes/arglasses_all/New()
	..()
	var/list/selector_uniforms = list(
		"standard AR-Command glasses"=/obj/item/clothing/glasses/omnihud/all,
		"prescription AR-Command glasses"=/obj/item/clothing/glasses/omnihud/all/prescription
	)
	gear_tweaks += new/datum/gear_tweak/path(sortAssoc(selector_uniforms))

/datum/gear/eyes/spiffygogs
	display_name = "slick orange goggles"
	path = /obj/item/clothing/glasses/fluff/spiffygogs

/datum/gear/eyes/science_proper
	display_name = "science goggles (no overlay)"
	path = /obj/item/clothing/glasses/fluff/science_proper

/datum/gear/eyes/bigshot
	display_name = "Big Shot's Glasses"
	path = /obj/item/clothing/glasses/sunglasses/bigshot
