-- Initial
local addonName, ns = ...
ns[1] = {}			-- B, Basement
ns[2] = {}			-- C, Config
ns[3] = {}			-- L, LocaleDB
ns[4] = {}			-- DB, DataBase

_G[addonName] = ns

local B, C, L, DB = unpack(ns)

-- Events
local events = {}

local host = CreateFrame("Frame")
host:SetScript("OnEvent", function(_, event, ...)
	for func in pairs(events[event]) do
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			func(event, CombatLogGetCurrentEventInfo())
		else
			func(event, ...)
		end
	end
end)

function B:RegisterEvent(event, func, unit1, unit2)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end
	if not events[event] then
		events[event] = {}
		if unit1 then
			host:RegisterUnitEvent(event, unit1, unit2)
		else
			host:RegisterEvent(event)
		end
	end

	events[event][func] = true
end

function B:UnregisterEvent(event, func)
	if event == "CLEU" then
		event = "COMBAT_LOG_EVENT_UNFILTERED"
	end
	local funcs = events[event]
	if funcs and funcs[func] then
		funcs[func] = nil

		if not next(funcs) then
			events[event] = nil
			host:UnregisterEvent(event)
		end
	end
end