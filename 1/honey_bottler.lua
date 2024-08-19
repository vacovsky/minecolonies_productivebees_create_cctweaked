local WAIT_SECONDS = 30
local warehouse = peripheral.find("minecolonies:warehouse")
local REBOOT_AFTER_LOOPS = 60 -- REBOOT AFTER THIS MANY LOOPS


function Main()
    peripherals = peripheral.getNames()
    honey_storage = 'fluidTank_0'
    honey_bottler = 'create:depot_0'

    -- HONEY BOTTLER
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, honey_bottler) then
            container = peripheral.wrap(attached_peripheral)
            -- PLACE FILLED BOTTLES IN WAREHOUSE
            for slot, item in pairs(container.list()) do
                if item.name == 'minecraft:honey_bottle' then
                    print('Warehousing honey bottles')
                    TransferItem(container, slot, warehouse)
                end
            end
            -- REFILL WITH EMPTY BOTTLES
            for slot, item in pairs(warehouse.list()) do
                if item.name == 'minecraft:glass_bottle' then
                    print('Restocking empty bottles')
                    TransferItem(warehouse, slot, container)
                end
            end
        end
    end
end

function TransferItem(sourceStorage, sourceSlot, dest)
    sourceStorage.pushItems(peripheral.getName(dest), sourceSlot)
end

function TransferItemWithSlot(sourceStorage, sourceSlot, dest, limit, destSlot)
    sourceStorage.pushItems(peripheral.getName(dest), sourceSlot, limit, destSlot)
end

local LOOPS = 0
while true do
    if redstone.getInput('top') then
        pcall(Main)
    else
        print('Service Offline - Flip the lever on top!')
    end
    LOOPS = LOOPS + 1
    print('Sleeping', WAIT_SECONDS, 'seconds. Loop #', LOOPS, 'of', REBOOT_AFTER_LOOPS )
    sleep(WAIT_SECONDS)
    if LOOPS >= REBOOT_AFTER_LOOPS then os.reboot() end
end