do
local Lib = LibStub("dzjrGUI")

--Creates an input box.  The resultant box has a height set, but no width
function Lib.InputBox(func, name, parent)
    local obj = CreateFrame("EditBox", name, parent, "InputBoxTemplate")
    obj:SetAutoFocus(false)
    obj:SetFontObject(ChatFontNormal)
    obj:SetTextInsets(0, 0, 3, 3)
    obj:SetHeight(20)
    obj:SetScript("OnEnterPressed", func)
    return obj
end
end