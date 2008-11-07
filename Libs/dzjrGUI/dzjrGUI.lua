do

local MAJOR, MINOR = "dzjrGUI", 1
local Lib = LibStub:NewLibrary(MAJOR, MINOR)

if not Lib then return end

function Lib.AddMouseoverText(frame, text, r, g, b, a)
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

end