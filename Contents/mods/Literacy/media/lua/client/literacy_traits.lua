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
TraitFactory.getTrait('FastReader'):addXpBoost(Perks.Reading, 1)
TraitFactory.getTrait('SlowReader'):addXpBoost(Perks.Reading, -1)
TraitFactory.getTrait('Illiterate'):addXpBoost(Perks.Reading, -5)

TraitFactory.addTrait('PoorReader', 'UI_trait_PoorReader', -2, 'UI_trait_PoorReaderDesc', false)
TraitFactory.setMutualExclusive('PoorReader', 'Illiterate')
TraitFactory.setMutualExclusive('PoorReader', 'FastReader')

TraitFactory.addTrait('VerySlowReader', 'UI_trait_VerySlowReader', -4, 'UI_trait_VerySlowReaderDesc', true)
TraitFactory.setMutualExclusive('VerySlowReader', 'Illiterate')
TraitFactory.setMutualExclusive('VerySlowReader', 'FastReader')
TraitFactory.setMutualExclusive('VerySlowReader', 'SlowReader')