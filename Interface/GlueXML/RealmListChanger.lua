
if not LOAD_REALMLIST_CHANGER then
	return
end

--if LOAD_REALMLIST_CHANGER then

REALMLIST_BUTTON_HEIGHT = 32
MAX_REALMLISTS_DISPLAYED = 10

REALMLIST_SEPARATOR = "#!#"
REALMLIST_ADDRESS_SEPARATOR = "#?#"
REALMLIST_ACCINFO_SEPARATOR = "#$#"

REALMLIST_USED = -1
REALMLIST_USED_BEFORE = -1
REALMLIST_TABLE = {}
REALMLIST_TABLE_BEFORE = {}

-- Impl

local isEditing = false

GlueDialogTypes["DELETE_REALMLIST"] = {
	text = "Do you really want to delete this realmlist?",
	button1 = YES,
	button2 = NO,
	OnAccept = function ()
		tremove(REALMLIST_TABLE, REALMLIST_USED)
		REALMLIST_USED = 0
		RealmListChangerUpdate()
	end,
	OnCancel = function()
	end,
}

function RealmListChangerButton_Add()
	RealmListChanger_EditingBackgroundFrame:Show()
	RealmListChanger_RealmListEditBox:SetFocus()
	RealmListChanger_RealmListEditBox:SetText("")
	RealmListChanger_RealmListNameEditBox:SetText("")
	isEditing = false
end

function RealmListChangerButton_Edit()
	RealmListChanger_EditingBackgroundFrame:Show()
	RealmListChanger_RealmListEditBox:SetText(REALMLIST_TABLE[REALMLIST_USED][1])
	RealmListChanger_RealmListNameEditBox:SetText(REALMLIST_TABLE[REALMLIST_USED][2])
	isEditing = true
end

function RealmListChangerButton_Delete()
	GlueDialog_Show("DELETE_REALMLIST")
end

function RealmListChanger_Editing_Input(self, userInput)
	if userInput and not isEditing then
		local str = self:GetText()
		local start = strsub(str, 1, 4)
		if start == "rli:" then
			local endS = strsub(str, 5, strlen(str))
			local rl, nm = unpack(string_explode(endS, "+"))
			RealmListChanger_RealmListEditBox:SetText(rl)
			RealmListChanger_RealmListNameEditBox:SetText(nm)
			RealmListChanger_Editing_Okay()
		end
	end
end

function RealmListChanger_Editing_Okay()
	if isEditing then
		REALMLIST_TABLE[REALMLIST_USED][1] = RealmListChanger_RealmListEditBox:GetText()
		REALMLIST_TABLE[REALMLIST_USED][2] = RealmListChanger_RealmListNameEditBox:GetText()
	else
		local newData = {
			RealmListChanger_RealmListEditBox:GetText(),
			RealmListChanger_RealmListNameEditBox:GetText(),
			"",
			""
		}
		tinsert(REALMLIST_TABLE, newData)
	end
	
	RealmListChanger_Editing_Cancel()
	RealmListChangerUpdate()
end

function RealmListChanger_Editing_Cancel()
	RealmListChanger_EditingBackgroundFrame:Hide()
end

function RealmListChanger_Editing_Tab(self)
	if self:GetID() == 1 then
		RealmListChanger_RealmListNameEditBox:SetFocus()
	else
		RealmListChanger_RealmListEditBox:SetFocus()
	end
end

