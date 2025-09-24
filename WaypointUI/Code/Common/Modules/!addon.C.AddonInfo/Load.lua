---@class env
local env = select(2, ...)

--------------------------------

env.C.AddonInfo = {}
local NS = env.C.AddonInfo; env.C.AddonInfo = NS

--------------------------------

function NS:Load()
	local function Modules()

	end

	--------------------------------

	Modules()
end
