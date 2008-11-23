do
local Lib = LibStub("dzjrGUI")

local setmetatable = setmetatable
local CreateFrame = CreateFrame

Lib.InputBox = setmetatable({}, Lib.Base["EditBox"])
Lib.InputBox.__index = Lib.InputBox

local function Escape(self)
    self:ClearFocus()
end

local function FocusGained(self)
    self:HighlightText()
end

local function FocusLost(self)
    self:HighlightText(0, 0)
end

local count = 0
--Creates an input box.  The resultant box has a height set, but no width
function Lib.InputBox:new(func, name, parent)
    if not name then
        name = "dzjrGUIInputBox" .. count
        count = count + 1
    end
    local obj = CreateFrame("EditBox", name, parent)--, "InputBoxTemplate")
    obj = setmetatable(obj, Lib.InputBox)
    
    local left = obj:CreateTexture()
    left:SetWidth(8)
    left:SetHeight(20)
    left:SetPoint("TOPLEFT")
    left:SetPoint("BOTTOM")
    left:SetTexture("Interface\\Common\\Common-Input-Border")
    left:SetDrawLayer("BACKGROUND")
    left:SetTexCoord(0, 0.0625, 0, 0.625)
    
    local right = obj:CreateTexture()
    right:SetWidth(8)
    right:SetHeight(20)
    right:SetPoint("TOPRIGHT")
    right:SetPoint("BOTTOM")
    right:SetTexture("Interface\\Common\\Common-Input-Border")
    right:SetDrawLayer("BACKGROUND")
    right:SetTexCoord(0.9375, 1, 0, 0.625)
    
    local middle = obj:CreateTexture()
    middle:SetWidth(10)
    middle:SetHeight(20)
    middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
    middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
    middle:SetTexture("Interface\\Common\\Common-Input-Border")
    middle:SetDrawLayer("BACKGROUND")
    middle:SetTexCoord(0.0625, 0.9375, 0, 0.625)
    
    obj:SetScript("OnEscapePressed", Escape)
    obj:SetScript("OnEditFocusLost", FocusLost)
    obj:SetScript("OnEditFocusGained", FocusGained)
    
    obj:SetAutoFocus(false)
    obj:SetFontObject(ChatFontNormal)
    obj:SetTextInsets(5, 0, 3, 3)
    obj:SetHeight(20)
    obj:SetScript("OnEnterPressed", func)
    return obj
end
end