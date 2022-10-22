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

local function setInitialLiteracy()
    local player = getPlayer()
    if player:getModData().LiteracySetUp == nil then

        player:level0(Perks.Reading)
        player:getXp():setPerkBoost(Perks.Reading, 0)

        if not player:HasTrait('Illiterate') then
            local desiredLevel = 5
            if player:HasTrait('FastReader') then
                desiredLevel = 6
            elseif player:HasTrait('SlowReader') then
                desiredLevel = 4
            end

            for i=1, desiredLevel do
                player:LevelPerk(Perks.Reading)
            end
            player:getXp():setXPToLevel(Perks.Reading, desiredLevel)
        end
        player:getModData().LiteracySetUp = 1
    end
end
Events.OnCreatePlayer.Add(setInitialLiteracy)

function Literacy.calculateReadingSpeed(character)
    local readingSpeed = character:getPerkLevel(Perks.Reading)
    readingSpeed = math.max(1, readingSpeed)
    readingSpeed = readingSpeed - 5
    if readingSpeed > 0 then
        readingSpeed = readingSpeed * 0.3
    else
        readingSpeed = readingSpeed * 0.2
    end
    
    if character:HasTrait('FastReader') then
        readingSpeed = readingSpeed + 0.2
    elseif character:HasTrait('SlowReader') then
        readingSpeed = readingSpeed - 0.2
    elseif character:HasTrait('VerySlowReader') then
        readingSpeed = readingSpeed - 0.4
    end

    readingSpeed = readingSpeed + 1
    readingSpeed = math.max(0.2, readingSpeed)
    return readingSpeed
end

-- ISReadABook overrides

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

    if not character:isSitOnGround() then
        time = time * SandboxVars.Literacy.StandingReadingSpeed
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
        local XPReward = modData['XPReward'] or 5
        self.character:getXp():AddXP(Perks.Reading, (XPReward * 4) * SandboxVars.Literacy.XPMultiplier)
    end
    old_perform(self)
end

local old_isValid = ISReadABook.isValid

function ISReadABook:isValid()
    if not character:isSitOnGround() and SandboxVars.Literacy.StandingReadingSpeed == 0 and not self.character:getVehicle() then
        self.character:Say(getText("IGUI_PlayerText_CantReadStanding"))
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

local function LevelPerk(character, perk)
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
Events.LevelPerk.Add(LevelPerk)