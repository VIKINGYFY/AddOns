local _, ns = ...
local B, C, L, DB = unpack(ns)

C.OnLoginThemes["HelpFrame"] = function()

	B.StripTextures(HelpFrame)
	B.CreateBG(HelpFrame)
	B.ReskinClose(HelpFrame.CloseButton)
	B.StripTextures(HelpBrowser.BrowserInset)

	B.StripTextures(BrowserSettingsTooltip)
	B.CreateBG(BrowserSettingsTooltip)
	B.ReskinButton(BrowserSettingsTooltip.CookiesButton)

	B.StripTextures(TicketStatusFrameButton)
	B.CreateBG(TicketStatusFrameButton)

	B.CreateBG(ReportCheatingDialog)
	ReportCheatingDialog.Border:Hide()
	B.ReskinButton(ReportCheatingDialogReportButton)
	B.ReskinButton(ReportCheatingDialogCancelButton)
	B.StripTextures(ReportCheatingDialogCommentFrame)
	B.CreateBDFrame(ReportCheatingDialogCommentFrame, .25)
end