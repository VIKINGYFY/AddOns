---@class env
local env = select(2, ...)

env.Support.UnlimitedMapPinDistance = {}
local NS = env.Support.UnlimitedMapPinDistance; env.Support.UnlimitedMapPinDistance = NS

function NS:Load()
	NS.Script:Load()
end

C_Timer.After(env.C.Variables.INIT_DELAY_LAST, function()
	if env.C.WoWClient.Script:IsAddOnLoaded("UnlimitedMapPinDistance") then
		NS:Load()
	end
end)