function RealmListChangerUpdate()
	local numRealmLists = #REALMLIST_TABLE
	local current = REALMLIST_USED
	local index
	
	RealmListChangerFrame_OkayButton:Disable();
	RealmListChangerFrame_EditButton:Disable();
	RealmListChangerFrame_DeleteButton:Disable();
	RealmListChangerFrame_Highlight:Hide()
	RealmListChangerFrame_Highlight:SetFrameStrata("TOOLTIP")
	for i=1,MAX_REALMLISTS_DISPLAYED do
		local button = _G["RealmListSelectButton"..i]
		if i > numRealmLists then
			button:Hide()
		else
			local realmlist = REALMLIST_TABLE[i][1]
			local name = REALMLIST_TABLE[i][2]
			local accname = REALMLIST_TABLE[i][3]
			local pwstring = REALMLIST_TABLE[i][4]
			local buttonName = _G[button:GetName().."Name"]
			local buttonRealmList = _G[button:GetName().."RealmList"]
			
			if name == "" then
				name = realmlist
				buttonName:ClearAllPoints()
				buttonName:SetPoint("LEFT", 5,0)
				buttonRealmList:SetText("")
			else
				buttonName:ClearAllPoints()
				buttonName:SetPoint("TOPLEFT", 5,-3)
				buttonRealmList:SetText(realmlist)
			end
			
			buttonName:SetText(name)
			button:Show()
			if current > 0 then 
				if i == current then
					button.highlightLocked = true
					RealmListChangerFrame_OkayButton:Enable()
					RealmListChangerFrame_EditButton:Enable()
					RealmListChangerFrame_DeleteButton:Enable()
					RealmListChangerFrame_Highlight:Show()
					RealmListChangerFrame_Highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 0,0)
					RealmListChangerFrame_HighlightTexture:SetVertexColor(0.1, 1.0, 0.1)
				else
					button.highlightLocked = false
					RLCB_Leave(button)
				end
			end
		end
	end
end

function RealmListChangerButton_Click(self)
	local id = self:GetID()
	REALMLIST_USED = id
	
	RealmListChangerUpdate()
end

function RealmListChangerButton_DoubleClick(self)
	local id = self:GetID()
	REALMLIST_USED = id
	
	RealmListChangerButton_Okay()
end

function RealmListChangerButton_Okay()
	local accName = REALMLIST_TABLE[REALMLIST_USED][3]
	local pwStrng = REALMLIST_TABLE[REALMLIST_USED][4]
	
	SetCVar("realmList", REALMLIST_TABLE[REALMLIST_USED][1] or "")
	if accName ~= "" then
		AccountLoginAccountEdit:SetText(accName)
		AccountLoginPasswordEdit:SetText(pwStrng)
	end
	RealmListChangerRealmList:SetText(GetCVar("realmList"))
	
	RealmListChanger:Hide()
end

function RealmListChangerButton_Cancel()
	REALMLIST_USED = REALMLIST_USED_BEFORE
	REALMLIST_TABLE = REALMLIST_TABLE_BEFORE
	
	RealmListChanger:Hide()
end

function RealmListChangerButton_OnKeyDown(self, key)
	if key=="ESCAPE" then
		RealmListChangerButton_Cancel()
	elseif key=="ENTER" then
		RealmListChangerButton_Okay()
	end
end

function RealmListChangerButton_OnShow()
	REALMLIST_USED_BEFORE = REALMLIST_USED
	REALMLIST_TABLE_BEFORE = REALMLIST_TABLE
	
	RealmListChangerUpdate()
end

function RealmListChangerButton_OnLoad()
	RealmListChangerRealmList:SetText(GetCVar("realmList"))
end

-- Form
backdropColor = DEFAULT_TOOLTIP_COLOR
backdropST = {		-- NEW EDITBOX BACKDROP
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Glues\\Common\\Glue-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = {
		left = 10,
		right = 5,
		top = 4,
		bottom = 9
	}
}

function RLCB_Enter(self)
	if not self.highlightLocked then
		_G[self:GetName().."Name"]:SetFontObject(GlueFontHighlightLeft)
	end
end

function RLCB_Leave(self)
	if not self.highlightLocked then
		_G[self:GetName().."Name"]:SetFontObject(GlueFontNormalLeft)
	end
end

function RLCB_MDown(self, button)
	if button == "LeftButton" then
		local p,rt,rp,xo,yo = _G[self:GetName().."Name"]:GetPoint()
		_G[self:GetName().."Name"]:SetPoint(p,rt,rp,xo+1,yo-1)
	end
end

