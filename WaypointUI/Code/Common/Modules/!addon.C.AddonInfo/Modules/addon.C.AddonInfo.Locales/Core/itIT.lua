---@class env
local env = select(2, ...)
local L = env.C.AddonInfo.Locales

--------------------------------

L.itIT = {}
local NS = L.itIT; L.itIT = NS

--------------------------------

function NS:Load()
	if GetLocale() ~= "itIT" then
		return
	end
end

NS:Load()
