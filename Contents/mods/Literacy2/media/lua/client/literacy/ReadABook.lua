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

local readingDifficultyMultipliers = {1, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45}

if getSteamModeActive() then
    function Literacy.getIdentifier(player)
        return player:getSteamID()
    end
else
    function Literacy.getIdentifier(player)
        return player:getUsername()
    end
end

local old_new = ISReadABook.new

function ISReadABook:new(character, item, time)
    local o = old_new(self, character, item, time)

    if o.maxMultiplier and character:HasTrait('PoorReader') then
        o.maxMultiplier = o.maxMultiplier * 0.75
    end
    
    if character:getPerkLevel(Perks.Reading) >= SandboxVars.Literacy.WalkWhileReadingLevel then
        o.stopOnWalk = false
    end
    if SandboxVars.Literacy.WalkWhileReadingLevel == -1 then
        o.stopOnWalk = true
    end

    o.characterWasMoving = false

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

    local readingLevel = Literacy.calculateReadingSpeed(character)
    time = time / readingLevel
    time = time / SandboxVars.Literacy.OverallSpeedMultiplier

    if not (character:isSitOnGround() or character:getVehicle()) then
        time = time / SandboxVars.Literacy.StandingReadingSpeed
    end
    
    o.maxTime = time
    return o
end

local old_update = ISReadABook.update

function ISReadABook:update()
    if self.character:isPlayerMoving() then
        if not self.characterWasMoving then
            self:changeMaxTime(self.maxTime / SandboxVars.Literacy.SpeedWhileMoving)
        end
    else
        if self.characterWasMoving then
            self:changeMaxTime(self.maxTime * SandboxVars.Literacy.SpeedWhileMoving)
        end
    end
    self.characterWasMoving = self.character:isPlayerMoving()

    local pagesRead = math.floor(self.item:getNumberOfPages() * self:getJobDelta())
    if pagesRead > self.item:getAlreadyReadPages() then
        local difference = pagesRead - self.item:getAlreadyReadPages()
        self.character:getXp():AddXP(Perks.Reading, difference * 1.5 * readingDifficultyMultipliers[self.item:getLvlSkillTrained()] * SandboxVars.Literacy.XPMultiplier)
    end
    old_update(self)
end

local old_perform = ISReadABook.perform

function ISReadABook:perform()
    if self.stats then
        local modData = self.item:getModData()
        local XPReward = modData['XPReward'] or 3
        self.character:getXp():AddXP(Perks.Reading, (XPReward * 4) * SandboxVars.Literacy.XPMultiplier)
        if SandboxVars.Literacy.DontDestroyStatBooks and not Literacy.IsRecipeBook(self.item) then
            if not modData['AlreadyReadPlayers'] then modData['AlreadyReadPlayers'] = {} end
            modData['AlreadyReadPlayers'][Literacy.getIdentifier(self.character)] = true
        end
    end
    old_perform(self)
end

local old_isValid = ISReadABook.isValid

function ISReadABook:isValid()
    if Literacy.PlayerHasReadBook(self.character, self.item) or self.character:getAlreadyReadBook():contains(self.item:getFullType()) then
        local line = nil
        local rand = ZombRand(1, 3)
        if rand == 1 then
            line = getTextOrNull("IGUI_PlayerText_AlreadyRead")
        else
            line = getTextOrNull("IGUI_PlayerText_AlreadyRead2")
        end
        if line then self.character:Say(line) end

        return false
    end

    if not self.character:isSitOnGround() and SandboxVars.Literacy.StandingReadingSpeed == 0 and not self.character:getVehicle() then
        local line = getTextOrNull("IGUI_PlayerText_CantReadStanding")
        if line then self.character:Say(line) end
        return false
    end
    
    ISReadABook.checkMultiplier(self)
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
        if Literacy.IsRecipeBook(item) or not SandboxVars.Literacy.DontDestroyStatBooks then
            old_ReadLiterature(self, item)
        else
            self:getStats():setStress(self:getStats():getStress() + item:getStressChange())
            self:getBodyDamage():JustReadSomething(item)
        end
    end
end