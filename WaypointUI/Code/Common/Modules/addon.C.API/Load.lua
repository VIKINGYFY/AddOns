---@class env
local env = select(2, ...)

--------------------------------

env.C.API = {}
local NS = env.C.API; env.C.API = NS

--------------------------------

function NS:Load()
	local function Modules()

	end

	--------------------------------

	Modules()
end
