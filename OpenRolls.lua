OpenRolls = LibStub("AceAddon-3.0"):NewAddon("OpenRolls", 
    "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "GroupLib-1.0", "Countdown-1.0")

--I think this can be removed?  I really shouldn't have included a library I wrote as an expriment ><
local Group = LibStub("GroupLib-1.0")

OpenRolls.Defaults = {
    ShowSummaryWhenRollsOver = true,
    ShowLootWindows = "whenML",
    ConfirmBeforeLooting = true,
    Disenchanter = "",
    Banker = "",
    Warning = true,
    SilentTime = 25,
    CountdownTime = 5,
    RollMin = 1,
    RollMax = 100,
    LootFramesOffset = {horizontal = -68, vertical = -10},
    LootFramesAnchorFrame = "LootFrame",
    LootFramesAnchorFrom = "TOPLEFT",
    LootFramesAnchorTo = "TOPRIGHT",
    NameFramesOffset = {horizontal = 61, vertical = -13},
    NameFramesAnchorFrame = "LootFrame",
    NameFramesAnchorFrom = "BOTTOMLEFT",
    NameFramesAnchorTo = "TOPLEFT"
}

--Regex that matches an item link
local ItemLinkPattern = "|c%x+|H.+|h%[.+%]|h|r"

local tonumber = tonumber
local table = table
local pairs = pairs

--Sorts a table according to value instead of by key; comp is the comparison function
--  This is a really weird sort.  The parameters to comp are two key-value pairs.  Example:
--  Table - {a = 9, c = 5, b = 6}
--  comp(left, right) might be left = {key = a, value = 9}; right = {key = c, value = 5}
--  The return value is an array of these key-value pairs
--  If comp sorts by value, the returned array would be 
--    {1 = {key = c, value = 5}, 
--     2 = {key = b, value = 6},
--     3 = {key = a, value = 9}}
local function mysort(tbl, comp)
    local newtbl = {}
    local k = 1
    for i,j in pairs(tbl) do
        newtbl[k] = {key = i, value = j}
        k = k + 1
    end
    for i = 2, #newtbl do
        local value = newtbl[i]
        local j = i - 1
        while j >= 1 and comp(newtbl[j], value) do--strings[j]:Compare(value) do
            newtbl[j + 1] = newtbl[j]
            j = j - 1
        end
        newtbl[j+1] = value
    end
    return newtbl
end

--Creates the "Banker" and "Disenchanter" frames that get tacked above the default loot window
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
    frame:SetWidth(250)
    frame:SetHeight(48)
    frame:SetPoint("BOTTOMLEFT", LootFrame, "TOPLEFT", 61, -13)

    local BankName = CreateFrame("EditBox", "OpenRollsBankName", frame, "InputBoxTemplate")
    BankName:SetAutoFocus(false)
    BankName:SetFontObject(ChatFontNormal)
    BankName:SetTextInsets(0,0,3,3)
    BankName:SetMaxLetters(12)
    BankName:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 13, 8)
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
    
    local func = function(self, anchorFrom, anchor, anchorTo, x, y)
        self.frame:ClearAllPoints()
        self.frame:SetPoint(anchorFrom, anchor, anchorTo, x, y)
    end
    
    frame:Hide()

    return {frame = frame, 
            bankString = BankString, bankName = BankName, 
            chantString = ChantString, chantName = ChantName,
            SetPoint = func}
end


local NamesFrame = NamesFrame or CreateNameFrame()

--The OpenRolls copy of the summary frame...I'm only going to keep one, but its possible for
--  multiple versions to be created independantly
local SummaryFrame

--The item/quantity currently being rolled for, if any
local currentItem, currentQuantity

--The timer for the current roll, if any
local timer

function OpenRolls:GetDisenchanter()
    return NamesFrame.chantName:GetText()
end

function OpenRolls:GetBanker()
    return NamesFrame.bankName:GetText()
end

--a table of who has already rolled
--  index is the character's name
--  value is the character's roll
local rolls = {}
local function HasRolled(char)
    return rolls[char] ~= nil and rolls[char] > 0
end

--Modifies a character's roll, and ends the roll if neccessary
--  msg == 'roll' a roll is assigned
--  msg == 'pass' a roll is removed
--  msg == 'clear' a roll is reset
--  roll is only used when assigning a roll [msg=='roll']
local function AssignRoll(char, msg, roll)
    if msg == "roll" then
        rolls[char] = roll
    elseif msg == "pass" then
        rolls[char] = -2
    elseif msg == "clear" then
        rolls[char] = 0
    else
        error("OpenRolls: AssignRoll: unknown argument type '" .. msg .. "'.", 3)
    end
    for c, r in pairs(rolls) do
        if r == 0 then return end
    end
    OpenRolls:EndRoll(currentItem, currentQuantity)
