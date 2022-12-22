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
local Literacy = require 'literacy/literacy'
local sandboxVars = SandboxVars.Literacy

local readingDifficultyMultipliers = {1, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45}

local old_new = ISReadABook.new

function ISReadABook:new(character, item, time)
    local o = old_new(self, character, item, time)

    local readingLevel = self.character:getPerkLevel(Perks.Reading)

    if o.maxMultiplier and character:HasTrait('PoorReader') then
        o.maxMultiplier = o.maxMultiplier * 0.75
    end
    
    if readingLevel >= sandboxVars.WalkWhileReadingLevel then
        o.stopOnWalk = false
    end
    if sandboxVars.WalkWhileReadingLevel == -1 then
        o.stopOnWalk = true
    end
    o.characterWasMoving = false

    if sandboxVars.LiteracyLevelMultIncrease ~= 0 then
        if readingLevel > 5 then
            o.maxMultiplier = o.maxMultiplier * (readingLevel - 5) * (1 + sandboxVars.LiteracyLevelMultIncrease)
        elseif readingLevel < 5 then
            o.maxMultiplier = o.maxMultiplier * (1 - (readingLevel - 5) * -0.05)
        end
    end

    if character:isTimedActionInstant() then
        return o
    end

    time = o.maxTime
    -- undo vanilla trait multipliers
    if character:HasTrait("FastReader") then
        time = time / 0.7
    elseif character:HasTrait("SlowReader") then
        time = time / 1.3
    end

    local readingSpeed = Literacy.calculateReadingSpeed(character)
    time = time / readingSpeed
    time = time / sandboxVars.OverallSpeedMultiplier

    if not (character:isSitOnGround() or character:getVehicle()) then
        time = time / sandboxVars.StandingReadingSpeed
    end
    
    o.maxTime = time
    return o
end

local old_update = ISReadABook.update

function ISReadABook:update()
    if self.character:isPlayerMoving() then
        if not self.characterWasMoving then
            self:changeMaxTime(self.maxTime / sandboxVars.SpeedWhileMoving)
        end
    else
        if self.characterWasMoving then
            self:changeMaxTime(self.maxTime * sandboxVars.SpeedWhileMoving)
        end
    end
    self.characterWasMoving = self.character:isPlayerMoving()

    local pagesRead = math.floor(self.item:getNumberOfPages() * self:getJobDelta())
    if pagesRead > self.item:getAlreadyReadPages() then
        local difference = pagesRead - self.item:getAlreadyReadPages()
        self.character:getXp():AddXP(Perks.Reading, difference * 1.5 * readingDifficultyMultipliers[self.item:getLvlSkillTrained()] * sandboxVars.XPMultiplier)
    end
    old_update(self)
end

local old_perform = ISReadABook.perform

function ISReadABook:perform()
    if self.stats then
        local modData = self.item:getModData()
        local XPReward = modData['XPReward'] or 3
        self.character:getXp():AddXP(Perks.Reading, (XPReward * 4) * sandboxVars.XPMultiplier)
        if sandboxVars.DontDestroyStatBooks and not Literacy.IsRecipeBook(self.item) then
            if not modData['AlreadyReadPlayers'] then modData['AlreadyReadPlayers'] = {} end
            modData['AlreadyReadPlayers'][self.character:getModData().StarlitUUID] = true
        end
    end
    old_perform(self)
end

local old_isValid = ISReadABook.isValid

function ISReadABook:isValid()
    if Literacy.PlayerHasReadBook(self.character, self.item) or self.character:getAlreadyReadBook():contains(self.item:getFullType()) then
        local line
        local rand = ZombRand(1, 3)
        if rand == 1 then
            line = getText("IGUI_PlayerText_AlreadyRead")
        else
            line = getText("IGUI_PlayerText_AlreadyRead2")
        end
        self.character:Say(line)

        return false
    end

    if not sandboxVars.ReadInTheDark and self.character:getSquare():getLightLevel(self.character:getPlayerNum()) < 0.35 then
        local line
        local rand = ZombRand(1, 3)
        if rand == 1 then
            line = getText("IGUI_PlayerText_CantReadDark")
        else
            line = getText("IGUI_PlayerText_CantReadDark2")
        end
        self.character:Say(line)

        return false
    end

    if sandboxVars.StandingReadingSpeed == 0 and not self.character:isSitOnGround() and not self.character:getVehicle() then
        self.character:Say(getText("IGUI_PlayerText_CantReadStanding"))
        return false
    end
    
    if ISReadABook.checkMultiplier then ISReadABook.checkMultiplier(self) end -- CDDA reading overwrites ISReadABook and removes this function u_u
    return old_isValid(self)
end

function ISReadABook:changeMaxTime(newTime)
    local mult = newTime / self.maxTime
    self:setTime(newTime)
    self.action:setTime(newTime)
    self:setCurrentTime(self.action:getCurrentTime() * mult)
end

do
    local metatable = __classmetatables[zombie.characters.IsoPlayer.class].__index
    local old_ReadLiterature = metatable.ReadLiterature
    function metatable.ReadLiterature(self, item) -- lua reimplementation of ReadLiterature that doesn't remove the item
        if Literacy.IsRecipeBook(item) or not sandboxVars.DontDestroyStatBooks then
            old_ReadLiterature(self, item)
        else
            self:getStats():setStress(self:getStats():getStress() + item:getStressChange())
            self:getBodyDamage():JustReadSomething(item)
        end
    end
end