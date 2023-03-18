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

local skills = {'Reading', 'Reloading', 'Aiming', 'Strength', 'Fitness', 'Nimble', 'Sprinting', 'Sneak', 'Lightfoot', 'Maintenance', 'Axe', 'SmallBlunt', 'Blunt', 'SmallBlade', 'LongBlade', 'Spear'}
local multipliers = {3,5,8,12,16}

for i = 1, #skills do
    local skill = skills[i]
    SkillBook[skill] = {}
    SkillBook[skill].perk = Perks[skill]
    for j = 1, #multipliers do
        SkillBook[skill]["maxMultiplier" .. j] = multipliers[j]
    end
end