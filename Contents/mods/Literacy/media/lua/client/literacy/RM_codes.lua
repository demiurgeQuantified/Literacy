--[[LITERACY MOD
    Copyright (C) 2022 albion

    This program is free software: you can redistribute it and/or modify
    it under the terms of Version 3 of the GNU Affero General Public License as published
    by the Free Software Foundation.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    For any questions, contact me through steam or on Discord - albion#0123
]]
local mults = {3,5,8,12,16}

local RadioInteractions = ISRadioInteractions:getInstance()

local LiteracyCodeHandler = {}

---Adds to the player's multiplier if it follows the usual rules of books
---@param character IsoGameCharacter
---@param level number What level of multiplier is being added (1 = 0-2, 2 = 2-4, etc)
---@param multiplier number How much of the multiplier to add (0.2 adds 20% of the full multiplier)
function LiteracyCodeHandler.addLiteracyMultiplier(character, level, multiplier)
    local lowestLevel = (level-1)*2
    local highestLevel = lowestLevel+1
    if character:getPerkLevel(Perks.Reading) >= lowestLevel and character:getPerkLevel(Perks.Reading) <= highestLevel then
        local xp = character:getXp()
        local oldMult = xp:getMultiplier(Perks.Reading)
        if oldMult < mults[level] then
            local newMult = oldMult + (mults[level] * multiplier)
            newMult = newMult * 10
            newMult = math.floor(newMult + 0.5)
            newMult = newMult / 10
            newMult = math.min(mults[level], newMult)

            xp:addXpMultiplier(Perks.Reading, newMult, lowestLevel, highestLevel+1)
        end
    end
end

---Removes the Illiterate trait from the character, and gives the appropriate penalties
---@param character IsoGameCharacter
function LiteracyCodeHandler.loseIlliterate(character)
    if character:HasTrait('Illiterate') then
        local traits = character:getTraits()
        traits:remove('Illiterate')
        if SandboxVars.Literacy.IlliteratePenalty == 2 then
            traits:add('SlowReader')
            traits:add('PoorReader')
        elseif SandboxVars.Literacy.IlliteratePenalty == 3 then
            traits:add('VerySlowReader')
        end
        if ISCharacterInfoWindow.instance then
            ISCharacterInfoWindow.instance.charScreen:loadTraits()
        end
    end
end

---@param _guid string
---@param code string
---@param x number
---@param y number
---@param z number
function LiteracyCodeHandler.OnDeviceText(_guid, code, x, y, z)
    if not code then return end

    local _, _, type, level, operator, multiplier = string.find(code, "(?%-%a%a%a)(%d?)([%*%+%-])([%d.]-)")
    multiplier, level = tonumber(multiplier), tonumber(level)

    ---@type function
    ---@param character IsoGameCharacter
    local func
    if type == "LIT" then
        if operator == "*" then
            func = function(character) LiteracyCodeHandler.addLiteracyMultiplier(character, level, multiplier) end
        end
    elseif type == '-ILT' then
        func = LiteracyCodeHandler.loseIlliterate
    end
    if not func then return end

    for playerNum = 0,3 do
        local player = getSpecificPlayer(playerNum)
        if player and not (player:isAsleep() or player:isDead()) and RadioInteractions.playerInRange(player, x, y, z) then
            func(player)
        end
    end
end
Events.OnDeviceText.Add(LiteracyCodeHandler.OnDeviceText)

return LiteracyCodeHandler