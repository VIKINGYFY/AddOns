---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.ContextIcon; env.ContextIcon = NS

--------------------------------

NS.Variables = {}

--------------------------------

function NS.Variables:Load()
	--------------------------------
	-- VARIABLES
	--------------------------------

	do -- CONSTANTS
		do -- MAIN
			NS.Variables.PATH = env.CS:GetAddonPath() .. "Art/Elements/ContextIcons/"
		end

		do -- DATA
			NS.Variables.ICON_MAP = {
				-- GOSSIP
				["132053"] = "gossip-bubble",

				-- DEFAULT
				["132048"] = "quest-complete",
				["132049"] = "quest-available",
				["-1746"] = "quest-available", -- Cata classic bug?

				-- CLASSIC ERA
				["136788"] = "quest-available",

				-- IMPORTANT
				["importantactivequesticon"] = "quest-important-complete",
				["importantavailablequesticon"] = "quest-important-available",
				["importantincompletequesticon"] = "quest-important-active",

				-- RECURRING
				["Recurringactivequesticon"] = "quest-recurring-complete",
				["Recurringavailablequesticon"] = "quest-recurring-available",
				["Recurringincompletequesticon"] = "quest-recurring-active",

				-- REPEATABLE
				["Repeatableactivequesticon"] = "quest-repeatable-complete",
				["Repeatableavailablequesticon"] = "quest-repeatable-available",
				["Repeatableicnompletequesticon"] = "quest-repeatable-active",

				-- CAMPAIGN
				["CampaignActiveQuestIcon"] = "quest-campaign-complete",
				["CampaignAvailableQuestIcon"] = "quest-campaign-available",
				["CampaignIncompleteQuestIcon"] = "quest-campaign-active",
				["CampaignActiveDailyQuestIcon"] = "quest-campaign-recurring-complete",
				["CampaignAvailableDailyQuestIcon"] = "quest-campaign-recurring-available",

				-- META
				["Wrapperactivequesticon"] = "quest-meta-complete",
				["Wrapperavailablequesticon"] = "quest-meta-available",
				["Wrapperincompletequesticon"] = "quest-meta-active",

				-- LEGENDARY
				["legendaryactivequesticon"] = "quest-legendary-complete",
				["legendaryavailablequesticon"] = "quest-legendary-available",
				["legendaryincompletequesticon"] = "quest-legendary-active",

				-- IN_PROGRESS
				["CampaignInProgressQuestIcon"] = "quest-campaign-active",
				["RepeatableInProgressquesticon"] = "quest-recurring-active",
				["SideInProgressquesticon"] = "quest-active",
				["importantInProgressquesticon"] = "quest-important-active",
				["WrapperInProgressquesticon"] = "quest-meta-active",
				["legendaryInProgressquesticon"] = "quest-legendary-active",
			}
		end
	end

	do -- MAIN

	end
end
