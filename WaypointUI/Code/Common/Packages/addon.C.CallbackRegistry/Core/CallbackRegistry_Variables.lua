---@class env
local env = select(2, ...)
local NS = env.C.CallbackRegistry; env.C.CallbackRegistry = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- MAIN
		NS.Variables.Callbacks = {}
	end

	do -- CONSTANTS

	end
end
