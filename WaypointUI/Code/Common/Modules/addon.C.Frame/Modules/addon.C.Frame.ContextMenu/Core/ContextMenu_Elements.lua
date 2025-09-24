---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.Frame.ContextMenu; env.C.Frame.ContextMenu = NS

--------------------------------

NS.Elements = {}

--------------------------------

function NS.Elements:Load()
	local Frame = env.CS:GetCommonFrame()

	--------------------------------
	-- CREATE ELEMENTS
	--------------------------------

	do
		do -- ELEMENTS
			Frame.ContextMenu = env.C.FrameTemplates:CreateFrame("Frame", "$parent.ContextMenu", Frame)
			Frame.ContextMenu:SetPoint("CENTER", Frame)
			Frame.ContextMenu:SetFrameStrata(NS.Variables.FRAME_STRATA)
			Frame.ContextMenu:SetFrameLevel(NS.Variables.FRAME_LEVEL)
			env.C.API.FrameUtil:SetDynamicSize(Frame.ContextMenu, Frame, 0, 0)

			local Frame_ContextMenu = Frame.ContextMenu

			--------------------------------

			do -- MAIN
				Frame_ContextMenu.Main = PrefabRegistry:Create("C.Frame.ContextMenu", Frame_ContextMenu, NS.Variables.FRAME_STRATA, NS.Variables.FRAME_LEVEL + 1, nil, "$parent.Main")
			end
		end

		do -- REFERENCES

		end
	end

	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame_ContextMenu = Frame.ContextMenu
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Frame_ContextMenu.Main:Hide()
		Frame_ContextMenu.Main.hidden = true
	end
end
