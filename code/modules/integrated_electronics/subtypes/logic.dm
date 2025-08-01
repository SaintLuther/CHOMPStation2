/obj/item/integrated_circuit/logic
	name = "logic gate"
	desc = "This tiny chip will decide for you!"
	extended_desc = "Logic circuits will treat a null, 0, and a \"\" string value as FALSE and anything else as TRUE."
	complexity = 3
	outputs = list("result")
	activators = list("compare" = IC_PINTYPE_PULSE_IN)
	category_text = "Logic"
	power_draw_per_use = 1

/obj/item/integrated_circuit/logic/do_work()
	push_data()

/obj/item/integrated_circuit/logic/binary
	inputs = list("A","B")
	activators = list("compare" = IC_PINTYPE_PULSE_IN, "on true result" = IC_PINTYPE_PULSE_OUT, "on false result" = IC_PINTYPE_PULSE_OUT)

/obj/item/integrated_circuit/logic/binary/do_work()
	pull_data()
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/B = inputs[2]
	var/datum/integrated_io/O = outputs[1]
	O.data = do_compare(A, B) ? TRUE : FALSE

	if(get_pin_data(IC_OUTPUT, 1))
		activate_pin(2)
	else
		activate_pin(3)
	..()

/obj/item/integrated_circuit/logic/binary/proc/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return FALSE

/obj/item/integrated_circuit/logic/unary
	inputs = list("A")
	activators = list("compare" = IC_PINTYPE_PULSE_IN, "on compare" = IC_PINTYPE_PULSE_OUT)

/obj/item/integrated_circuit/logic/unary/do_work()
	pull_data()
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/O = outputs[1]
	O.data = do_check(A) ? TRUE : FALSE
	..()
	activate_pin(2)

/obj/item/integrated_circuit/logic/unary/proc/do_check(var/datum/integrated_io/A)
	return FALSE

/obj/item/integrated_circuit/logic/binary/equals
	name = "equal gate"
	desc = "This gate compares two values, and outputs the number one if both are the same."
	icon_state = "equal"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/equals/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	if(istext(A.data) && istext(B.data)) // Also compare strings to better match circuit description.
		return lowertext(A.data) == lowertext(B.data)
	return A.data == B.data

