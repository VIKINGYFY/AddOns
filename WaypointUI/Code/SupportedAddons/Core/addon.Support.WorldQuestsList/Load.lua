---@class env
local env = select(2, ...)

env.Support.WorldQuestsList = {}
local NS = env.Support.WorldQuestsList; env.Support.WorldQuestsList = NS

function NS:Load()
	NS.Script:Load()
end

C_Timer.After(env.C.Variables.INIT_DELAY_LAST, function()
	if env.C.WoWClient.Script:IsAddOnLoaded("WorldQuestsList") then
		NS:Load()
	end
end)
