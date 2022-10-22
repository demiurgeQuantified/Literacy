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
local function HandleDistributions()
    local bookLocationsAndValues = {
        ['BookstoreBooks'] = {10, 8, 6, 4, 2},
        ['ClassroomMisc'] = {2, 1, 0.5, 0.1, 0.01},
        ['ClassroomShelves'] = {2, 1, 0.5, 0.1, 0.01},
        ['CrateBooks'] = {6, 4, 2, 1, 0.5},
        ['LibraryBooks'] = {8, 6, 4, 2, 1},
        ['LivingRoomShelf'] = {2, 1, 0.5, 0.1, 0.01},
        ['LivingRoomShelfNoTapes'] = {2, 1, 0.5, 0.1, 0.01},
        ['PostOfficeBooks'] = {6, 4, 2, 1, 0.5},
        ['ShelfGeneric'] = {2, 1, 0.5, 0.1, 0.01},
    }
    
    local wantedBooks = {}

    if SandboxVars.Literacy.WantGunBooks then
        table.insert(wantedBooks, 'Literacy.BookAiming')
        table.insert(wantedBooks, 'Literacy.BookReloading')
    end

    if SandboxVars.Literacy.WantPassiveBooks then
        table.insert(wantedBooks, 'Literacy.BookStrength')
        table.insert(wantedBooks, 'Literacy.BookFitness')
    end

    if SandboxVars.Literacy.WantAgilityBooks then
        table.insert(wantedBooks, 'Literacy.BookSprinting')
        table.insert(wantedBooks, 'Literacy.BookNimble')
        table.insert(wantedBooks, 'Literacy.BookLightfoot')
        table.insert(wantedBooks, 'Literacy.BookSneak')
    end

    if SandboxVars.Literacy.WantWeaponBooks then
        table.insert(wantedBooks, 'Literacy.BookAxe')
        table.insert(wantedBooks, 'Literacy.BookSmallBlunt')
        table.insert(wantedBooks, 'Literacy.BookBlunt')
        table.insert(wantedBooks, 'Literacy.BookSmallBlade')
        table.insert(wantedBooks, 'Literacy.BookLongBlade')
        table.insert(wantedBooks, 'Literacy.BookSpear')
    end

    if SandboxVars.Literacy.WantMaintenanceBooks then
        table.insert(wantedBooks, 'Literacy.BookMaintenance')
        table.insert(ProceduralDistributions['list']['ToolStoreBooks'].items, 'Literacy.BookMaintenance1')
        table.insert(ProceduralDistributions['list']['ToolStoreBooks'].items, 10)
        table.insert(ProceduralDistributions['list']['ToolStoreBooks'].items, 'Literacy.BookMaintenance2')
        table.insert(ProceduralDistributions['list']['ToolStoreBooks'].items, 8)
        table.insert(ProceduralDistributions['list']['ToolStoreBooks'].items, 'Literacy.BookMaintenance3')
        table.insert(ProceduralDistributions['list']['ToolStoreBooks'].items, 6)
        table.insert(ProceduralDistributions['list']['ToolStoreBooks'].items, 'Literacy.BookMaintenance4')
        table.insert(ProceduralDistributions['list']['ToolStoreBooks'].items, 4)
        table.insert(ProceduralDistributions['list']['ToolStoreBooks'].items, 'Literacy.BookMaintenance5')
        table.insert(ProceduralDistributions['list']['ToolStoreBooks'].items, 2)
    end

    table.insert(ProceduralDistributions['list']['LivingRoomShelf'].items, 'Literacy.VHS_Literacy')
    table.insert(ProceduralDistributions['list']['LivingRoomShelf'].items, 3.61)
    table.insert(ProceduralDistributions['list']['CrateRandomJunk'].items, 'Literacy.VHS_Literacy')
    table.insert(ProceduralDistributions['list']['CrateRandomJunk'].items, 0.025)
    table.insert(ProceduralDistributions['list']['CrateVHSTapes'].items, 'Literacy.VHS_Literacy')
    table.insert(ProceduralDistributions['list']['CrateVHSTapes'].items, 2)

    if not wantedBooks[1] then return end
    for k,v in pairs(bookLocationsAndValues) do
        local lootTable = ProceduralDistributions['list'][k].items
        local multiplier = 1
        local wantedBooksForLocation = {}
        for _,book in ipairs(wantedBooks) do
            table.insert(wantedBooksForLocation, book)
        end
        if not SandboxVars.Literacy.SafeMode then
            local oldBooks = 0
            for iterator = #lootTable-1,1,-2 do
                if luautils.stringStarts(lootTable[iterator], 'Book') and lootTable[iterator] ~= 'Book' then
                    local removedBook = lootTable[iterator]
                    table.remove(lootTable, iterator+1)
                    table.remove(lootTable, iterator)
                    local trimmedBook = string.sub(removedBook, 1, -2)
                    if trimmedBook ~= wantedBooksForLocation[#wantedBooksForLocation] then
                        oldBooks = oldBooks + 1
                        table.insert(wantedBooksForLocation, trimmedBook)
                    end
                end
            end
            multiplier = oldBooks / #wantedBooksForLocation
        end
        for _,book in ipairs(wantedBooksForLocation) do
            for i=1,5 do
                table.insert(lootTable, book .. tostring(i))
                table.insert(lootTable, v[i] * multiplier)
            end
        end
    end

    ItemPickerJava.Parse()
end

Events.OnInitGlobalModData.Add(HandleDistributions)