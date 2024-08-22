local whi = require 'warehouse_interface'
local warehouses = 'minecolonies:warehouse'
local TRASHCAN = 'ironchests:obsidian_barrel_1'

local MIN_KEEP_COUNT = 1024

-- ITEMS TO KEEP REGARDLESS OF VOLUME
local BLACKLIST = {
    'minecraft:nether_quartz'
}

function PruneWarehouse()
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
            print('Burned', whi.GetFromAnyWarehouse(false, name, TRASHCAN, 64), name)
            itemCountMap[name] = itemCountMap[name] - 64
            goto loopback
        end
    end
end

while true do
    PruneWarehouse()
    sleep(600)
end
