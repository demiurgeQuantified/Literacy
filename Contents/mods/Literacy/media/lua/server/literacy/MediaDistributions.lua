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

---@type RecordedMedia
local recMedia

---@param recordedMedia RecordedMedia
function LiteracyTapes.getTapes(recordedMedia)
    recMedia = recordedMedia
    for guid,data in pairs(RecMedia) do
        if data.category == 'Literacy-VHS' then
            if not LiteracyTapes.Tapes[data.spawning] then LiteracyTapes.Tapes[data.spawning] = {} end
            table.insert(LiteracyTapes.Tapes[data.spawning], guid)
        end
    end
end
Events.OnInitRecordedMedia.Add(LiteracyTapes.getTapes)

---@param rarity int
---@return MediaData
function LiteracyTapes.getRandomTape(rarity)
    return recMedia:getMediaData(LiteracyTapes.Tapes[rarity][ZombRand(1, #LiteracyTapes.Tapes[rarity]+1)])
end

---@param _roomName string
---@param _containerType string
---@param container ItemContainer
function LiteracyTapes.setContainerTapes(_roomName, _containerType, container)
    local VHSs = container:FindAll('VHS_Literacy')
    if not VHSs then return end
    for i = 0, VHSs:size()-1 do
        ---@type InventoryItem
        local item = VHSs:get(i)
        
        local rarity = 0
        local remove
        local choice = ZombRand(0, 10)
        if choice > 8 then
            if SandboxVars.Literacy.WantLiteracyVHS then
                rarity = 3
            else
                remove = true
            end
        elseif choice > 6 then
            rarity = 2
        elseif choice > 3 then
            rarity = 1
        end
        
        if remove then
            container:Remove(item)
        else
            item:setRecordedMediaData(LiteracyTapes.getRandomTape(rarity))
        end
    end
end
Events.OnFillContainer.Add(LiteracyTapes.setContainerTapes)

return LiteracyTapes