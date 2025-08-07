---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")

---@class Categories: AceModule
---@field WipeCategory fun(self: Categories, ctx: Context, category: string)
---@field RegisterCategoryFunction fun(self: Categories, name: string, func: fun(data: ItemData): string|nil)
local categories = BetterBags:GetModule('Categories')

---@class Localization: AceModule
---@field G fun(self: Localization, key: string): string
local L = BetterBags:GetModule('Localization')

---@class Context: AceModule
---@field New fun(self: Context, name: string): Context
local context = BetterBags:GetModule('Context')

local ctx = context:New('Keystones_Event')

categories:WipeCategory(ctx, L:G("|cff7997dbKeystone|r"))

---@param data ItemData
categories:RegisterCategoryFunction("KeystonesCategoryFilter", function(data)
	if C_Item.IsItemKeystoneByID(data.itemInfo.itemID) then
		return L:G("|cff7997dbKeystone|r")
	end
	return nil
end)