function RLCB_MUp(self, button)
	if button == "LeftButton" then
		local p,rt,rp,xo,yo = _G[self:GetName().."Name"]:GetPoint()
		_G[self:GetName().."Name"]:SetPoint(p,rt,rp,xo-1,yo+1)
		if time() - self.lastClick < 1 then
			RealmListChangerButton_DoubleClick(self)
		else
			RealmListChangerButton_Click(self)
			self.lastClick = time()
		end
	end
end

function newRealmListCheckbox(i)
	b = CreateFrame("Frame", "RealmListSelectButton"..i, RealmListChangerFrame)
	b:EnableMouse(true)
	b:SetScript("OnEnter", RLCB_Enter)
	b:SetScript("OnLeave", RLCB_Leave)
	b:SetScript("OnMouseDown", RLCB_MDown)
	b:SetScript("OnMouseUp", RLCB_MUp)
	b.lastClick = 0
	b.highlightLocked = false
	
	b_text = b:CreateFontString("RealmListSelectButton"..i.."Name")
	b_text:SetSize(462,12)
	b_text:SetPoint("TOPLEFT", 5,0)
	b_text:SetFontObject(GlueFontNormalLeft)
	
	b_list = b:CreateFontString("RealmListSelectButton"..i.."RealmList")
	b_list:SetSize(462,12)
	b_list:SetPoint("TOPLEFT", b_text, "BOTTOMLEFT", 15,-6)
	b_list:SetFontObject(GlueFontDisableLeft)
	
	b:SetSize(512,REALMLIST_BUTTON_HEIGHT)
	b:SetID(i)
	b:Hide()
	
	return b
end

function newRealmListEditBox(frame, name)
	eb = CreateFrame("EditBox",name,frame)
	
	eb:SetSize(GlueParent:GetWidth()/2, 30)
	eb:SetPoint("CENTER")
	eb:SetBackdrop(backdropST)
	eb:SetFrameStrata("TOOLTIP")
	eb:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3])
	eb:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6])
	eb:SetFontObject("GlueEditBoxFont")
	eb:SetTextInsets(12,5,5,12)
	
	return eb
end

RealmListChanger = CreateFrame("Frame",nil,AccountLogin)
	RealmListChanger:SetToplevel(true)
	RealmListChanger:SetFrameStrata("DIALOG")
	RealmListChanger:SetAllPoints()
	RealmListChanger:EnableMouse(true)
	RealmListChanger:EnableKeyboard(true)
	RealmListChanger:Hide()
	RealmListChanger_BackgroundColor = RealmListChanger:CreateTexture(nil,"BACKGROUND")
		RealmListChanger_BackgroundColor:SetAllPoints()
		RealmListChanger_BackgroundColor:SetTexture(0,0,0,0.5)
	RealmListChanger:SetScript("OnLoad", RealmListChangerButton_OnLoad)
	RealmListChanger:SetScript("OnShow", RealmListChangerButton_OnShow)
	RealmListChanger:SetScript("OnKeyDown", RealmListChangerButton_OnKeyDown)
		
