local WAIT_SECONDS = 180
local REBOOT_AFTER_LOOPS = 6 -- REBOOT AFTER THIS MANY LOOPS
local SMELT_FLESH = false

local hives = 'productivebees:advanced_'
local fuges = 'productivebees:centrifuge'
local furnaces = 'minecraft:furnace'
local blast_furnaces = 'minecraft:blast_furnace'
local warehouses = "minecolonies:warehouse"
-- local warehouse = peripheral.find("minecolonies:warehouse")

function Main()
    peripherals = peripheral.getNames()
    honey_storage = 'fluidTank_0'
    furnaces_list = {}
    blast_furnaces_list = {}
    fuge_list = {}
    honey_bottler = 'create:depot_0'

    -- CREATE LISTS OF PERIPHERAL PROCESSORS
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, fuges) then
            fuge_list[#fuge_list+1] = attached_peripheral
        end

        if string.find(attached_peripheral, furnaces) then
            furnaces_list[#furnaces_list+1] = attached_peripheral
        end

        if string.find(attached_peripheral, blast_furnaces) then
            blast_furnaces_list[#blast_furnaces_list+1] = attached_peripheral
        end
    end

    for index, attached_peripheral in pairs(peripherals) do
        -- TRANSFER WOOD/STONE TO WAREHOUSE
        if string.find(attached_peripheral, hives) then
            container = peripheral.wrap(attached_peripheral)
            for slot, item in pairs(container.list()) do
                if not string.find(item.name, 'productivebees:') and not string.find(item.name, 'minecrfaft:glass_bottle') then
                    print('Warehousing:', item.name)
                    DepositInAnyWarehouse(container, slot)
                end
            end
        end

        -- REMOVE SMELTED ITEMS FROM BLAST FURNACES
        if string.find(attached_peripheral, blast_furnaces) then
            for f, blast_furnace in pairs(blast_furnaces_list) do
                source_blast_furnace = peripheral.wrap(blast_furnace)
                DepositInAnyWarehouse(source_blast_furnace, 3)
            end
        end

        -- REMOVE SMELTED ITEMS FROM FURNACES
        if string.find(attached_peripheral, furnaces) then
            for f, furnace in pairs(furnaces_list) do
                source_furnace = peripheral.wrap(furnace)
                DepositInAnyWarehouse(container, 3)
            end
        end

        -- TRANSFER COMBS TO FUGES
        for i, attached_peripheral in pairs(peripherals) do
            if string.find(attached_peripheral, hives) then
                hive = peripheral.wrap(attached_peripheral)
                for slot, item in pairs(hive.list()) do
                    if string.find(item.name, 'productivebees:') then
                        for f, fuge in pairs(fuge_list) do
                            dest_fuge = peripheral.wrap(fuge)
                            -- print('Spinning:', item.name)
                            TransferItem(hive, slot, dest_fuge)
                        end
                    end
                end
            end
        end

        -- TRANSFER FUGE-PROCESSED MATERIALS TO WAREHOUSE 
        if string.find(attached_peripheral, fuges) then
            container = peripheral.wrap(attached_peripheral)

            -- PUSH HONEY TO HONEY STORAGE VESSEL
            print('Tranferring honey')
            container.pushFluid(honey_storage)

            -- PUSH THE REST
            for slot, item in pairs(container.list()) do
                if not string.find(item.name, 'productivebees:') then

                    -- GRAB RAW ORES FOR PROCESSING
                    if string.find(item.name, 'minecraft:raw_') or string.find(item.name, 'minecraft:ancient_debris')then
                        for f, blast_furnace in pairs(blast_furnaces_list) do
                            print('Firing:', item.name, blast_furnace)
                            dest_blast_furnace = peripheral.wrap(blast_furnace)
                            TransferItemWithSlot(container, slot, dest_blast_furnace, 64, 1)
                        end
                        -- SMELT ROTTEN FLESH INTO LEATHER
                        if SMELT_FLESH and string.find(item.name, 'rotten_flesh') then
                            for f, furnace in pairs(furnaces_list) do
                                print('Firing:', item.name, furnace)
                                dest_furnace = peripheral.wrap(furnace)
                                TransferItemWithSlot(container, slot, dest_furnace, 64, 1)
                            end
                        end
                    end
                    -- OTHERWISE, SEND TO WAREHOUSE
                    DepositInAnyWarehouse(container, slot)

                elseif string.find(item.name, 'productivebees:wax') then
                    -- FILL BLAST FURNACES WITH FUEL
                    for f, blast_furnace in pairs(blast_furnaces_list) do
                        dest_blast_furnace = peripheral.wrap(blast_furnace)
                        print('Fueling:', blast_furnace)
                        TransferItemWithSlot(container, slot, dest_blast_furnace, 64, 2)
                    end
                    -- FILL FURNACES WITH FUEL
                    for f, furnace in pairs(furnaces_list) do
                        dest_furnace = peripheral.wrap(furnace)
                        print('Fueling:', furnace)
                        TransferItemWithSlot(container, slot, dest_furnace, 64, 2)
                    end

                    -- LAST RESORT, SEND TO WAREHOUSE
                    DepositInAnyWarehouse(container, slot)
                    elseif string.find(item.name, 'productivebees:sugarbag_honeycomb') then
                        DepositInAnyWarehouse(container, slot)
                    end
            end
        end
    end
end

function DepositInAnyWarehouse(sourceStorage, sourceSlot)
    peripherals = peripheral.getNames()
    warehouses_list = {}
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, warehouses) then
            print(attached_peripheral)
            warehouses_list[#warehouses_list+1] = attached_peripheral
        end
    end
    for whi, warehouse in pairs(warehouses_list) do
        TransferItem(sourceStorage, sourceSlot, warehouse)
    end
end

function GetFromAnyWarehouse(itemName, destination)
    peripherals = peripheral.getNames()
    warehouses_list = {}
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, warehouses) then
            warehouses_list[#warehouses_list+1] = attached_peripheral
        end
    end
    for whi, warehouse in pairs(warehouses_list) do
        warehouse_peripheral = peripheral.wrap(warehouse)
        for slot, item in pairs(warehouse.list()) do
            if item.name == itemName then
                print('Restocking', itemName)
                TransferItem(warehouse_peripheral, slot, container)
                goto found
            end
        end
        ::found::
    end
end

function TransferItem(sourceStorage, sourceSlot, dest)
    sourceStorage.pushItems(peripheral.getName(dest), sourceSlot)
end

function TransferItemWithSlot(sourceStorage, sourceSlot, dest, limit, destSlot)
    sourceStorage.pushItems(peripheral.getName(dest), sourceSlot, limit, destSlot)
end


function DepositInAnyWarehouse(sourceStorage, sourceSlot)
    peripherals = peripheral.getNames()
    warehouses_list = {}
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(warehouses, attached_peripheral) then
            warehouses_list[#warehouses_list+1] = attached_peripheral
        end
    end
    for whi, warehouse in pairs(warehouses_list) do
        TransferItem(sourceStorage, sourceSlot, warehouse)
    end
end

function GetFromAnyWarehouse(itemName, destination)
    peripherals = peripheral.getNames()
    warehouses_list = {}
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, warehouses) then
            warehouses_list[#warehouses_list+1] = attached_peripheral
        end
    end
    for whi, warehouse in pairs(warehouses_list) do
        warehouse_peripheral = peripheral.wrap(warehouse)
        for slot, item in pairs(warehouse.list()) do
            if item.name == itemName then
                print('Restocking', itemName)
                TransferItem(warehouse_peripheral, slot, destination)
                goto found
            end
        end
        ::found::
    end
end

LOOPS = 0
print('Starting HIVE MANAGER...')

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