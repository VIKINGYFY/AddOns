---@class env
local env = select(2, ...)
local CallbackRegistry = env.C.CallbackRegistry.Script
local PrefabRegistry = env.C.PrefabRegistry.Script
local TagManager = env.C.TagManager.Script
local L = env.C.AddonInfo.Locales
local NS = env.C.FrameTemplates; env.C.FrameTemplates = NS

--------------------------------
-- VARIABLES
--------------------------------

do -- MAIN

end

do -- CONSTANTS

end

--------------------------------
-- TEMPLATES
--------------------------------

do
	-- Creates a frame
	function NS:CreateFrame(...)
		local Frame = CreateFrame(...)

		--------------------------------

		do -- LOGIC
			do -- FUNCTIONS
				do -- GET
					-- Returns the frame's id
					function Frame:GetId()
						return Frame.C_REFERENCE_REGISTRY_ID
					end

					-- Returns the frame's class
					function Frame:GetClass()
						return Frame.C_REFERENCE_REGISTRY_CLASS
					end
				end

				do -- SET
					-- Adds the frame to the reference registry under an id. The id must be unique.
					---@param id string
					function Frame:SetId(id)
						TagManager.Id:Add(Frame, id)
					end

					-- Adds the frame to the reference registry under a class. The class may contain multiple frames.
					---@param class string
					function Frame:SetClass(class)
						TagManager.Class:Add(Frame, class)
					end

					-- Removes the frame from the reference registry under an id.
					function Frame:RemoveId()
						TagManager.Id:Remove(Frame:GetId())
					end

					-- Removes the frame from the reference registry in a class.
					function Frame:RemoveClass()
						TagManager.Class:Remove(Frame, Frame:GetClass())
					end
				end
			end

			--------------------------------

			return Frame
		end
	end
end
