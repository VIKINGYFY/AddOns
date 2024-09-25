local E, L, C = select(2, ...):unpack()

if E.isClassic then E.changelog = [=[
v1.15.4.2806
	bump toc
]=]
elseif E.isBCC then E.changelog = [=[
v2.5.4.2722
	Fixed sync for cross realm group members
]=]
elseif E.isWOTLKC then E.changelog = [=[
v3.4.3.2773
	Added season 8 Wrathful Gladiator's set bonuses
	Fixed incorrect sorting when a unit dies or resurrects on ver.2772
	Added option to change icon texture for 'Trinket, Main Hand, Consumables' spell type.
]=]
elseif E.isCata then E.changelog = [=[
v4.4.0.2803
	minor bug fix
]=]
else E.changelog = [=[
v11.0.2.2806
	GW2UI anchor updates
	Healbot anchor fix
	Zone profile copy fix
	Breath of Eons w/ Terror of the Skies texture fix
	Addon will corectly update on zone change w/o a loading screen (e.g. Delves)
	Sync list updated for Brewmaster Monk

	HOTFIXES
		September 5, 2024:
			Face Palm's CDR fixed
			Peaceweaver CDR updated to 33% (was 50%)
		September 17, 2024:
			Witch Doctor’s Ancestry CDR updated to 1 sec (was 2 sec)
			Peaceweaver CDR updated to 16% (was 33%)

v11.0.2.2804
	minor bug fixes
	zhCN localization update

v11.0.2.2803
	Release for WoW: The War Within

]=]
end

E.changelog = E.changelog .. "\n\n|cff808080Full list of changes can be found in the CHANGELOG file"
