---@class env
local env = select(2, ...)

env.Support.MapPinEnhanced = {}
local NS = env.Support.MapPinEnhanced; env.Support.MapPinEnhanced = NS

function NS:Load()
	NS.Script:Load()
end

C_Timer.After(env.C.Variables.INIT_DELAY_LAST, function()
	if env.C.WoWClient.Script:IsAddOnLoaded("MapPinEnhanced") then
		NS:Load()
	end
end)