end

--Equivilent to AssignRoll(char, 'clear')
--  Why is there a msg parameter?
local function ClearRoll(msg, char)
    rolls[char] = 0
end

--Equivilent to AssignRoll(char, 'pass')
--  See ClearRoll()
local function PassRoll(msg, char)
    rolls[char] = -1
end


--Prints people who have not yet rolled, if neccessary
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
    SummaryFrame = OpenRolls:CreateSummaryFrame("OpenRollsSummaryFrame", AssignRoll)

    OpenRollsData = setmetatable(OpenRollsData or {}, {__index = OpenRolls.Defaults})
    
    local Data = OpenRollsData
    NamesFrame.bankName:SetText(Data.Banker)
    NamesFrame.chantName:SetText(Data.Disenchanter)
    local anchor = Data.NameFramesAnchorFrame
    local anchorFrom = Data.NameFramesAnchorFrom
    local anchorTo = Data.NameFramesAnchorTo
    local offset = Data.NameFramesOffset
    NamesFrame:SetPoint(anchorFrom, anchor, anchorTo, offset.horizontal, offset.vertical)
    OpenRolls:CreateConfig()    
end

--Ensures changes get saved
function OpenRolls:PLAYER_LEAVING_WORLD()
    local Data = OpenRollsData
    Data.Disenchanter = NamesFrame.chantName:GetText()
    Data.Banker = NamesFrame.bankName:GetText()
end


--Sort the rolls table and prints the top rollers, one per item being rolled for
--  If there's a tie in the last position, prints additional names as appropriate
--  Actually rolling off this tie is up to the user
function OpenRolls:PrintWinners(item, quantity)
    OpenRolls:Communicate("Roll over for " .. quantity .. "x" .. item)
    local winners = mysort(rolls, function(i,j) return i.value < j.value end)
    if winners[1].value < 1 then
        OpenRolls:Communicate("   Nobody rolled")
    end
    
    for i = 1, quantity do
        if winners[i] == nil or winners[i].value < 1 then
            return
        end
        OpenRolls:Communicate(winners[i].key .. " rolled " .. winners[i].value)
    end
    local i = quantity + 1
    while winners[i] ~= nil and winners[i].value == winners[i-1].value do
        OpenRolls:Communicate(winners[i].key .. " rolled " .. winners[i].value)
        i = i + 1
    end
end

--Begins an actual roll
function OpenRolls:Roll(item, quantity)
    --we only want one roll at a time
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
                                    OpenRolls:EndRoll(item, quantity)
                                  end})
    
    --RollTrack_Roll is the message that is thrown when somebody rolls
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

        AssignRoll(char, "roll", roll)
        SummaryFrame:AssignRoll(char, "roll", roll)
    end)
end

--In their infinite wisdom, Blizzard decided that loot should be assigned via a random value
--  that apparently gets reassigned at their whim
--This bypasses this, allowing you to distribute to a specific person
--Optionally, it provides you with a confirmation box
--window is the loot window that asked for the distribution; it provides the item's slot
--followup is used to inform intrested third party addons about the distribution; what it
--  does is determained by the source of the distribution [the banker button does something
--  different from the Asisgn button, for instance]
function OpenRolls:DistributeItemByName(player, window, followup)
    if followup == nil then followup = function(window, player) end end
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

--Finishes the roll, printing winners, et cetera
function OpenRolls:EndRoll(item, quantity)
    OpenRolls:UnregisterMessage("RollTrack_Roll")
    for c, r in pairs(rolls) do
        if r == 0 then OpenRolls:SendMessage("OpenRolls_Pass") end
    end
    
    OpenRolls:PrintWinners(item, quantity)
    if OpenRollsData.ShowSummaryWhenRollsOver then
        SummaryFrame:ShowSummary()
    end
    
    OpenRolls:CancelCountdown(timer)

    timer = nil
    currentItem = nil
    currentQuantity = nil
end

--The function that gets called when somebody types /openroll
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
    
    if str:lower() == "config" then
        OpenRolls:ShowConfig()
        return
    end
    
    OpenRolls:Print("Proper usage:")
    OpenRolls:Print("     /openroll config -- Brings up options frame")
    OpenRolls:Print("     /openroll [Item] -- Roll for one [Item]")
    OpenRolls:Print("     /openroll [Quantity]x[Item] -- Roll for multiple [Item]s")
    OpenRolls:Print("     /openroll -- Review last roll")
    
end
OpenRolls:RegisterChatCommand("openroll", CommandLine)

--All the currently active loot windows; what a descriptive name
local lewt = {}