RealmListChangerFrame = CreateFrame("Frame",nil,RealmListChanger)
	RealmListChangerFrame:SetSize(640,512)
	RealmListChangerFrame:SetPoint("CENTER", 24,0)
	RealmListChangerFrame:SetHitRectInsets(0,44,0,13)
	RealmListChangerFrame_TopLeft = RealmListChangerFrame:CreateTexture(nil,"BACKGROUND")
		RealmListChangerFrame_TopLeft:SetSize(256,256)
		RealmListChangerFrame_TopLeft:SetPoint("TOPLEFT")
		RealmListChangerFrame_TopLeft:SetTexture("Interface/HelpFrame/HelpFrame-TopLeft")
	RealmListChangerFrame_Top = RealmListChangerFrame:CreateTexture(nil,"BACKGROUND")
		RealmListChangerFrame_Top:SetSize(256,256)
		RealmListChangerFrame_Top:SetPoint("TOPLEFT", 256,0)
		RealmListChangerFrame_Top:SetTexture("Interface/HelpFrame/HelpFrame-Top")
	RealmListChangerFrame_TopRight = RealmListChangerFrame:CreateTexture(nil,"BACKGROUND")
		RealmListChangerFrame_TopRight:SetSize(128,256)
		RealmListChangerFrame_TopRight:SetPoint("TOPRIGHT")
		RealmListChangerFrame_TopRight:SetTexture("Interface/HelpFrame/HelpFrame-TopRight")
	RealmListChangerFrame_BottomLeft = RealmListChangerFrame:CreateTexture(nil,"BACKGROUND")
		RealmListChangerFrame_BottomLeft:SetSize(256,256)
		RealmListChangerFrame_BottomLeft:SetPoint("BOTTOMLEFT")
		RealmListChangerFrame_BottomLeft:SetTexture("Interface/HelpFrame/HelpFrame-BotLeft")
	RealmListChangerFrame_Bottom = RealmListChangerFrame:CreateTexture(nil,"BACKGROUND")
		RealmListChangerFrame_Bottom:SetSize(256,256)
		RealmListChangerFrame_Bottom:SetPoint("BOTTOMLEFT", 256,0)
		RealmListChangerFrame_Bottom:SetTexture("Interface/HelpFrame/HelpFrame-Bottom")
	RealmListChangerFrame_BottomRight = RealmListChangerFrame:CreateTexture(nil,"BACKGROUND")
		RealmListChangerFrame_BottomRight:SetSize(128,256)
		RealmListChangerFrame_BottomRight:SetPoint("BOTTOMRIGHT")
		RealmListChangerFrame_BottomRight:SetTexture("Interface/HelpFrame/HelpFrame-BotRight")
	RealmListChangerFrame_Header = RealmListChangerFrame:CreateTexture(nil,"ARTWORK")
		RealmListChangerFrame_Header:SetSize(256,64)
		RealmListChangerFrame_Header:SetPoint("TOP", -12,12)
		RealmListChangerFrame_Header:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
	RealmListChangerFrame_HeaderString = RealmListChangerFrame:CreateFontString("RealmListChangerFrame_HeaderString","ARTWORK","GlueFontNormalSmall")
		RealmListChangerFrame_HeaderString:SetPoint("TOP", RealmListChangerFrame_Header, "TOP", 0,-14)
		RealmListChangerFrame_HeaderString:SetText("Realmlist Selection")
	RealmListChangerFrame_CloseButton = CreateFrame("Button",nil,RealmListChangerFrame,"GlueCloseButton")
		RealmListChangerFrame_CloseButton:SetPoint("TOPRIGHT", -42,-3)
		RealmListChangerFrame_CloseButton:SetScript("OnClick", RealmListChangerButton_Cancel)
	RealmListChangerFrame_Highlight = CreateFrame("Frame","RealmListChangerFrame_Highlight",RealmListChangerFrame)
		RealmListChangerFrame_Highlight:SetSize(557,REALMLIST_BUTTON_HEIGHT)
		RealmListChangerFrame_Highlight:SetPoint("TOPLEFT")
		RealmListChangerFrame_Highlight:Hide()
		RealmListChangerFrame_HighlightTexture = RealmListChangerFrame_Highlight:CreateTexture("RealmListChangerFrame_HighlightTexture","ARTWORK")
			RealmListChangerFrame_HighlightTexture:SetTexture("Interface\QuestFrame\UI-QuestLogTitleHighlight")
			RealmListChangerFrame_HighlightTexture:SetBlendMode("ADD")
	for i=1,MAX_REALMLISTS_DISPLAYED do
		b = newRealmListCheckbox(i)
		if i == 1 then
			b:SetPoint("TOPLEFT", 22,-56)
		else
			b:SetPoint("TOP", _G["RealmListSelectButton"..(i-1)], "BOTTOM", 0,-5)
		end
	end
	RealmListChangerFrame_CancelButton = CreateFrame("Button",nil,RealmListChangerFrame,"GlueButtonSmallTemplateBlue")
		RealmListChangerFrame_CancelButton:SetSize(125,35)
		RealmListChangerFrame_CancelButton:SetPoint("BOTTOMRIGHT", -46,13)
		RealmListChangerFrame_CancelButton:SetText("Cancel")
		RealmListChangerFrame_CancelButton:SetScript("OnClick", RealmListChangerButton_Cancel)
	RealmListChangerFrame_OkayButton = CreateFrame("Button",nil,RealmListChangerFrame,"GlueButtonSmallTemplateBlue")
		RealmListChangerFrame_OkayButton:SetSize(125,35)
		RealmListChangerFrame_OkayButton:SetPoint("RIGHT", RealmListChangerFrame_CancelButton, "LEFT", 8,0)
		RealmListChangerFrame_OkayButton:SetText("Okay")
		RealmListChangerFrame_OkayButton:SetScript("OnClick", RealmListChangerButton_Okay)
	RealmListChangerFrame_AddButton = CreateFrame("Button",nil,RealmListChangerFrame,"GlueButtonSmallTemplateBlue")
		RealmListChangerFrame_AddButton:SetSize(125,35)
		RealmListChangerFrame_AddButton:SetPoint("TOPLEFT", 9,-23)
		RealmListChangerFrame_AddButton:SetText("Add")
		RealmListChangerFrame_AddButton:SetScript("OnClick", RealmListChangerButton_Add)
	RealmListChangerFrame_EditButton = CreateFrame("Button",nil,RealmListChangerFrame,"GlueButtonSmallTemplateBlue")
		RealmListChangerFrame_EditButton:SetSize(125,35)
		RealmListChangerFrame_EditButton:SetPoint("TOPRIGHT", -66,-23)
		RealmListChangerFrame_EditButton:SetText("Edit")
		RealmListChangerFrame_EditButton:SetScript("OnClick", RealmListChangerButton_Edit)
	RealmListChangerFrame_DeleteButton = CreateFrame("Button",nil,RealmListChangerFrame,"GlueButtonSmallTemplateBlue")
		RealmListChangerFrame_DeleteButton:SetSize(125,35)
		RealmListChangerFrame_DeleteButton:SetPoint("RIGHT", RealmListChangerFrame_EditButton, "LEFT", 8,0)
		RealmListChangerFrame_DeleteButton:SetText("Delete")
		RealmListChangerFrame_DeleteButton:SetScript("OnClick", RealmListChangerButton_Delete)
		
	-- Editing Boxes (Add & Edit)
	RealmListChanger_EditingBackgroundFrame = CreateFrame("Frame",nil,GlueParent)
		RealmListChanger_EditingBackgroundFrame:SetFrameStrata("TOOLTIP")
		RealmListChanger_EditingBackgroundFrame:SetAllPoints(GlueParent)
		RealmListChanger_EditingBackgroundFrame:EnableMouse(true)
		RealmListChanger_EditingBackgroundFrame:EnableKeyboard(true)
		RealmListChanger_EditingBackgroundFrame:Hide()
	RealmListChanger_EditingBackground = RealmListChanger_EditingBackgroundFrame:CreateTexture(nil,"OVERLAY")
		RealmListChanger_EditingBackground:SetAllPoints(GlueParent)
		RealmListChanger_EditingBackground:SetTexture(0,0,0,0.75)
	RealmListChanger_RealmListEditBox = newRealmListEditBox(RealmListChanger_EditingBackgroundFrame, "RealmListChanger_RealmListEditBox")
		RealmListChanger_RealmListEditBox:SetID(1)
		RealmListChanger_RealmListEditBox:SetScript("OnEnterPressed", RealmListChanger_Editing_Okay)
		RealmListChanger_RealmListEditBox:SetScript("OnEscapePressed", RealmListChanger_Editing_Cancel)
		RealmListChanger_RealmListEditBox:SetScript("OnTextChanged", RealmListChanger_Editing_Input)
		RealmListChanger_RealmListEditBox:SetScript("OnTabPressed", RealmListChanger_Editing_Tab)
		local RealmListChanger_RealmListEditBoxText = RealmListChanger_RealmListEditBox:CreateFontString("RealmListChanger_RealmListEditBoxText", "OVERLAY", "GlueEditBoxFont")
			RealmListChanger_RealmListEditBoxText:SetPoint("RIGHT", RealmListChanger_RealmListEditBox, "LEFT", 0, 3)
			RealmListChanger_RealmListEditBoxText:SetText("Realmlist:")
	RealmListChanger_RealmListNameEditBox = newRealmListEditBox(RealmListChanger_EditingBackgroundFrame, "RealmListChanger_RealmListNameEditBox")
		RealmListChanger_RealmListNameEditBox:SetID(2)
		RealmListChanger_RealmListNameEditBox:SetPoint("TOP", RealmListChanger_RealmListEditBox, "BOTTOM", 0,0)
		RealmListChanger_RealmListNameEditBox:SetScript("OnEnterPressed", RealmListChanger_Editing_Okay)
		RealmListChanger_RealmListNameEditBox:SetScript("OnEscapePressed", RealmListChanger_Editing_Cancel)
		RealmListChanger_RealmListNameEditBox:SetScript("OnTextChanged", RealmListChanger_Editing_Input)
		RealmListChanger_RealmListNameEditBox:SetScript("OnTabPressed", RealmListChanger_Editing_Tab)
		local RealmListChanger_RealmListNameEditBoxText = RealmListChanger_RealmListNameEditBox:CreateFontString("RealmListChanger_RealmListNameEditBoxText", "OVERLAY", "GlueEditBoxFont")
			RealmListChanger_RealmListNameEditBoxText:SetPoint("RIGHT", RealmListChanger_RealmListNameEditBox, "LEFT", 0, 3)
			RealmListChanger_RealmListNameEditBoxText:SetText("(Optional) Name:")
	RealmListChangerFrame_Editing_CancelButton = CreateFrame("Button",nil,RealmListChanger_EditingBackgroundFrame,"GlueButtonSmallTemplateBlue")
		RealmListChangerFrame_Editing_CancelButton:SetSize(125,35)
		RealmListChangerFrame_Editing_CancelButton:SetPoint("TOP", RealmListChanger_RealmListNameEditBox, "BOTTOM", 70,0)
		RealmListChangerFrame_Editing_CancelButton:SetText("Cancel")
		RealmListChangerFrame_Editing_CancelButton:SetScript("OnClick", RealmListChanger_Editing_Cancel)
	RealmListChangerFrame_Editing_OkayButton = CreateFrame("Button",nil,RealmListChanger_EditingBackgroundFrame,"GlueButtonSmallTemplateBlue")
		RealmListChangerFrame_Editing_OkayButton:SetSize(125,35)
		RealmListChangerFrame_Editing_OkayButton:SetPoint("TOP", RealmListChanger_RealmListNameEditBox, "BOTTOM", -70,0)
		RealmListChangerFrame_Editing_OkayButton:SetText("Okay")
		RealmListChangerFrame_Editing_OkayButton:SetScript("OnClick", RealmListChanger_Editing_Okay)

RealmListChangerButton = CreateFrame("Button",nil,AccountLogin,"GlueButtonSmallTemplateBlue")
	RealmListChangerButton:SetText("Realmlist")
	RealmListChangerButton:SetPoint(AccountLoginCommunityButton:GetPoint(1))
	RealmListChangerButton:SetFrameStrata("HIGH")
	RealmListChangerButton:SetScript("OnClick", function()
		RealmListChanger:Show()
	end)

RealmListChangerRealmList = RealmListChangerButton:CreateFontString("RealmListChangerRealmList", "ARTWORK", "GlueFontDisableSmall")
	RealmListChangerRealmList:SetText(GetCVar("realmList"))
	RealmListChangerRealmList:SetJustifyH("LEFT")
	RealmListChangerRealmList:SetPoint("LEFT", RealmListChangerButton, "RIGHT", 0,2)
	
AccountLoginCommunityButton:ClearAllPoints()
AccountLoginCommunityButton:SetPoint("BOTTOM", RealmListChangerButton, "TOP", 0,0)

-- end
























