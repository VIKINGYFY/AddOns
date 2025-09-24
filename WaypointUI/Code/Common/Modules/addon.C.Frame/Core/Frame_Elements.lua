---@class env
local env = select(2, ...)
local NS = env.C.Frame; env.C.Frame = NS

--------------------------------

NS.Elements = {}

--------------------------------

function NS.Elements:Load()
	--------------------------------
	-- CREATE ELEMENTS
	--------------------------------

	do -- CREATE ELEMENTS
		do -- ELEMENTS
			local Frame = env.C.FrameTemplates:CreateFrame("Frame", env.C.AddonInfo.Variables.General.ADDON_FRAME_NAME, nil)
			Frame:SetId("root")
			Frame:SetSize(WorldFrame:GetSize())
			Frame:SetPoint("CENTER", nil)
			C_Timer.After(.1, function() Frame:SetScale(env.C.AddonInfo.Variables.General.UI_SCALE) end)

			env.C.AddonInfo.Variables.General.ADDON_FRAME = Frame
			_G[env.C.AddonInfo.Variables.General.ADDON_FRAME_NAME] = Frame

			--------------------------------

			do -- COMMON
				Frame.Common = env.C.FrameTemplates:CreateFrame("Frame", "$parent.Common", Frame)
				Frame.Common:SetAllPoints(Frame)

				env.C.AddonInfo.Variables.General.COMMON_FRAME = Frame.Common
			end
		end
	end

	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame = _G[env.C.AddonInfo.Variables.General.ADDON_FRAME_NAME]
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- SETUP
	--------------------------------

	do

	end
end
