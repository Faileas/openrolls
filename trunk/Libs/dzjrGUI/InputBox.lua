do
local Lib = LibStub("dzjrGUI")

Lib.InputBox = setmetatable({}, Lib.Base["EditBox"])
Lib.InputBox.__index = Lib.InputBox

--Creates an input box.  The resultant box has a height set, but no width
function Lib.InputBox:new(func, name, parent)
    local obj = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    obj = setmetatable(obj, Lib.InputBox)
    
    obj:SetAutoFocus(false)
    obj:SetFontObject(ChatFontNormal)
    obj:SetTextInsets(0, 0, 3, 3)
    obj:SetHeight(20)
    obj:SetScript("OnEnterPressed", func)
    return obj
end
end