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
    local supportedLanguages = {['EN'] = true, ['TR'] = true} -- languages with full translations
    local specialNumerationLanguages = {['PL'] = true} -- languages you can't just insert i into to get the correct translation

    local lang = getCore():getOptionLanguageName()

    if not supportedLanguages[lang] then
        local skills = {'Reloading', 'Aiming', 'Strength', 'Fitness', 'Nimble', 'Sprinting', 'Sneak', 'Lightfoot', 'Maintenance', 'Axe', 'SmallBlunt', 'Blunt', 'SmallBlade', 'LongBlade', 'Spear'}
        local skillTranslation = {Lightfoot = 'Lightfooted', Sneak = 'Sneaking'}
        local scriptManager = getScriptManager()
        
        for _,skill in ipairs(skills) do
            for i=1,5 do
                local skillName = getText('IGUI_perks_' .. (skillTranslation[skill] or skill))
                local name
                if not specialNumerationLanguages[lang] then
                    name = getText('IGUI_BookName', skillName, i)
                else
                    name = getText('IGUI_BookName_' .. i, skillName)
                end
                scriptManager:getItem('Literacy.Book' .. skill .. i):setDisplayName(name)
            end
        end
    end
end