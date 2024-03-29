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

local old_checkXPBoost = Starlit.saveFunc('CharacterCreationProfession.checkXPBoost')

function CharacterCreationProfession:checkXPBoost()
    old_checkXPBoost(self)

    self.listboxXpBoost:removeItem(PerkFactory.getPerkName(Perks.Reading))
    local readingLevel
    if self.listboxTraitSelected and self.listboxTraitSelected.items then
        for i,v in pairs(self.listboxTraitSelected.items) do
            if v.item:getXPBoostMap() then
                local table = transformIntoKahluaTable(v.item:getXPBoostMap())
                if table[Perks.Reading] then
                    readingLevel = table[Perks.Reading]:intValue()
                else
                    readingLevel = 0
                end
            end
        end
    end
    readingLevel = (readingLevel or 0) + 5
    self.listboxXpBoost:addItem(PerkFactory.getPerkName(Perks.Reading), { perk = Perks.Reading, level = readingLevel })
    self.listboxXpBoost:sort()
end

local old_drawXpBoostMap = Starlit.saveFunc('CharacterCreationProfession.drawXpBoostMap')

function CharacterCreationProfession:drawXpBoostMap(y, item, alt)
    if item.item.perk == Perks.Reading then
        local dy = (self.itemheight - self.fontHgt) / 2
        local hc = getCore():getGoodHighlitedColor()
        self:drawText(item.text, 16, y + dy, 0, 1, 0, 1, UIFont.Small);

        local textWid = getTextManager():MeasureStringX(UIFont.Small, item.text)
        local greenBlitsX = self.width - (68 + 10 * 4)
        local yy = y
        if 16 + textWid > greenBlitsX - 4 then
            yy = y + self.fontHgt
        end

        for i = 1,item.item.level do
            self:drawTexture(CharacterCreationProfession.instance.whiteBar, self.width - (68 + 10 * 4) + (i * 4), (yy) + dy + 4, 1, hc:getR(), hc:getG(), hc:getB());
        end

        yy = yy + self.itemheight;

        self:drawRectBorder(0, (y), self:getWidth(), yy - y - 1, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b);

        return yy;
    else
        return old_drawXpBoostMap(self, y, item, alt)
    end
end

local old_updateTooltip = Starlit.saveFunc('ISSkillProgressBar.updateTooltip')

function ISSkillProgressBar:updateTooltip(lvlSelected)
    old_updateTooltip(self, lvlSelected)
    if self.perk == Perks.Reading then
        local readingSpeed = Literacy.calculateReadingSpeed(self.char)
        readingSpeed = readingSpeed * 100
        readingSpeed = math.floor(readingSpeed + 0.5)
        self.message = self.message .. ' <LINE> ' .. getText('IGUI_XP_readingspeed', readingSpeed)
        
        local readingMult = Literacy.calculateReadingMultiplier(self.char)
        readingMult = readingMult * 100
        readingMult = math.floor(readingMult + 0.5)
        self.message = self.message .. ' <LINE> ' .. getText('IGUI_XP_readingmult', readingMult)
    end
end

-- this didn't work anyway TODO: just have a toggle to replace the function for splitscreen

--local old_refreshContainer = Starlit.saveFunc('ISInventoryPane.refreshContainer')
--
--function ISInventoryPane:refreshContainer()
--    if getNumActivePlayers() ~= 1 then
--        local books = self.inventory:getItemsFromCategory('Literature')
--        for i = 0, books:size()-1 do
--            local book = books:get(i)
--            if Literacy.PlayerHasReadBook(getSpecificPlayer(self.player), book) then
--                book:setName(getText('IGUI_ReadIndicator', book:getScriptItem():getDisplayName()))
--                -- this will break mods that change the names of instances of the item, but only in splitscreen
--            end
--        end
--    end
--    old_refreshContainer(self)
--end

local metatable = Starlit.findMetatable('Literature')
local old_getName = metatable.getName
function metatable.getName(self)
    if Literacy.PlayerHasReadBook(getPlayer(), self) then
        return getText('IGUI_ReadIndicator', old_getName(self))
    end
    return old_getName(self)
end