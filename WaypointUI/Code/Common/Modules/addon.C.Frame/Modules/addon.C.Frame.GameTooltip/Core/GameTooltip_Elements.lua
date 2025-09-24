---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.Frame.GameTooltip; env.C.Frame.GameTooltip = NS

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
			Frame.GameTooltip = env.C.FrameTemplates:CreateFrame("GameTooltip", "$parent.GameTooltip", Frame, "GameTooltipTemplate")
			Frame.ShoppingTooltip1 = env.C.FrameTemplates:CreateFrame("GameTooltip", "$parent.ShoppingTooltip1", Frame, "GameTooltipTemplate")
			Frame.ShoppingTooltip2 = env.C.FrameTemplates:CreateFrame("GameTooltip", "$parent.ShoppingTooltip2", Frame, "GameTooltipTemplate")

			--------------------------------

			do -- STYLE
				local function StyleTooltip(tooltip, texture, color)
					local FRAME_STRATA = tooltip:GetFrameStrata()
					local FRAME_LEVEL = tooltip:GetFrameLevel()

					--------------------------------

					do -- BLIZZARD
						tooltip.NineSlice:SetAlpha(0)
					end

					do -- CUSTOM
						tooltip.Custom = env.C.FrameTemplates:CreateFrame("Frame", "$parent.Custom", tooltip)
						tooltip.Custom:SetAllPoints(tooltip)
						tooltip.Custom:SetFrameStrata(FRAME_STRATA)
						tooltip.Custom:SetFrameLevel(FRAME_LEVEL)

						--------------------------------

						do -- BACKGROUND
							tooltip.Custom.Background, tooltip.Custom.BackgroundTexture = env.C.FrameTemplates:CreateNineSlice(tooltip.Custom, FRAME_STRATA, texture, 95, .125, "$parent.Background", Enum.UITextureSliceMode.Stretched)
							tooltip.Custom.Background:SetPoint("TOPLEFT", tooltip.Custom, -15, 15)
							tooltip.Custom.Background:SetPoint("BOTTOMRIGHT", tooltip.Custom, 15, -15)
							tooltip.Custom.Background:SetFrameStrata(FRAME_STRATA)
							tooltip.Custom.Background:SetFrameLevel(FRAME_LEVEL - 1)
							tooltip.Custom.BackgroundTexture:SetVertexColor(color, color, color)
						end
					end
				end

				--------------------------------

				StyleTooltip(Frame.GameTooltip, env.C.AddonInfo.Variables.GameTooltip.TOOLTIP_STYLE["GameTooltip"].texture, env.C.AddonInfo.Variables.GameTooltip.TOOLTIP_STYLE["GameTooltip"].modifier)
				StyleTooltip(Frame.ShoppingTooltip1, env.C.AddonInfo.Variables.GameTooltip.TOOLTIP_STYLE["ShoppingTooltip1"].texture, env.C.AddonInfo.Variables.GameTooltip.TOOLTIP_STYLE["ShoppingTooltip1"].modifier)
				StyleTooltip(Frame.ShoppingTooltip2, env.C.AddonInfo.Variables.GameTooltip.TOOLTIP_STYLE["ShoppingTooltip2"].texture, env.C.AddonInfo.Variables.GameTooltip.TOOLTIP_STYLE["ShoppingTooltip2"].modifier)
			end
		end
	end

	--------------------------------
	-- REFERENCES
	--------------------------------

	local Frame_GameTooltip = Frame.GameTooltip
	local Frame_ShoppingTooltip1 = Frame.ShoppingTooltip1
	local Frame_ShoppingTooltip2 = Frame.ShoppingTooltip2
	local Callback = NS.Script; NS.Script = Callback

	--------------------------------
	-- SETUP
	--------------------------------

	do
		Frame_GameTooltip.shoppingTooltips = { Frame_ShoppingTooltip1, Frame_ShoppingTooltip2 }
	end
end
