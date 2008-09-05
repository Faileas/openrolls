--Handles everything involving the actual Summary Frame.

local Group = LibStub("GroupLib-1.0")

local function Callback(self, callback, ...)
    if callback == nil then return end
    if type(callback) == "string" then
        self[callback](self, ...)
    else
        callback(...)
    end
end

local function ValidateCallback(self, callback, source, callbackname)
	if type(callback) ~= "string" and type(callback) ~= "function" then 
		error("OpenRolls: " .. source ..": '" .. callbackname .. "' - function or method name expected.", 3)
	end
	if type(callback) == "string" then
		if type(self)~="table" then
			error("OpenRolls: " .. source .. ": 'self' - must be a table.", 3)
		end
		if type(self[callback]) ~= "function" then 
			error("OpenRolls: " .. source .. ": '" .. callbackname .. "' - method not found on target object.", 3)
		end
	end
    return true
end

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

local function BeginRoll(self, item, quantity)
    self:SetTitle("Roll in progress for " .. quantity .. "x" .. item)
    self:BuildList()
end

local function EndRoll(self, item, quantity)
    self:SetTitle("Roll finished for " .. quantity .. "x" .. item)
    local strings = self.strings
    for i = 1, Group.Number() do 
        if strings[i]:Value() == -1 then 
            strings[i]:PassRoll() 
        end 
    end 
end

local function ShowSummary(self)
    --If we haven't rolled on an item yet, force a rebuild of the list so it reflects the current
    --  raid status.  
    --We don't do this if there's already been a roll because then we couldn't go back later and 
    --  look at the results
    if self:GetTitle() == "No item" then
        self:SetTitle("No item")
        self:BuildList()
    end
    self:Show()
end

local function BuildList(self)
    local height = 0
    local strings = self.strings
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
    self.group:SetHeight(height)
    self:SetHeight(self.title:GetTop() - self.close:GetBottom() + 24)
    self:Sort()
end

local function SetTitle(self, title)
    self.title:SetText(title)
end

local function GetTitle(self)
    return self.title:GetText()
end

local function AddHook(self, name, single, func)
    table.insert(self.hooks, {name = name, single = single, func = func})
end

local function RemoveHook(self, name)
    for i, j in pairs(self.hooks) do
        if j.name == name then table.remove(self.hooks, i) return end
    end
end

local function Hooks(self)
    local i = 0
    return function() 
        i = i + 1
        if i > #self.hooks then return nil end
        return self.hooks[i].single, self.hooks[i].func
    end
end

local function InformRoll(self, char, typeof, roll)
    Callback(self.owner, self.callback, char, typeof, roll)
end

local function AssignRoll(self, char, typeof, roll)
    for _, i in pairs(self.strings) do
        if i:GetPlayer() == char then i:RegisterRoll(char, typeof, roll) end
    end
end

--This creates the actual frame
--owner is the addon creating the frame, it can be nil if callback is a function
--name is the standard frame name
--callback is the method called to modify rolls; either string or method
--   string is called as owner[callback](char, type, roll)
--   method is simply called callback(char, type, roll)
--   char is the character who's roll is modified
--   type is either 'roll' 'pass' 'disqualify' or 'reset'
--   roll is the value changed when type == 'roll'
--parent is the standard frame parent; if nil defaults to UIParent
function OpenRolls.CreateSummaryFrame(owner, name, callback, parent)
    if parent == nil then parent = UIParent end
    
    ValidateCallback(owner, callback, "CreateSummaryFrame", "callback")
    
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

    self.hooks = {}
    
    self:Hide()

    self.title = title
    self.group = group
    self.strings = strings
    self.close = close
    self.Sort = Sort
    self.BeginRoll = BeginRoll
    self.EndRoll = EndRoll
    self.ShowSummary = ShowSummary
    self.BuildList = BuildList
    self.SetTitle = SetTitle
    self.GetTitle = GetTitle
    self.AddHook = AddHook
    self.RemoveHook = RemoveHook
    self.Hooks = Hooks
    
    self.owner = owner
    self.callback = callback
    self.InformRoll = InformRoll
    self.AssignRoll = AssignRoll
    
    return self
end
