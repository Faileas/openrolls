--THIS FILE NEEDS TO BE CLEANED UP
--Handles everything involving the actual Summary Frame.  Unfortunately, this includes things like
--starting and ending rolls that really belongs more in the OpenRolls.lua file.  Need to fix that.

local Group = LibStub("GroupLib-1.0")

local function Sort(self)
    --this code was basically stolen from the wikipedia article on insertion sort
    for i = 2, Group.Number() do
        local value = self.strings[i]
        local j = i - 1
        while j >= 1 and self.strings[j]:Value() < value:Value() do--strings[j]:Compare(value) do
            self.strings[j + 1] = self.strings[j]
            j = j - 1
        end
        self.strings[j+1] = value
    end
    
    self.strings[1]:SetPoint("TOP", self.group, "TOP")
    for i = 2, 40 do
        self.strings[i]:SetPoint("TOP", self.strings[i-1], "BOTTOM")
    end
    
--[[insertionSort(array A)
    for i = 1 to length[A]-1 do
    begin
        value = A[i]
        j = i-1
        while j >= 0 and A[j] > value do
        begin
            A[j + 1] = A[j]
            j = j-1
        end
        A[j+1] = value
    end]]--
end

local function CreateSummaryFrame(name, parent)
    local self = CreateFrame("frame", name, parent)
    self:SetBackdrop({
        bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
        tile = true, tileSize = 32, edgeSize = 16, 
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })    
    self:SetBackdropColor(0,0,0,1)
    self:SetToplevel(true)
    self:SetFrameStrata("FULLSCREEN_DIALOG")
    self:SetMovable(true)
    self:EnableMouse()    
    self:SetScript("OnMouseDown", function(frame) frame:StartMoving() end)
    self:SetScript("OnMouseUp", function(frame) frame:StopMovingOrSizing() end)
    self:SetPoint("CENTER", UIParent, "CENTER")
    self:SetWidth(400)
    self:SetHeight(200)

    local title = self:CreateFontString(name .. "Title", "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", self, "TOPLEFT", 6, -12)
    title:SetPoint("RIGHT", self, "RIGHT", -6)
    title:SetText("No item")

    local group = CreateFrame("frame", name .. "Group", self)
    group:SetPoint("LEFT", self, "LEFT", 12, 0)
    group:SetPoint("RIGHT", self, "RIGHT", -12, 0)
    group:SetPoint("TOP", title, "BOTTOM", 0, -12)

    local strings = {}
    for i = 1, 40 do
        local str = OpenRolls:CreateSummaryLine(name .. "String" .. i, self, "Not Yet Filled")
        str:SetPoint("LEFT", group, "LEFT")
        str:SetPoint("RIGHT", group, "RIGHT")
        strings[i] = str
    end

    strings[1]:SetPoint("TOP", group, "TOP")
    for i = 2, 40 do
        strings[i]:SetPoint("TOP", strings[i-1], "BOTTOM")
    end

    local close = CreateFrame("Button", name .. "Close", self, "UIPanelButtonTemplate")
    close:SetHeight(20)
    close:SetWidth(100)
    --close:SetPoint("CENTER", title, "CENTER")
    close:SetPoint("TOP", group, "BOTTOM")
    close:SetText("Close")
    close:SetScript("OnClick", function(frame) 
        frame:GetParent():Hide()
    end)

    group:SetHeight(strings[1]:GetTop() - strings[40]:GetBottom())
    self:SetHeight(title:GetTop() - close:GetBottom() + 24)

    self:Hide()

    self.title = title
    self.group = group
    self.strings = strings
    self.close = close
    self.Sort = Sort
    
    return self
end
local frame = CreateSummaryFrame("OpenRollsSummaryFrame", UIParent)

--This function can probably be removed
local function RollValue(roll)
    if roll == "Offline" then 
        return -2
    elseif roll == "Waiting..." then
        return -1
    elseif roll == "Passed" then
        return 0
    else
        return tonumber(roll)
    end
end

--This will be unneccessary since OpenRolls.lua will have its own copy of rolls
function OpenRolls:HasEverybodyRolled()
    for i = 1, Group.Number() do
        if frame.strings[i]:Value() == -1 then 
            return false
        end
    end
    return true
end


--This will be moved to OpenRolls.lua
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


--This will be moved to OpenRolls.lua
function OpenRolls:Warning()
    if not OpenRollsData.Warning then return end

    OpenRolls:Communicate("The following players have not rolled: ")
    for i = 1, Group.Number() do
        if frame.strings[i]:Value() == -1 then
            OpenRolls:Communicate("   " .. frame.strings[i]:GetPlayer())
        end
    end
end


--This seems reasonable
function OpenRolls:HideSummary()
    frame:Hide()
end

local currentItem, currentQuantity

function OpenRolls:StartRoll(item, quantity)
    OpenRolls:Communicate("Open roll for " .. quantity .. "x" .. item)
    OpenRolls:FillSummary("Roll in progress for " .. quantity .. "x" .. item)
    OpenRolls:ShowSummary()
    
    currentItem = item
    currentQuantity = quantity
end

function OpenRolls:EndRoll()
    frame.title:SetText("Roll finished for " .. currentQuantity .. "x" .. currentItem)
    for i = 1, Group.Number() do
        if frame.strings[i]:Value() == -1 then
            frame.strings[i]:PassRoll()
        end
    end
    OpenRolls:PrintWinners(currentItem, currentQuantity)
    if OpenRollsData.ShowSummaryWhenRollsOver then
        OpenRolls:ShowSummary()
    end
    
    OpenRolls:UnregisterMessage("RollTrack_Roll")
    OpenRolls:CancelCountdown(OpenRolls.timer)
    
    currentItem = nil
    currentQuantity = nil
    OpenRolls.timer = nil
end

function OpenRolls:FillSummary(titl)
    frame.title:SetText(titl)
    local height = 0
    local del = frame.strings[1]:GetHeight()
    local i = 0
    for name, _, online in Group.Members() do
        i = i + 1
        frame.strings[i]:SetPlayer(name)
        height = height + del
        if online then
            frame.strings[i]:ClearRoll()
        else
            frame.strings[i]:SetOffline()
        end
        frame.strings[i]:Show()
    end
    for i = Group.Number()+1, 40 do
        frame.strings[i]:Hide()
    end
    frame.group:SetHeight(height)
    frame:SetHeight(frame.title:GetTop() - frame.close:GetBottom() + 24)
    frame:Sort()
end

local summaryHooks = {}

function OpenRolls:AddSummaryHook(name, single, func)
    table.insert(summaryHooks, {name = name, single = single, func = func})
end

function OpenRolls:RemoveSummaryHook(name)
    for i, j in pairs(summaryHooks) do
        if j.name == name then table.remove(summaryHooks, i) return end
    end
end

function OpenRolls:SummaryHooks()
    local i = 0
    return function() 
        i = i + 1
        if i > #summaryHooks then return nil end
        return summaryHooks[i].single, summaryHooks[i].func
    end
end

function OpenRolls:ShowSummary()
    --If we haven't rolled on an item yet, force a rebuild of the list so it reflects the current
    --  raid status.  
    --We don't do this if there's already been a roll because then we couldn't go back later and 
    --  look at the results
    if frame.title:GetText() == "No item" then
        OpenRolls:FillSummary("No item")
    end
    frame:Show()
end
