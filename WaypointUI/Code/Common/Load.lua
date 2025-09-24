---@class env
local env = select(2, ...)

--------------------------------

env.C = {}
local NS = env.C; env.C = NS

--------------------------------

function NS:Load()
	local function Modules()
		-- PACKAGES
		NS.CallbackRegistry:Load()
		NS.TagManager:Load()
		NS.PrefabRegistry:Load()

		-- PRIORITY
		NS.Frame:Load()
		NS.Sound:Load()
		NS.SharedVariables:Load()
		NS.DevTools:Load()
		NS.AddonInfo:Load()
		NS.Database:Load()
		NS.Fonts:Load()
		NS.EventListener:Load()
		NS.WoWClient:Load()

		-- CORE
		NS.API:Load()
		NS.FrameTemplates:Load()

		-- INITIALIZE
		NS.Initializer:Load()

		-- CONFIG
		C_Timer.After(.1, NS.Config.Load)

		-- ADDITIONAL
		NS.SlashCommand:Load()
	end

	--------------------------------

	Modules()
end

C_Timer.After(0, NS.Load)
