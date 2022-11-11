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
local function doTraits()
    TraitFactory.addTrait('PoorReader', getText('UI_trait_PoorReader'), -2, getText('UI_trait_PoorReaderDesc'), false)
    TraitFactory.addTrait('VerySlowReader', getText('UI_trait_VerySlowReader'), -4, getText('UI_trait_VerySlowReaderDesc'), true)

    local trait = TraitFactory.getTrait('FastReader')
    if trait then
        trait:addXPBoost(Perks.Reading, 1)
        TraitFactory.setMutualExclusive('FastReader', 'VerySlowReader')
        TraitFactory.setMutualExclusive('FastReader', 'PoorReader')
    end
    local trait = TraitFactory.getTrait('SlowReader')
    if trait then
        trait:addXPBoost(Perks.Reading, -1)
        TraitFactory.setMutualExclusive('SlowReader', 'VerySlowReader')
    end
    local trait = TraitFactory.getTrait('Illiterate')
    if trait then
        trait:addXPBoost(Perks.Reading, -5)
        TraitFactory.setMutualExclusive('Illiterate', 'VerySlowReader')
        TraitFactory.setMutualExclusive('Illiterate', 'PoorReader')
    end
end

Events.OnGameBoot.Add(doTraits)