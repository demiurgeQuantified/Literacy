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
local Starlit = require 'lib/starlit'

Starlit.doItemParam('Base.Book', 'XPReward = 20')
Starlit.doItemParam('Base.Magazine', 'XPReward = 3')
Starlit.doItemParam('Base.TVMagazine', 'XPReward = 3')
Starlit.doItemParam('Base.HottieZ', 'XPReward = 3')
Starlit.doItemParam('Base.ComicBook', 'XPReward = 3')
Starlit.doItemParam('Base.Newspaper', 'XPReward = 4.5')

Starlit.doItemParam('Base.MagazineCrossword1', 'XPReward = 3')
Starlit.doItemParam('Base.MagazineCrossword2', 'XPReward = 3')
Starlit.doItemParam('Base.MagazineCrossword3', 'XPReward = 3')

Starlit.doItemParam('Base.MagazineWordsearch1', 'XPReward = 3')
Starlit.doItemParam('Base.MagazineWordsearch2', 'XPReward = 3')
Starlit.doItemParam('Base.MagazineWordsearch3', 'XPReward = 3')

local bookToModel = {FirstAid = 2, Farming = 3, Trapping = 4, Fishing = 5, Electrician = 6, MetalWelding = 7,
                     Carpentry = 8, Cooking = 9, Foraging = 10, Mechanic = 11, Tailoring = 11}
for skillbook,model in pairs(bookToModel) do
    for i=1,5 do
        Starlit.doItemParam('Base.Book' .. skillbook .. i, 'StaticModel = Literacy.Book' .. model)
    end
end