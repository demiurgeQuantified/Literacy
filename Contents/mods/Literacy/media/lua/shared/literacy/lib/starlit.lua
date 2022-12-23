local Starlit = {}

local scriptManager = ScriptManager.instance
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
Starlit.assignUUID = function(character)
    local modData = character:getModData()
    if not modData.StarlitUUID then
        modData.StarlitUUID = getRandomUUID()
    end
end

---Makes the given character speak a random line from a table of translation strings
---@param character IsoGameCharacter
---@param lines table
Starlit.sayRandomLine = function(character, lines)
    local line = lines[ZombRand(#lines)+1]
    character:Say(getText(line))
end

return Starlit