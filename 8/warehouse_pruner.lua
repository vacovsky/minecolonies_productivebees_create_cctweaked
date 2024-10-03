local json = require "lib/json"
local whi = require 'lib/whi'
local warehouses = 'minecolonies:warehouse'
local TRASHCAN = 'ironchests:diamond_chest_1'
COLONY_NAME = 'Nolins'

local MIN_KEEP_COUNT = 2048
local MAX_SLOTS_COUNT = 32

function PruneWarehouse()
    local burnedCount = 0
    local itemCountMap = {}

    -- COLLECT WAREHOUSE NAMES
    local peripherals = peripheral.getNames()
    local warehouses_list = {}
    for _, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, warehouses) then
            warehouses_list[#warehouses_list + 1] = attached_peripheral
        end
    end

    for _, warehouse in pairs(warehouses_list) do
        local whp = peripheral.wrap(warehouse)
        for _, item in pairs(whp.list()) do
            if itemCountMap[item.name] then
                itemCountMap[item.name] = {
                    count = itemCountMap[item.name].count + item.count,
                    slots = itemCountMap[item.name].slots + 1
                }
            else
                itemCountMap[item.name] = {
                    count = 0 + item.count,
                    slots = 1
                }
            end
        end
    end

    ::loopback::
    for name, tab in pairs(itemCountMap) do
        -- print(name, tab)
        if type(tab) == 'table' then
            if tab.count > MIN_KEEP_COUNT
                or (tab.count > MIN_KEEP_COUNT / 2 and tab.slots > MAX_SLOTS_COUNT) then
                local this = whi.GetFromAnyWarehouse(false, name, TRASHCAN, 64)
                itemCountMap[name] = itemCountMap[name].count - this
                burnedCount = burnedCount + this
                print('Burned', this, ':', tab.slots, name, burnedCount)
                goto loopback
            end
        end
    end
    local data = {
        timeStamp = os.epoch("utc"),
        incinerator = {
            name = COLONY_NAME,
            incineratedCount = burnedCount
        }
    }
    WriteToFile(json.encode(data), "prunerData.json", "w")
end

function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end

while true do
    print('Starting warehouse prune...')
    PruneWarehouse()
    -- pcall(PruneWarehouse)
    sleep(5)
end
