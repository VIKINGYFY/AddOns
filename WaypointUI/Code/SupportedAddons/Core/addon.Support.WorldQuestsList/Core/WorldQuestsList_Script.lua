---@class env
local env = select(2, ...)
local NS = env.Support.WorldQuestsList; env.Support.WorldQuestsList = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	--------------------------------
	-- REFERENCES
	--------------------------------

	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do

	end

	--------------------------------
	-- EVENTS
	--------------------------------

	--------------------------------
	-- SETUP
	--------------------------------

	do
		C_Timer.After(10, function()
			env.C.SlashCommand.Script:RemoveSlashCommand("WQLSlashWay")
		end)
	end
end
