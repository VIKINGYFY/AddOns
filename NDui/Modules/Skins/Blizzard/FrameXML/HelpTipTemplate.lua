local _, ns = ...
local B, C, L, DB = unpack(ns)

local function reskinHelpTips(self)
	for frame in self.framePool:EnumerateActive() do
		if not frame.styled then
			if frame.OkayButton then B.ReskinButton(frame.OkayButton) end
			--if frame.CloseButton then B.ReskinClose(frame.CloseButton) end

			frame.styled = true
		end
	end
end

C.OnLoginThemes["HelpTipTemplate"] = function()

	reskinHelpTips(HelpTip)
	hooksecurefunc(HelpTip, "Show", reskinHelpTips)
end