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
local LiteracyTapes = {}
LiteracyTapes.Tapes = {}

function LiteracyTapes.getTapes()
    for guid,data in pairs(RecMedia) do
        if data.category == 'Literacy-VHS' then
            if not LiteracyTapes.Tapes[data.spawning] then Literacy.Tapes[data.spawning] = {} end
            table.insert(LiteracyTapes.Tapes[data.spawning], guid)
        end
    end
end
Events.OnInitRecordedMedia.Add(LiteracyTapes.getTapes)

function LiteracyTapes.setVHS(_roomName, _containerType, container)
    local VHSs = container:FindAll('VHS_Literacy')
    if not VHSs then return end
    for i = 0, VHSs:size()-1 do
        local item = VHSs:get(i)
        local rarity = 0
        local choice = ZombRand(0, 10)
        if choice > 8 then
            if SandboxVars.Literacy.WantLiteracyVHS then
                rarity = 3
            else
                rarity = 2
            end
        elseif choice > 6 then
            rarity = 2
        elseif choice > 3 then
            rarity = 1
        end
        local tape = LiteracyTapes.Tapes[rarity][ZombRand(1, #LiteracyTapes.Tapes[rarity]+1)]
        item:setRecordedMediaData(getZomboidRadio():getRecordedMedia():getMediaData(tape))
    end
end
Events.OnFillContainer.Add(LiteracyTapes.setVHS)

return LiteracyTapes