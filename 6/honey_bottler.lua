local whi = require "lib/whi"
local net = require "lib/network"

local WAIT_SECONDS = 30
local REBOOT_AFTER_LOOPS = 60 -- REBOOT AFTER THIS MANY LOOPS
local honey_bottler = 'create:depot_5'

function Main()
    local restockNum = 0
    local peripherals = peripheral.getNames()
    print('\n')
    -- HONEY BOTTLER
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, honey_bottler) then
            local container = peripheral.wrap(attached_peripheral)
            -- PLACE FILLED BOTTLES IN WAREHOUSE
            for slot, item in pairs(container.list()) do
                if item.name == 'minecraft:honey_bottle' then
                    local depositNum = whi.DepositInAnyWarehouse(attached_peripheral, slot)
                    if depositNum > 0 then print('Warehoused', depositNum, 'honey bottles') end
                end
            end
            -- REFILL WITH EMPTY BOTTLES
            restockNum = whi.GetFromAnyWarehouse('minecraft:glass_bottle', peripheral.getName(container), 64, false)
        end
    end

    for _, hive in pairs(net.ListMatchingDevices('productivebees:advanced_')) do 
        restockNum = whi.GetFromAnyWarehouse('minecraft:glass_bottle', hive, 64, false)
    end

    if restockNum > 0 then print('Restocked', restockNum, 'glass bottles') end
    print('\n')
end



local LOOPS = 0
print('Starting HONEY BOTTLER')
while true do
    Main()
    LOOPS = LOOPS + 1
    print('Sleeping', WAIT_SECONDS, 'seconds. Loop #', LOOPS, 'of', REBOOT_AFTER_LOOPS )
    sleep(WAIT_SECONDS)
    if LOOPS >= REBOOT_AFTER_LOOPS then os.reboot() end
end