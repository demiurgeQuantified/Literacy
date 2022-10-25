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
Literacy = Literacy or {}
local mults = {3,5,8,12,16}

function Literacy.handleLiteracyVHS(_guid, code)
    if not code then return end
    player = getPlayer()
    if player:isAsleep() then return end

    if luautils.stringStarts(code, 'LIT') then
        local level = tonumber(string.sub(code, 4, 4))
        local multiplier = tonumber(string.sub(code, 6, -1))
        local lowestLevel = (level-1)*2
        local highestLevel = lowestLevel+1
        if player:getPerkLevel(Perks.Reading) >= lowestLevel and player:getPerkLevel(Perks.Reading) <= highestLevel then
            local oldMult = player:getXp():getMultiplier(Perks.Reading)
            if oldMult < mults[level] then
                local newMult = oldMult + (mults[level] * multiplier)
                newMult = newMult * 10
                newMult = math.floor(newMult + 0.5)
                newMult = newMult / 10
                newMult = math.min(mults[level], newMult)   
                player:getXp():addXpMultiplier(Perks.Reading, newMult, lowestLevel, highestLevel+1)
            end
        end
    elseif code == '-ILT' then
        if player:HasTrait('Illiterate') then
            player:getTraits():remove('Illiterate')
            if SandboxVars.Literacy.IlliteratePenalty == 2 then
                player:getTraits():add('SlowReader')
                player:getTraits():add('PoorReader')
            elseif SandboxVars.Literacy.IlliteratePenalty == 3 then
                player:getTraits():add('VerySlowReader')
            end
            if ISCharacterInfoWindow.instance then
                ISCharacterInfoWindow.instance.charScreen:loadTraits()
            end
        end
    end
end
Events.OnDeviceText.Add(Literacy.handleLiteracyVHS)