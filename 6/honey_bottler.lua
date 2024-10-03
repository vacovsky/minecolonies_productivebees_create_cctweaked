local whi = require "lib/whi"
local net = require "lib/network"

local WAIT_SECONDS = 30
local REBOOT_AFTER_LOOPS = 60 -- REBOOT AFTER THIS MANY LOOPS
local honey_bottler = 'create:depot_5'
local destination = 'minecolonies:colonybuilding_2'

-- HONEY BOTTLER
function Main()
    local restockNum = 0
    local container = peripheral.wrap(honey_bottler)
    -- PLACE FILLED BOTTLES IN WAREHOUSE
    for slot, item in pairs(container.list()) do
        if item.name == 'minecraft:honey_bottle' then
            local depositNum = peripheral.wrap(destination).pullItems(honey_bottler, slot)
            if depositNum > 0 then print('Delivered', depositNum, 'honey bottles') end
        end
    end
    -- REFILL WITH EMPTY BOTTLES
    restockNum = whi.GetFromAnyWarehouse(false, 'minecraft:glass_bottle', honey_bottler, 64)


    for _, hive in pairs(net.ListMatchingDevices('productivebees:advanced_')) do
        restockNum = restockNum + whi.GetFromAnyWarehouse(false, 'minecraft:glass_bottle', hive, 64)
    end
    if restockNum > 0 then print('Restocked', restockNum, 'glass bottles') end
end

local LOOPS = 0
print('Starting HONEY BOTTLER')
while true do
    Main()
    LOOPS = LOOPS + 1
    print('Sleeping', WAIT_SECONDS, 'seconds. Loop #', LOOPS, 'of', REBOOT_AFTER_LOOPS)
    sleep(WAIT_SECONDS)
    if LOOPS >= REBOOT_AFTER_LOOPS then os.reboot() end
end
