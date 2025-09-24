---@class env
local env = select(2, ...)
local NS = env.C.PrefabRegistry; env.C.PrefabRegistry = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- MAIN
		NS.Variables.Prefabs = {}
		NS.Variables.PrefabVariables = {}
	end

	do -- CONSTANTS

	end
end
