local funActionPanel = CreateFrame("Frame", "FunActionPanel", UIParent)
funActionPanel:SetWidth(256)
funActionPanel:SetHeight(256)
funActionPanel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
funActionPanel:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
funActionPanel:SetBackdropColor(0, 0, 0, 1)
funActionPanel:Hide()

funActionPanel.title = funActionPanel:CreateFontString(nil, "OVERLAY")
funActionPanel.title:SetFontObject("GameFontHighlight")
funActionPanel.title:SetPoint("TOP", funActionPanel, "TOP", 0, -10)
funActionPanel.title:SetText("FunAction 設定")

local eventDropdown = CreateFrame("Frame", "FunActionEventDropdown", funActionPanel, "UIDropDownMenuTemplate")
eventDropdown:SetPoint("TOPLEFT", funActionPanel, "TOPLEFT", 10, -40)

local eventsList = {
    "CHAT_MSG_SPELL_SELF_BUFF",
    "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS",
    "CHAT_MSG_SPELL_SELF_DAMAGE",
    "CHAT_MSG_SPELL_AURA_GONE_SELF"
}

local selectedIndex = 1
local function EventDropdown_Initialize()
    for i, eventName in ipairs(eventsList) do
        local index = i
        local info = {}
        info.text = eventName
        info.value = index
        info.checked = (index == selectedIndex)
        info.func = function()
            selectedIndex = index
            UIDropDownMenu_SetSelectedID(eventDropdown, index)
            FunActionSaved.selectedIndex = index
        end
        UIDropDownMenu_AddButton(info, 1)
    end
end

UIDropDownMenu_Initialize(eventDropdown, EventDropdown_Initialize)
UIDropDownMenu_SetSelectedID(eventDropdown, selectedIndex)

local skillEditBox = CreateFrame("EditBox", nil, funActionPanel, "InputBoxTemplate")
skillEditBox:SetHeight(30)
skillEditBox:SetWidth(180)
skillEditBox:SetPoint("TOPLEFT", eventDropdown, "BOTTOMLEFT", 20, -10)
skillEditBox:SetAutoFocus(false)
skillEditBox:SetText("正义圣印")

local saveButton = CreateFrame("Button", nil, funActionPanel, "GameMenuButtonTemplate")
saveButton:SetPoint("BOTTOM", funActionPanel, "BOTTOM", 0, 10)
saveButton:SetHeight(30)
saveButton:SetWidth(120)
saveButton:SetText("儲存設定")
saveButton:SetScript("OnClick", function()
    FunActionSaved.spellName = skillEditBox:GetText()
    DEFAULT_CHAT_FRAME:AddMessage("已選擇事件：" .. eventsList[FunActionSaved.selectedIndex] .. "技能: " .. FunActionSaved.spellName)
    funActionPanel:Hide()
end)

--
local funActionButton = CreateFrame("Button", "GameMenuButtonFunAction", GameMenuFrame, "GameMenuButtonTemplate")
funActionButton:SetText("FunAction")
funActionButton:SetPoint("TOP", GameMenuButtonLogout, "BOTTOM", 0, 100)
funActionButton:SetScript("OnClick", function()
    HideUIPanel(GameMenuFrame)
    funActionPanel:Show()
end)

GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 22)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    FunActionSaved = FunActionSaved or {}
local clickedFrame = CreateFrame("Frame")
clickedFrame:RegisterEvent(eventsList[FunActionSaved.selectedIndex])
clickedFrame:SetScript("OnEvent", function()
    local msg = arg1
    if msg and string.find(msg, FunActionSaved.spellName) then
        ShowCustomImage()
        PlaySoundFile("Interface\\AddOns\\FunAction\\wav\\sound.wav")
    end
end)
end)

function ShowCustomImage()
    -- DEFAULT_CHAT_FRAME:AddMessage("test msg")
    local texture = UIParent:CreateTexture(nil, "OVERLAY")
    texture:SetTexture("Interface\\AddOns\\FunAction\\image\\image-1.tga")
    texture:SetWidth(256)
    texture:SetHeight(256)
    local screenWidth = UIParent:GetWidth()
    local screenHeight = UIParent:GetHeight()
    local textureWidth = 256
    local textureHeight = 256
    local x = screenWidth
    local y = (screenHeight - textureHeight) / 2
    texture:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, -y)
    texture:Show()

    local animFrame = CreateFrame("Frame")
    local phase = 1
    local startTime = GetTime()

    animFrame:SetScript("OnUpdate", function()
        local now = GetTime()
        local elapsed = now - startTime

        if phase == 1 then
            local progress = math.min(elapsed / 0.3, 1)
            x = UIParent:GetWidth() - (UIParent:GetWidth() - 1200) * progress
            texture:ClearAllPoints()
            texture:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, -y)

            if progress >= 1 then
                phase = 2
                startTime = now
            end

        elseif phase == 2 then
            texture:SetTexture("Interface\\AddOns\\FunAction\\image\\image-2.tga")
            if elapsed >= 0.9 then
                phase = 3
                startTime = now
            end

        elseif phase == 3 then
            texture:SetTexture("Interface\\AddOns\\FunAction\\image\\image-3.tga")
            local progress = math.min(elapsed / 0.3, 1)
            x = 1200 + (UIParent:GetWidth() - 1200) * progress
            texture:ClearAllPoints()
            texture:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, -y)

            if progress >= 1 then
                texture:Hide()
                animFrame:SetScript("OnUpdate", nil)
            end
        end
    end)
end