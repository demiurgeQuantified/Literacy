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
do
    local supportedLanguages = {['EN'] = true, ['TR'] = true}

    local skills = {'Reloading', 'Aiming', 'Strength', 'Fitness', 'Nimble', 'Sprinting', 'Sneak', 'Lightfoot', 'Maintenance', 'Axe', 'SmallBlunt', 'Blunt', 'SmallBlade', 'LongBlade', 'Spear'}

    local skillTranslation = {['Lightfoot'] = 'Lightfooted', ['Sneak'] = 'Sneaking'}

    if not supportedLanguages[getCore():getOptionLanguageName()] then
        local scriptManager = getScriptManager()
        for _,skill in ipairs(skills) do
            for i=1,5 do
                local skillName = getText('IGUI_perks_' .. (skillTranslation[skill] or skill))
                local name = getText('IGUI_BookName_' .. i, skillName)
                scriptManager:getItem('Literacy.Book' .. skill .. i):setDisplayName(name)
            end
        end
    end
end