/obj/item/integrated_circuit/logic/binary/jklatch
	name = "JK latch"
	desc = "This gate is a synchronysed JK latch."
	icon_state = "jklatch"
	inputs = list("J","K")
	outputs = list("Q","!Q")
	activators = list("pulse in C" = IC_PINTYPE_PULSE_IN, "pulse out Q" = IC_PINTYPE_PULSE_OUT, "pulse out !Q" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/lstate=FALSE

/obj/item/integrated_circuit/logic/binary/jklatch/do_work()
	pull_data()
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/B = inputs[2]
	var/datum/integrated_io/O = outputs[1]
	var/datum/integrated_io/Q = outputs[2]
	if(A.data)
		if(B.data)
			lstate=!lstate
		else
			lstate = TRUE
	else
		if(B.data)
			lstate=FALSE
	O.data = lstate ? TRUE : FALSE
	Q.data = !lstate ? TRUE : FALSE
	if(get_pin_data(IC_OUTPUT, 1))
		activate_pin(2)
	else
		activate_pin(3)
	push_data()

/obj/item/integrated_circuit/logic/binary/rslatch
	name = "RS latch"
	desc = "This gate is synchronysed a RS latch. If both R and S are true, the state will not change."
	icon_state = "sr_nor"
	inputs = list("S","R")
	outputs = list("Q","!Q")
	activators = list("pulse in C" = IC_PINTYPE_PULSE_IN, "pulse out Q" = IC_PINTYPE_PULSE_OUT, "pulse out !Q" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/lstate=FALSE

/obj/item/integrated_circuit/logic/binary/rslatch/do_work()
	pull_data()
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/B = inputs[2]
	var/datum/integrated_io/O = outputs[1]
	var/datum/integrated_io/Q = outputs[2]
	if(A.data)
		if(!B.data)
			lstate=TRUE
	else
		if(B.data)
			lstate=FALSE
	O.data = lstate ? TRUE : FALSE
	Q.data = !lstate ? TRUE : FALSE
	if(get_pin_data(IC_OUTPUT, 1))
		activate_pin(2)
	else
		activate_pin(3)
	push_data()

/obj/item/integrated_circuit/logic/binary/gdlatch
	name = "gated D latch"
	desc = "This gate is a synchronysed gated D latch."
	icon_state = "gated_d"
	inputs = list("D","E")
	outputs = list("Q","!Q")
	activators = list("pulse in C" = IC_PINTYPE_PULSE_IN, "pulse out Q" = IC_PINTYPE_PULSE_OUT, "pulse out !Q" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/lstate=FALSE

/obj/item/integrated_circuit/logic/binary/gdlatch/do_work()
	pull_data()
	var/datum/integrated_io/A = inputs[1]
	var/datum/integrated_io/B = inputs[2]
	var/datum/integrated_io/O = outputs[1]
	var/datum/integrated_io/Q = outputs[2]
	if(B.data)
		if(A.data)
			lstate=TRUE
		else
			lstate=FALSE

	O.data = lstate ? TRUE : FALSE
	Q.data = !lstate ? TRUE : FALSE
	if(get_pin_data(IC_OUTPUT, 1))
		activate_pin(2)
	else
		activate_pin(3)
	push_data()

/obj/item/integrated_circuit/logic/binary/not_equals
	name = "not equal gate"
	desc = "This gate compares two values, and outputs the number one if both are different."
	icon_state = "not_equal"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/not_equals/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	if(istext(A.data) && istext(B.data)) // Also compare strings to better match circuit description.
		return lowertext(A.data) != lowertext(B.data)
	return A.data != B.data

/obj/item/integrated_circuit/logic/binary/and
	name = "and gate"
	desc = "This gate will output 'one' if both inputs evaluate to true."
	icon_state = "and"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/and/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return A.data && B.data

/obj/item/integrated_circuit/logic/binary/or
	name = "or gate"
	desc = "This gate will output 'one' if one of the inputs evaluate to true."
	icon_state = "or"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/or/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return A.data || B.data

/obj/item/integrated_circuit/logic/binary/less_than
	name = "less than gate"
	desc = "This will output 'one' if the first input is less than the second input."
	icon_state = "less_than"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/less_than/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return A.data < B.data

/obj/item/integrated_circuit/logic/binary/less_than_or_equal
	name = "less than or equal gate"
	desc = "This will output 'one' if the first input is less than, or equal to the second input."
	icon_state = "less_than_or_equal"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/less_than_or_equal/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return A.data <= B.data

/obj/item/integrated_circuit/logic/binary/greater_than
	name = "greater than gate"
	desc = "This will output 'one' if the first input is greater than the second input."
	icon_state = "greater_than"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/greater_than/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return A.data > B.data

/obj/item/integrated_circuit/logic/binary/greater_than_or_equal
	name = "greater_than or equal gate"
	desc = "This will output 'one' if the first input is greater than, or equal to the second input."
	icon_state = "greater_than_or_equal"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/binary/greater_than_or_equal/do_compare(var/datum/integrated_io/A, var/datum/integrated_io/B)
	return A.data >= B.data

/obj/item/integrated_circuit/logic/unary/not
	name = "not gate"
	desc = "This gate inverts what's fed into it."
	icon_state = "not"
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	activators = list("invert" = IC_PINTYPE_PULSE_IN, "on inverted" = IC_PINTYPE_PULSE_OUT)

/obj/item/integrated_circuit/logic/unary/not/do_check(var/datum/integrated_io/A)
	return !A.data

/obj/item/integrated_circuit/logic/toggler // Allows parts of circuits to be toggled on/off.
	name = "circuit toggler"
	desc = "Outputs its input data if enabled, otherwise does nothing. Used for enable/disabling parts of your circuit boards"
	icon_state = "toggle_button"
	inputs = list(
		"input" = IC_PINTYPE_ANY,
		"enabled" = IC_PINTYPE_BOOLEAN,
		"toggle enable" = IC_PINTYPE_PULSE_IN,
	)
	inputs_default = list("2" = TRUE)
	outputs = list("output" = IC_PINTYPE_ANY)
	activators = list(
		"pulse in" = IC_PINTYPE_PULSE_IN,
		"pulse out" = IC_PINTYPE_PULSE_OUT
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/logic/toggler/do_work()
	pull_data()
	var/enabled_input = get_pin_data(IC_INPUT, 2)
	if(!enabled_input)
		return
	else
		set_pin_data(IC_OUTPUT, 1, get_pin_data(IC_INPUT, 1))
		push_data()
		activate_pin(2)
