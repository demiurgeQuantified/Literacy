local scriptManager = ScriptManager.instance

local Starlit = {}
if getDebug() then
    Starlit.funcCache = {}
end

---Applies the given parameter to the given item script, if it exists
---@param script string
---@param tweak string
Starlit.doItemParam = function(script, tweak)
    local item = scriptManager:getItem(script)
    if item then
        item:DoParam(tweak)
    end
end

---Assigns a UUID to a character, if they don't already have one
---@param character IsoGameCharacter
---@param shouldTransmit boolean Whether to transmit the moddata afterwards
Starlit.assignUUID = function(character, shouldTransmit)
    local modData = character:getModData()
    if not modData.StarlitUUID then
        modData.StarlitUUID = getRandomUUID()
        if shouldTransmit then
            character:transmitModData()
        end
    end
end

---Makes the given character speak a random line from a table of translation strings
---@param character IsoGameCharacter
---@param lines table
Starlit.sayRandomLine = function(character, lines)
    local line = lines[ZombRand(#lines)+1]
    character:Say(getText(line))
end

---Returns the metatable from the class name
---@param className string
Starlit.findMetatable = function(className)
    return __classmetatables[_G[className].class].__index
end

---Returns a function object from a string global variable name
---@param funcName string
Starlit.getFunctionObject = function(funcName)
    local splitFunc = luautils.split(funcName, '.')
    local func = _G
    for i = 1,#splitFunc do
        func = func[splitFunc[i]]
    end
    return func
end

---Saves a function into a variable - in debug mode functions are cached, so files can be reloaded safely
---@param funcName string
Starlit.saveFunc = function(funcName)
    if getDebug() then
        if not Starlit.funcCache[funcName] then
            Starlit.funcCache[funcName] = Starlit.getFunctionObject(funcName)
        end
        return Starlit.funcCache[funcName]
    end
    return Starlit.getFunctionObject(funcName)
end

return Starlit