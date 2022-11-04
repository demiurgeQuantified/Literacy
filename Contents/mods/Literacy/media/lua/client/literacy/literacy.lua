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
local Literacy = {}

function Literacy.getInitialLiteracyLevel(player)
    local level = 5
    if player:HasTrait('FastReader') then
        level = level + 1
    elseif player:HasTrait('SlowReader') then
        level = level - 1
    end
    return level
end

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

function Literacy.setInitialLiteracy(_playerNum, player)
    if not player:getModData().LiteracySetUp then
        player:level0(Perks.Reading)
        player:getXp():setPerkBoost(Perks.Reading, 0)

        if not player:HasTrait('Illiterate') then
            local desiredLevel = Literacy.getInitialLiteracyLevel(player)
            for i=1, desiredLevel do
                player:LevelPerk(Perks.Reading)
            end
            player:getXp():setXPToLevel(Perks.Reading, desiredLevel)
        end
        player:getModData().LiteracySetUp = true
    end
end
Events.OnCreatePlayer.Add(Literacy.setInitialLiteracy)

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

function Literacy.PlayerHasReadBook(player, book)
    return book:getModData()['AlreadyReadPlayers'] and book:getModData()['AlreadyReadPlayers'][Literacy.getIdentifier(player)]
end

function Literacy.IsRecipeBook(book)
    return book:getTeachedRecipes() and not book:getTeachedRecipes():isEmpty()
end

return Literacy