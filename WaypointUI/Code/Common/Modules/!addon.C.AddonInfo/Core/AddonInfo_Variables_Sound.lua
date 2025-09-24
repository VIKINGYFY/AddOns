---@class env
local env = select(2, ...)
local NS = env.C.AddonInfo; env.C.AddonInfo = NS

--------------------------------

NS.Variables = NS.Variables or {}
NS.Variables.Sound = {}

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS
	NS.Variables.Sound.ENABLE_AUDIO = function()
		return env.C.Database.Variables.DB_GLOBAL.profile.AUDIO_GLOBAL
	end
end
