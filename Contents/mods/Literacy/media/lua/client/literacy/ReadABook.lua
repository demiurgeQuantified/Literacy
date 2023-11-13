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
local Starlit = require 'literacy/lib/starlit'
local sandboxVars = SandboxVars.Literacy

local ReadABook = {}

ReadABook.readingDifficultyMultipliers = {1, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45}
ReadABook.itemXP = {
    default = 3,
    ["Base.Book"] = 20,
    ["Base.Magazine"] = 3,
    ["Base.TVMagazine"] = 3,
    ["Base.ComicBook"] = 3,
    ["Base.Newspaper"] = 4.5,
    ["Base.MagazineCrossword1"] = 4,
    ["Base.MagazineCrossword2"] = 4,
    ["Base.MagazineCrossword3"] = 4,
    ["Base.MagazineWordsearch1"] = 4,
    ["Base.MagazineWordsearch2"] = 4,
    ["Base.MagazineWordsearch3"] = 4,
    ["Base.HottieZ"] = 0,
}

local old_new = Starlit.saveFunc('ISReadABook.new')

function ISReadABook:new(character, item, time)
    local o = old_new(self, character, item, time)

    local readingLevel = o.character:getPerkLevel(Perks.Reading)
    
    if readingLevel >= sandboxVars.WalkWhileReadingLevel then
        o.stopOnWalk = false
    end
    if sandboxVars.WalkWhileReadingLevel == -1 then
        o.stopOnWalk = true
    end
    o.characterWasMoving = false
    
    if o.maxMultiplier then -- undefined for stat books
        o.maxMultiplier = o.maxMultiplier * Literacy.calculateReadingMultiplier(o.character)
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

local old_update = Starlit.saveFunc('ISReadABook.update')

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
        self.character:getXp():AddXP(Perks.Reading,
                                     difference * 1.5 * ReadABook.readingDifficultyMultipliers[self.item:getLvlSkillTrained()] * sandboxVars.XPMultiplier)
    end
    --TODO: optionally give xp instead of multiplier
    old_update(self)
end

local old_perform = Starlit.saveFunc('ISReadABook.perform')

function ISReadABook:perform()
    if self.stats then
        local XPReward = ReadABook.itemXP[self.item:getFullType()] or ReadABook.itemXP.default
        self.character:getXp():AddXP(Perks.Reading, (XPReward * 4) * sandboxVars.XPMultiplier)
        
        -- TODO: compatibility with chuck's Named Literature
        -- ignore this entire mechanic when it's enabled
        -- reduce reading xp on re-reads, like how stats from books are reduced
        if sandboxVars.DontDestroyStatBooks and not Literacy.IsRecipeBook(self.item) then
            self.character:getModData().Literacy.alreadyReadBooks[self.item:getID()] = true
        end
    end
    old_perform(self)
end

local old_isValid = Starlit.saveFunc('ISReadABook.isValid')

function ISReadABook:isValid()
    if Literacy.PlayerHasReadBook(self.character, self.item) or self.character:getAlreadyReadBook():contains(self.item:getFullType()) then
        Starlit.sayRandomLine(self.character, {'IGUI_PlayerText_AlreadyRead', 'IGUI_PlayerText_AlreadyRead2'})
        return false
    end

    if not sandboxVars.ReadInTheDark and self.character:getSquare():getLightLevel(self.character:getPlayerNum()) < 0.35 then
        Starlit.sayRandomLine(self.character, {'IGUI_PlayerText_CantReadDark', 'IGUI_PlayerText_CantReadDark2'})
        return false
    end

    if sandboxVars.StandingReadingSpeed == 0 and not self.character:isSitOnGround() and not self.character:getVehicle() then
        self.character:Say(getText("IGUI_PlayerText_CantReadStanding"))
        return false
    end
    
    if ISReadABook.checkMultiplier then ISReadABook.checkMultiplier(self) end -- CDDA reading overwrites ISReadABook and removes this function u_u
    return old_isValid(self)
end

---@param newTime int
function ISReadABook:changeMaxTime(newTime)
    local mult = newTime / self.maxTime
    self:setTime(newTime)
    self.action:setTime(newTime)
    self:setCurrentTime(self.action:getCurrentTime() * mult)
end

local metatable = Starlit.findMetatable('IsoPlayer')
local old_ReadLiterature = metatable.ReadLiterature
function metatable.ReadLiterature(self, item) -- lua reimplementation of ReadLiterature that doesn't remove the item
    if Literacy.IsRecipeBook(item) or not sandboxVars.DontDestroyStatBooks then
        old_ReadLiterature(self, item)
    else
        self:getStats():setStress(self:getStats():getStress() + item:getStressChange())
        self:getBodyDamage():JustReadSomething(item)
    end
end

return ReadABook