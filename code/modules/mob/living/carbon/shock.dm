/mob/living/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	if (species && (species.flags & NO_PAIN))
		src.traumatic_shock = 0
		return 0

	src.traumatic_shock = 			\
	1	* src.getOxyLoss() + 		\
	0.7	* src.getToxLoss() + 		\
	2.5	* src.getFireLoss() + 		\
	1.5	* src.getBruteLoss() + 		\
	1.8	* src.getCloneLoss() + 		\
	1.5	* src.halloss

	if(reagents.has_reagent("alkysine"))
		src.traumatic_shock -= 10
	if(reagents.has_reagent("inaprovaline"))
		src.traumatic_shock -= 25
	if(reagents.has_reagent("synaptizine"))
		src.traumatic_shock -= 40
	if(reagents.has_reagent("paracetamol"))
		src.traumatic_shock -= 50
	if(reagents.has_reagent("tramadol"))
		src.traumatic_shock -= 80
	if(reagents.has_reagent("oxycodone"))
		src.traumatic_shock -= 200
	if(src.slurring)
		src.traumatic_shock -= 20
	if(src.analgesic)
		src.traumatic_shock = 0

	//Broken or ripped off organs will add quite a bit of pain
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = src
		for(var/datum/organ/external/organ in M.organs)
			if (!organ)
				continue
			if((organ.status & ORGAN_DESTROYED) && !organ.amputated)
				src.traumatic_shock += 60
			else if(organ.status & ORGAN_BROKEN || organ.open)
				src.traumatic_shock += 30
				if(organ.status & ORGAN_SPLINTED)
					src.traumatic_shock -= 25
			if(organ.status && (organ.germ_level >= INFECTION_LEVEL_ONE))
				src.traumatic_shock += organ.germ_level * 0.05

		//Internal organs hurt too
		for(var/datum/organ/internal/organ in M.internal_organs)
			if (!organ)
				continue
			if(organ.damage)
				src.traumatic_shock += organ.damage * 1.5
			if(organ.germ_level >= INFECTION_LEVEL_ONE)
				src.traumatic_shock += organ.germ_level * 0.05
	if(src.traumatic_shock < 0)
		src.traumatic_shock = 0

	return src.traumatic_shock


/mob/living/carbon/proc/handle_shock()
	updateshock()
