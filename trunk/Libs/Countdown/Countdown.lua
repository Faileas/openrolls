do

local MAJOR, MINOR = "Countdown-1.0", 1
local Countdown = LibStub:NewLibrary(MAJOR, MINOR)

if not Countdown then return end -- No upgrade needed

local Timer = LibStub:GetLibrary("AceTimer-3.0")

local type = type

local ActiveIDs = {}

local function Callback(self, callback, arg)
    if callback == nil then return end
    if type(callback) == "string" then
        self[callback](self, arg)
    else
        callback(arg)
    end
end

local function ValidateCallback(self, callback, source, callbackname)
	if type(callback) ~= "string" and type(callback) ~= "function" then 
		error(MAJOR..": " .. source ..": '" .. callbackname .. "' - function or method name expected.", 3)
	end
	if type(callback) == "string" then
		if type(self)~="table" then
			error(MAJOR..": " .. source .. ": 'self' - must be a table.", 3)
		end
		if type(self[callback]) ~= "function" then 
			error(MAJOR..": " .. source .. ": '" .. callbackname .. "' - method not found on target object.", 3)
		end
	end
    return true
end

local count = 0
function Countdown.BeginCountdown(self, durations, display, callbacks)
    if type(durations) == "number" then
        durations = {count = durations}
    end
    if type(callbacks) == "function" then
        callbacks = {final = callbacks}
    end
    
    count = count + 1
    
    if durations.initial == nil then durations.initial = 0 end
    if durations.count == nil then durations.count = 0 end
    if durations.final == nil then durations.final = 0 end
    
    local src = "BeginCountdownBeta(self, durations, display, callbacks)"
    if callbacks.initial ~= nil then 
        ValidateCallback(self, callbacks.initial, src, "callbacks.initial") 
    end
    if callbacks.count ~= nil then 
        ValidateCallback(self, callbacks.count, src, "callbacks.count") 
    end
    if callbacks.final ~= nil then 
        ValidateCallback(self, callbacks.final, src, "callbacks.final") 
    end
    
    local id = count
    ActiveIDs[self] = ActiveIDs[self] or {}
    
    local function final()
        local myIDs = ActiveIDs[self]
        if not myIDs[id] then return end
        myIDs[id] = nil
        Callback(self, callbacks.final)
    end
    
    local function tick()
        local myIDs = ActiveIDs[self]
        if not myIDs[id] then return end
    
        Callback(self, display, durations.count)
    
        if durations.count == 0 then
            Callback(self, callbacks.count)
            Timer:ScheduleTimer(final, durations.final)
        else    
            durations.count = durations.count - 1
            Timer:ScheduleTimer(tick, 1)
        end
    end
    
    local function init()
        local myIDs = ActiveIDs[self]
        if not myIDs[id] then return end
        Callback(self, callbacks.initial, id)
        tick()
    end
    
    Timer:ScheduleTimer(init, durations.initial)
    ActiveIDs[self][id] = true
    
    return id
end

function Countdown.CancelCountdown(self, id)
    local myIDs = ActiveIDs[self]
    if myIDs then myIDs[id] = nil end
end

function Countdown.CancelAllCountdowns(self)
    ActiveIDs[self] = {}
end

Countdown.embeds = Countdown.embeds or {}

local mixins = {
	"BeginCountdown",
    "CancelCountdown",
    "CancelAllCountdowns"
}

function Countdown:Embed(target)
	for _,v in pairs(mixins) do
		target[v] = Countdown[v]
	end    
	self.embeds[target] = true    
	return target
end

for target, v in pairs(Countdown.embeds) do
	Countdown:Embed(target)
end

end