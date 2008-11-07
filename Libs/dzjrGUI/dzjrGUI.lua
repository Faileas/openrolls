do

local MAJOR, MINOR = "dzjrGUI", 1
local Lib = LibStub:NewLibrary(MAJOR, MINOR)

if not Lib then return end

local setmetatable = setmetatable
local pcall = pcall
local rawset = rawset
local type = type
local strlower = strlower

local function myAddMouseverText(frame, text, r, g, b, a)
    frame:EnableMouse()
    local oldEnter = frame:GetScript("OnEnter")
    local oldLeave = frame:GetScript("OnLeave")
    frame:SetScript("OnEnter", function(self, ...) 
        local GT = GameTooltip
        GT:SetOwner(self, "ANCHOR_TOPLEFT")
        GT:AddLine(text, r, g, b, a, true)
        GT:Show()
        if oldEnter then oldEnter() end
    end)
    frame:SetScript("OnLeave", function(self, ...) 
        GameTooltip:Hide() 
        if oldLeave then oldLeave() end
    end)
end

local function CreateBase(tbl, base)
    local ok, baseFrame = pcall(CreateFrame, strlower(base))
    if not ok then return end
    
    baseFrame.__index = baseFrame
    
    local myFrame = setmetatable({}, baseFrame)
    myFrame.__index = myFrame    
    myFrame.AddMouseoverText = myAddMouseverText
    
    rawset(tbl, base, myFrame)
    return myFrame
end

Lib.Base = setmetatable({}, {__index = CreateBase})


function Lib.AddMouseoverText(frame, text, r, g, b, a)
    if type(frame.AddMouseoverText) == "function" then
        frame:AddMouseoverText(text, r, g, b, a)
    else
        myAddMouseverText(frame, text, r, g, b, a)
    end
end

end