--This shifts loot windows up when one closes
function OpenRolls:RepositionLootWindows()
    if #lewt == 0 then return end
    lewt[1]:ClearAllPoints()
    local Data = OpenRollsData
    local anchor = Data.LootFramesAnchorFrame
    local anchorTo = Data.LootFramesAnchorTo
    local anchorFrom = Data.LootFramesAnchorFrom
    local offset = Data.LootFramesOffset
    
    lewt[1]:SetPoint(anchorFrom, anchor, anchorTo, offset.horizontal, offset.vertical)
    for i = 2, #lewt do
        lewt[i]:ClearAllPoints()
        lewt[i]:SetPoint("TOPLEFT", lewt[i-1], "BOTTOMLEFT")
    end

    anchor = Data.NameFramesAnchorFrame
    anchorTo = Data.NameFramesAnchorTo
    anchorFrom = Data.NameFramesAnchorFrom
    offset = Data.NameFramesOffset
    NamesFrame:SetPoint(anchorFrom, anchor, anchorTo, offset.horizontal, offset.vertical)
end

--Support for Summary Hooks
--Third party addons call AddSummaryHook in order to get extra information added to the
--  mouseover text for characters in the summary frame
--single determains if we are adding a single line or a double line
--  true -- http://www.wowwiki.com/API_GameTooltip_AddLine
--  false -- http://www.wowwiki.com/API_GameTooltip_AddDoubleLine
--func is called as func(name, roll)
--  The return values are passed directly to one of the above functions, as determined
--  by the value of single
function OpenRolls:AddSummaryHook(name, single, func)
    SummaryFrame:AddHook(name, single, func)
end

function OpenRolls:RemoveSummaryHook(name)
    SummaryFrame:RemoveHook(name)
end


--This is the list of addons that have added to the default loot window
local AttachedLootWindows = {}

--Registers an addition to the default loot window
--addon must be a table with a function called CreateLootWindow that takes two parameters
--  the loot slot the window corresponds to and the base loot window
--The return value is the actual frame; its size needs to be absolute, since it gets all 
--  anchor points cleared and reassigned appropriately
--The frame will get two additional functions added to it: SetAssign(char) and GetAssign()
--  These are used so the addon can manipulate OpenRolls assignment window as needed
--There are three optional functions that can be part of this frame
--  AwardToBanker and AwardToDisenchanter are called when the Banker and Disenchanter buttons
--    are clicked, respectively
--  AwardToPlayer is called when the Award button is clicked
--  If the addon doesn't care about these situations, simply don't add those functions
--  At present, the addon is not informed if an item is distributed via a random roll
function OpenRolls:RegisterLootWindow(addon)
    table.insert(AttachedLootWindows, addon)
end

function OpenRolls:UnregisterLootWindow(addon)
    for i, j in pairs(AttachedLootWindows) do
        if j == addon then table.remove(AttachedLootWindows, i) return end
    end
end

--The number of loot windows we've created...I need unique names
local framecount = 0

--Create/destroy the loot windows if neccessary
function OpenRolls:LOOT_OPENED()
    if OpenRollsData.ShowLootWindows == 'never' then return end
    if OpenRollsData.ShowLootWindows == 'whenML' and (select(2, GetLootMethod())) ~= 0 then return end
    
    NamesFrame.frame:Show()
    if #lewt > 0 then
        for _, frame in pairs(lewt) do
            frame:Release()
        end
    end
    lewt = {}
    local threshold = GetLootThreshold()
    for i = 1, GetNumLootItems() do
        if (select(4, GetLootSlotInfo(i))) >= threshold then
            local item = OpenRolls:CreateLootWindow("OpenRollsLootWindow" .. framecount, UIParent, i)
            framecount = framecount + 1
            for _, j in pairs(AttachedLootWindows) do
                item:AttachLootWindow(j)
            end
            table.insert(lewt, item)
            item:Show()
        end
    end
    OpenRolls:RepositionLootWindows()
end

function OpenRolls:LOOT_CLOSED()
    NamesFrame.frame:Hide()
    for i, j in pairs(lewt) do
        j:Release()
    end
end

--Destroy one loot window when the item is distributed
function OpenRolls:LOOT_SLOT_CLEARED(event, slot)
    local pos = nil
    for i, frame in pairs(lewt) do
        if frame.slot == slot then 
            frame:Release() 
            pos = i
        end
    end
    if pos ~= nil then table.remove(lewt, pos) end
    OpenRolls:RepositionLootWindows()
end

OpenRolls:RegisterEvent("LOOT_OPENED")
OpenRolls:RegisterEvent("LOOT_CLOSED")
OpenRolls:RegisterEvent("LOOT_SLOT_CLEARED")
OpenRolls:RegisterEvent("PLAYER_LEAVING_WORLD")

