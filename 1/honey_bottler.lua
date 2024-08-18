local WAIT_SECONDS = 30
local warehouse = peripheral.find("minecolonies:warehouse")

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

while true do
    print(redstone.getInput('top'))
    if redstone.getInput('top') then
        pcall(Main)
    else
        print('Service Offline - Flip the lever!')
    end
    print('Sleeping', WAIT_SECONDS, 'seconds')
    sleep(WAIT_SECONDS)
end