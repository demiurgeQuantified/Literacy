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
local Starlit = require 'literacy/lib/starlit'
local Literacy = {}
local sandboxVars = SandboxVars.Literacy

---@param character IsoGameCharacter
function Literacy.getInitialLiteracyLevel(character)
    local level = 5
    if character:HasTrait('FastReader') then
        level = level + 1
    elseif character:HasTrait('SlowReader') then
        level = level - 1
    end
    return level
end

---@param character IsoGameCharacter
---@param speed number
function Literacy.applyTraitModifiers(character, speed)
    if character:HasTrait('FastReader') then
        speed = speed + 0.2
    elseif character:HasTrait('SlowReader') then
        speed = speed - 0.2
    elseif character:HasTrait('VerySlowReader') then
        speed = speed - 0.4
    end
    return speed
end

---@param character IsoLivingCharacter
function Literacy.setupLiteracy(_playerNum, character)
    local modData = character:getModData()
    modData.literacy = modData.literacy or {}
    if not modData.literacy.initialised then
        character:level0(Perks.Reading)
        character:getXp():setPerkBoost(Perks.Reading, 0)

        if not character:HasTrait('Illiterate') then
            local desiredLevel = Literacy.getInitialLiteracyLevel(character)
            for i=1, desiredLevel do
                character:LevelPerk(Perks.Reading)
            end
            character:getXp():setXPToLevel(Perks.Reading, desiredLevel)
        end
        modData.literacy.alreadyReadBooks = {}
        modData.literacy.initialised = true
    end
    character:transmitModData()
end
Events.OnCreatePlayer.Add(Literacy.setupLiteracy)

function Literacy.calculateReadingSpeed(character)
    local readingSpeed = character:getPerkLevel(Perks.Reading)
    readingSpeed = math.max(1, readingSpeed)
    readingSpeed = readingSpeed - 5
    if readingSpeed > 0 then
        readingSpeed = readingSpeed * 0.3
    else
        readingSpeed = readingSpeed * 0.2
    end
    
    readingSpeed = Literacy.applyTraitModifiers(character, readingSpeed)

    readingSpeed = readingSpeed + 1
    readingSpeed = math.max(0.2, readingSpeed)
    return readingSpeed
end

---@param character IsoLivingCharacter
function Literacy.calculateReadingMultiplier(character)
    local mult = 1

    if sandboxVars.LiteracyLevelMultIncrease ~= 0 then
        local readingLevel = character:getPerkLevel(Perks.Reading) - 5
        if readingLevel > 0 then
            mult = mult * 1 + readingLevel * sandboxVars.LiteracyLevelMultIncrease
        elseif readingLevel < 0 then
            mult = mult * 1 + readingLevel * 0.05
        end
    end

    if character:HasTrait('PoorReader') then
        mult = mult * 0.75
    end

    return mult
end

function Literacy.LevelPerk(character, perk)
    if perk == Perks.Reading then
        local queue = ISTimedActionQueue.getTimedActionQueue(character)
        if not queue.current then return end
        if queue.current.action:getMetaType() == 'ISReadABook' then
            local item = queue.current.item
            queue.current:stop()
            ISTimedActionQueue.add(ISReadABook:new(character, item, 150))
        end
    end
end
Events.LevelPerk.Add(Literacy.LevelPerk)

---@param player IsoPlayer
---@param book InventoryItem
function Literacy.PlayerHasReadBook(player, book)
    return player:getModData().literacy and player:getModData().literacy.alreadyReadBooks[book:getID()]
end

---@param book InventoryItem
function Literacy.IsRecipeBook(book)
    return book:getTeachedRecipes() and not book:getTeachedRecipes():isEmpty()
end

return Literacy