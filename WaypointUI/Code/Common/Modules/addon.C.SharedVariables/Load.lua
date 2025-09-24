---@class env
local env = select(2, ...)

--------------------------------

env.C.SharedVariables = {}
local NS = env.C.SharedVariables; env.C.SharedVariables = NS

--------------------------------

function NS:Load()
	local function Modules()

	end

	--------------------------------

	Modules()
end
