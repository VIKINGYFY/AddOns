---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.Frame.ContextMenu; env.C.Frame.ContextMenu = NS

--------------------------------

NS.Script = {}

--------------------------------

function NS.Script:Load()
	local Frame = env.CS:GetCommonFrame()

	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame_ContextMenu = Frame.ContextMenu
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- FUNCTIONS (MAIN)
	--------------------------------

	do
		do -- MAIN
			function Callback:Main_Show(data)
				local parent, buttonParent, point, relativePoint, offsetX, offsetY, width, layoutInfo = data.parent, data.buttonParent, data.point, data.relativePoint, data.offsetX, data.offsetY, data.width, data.layoutInfo

				--------------------------------

				Frame_ContextMenu.Main:SetPoint(point, parent, relativePoint, offsetX, offsetY)
				Frame_ContextMenu.Main:SetWidth(width)
				Frame_ContextMenu.Main:SetLayout(layoutInfo)
				Frame_ContextMenu.Main:SetButtonParent(buttonParent)

				--------------------------------

				Frame_ContextMenu.Main:ShowWithAnimation()
			end

			function Callback:Main_Hide()
				Frame_ContextMenu.Main:HideWithAnimation()
			end

			function Callback:Main_IsShown()
				return Frame_ContextMenu.Main:IsShown()
			end
		end
	end

	--------------------------------
	-- EVENTS
	--------------------------------

	do

	end

	--------------------------------
	-- SETUP
	--------------------------------

	do

	end
end
