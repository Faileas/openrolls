local Group = LibStub("GroupLib-1.0")

local frame = CreateFrame("frame", "OpenRollsSummaryFrame", UIParent)
frame:SetBackdrop({
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
    tile = true, tileSize = 32, edgeSize = 16, 
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})    
frame:SetBackdropColor(0,0,0,1)
frame:SetToplevel(true)
frame:SetFrameStrata("FULLSCREEN_DIALOG")
frame:SetMovable(true)
frame:EnableMouse()    
frame:SetScript("OnMouseDown", function(frame) frame:StartMoving() end)
frame:SetScript("OnMouseUp", function(frame) frame:StopMovingOrSizing() end)
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetWidth(400)
frame:SetHeight(200)

local title = frame:CreateFontString("OpenRollsSummaryTitle", "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -12)
title:SetPoint("RIGHT", frame, "RIGHT", -6)
title:SetText("Title")

local group = CreateFrame("frame", "OpenRollsSummaryGroup", frame)
group:SetPoint("LEFT", frame, "LEFT", 12, 0)
group:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
group:SetPoint("TOP", title, "BOTTOM", 0, -12)

local strings = {}
for i = 1, 40 do
    local str = OpenRolls:CreateSummaryLine("OpenRollsSummaryString" .. i, group, "Not Yet Filled")
    str:SetPoint("LEFT", group, "LEFT")
    str:SetPoint("RIGHT", group, "RIGHT")
    strings[i] = str
end

strings[1]:SetPoint("TOP", group, "TOP")
for i = 2, 40 do
    strings[i]:SetPoint("TOP", strings[i-1], "BOTTOM")
end

local close = CreateFrame("Button", "OpenRollsSummaryClose", frame, "UIPanelButtonTemplate")
close:SetHeight(20)
close:SetWidth(100)
--close:SetPoint("CENTER", title, "CENTER")
close:SetPoint("TOP", group, "BOTTOM")
close:SetText("Close")
close:SetScript("OnClick", function(frame) 
    frame:GetParent():Hide()
end)

group:SetHeight(strings[1]:GetTop() - strings[40]:GetBottom())
frame:SetHeight(title:GetTop() - close:GetBottom() + 24)

frame:Hide()

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

local debugz = true

local function Sort()
    --this code was basically stolen from the wikipedia article on insertion sort
    for i = 2, Group.Number() do
        local value = strings[i]
        local j = i - 1
        while j >= 1 and strings[j]:Value() < value:Value() do--strings[j]:Compare(value) do
            strings[j + 1] = strings[j]
            j = j - 1
        end
        strings[j+1] = value
    end
    
    strings[1]:SetPoint("TOP", group, "TOP")
    for i = 2, 40 do
        strings[i]:SetPoint("TOP", strings[i-1], "BOTTOM")
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


function OpenRolls:UpdateRollList()
    Sort()
    if OpenRolls.timer and OpenRolls:HasEverybodyRolled() then
        OpenRolls:EndRoll(item, quantity)
    end
end

function OpenRolls:AssignRoll(name, roll)
    for i = 1, Group.Number() do
        if strings[i]:GetPlayer() == name then
            if strings[i]:Value() > 0 then return false end
            strings[i]:SetRoll(roll)
            Sort()
            return true
        end
    end
    return false
end

function OpenRolls:HasEverybodyRolled()
    for i = 1, Group.Number() do
        if strings[i]:Value() == -1 then 
            return false
        end
    end
    return true
end

function OpenRolls:PrintWinners(item, quantity)
    OpenRolls:Communicate("Roll over for " .. quantity .. "x" .. item)
    if strings[1]:Value() < 1 then
        OpenRolls:Communicate("   Nobody rolled")
        return
    end
    
    for i = 1, quantity do
        if strings[i]:Value() < 1 then
            return
        end
        OpenRolls:Communicate(strings[i]:GetPlayer() .. " rolled " .. strings[i]:Value())
    end
end

function OpenRolls:Warning()
    if not OpenRollsData.Warning then return end

    OpenRolls:Communicate("The following players have not rolled: ")
    for i = 1, Group.Number() do
        if strings[i]:Value() == -1 then
            OpenRolls:Communicate("   " .. strings[i]:GetPlayer())
        end
    end
end

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
    title:SetText("Roll finished for " .. currentQuantity .. "x" .. currentItem)
    for i = 1, Group.Number() do
        if strings[i]:Value() == -1 then
            strings[i]:PassRoll()
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
    title:SetText(titl)
    local height = 0
    local del = strings[1]:GetHeight()
    local i = 0
    for name, _, online in Group.Members() do
        i = i + 1
        strings[i]:SetPlayer(name)
        height = height + del
        if online then
            strings[i]:ClearRoll()
        else
            strings[i]:SetOffline()
        end
        strings[i]:Show()
    end
    for i = Group.Number()+1, 40 do
        strings[i]:Hide()
    end
    group:SetHeight(height)
    frame:SetHeight(title:GetTop() - close:GetBottom() + 24)
    Sort()
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
    if strings[1]:GetPlayer() == "Not Yet Filled" then
        OpenRolls:FillSummary("No item")
    end
    frame:Show()
end
