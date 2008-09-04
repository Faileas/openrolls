OpenRolls = LibStub("AceAddon-3.0"):NewAddon("OpenRolls", 
    "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "GroupLib-1.0", "Countdown-1.0")

local Group = LibStub("GroupLib-1.0")
    
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

local SummaryFrame
local currentItem, currentQuantity
local timer

function OpenRolls:GetDisenchanter()
    return NamesFrame.chantName:GetText()
end

function OpenRolls:GetBanker()
    return NamesFrame.bankName:GetText()
end

local function Init(var, initial)
    if OpenRollsData[var] == nil then
        OpenRollsData[var] = initial
    end
end

function OpenRolls:InitializeSavedVariables()
    Init("ShowSummaryWhenRollsOver", true)
    Init("ShowLootWindows", "whenML")
    Init("ConfirmBeforeLooting", true)
    Init("Disenchanter", "")
    Init("Banker", "")
    Init("Warning", true)
    Init("SilentTime", 25)
    Init("CountdownTime", 5)
    Init("RollMin", 1)
    Init("RollMax", 100)
end

local rolls = {}
local function HasRolled(char)
    return rolls[char] ~= nil and rolls[char] > 0
end

local function AssignRoll(msg, char, roll)
    if msg == "OpenRolls_Roll" then
        rolls[char] = roll
    elseif msg == "OpenRolls_Pass" then
        rolls[char] = -2
    elseif msg == "OpenRolls_Clear" then
        rolls[char] = 0
    else
        error("OpenRolls: AssignRoll: unknown argument type '" .. msg .. "'.", 3)
    end
    for c, r in pairs(rolls) do
        if r == 0 then return end
    end
    OpenRolls:EndRoll(currentItem, currentQuantity)
end

local function ClearRoll(msg, char)
    rolls[char] = 0
end

local function PassRoll(msg, char)
    rolls[char] = -1
end

local function Warning()
    if not OpenRollsData.Warning then return end

    OpenRolls:Communicate("The following players have not rolled: ")
    for c, r in pairs(rolls) do
        if r == 0 then
            OpenRolls:Communicate("   " .. c)
        end
    end
end

function OpenRolls:OnInitialize()
    OpenRolls:InitializeSavedVariables()
    NamesFrame.bankName:SetText(OpenRollsData.Banker)
    NamesFrame.chantName:SetText(OpenRollsData.Disenchanter)
    
    OpenRolls:RegisterMessage("OpenRolls_Roll", AssignRoll)
    OpenRolls:RegisterMessage("OpenRolls_Pass", AssignRoll)
    OpenRolls:RegisterMessage("OpenRolls_Clear", AssignRoll)
    
    SummaryFrame = OpenRolls:CreateSummaryFrame("OpenRollsSummaryFrame", UIParent)
end

function OpenRolls:PLAYER_LEAVING_WORLD()
    OpenRollsData.Disenchanter = NamesFrame.chantName:GetText()
    OpenRollsData.Banker = NamesFrame.bankName:GetText()
end

function OpenRolls:PrintWinners(item, quantity)
    OpenRolls:Communicate("Roll over for " .. quantity .. "x" .. item)
    if frame.strings[1]:Value() < 1 then
        OpenRolls:Communicate("   Nobody rolled")
        return
    end
    
    for i = 1, quantity do
        if frame.strings[i]:Value() < 1 then
            return
        end
        OpenRolls:Communicate(frame.strings[i]:GetPlayer() .. " rolled " .. frame.strings[i]:Value())
    end
end

function OpenRolls:Roll(item, quantity)
    if timer ~= nil then
        OpenRolls:Print("A roll is already in progress; please wait until it is finished before starting a new roll.")
        return
    end
    
    OpenRolls:Communicate("Begin roll for " .. quantity .. "x" .. item .. ".")
    rolls = {}
    for name, _, online in Group.Members() do
        if online then
            rolls[name] = 0
        else
            rolls[name] = -1
        end
    end
    
    currentItem = item
    currentQuantity = quantity
    SummaryFrame:BeginRoll(item, quantity)
    SummaryFrame:ShowSummary()
    timer = 
        OpenRolls:BeginCountdown({initial = OpenRollsData.SilentTime, 
                                 count = OpenRollsData.CountdownTime},
                                 "Communicate",
                                 {initial = Warning,
                                  count = function() 
                                    SummaryFrame:EndRoll(item, quantity)
                                    OpenRolls:UnregisterMessage("RollTrack_Roll")
                                  end})
    
    OpenRolls:RegisterMessage("RollTrack_Roll", function(msg, char, roll, min, max)
        if min ~= OpenRollsData.RollMin or max ~= OpenRollsData.RollMax then
            SendChatMessage("You rolled with a non-standard range [" 
                            .. OpenRollsData.RollMin .. ", " .. OpenRollsData.RollMax .. "]",
                            "WHISPER", nil, char)
            return
        end
        if HasRolled(char) then
            SendChatMessage("You have already rolled once for this item.", "WHISPER", nil, char)
            return
        end
        OpenRolls:SendMessage("OpenRolls_Roll", char, roll)
    end)
end

function OpenRolls:DistributeItemByName(player, window, followup)
    local slot = window.slot
    local item = GetLootSlotLink(slot)
    for i = 1, 40 do
        if GetMasterLootCandidate(i) == player then
            if OpenRollsData.ConfirmBeforeLooting == true then
                local str = "Do you wish to award " .. item .. " to " .. player .. "?"
                OpenRolls:CreateMessageBox(str, function() GiveMasterLoot(slot, i) 
                                                           followup(window, player)
                                                end, function() end)
            else
                GiveMasterLoot(slot, i)
                followup(window, player)
            end
            return true
        end
    end
    return false
end

function OpenRolls:EndRoll(item, quantity)
    OpenRolls:UnregisterMessage("RollTrack_Roll")
    for c, r in pairs(rolls) do
        if r == 0 then OpenRolls:SendMessage("OpenRolls_Pass") end
    end
    
    OpenRolls:PrintWinners(item, quantity)
    if OpenRollsData.ShowSummaryWhenRollsOver then
        OpenRolls:ShowSummary()
    end
    
    OpenRolls:CancelCountdown(OpenRolls.timer)

    timer = nil
    currentItem = nil
    currentQuantity = nil
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
        SummaryFrame:ShowSummary()
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

