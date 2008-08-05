OpenRolls = LibStub("AceAddon-3.0"):NewAddon("OpenRolls", 
    "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "GroupLib-1.0")
OpenRollsData = {}

local ItemLinkPattern = "|c%x+|H.+|h%[.+%]|h|r"

local tonumber = tonumber
local table = table
local pairs = pairs

local function CreateNameFrame()
    local frame = CreateFrame("Frame", "OpenRollsNameFrame", UIParent)
    frame:SetBackdrop({
        bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
        tile = true, tileSize = 32, edgeSize = 16, 
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })    
    frame:SetBackdropColor(0,0,0,1)
    frame:SetToplevel(true)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")

    local BankName = CreateFrame("EditBox", "OpenRollsBankName", frame, "InputBoxTemplate")
    BankName:SetAutoFocus(false)
    BankName:SetFontObject(ChatFontNormal)
    BankName:SetTextInsets(0,0,3,3)
    BankName:SetMaxLetters(12)
    BankName:SetPoint("BOTTOMLEFT", LootFrame, "TOPLEFT", 75, -4)
    BankName:SetHeight(20)
    BankName:SetWidth(110)
    BankName:SetScript("OnEnter", function(frame, ...)
        local GameTooltip = GameTooltip
        GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
        GameTooltip:SetText("Name of character to recieve bank loot", 1, 1, 1, 1)
        GameTooltip:Show()
    end)
    BankName:SetScript("OnLeave", function(frame, ...) GameTooltip:Hide() end)
    
    local BankString = frame:CreateFontString("OpenRollsBankString", "OVERLAY", "GameFontNormal")
    BankString:SetPoint("BOTTOMLEFT", BankName, "TOPLEFT")
    BankString:SetPoint("BOTTOMRIGHT", BankName, "TOPRIGHT")
    BankString:SetText("Bank Character")
    
    local ChantName = CreateFrame("EditBox", "OpenRollsChantName", frame, "InputBoxTemplate")
    ChantName:SetAutoFocus(false)
    ChantName:SetFontObject(ChatFontNormal)
    ChantName:SetTextInsets(0,0,3,3)
    ChantName:SetMaxLetters(12)
    ChantName:SetPoint("LEFT", BankName, "RIGHT", 10, 0)
    ChantName:SetHeight(20)
    ChantName:SetWidth(110)
    ChantName:SetScript("OnEnter", function(frame, ...)
        local GameTooltip = GameTooltip
        GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
        GameTooltip:SetText("Name of character to disenchant loot", 1, 1, 1, 1)
        GameTooltip:Show()
    end)
    ChantName:SetScript("OnLeave", function(frame, ...) GameTooltip:Hide() end)
    
    local ChantString = frame:CreateFontString("OpenRollsChantString", "OVERLAY", "GameFontNormal")
    ChantString:SetPoint("BOTTOMLEFT", ChantName, "TOPLEFT")
    ChantString:SetPoint("BOTTOMRIGHT", ChantName, "TOPRIGHT")
    ChantString:SetText("Disenchanter")
    
    frame:SetPoint("TOPLEFT", BankString, "TOPLEFT", -13, 8)
    frame:SetPoint("BOTTOMRIGHT", ChantName, "BOTTOMRIGHT", 8, -8)
    
    frame:Hide()
    return {frame = frame, 
            bankString = BankString, bankName = BankName, 
            chantString = ChantString, chantName = ChantName}
end


local NamesFrame = NamesFrame or CreateNameFrame()

function OpenRolls:GetDisenchanter()
    return NamesFrame.chantName:GetText()
end

function OpenRolls:GetBanker()
    return NamesFrame.bankName:GetText()
end

function OpenRolls:InitializeSavedVariables()
    local function Init(var, initial) 
        if OpenRollsData[var] == nil then
            OpenRollsData[var] = initial
        end
    end
    Init("ShowSummaryWhenRollsOver", true)
    Init("ShowLootWindows", "whenML")
    Init("ConfirmBeforeLooting", true)
    Init("Disenchanter", "")
    Init("Banker", "")
end

function OpenRolls:OnInitialize()
    OpenRolls:InitializeSavedVariables()
    NamesFrame.bankName:SetText(OpenRollsData.Banker)
    NamesFrame.chantName:SetText(OpenRollsData.Disenchanter)
end

function OpenRolls:PLAYER_LEAVING_WORLD()
    OpenRollsData.Disenchanter = NamesFrame.chantName:GetText()
    OpenRollsData.Banker = NamesFrame.bankName:GetText()
end

function OpenRolls:Roll(item, quantity, duration)
    if duration == nil or duration <= 0 then duration = 30 end
    OpenRolls:StartRoll(item, quantity)
    local timer = OpenRolls:ScheduleTimer(function() 
        OpenRolls:EndRoll(item, quantity)
        OpenRolls:UnregisterMessage("RollTrack_Roll")
    end, duration)
    
    OpenRolls:RegisterMessage("RollTrack_Roll", function(msg, char, roll, min, max)
        if not OpenRolls:AssignRoll(char, roll) then
            SendChatMessage("You have already rolled once for this item.", "WHISPER", nil, char)
            return
        end
        if OpenRolls:HasEverybodyRolled() then
            OpenRolls:EndRoll(item, quantity)
            OpenRolls:UnregisterMessage("RollTrack_Roll")
            OpenRolls:CancelTimer(timer)
        end
    end)
end

function OpenRolls:DistributeItemByName(player, slot)
    for i = 1, 40 do
        if GetMasterLootCandidate(i) == player then
            if OpenRollsData.ConfirmBeforeLooting == true then
                local str = "Do you wish to award " .. GetLootSlotLink(slot) .. " to " .. player .. "?"
                OpenRolls:CreateMessageBox(str, function() GiveMasterLoot(slot, i) end, function() end)
            else
                GiveMasterLoot(slot, i)
            end
            return true
        end
    end
    return false
end

local function CommandLine(str)
    local found, _, item, quantity = str:find("^(" .. ItemLinkPattern ..")%s*(%d*)$")
    if found then
        OpenRolls:Roll(item, tonumber(quantity) or 1)
        return
    end
    
    found, _, quantity, item = str:find("^(%d+)%s*x%s*(" .. ItemLinkPattern ..")$")
    if found then
        OpenRolls:Roll(item, tonumber(quantity) or 1)
        return
    end
    
    if str == "" then
        OpenRolls:ShowSummary()
        return
    end
    
    OpenRolls:Print("BAD [[" .. str .. "]]")
end

OpenRolls:RegisterChatCommand("openroll", CommandLine)

local lewt = {}

local function RepositionLootWindows()
    if #lewt == 0 then return end
    lewt[1]:ClearAllPoints()
    lewt[1]:SetPoint("LEFT", LootFrame, "RIGHT", -66, 0)
    lewt[1]:SetPoint("TOP", NamesFrame.frame, "BOTTOM", -4, 0)
    for i = 2, #lewt do
        lewt[i]:ClearAllPoints()
        lewt[i]:SetPoint("TOPLEFT", lewt[i-1], "BOTTOMLEFT")
    end
end

local AttachedLootWindows = {}

function OpenRolls:RegisterLootWindow(addon)
    table.insert(AttachedLootWindows, addon)
end

function OpenRolls:UnregisterLootWindow(addon)
    for i, j in pairs(AttachedLootWindows) do
        if j == addon then table.remove(AttachedLootWindows, i) return end
    end
end

function OpenRolls:LOOT_OPENED()
    if OpenRollsData.ShowLootWindows == 'never' then return end
    if OpenRollsData.ShowLootWindows == 'whenML' and (select(2, GetLootMethod())) ~= 0 then return end
    
    NamesFrame.frame:Show()
    lewt = {}
    local threshold = GetLootThreshold()
    for i = 1, GetNumLootItems() do
        if (select(4, GetLootSlotInfo(i))) >= threshold then
            local item = OpenRolls:CreateLootWindow("OpenRollsLootWindow" .. i, UIParent, i)
            for _, j in pairs(AttachedLootWindows) do
                item:AttachLootWindow(j)
            end
            table.insert(lewt, item)
            item:Show()
        end
    end
    RepositionLootWindows()
end

function OpenRolls:LOOT_CLOSED()
    NamesFrame.frame:Hide()
    for i, j in pairs(lewt) do
        j:Release()
    end
end

function OpenRolls:LOOT_SLOT_CLEARED(event, slot)
    local pos = nil
    for i, frame in pairs(lewt) do
        if frame.slot == slot then 
            frame:Release() 
            pos = i
        end
    end
    if pos ~= nil then table.remove(lewt, pos) end
    RepositionLootWindows()
end

OpenRolls:RegisterEvent("LOOT_OPENED")
OpenRolls:RegisterEvent("LOOT_CLOSED")
OpenRolls:RegisterEvent("LOOT_SLOT_CLEARED")
OpenRolls:RegisterEvent("PLAYER_LEAVING_WORLD")

OpenRollsTestAddon = {}
function OpenRollsTestAddon:CreateLootWindow(slot, parent)
    local f = CreateFrame("frame", "OpenRollsTestWindow" .. slot, parent)
    f:SetPoint("TOPLEFT", UIParent, "TOPLEFT")
    f:SetHeight(40)
    f:SetWidth(100)
    
    local greed = CreateFrame("button", "OpenRollsTestWindowGreed" .. slot, f, "UIPanelButtonTemplate")
    greed:SetPoint("TOPLEFT", f, "TOPLEFT")
    greed:SetHeight(20)
    greed:SetWidth(100)
    greed:SetText("Greed")
    greed:SetScript("OnClick", function(frame, ...)
        OpenRolls:Print("Greed " .. slot)
    end)
    
    local need = CreateFrame("button", "OpenRollsTestWindowNeed" .. slot, f, "UIPanelButtonTemplate")
    need:SetPoint("TOPLEFT", greed, "BOTTOMLEFT")
    need:SetHeight(20)
    need:SetWidth(100)
    need:SetText("Need")
    need:SetScript("OnClick", function(frame, ...)
        OpenRolls:Print("Need " .. slot)
    end)
    
    return f
end

