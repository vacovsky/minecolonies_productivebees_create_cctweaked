local json = require "json"
local whi = require 'warehouse_interface'
local warehouses = 'minecolonies:warehouse'
local TRASHCAN = 'ironchests:diamond_chest_0'
COLONY_NAME = 'Nolins'

local MIN_KEEP_COUNT = 1024

-- ITEMS TO KEEP REGARDLESS OF VOLUME
local BLACKLIST = {
    'minecraft:nether_quartz'
}

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
                itemCountMap[item.name] = itemCountMap[item.name] + item.count
            else
                itemCountMap[item.name] = item.count
            end
        end
    end

    ::loopback::
    for name, count in pairs(itemCountMap) do
        if count > MIN_KEEP_COUNT then
            local this = whi.GetFromAnyWarehouse(false, name, TRASHCAN, 64)
            itemCountMap[name] = itemCountMap[name] - this
            burnedCount = burnedCount + this
            print('Burned', this, name)
            goto loopback
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
    -- PruneWarehouse()
    pcall(PruneWarehouse)
    sleep(600)
end
