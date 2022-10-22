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
    local scriptManager = getScriptManager()

    getScriptManager():getItem('Base.Book'):DoParam('XPReward = 20')
    getScriptManager():getItem('Base.Magazine'):DoParam('XPReward = 3')
    getScriptManager():getItem('Base.TVMagazine'):DoParam('XPReward = 3')
    getScriptManager():getItem('Base.HottieZ'):DoParam('XPReward = 3')
    getScriptManager():getItem('Base.ComicBook'):DoParam('XPReward = 3')
    getScriptManager():getItem('Base.Newspaper'):DoParam('XPReward = 4.5')

    getScriptManager():getItem('Base.MagazineCrossword1'):DoParam('XPReward = 3')
    getScriptManager():getItem('Base.MagazineCrossword2'):DoParam('XPReward = 3')
    getScriptManager():getItem('Base.MagazineCrossword3'):DoParam('XPReward = 3')

    getScriptManager():getItem('Base.MagazineWordsearch1'):DoParam('XPReward = 3')
    getScriptManager():getItem('Base.MagazineWordsearch2'):DoParam('XPReward = 3')
    getScriptManager():getItem('Base.MagazineWordsearch3'):DoParam('XPReward = 3')
end