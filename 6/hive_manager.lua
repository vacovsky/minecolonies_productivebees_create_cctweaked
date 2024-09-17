local json = require "json"

local WAIT_SECONDS = 30
local REBOOT_AFTER_LOOPS = 30 -- REBOOT AFTER THIS MANY LOOPS
local SMELT_FLESH = true

local hives = 'productivebees:advanced_'
local fuges = 'productivebees:centrifuge'
local furnaces = 'minecraft:furnace'
local heated_fuges = 'productivebees:heated_centrifuge'
local generators = 'scguns:polar_generator'
local blast_furnaces = 'minecraft:blast_furnace'
local warehouses = "minecolonies:warehouse"
-- local warehouse = peripheral.find("minecolonies:warehouse")

local processed = {
    name = "Nolins"
}

function Main()
    local honey_collected = 0
    local peripherals = peripheral.getNames()
    local honey_storage = 'fluidTank_13'
    local generators_list = {}
    local blast_furnaces_list = {}
    local fuge_list = {}
    local furnaces_list = {}
    local heated_fuge_list = {}


    local totalWarehousedThisRun = 0
    -- CREATE LISTS OF PERIPHERAL PROCESSORS
    for _, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, fuges) then
            fuge_list[#fuge_list + 1] = attached_peripheral
        end

        if string.find(attached_peripheral, furnaces) then
            furnaces_list[#furnaces_list + 1] = attached_peripheral
        end

        if string.find(attached_peripheral, generators) then
            generators_list[#generators_list + 1] = attached_peripheral
        end

        if string.find(attached_peripheral, blast_furnaces) then
            blast_furnaces_list[#blast_furnaces_list + 1] = attached_peripheral
        end
        if string.find(attached_peripheral, heated_fuges) then
            heated_fuge_list[#heated_fuge_list + 1] = attached_peripheral
        end
    end

    for index, attached_peripheral in pairs(peripherals) do
        -- TRANSFER WOOD/STONE/HONEY BOTTLES TO WAREHOUSE
        if string.find(attached_peripheral, hives) then
            local container = peripheral.wrap(attached_peripheral)
            local bottles_replenished = GetFromAnyWarehouse('minecraft:glass_bottle', attached_peripheral, 4, false)
            print('Stocked', bottles_replenished, 'bottles to', attached_peripheral)
            for slot, item in pairs(container.list()) do
                if not string.find(item.name, 'productivebees:') and not string.find(item.name, 'minecrfaft:glass_bottle') then
                    print('Warehousing:', item.name)
                    totalWarehousedThisRun = totalWarehousedThisRun + DepositInAnyWarehouse(container, slot)
                end
            end
        end

        -- REMOVE SMELTED ITEMS FROM BLAST FURNACES
        if string.find(attached_peripheral, blast_furnaces) then
            local container = peripheral.wrap(attached_peripheral)
            totalWarehousedThisRun = totalWarehousedThisRun + DepositInAnyWarehouse(container, 3)
        end

        -- REMOVE SMELTED ITEMS FROM FURNACES
        if string.find(attached_peripheral, furnaces) then
            local container = peripheral.wrap(attached_peripheral)
            totalWarehousedThisRun = totalWarehousedThisRun + DepositInAnyWarehouse(container, 3)
        end

        -- TRANSFER COMBS TO FUGES
        for i, attached_peripheral in pairs(peripherals) do
            if string.find(attached_peripheral, hives) then
                local hive = peripheral.wrap(attached_peripheral)

                for slot, item in pairs(hive.list()) do
                    if string.find(item.name, 'productivebees:') then
                        for f, fuge in pairs(fuge_list) do
                            local dest_fuge = peripheral.wrap(fuge)
                            -- print('Spinning:', item.name)
                            TransferItem(hive, slot, dest_fuge)
                        end
                    end
                    if string.find(item.name, 'productivebees:') then
                        for f, fuge in pairs(fuge_list) do
                            local dest_fuge = peripheral.wrap(fuge)
                            -- print('Spinning:', item.name)
                            TransferItem(hive, slot, dest_fuge)
                        end
                    end
                end
            end
        end

        -- TRANSFER FUGE-PROCESSED MATERIALS TO WAREHOUSE
        if string.find(attached_peripheral, fuges) then
            local container = peripheral.wrap(attached_peripheral)
            -- PUSH HONEY TO HONEY STORAGE VESSEL
            print('Tranferring honey')
            honey_collected = honey_collected + container.pushFluid(honey_storage)

            -- PUSH THE REST
            for slot, item in pairs(container.list()) do
                if not string.find(item.name, 'productivebees:') then
                    -- GRAB RAW ORES FOR PROCESSING
                    -- if string.find(item.name, ':raw_') or string.find(item.name, 'minecraft:ancient_debris') then
                    --     for f, blast_furnace in pairs(blast_furnaces_list) do
                    --         print('Firing:', item.name, blast_furnace)
                    --         local dest_blast_furnace = peripheral.wrap(blast_furnace)
                    --         TransferItemWithSlot(container, slot, dest_blast_furnace, 64, 1)
                    --     end
                    -- end
                    -- SMELT ROTTEN FLESH INTO LEATHER
                    if SMELT_FLESH and string.find(item.name, 'rotten_flesh') then
                        for f, furnace in pairs(furnaces_list) do
                            print('Firing:', item.name, furnace)
                            local dest_furnace = peripheral.wrap(furnace)
                            TransferItemWithSlot(container, slot, dest_furnace, 64, 1)
                        end
                    end
                    -- OTHERWISE, SEND TO WAREHOUSE
                    totalWarehousedThisRun = totalWarehousedThisRun + DepositInAnyWarehouse(container, slot)
                elseif string.find(item.name, 'productivebees:wax') then
                    -- FILL BLAST FURNACES WITH FUEL
                    for f, blast_furnace in pairs(blast_furnaces_list) do
                        local dest_blast_furnace = peripheral.wrap(blast_furnace)
                        print('Fueling:', blast_furnace)
                        TransferItemWithSlot(container, slot, dest_blast_furnace, 64, 2)
                    end
                    -- FILL FURNACES WITH FUEL
                    for f, furnace in pairs(furnaces_list) do
                        local dest_furnace = peripheral.wrap(furnace)
                        print('Fueling:', furnace)
                        TransferItemWithSlot(container, slot, dest_furnace, 64, 2)
                    end
                    -- FILL GENERATORS WITH FUEL
                    for f, genny in pairs(generators_list) do
                        local dest_genny = peripheral.wrap(genny)
                        print('Fueling:', genny)
                        TransferItemWithSlot(container, slot, dest_genny, 64, 1)
                    end
                    -- LAST RESORT, SEND TO WAREHOUSE
                    totalWarehousedThisRun = totalWarehousedThisRun + DepositInAnyWarehouse(container, slot)
                elseif string.find(item.name, 'productivebees:draconic_') then
                    -- SEND TO WAREHOUSE
                    totalWarehousedThisRun = totalWarehousedThisRun + DepositInAnyWarehouse(container, slot)
                elseif string.find(item.name, 'productivebees:wither_') then
                    -- SEND TO WAREHOUSE
                    totalWarehousedThisRun = totalWarehousedThisRun + DepositInAnyWarehouse(container, slot)
                elseif string.find(item.name, 'productivebees:sugarbag_honeycomb') then
                    totalWarehousedThisRun = totalWarehousedThisRun + DepositInAnyWarehouse(container, slot)
                end
            end
        end
    end

    processed = {
        timeStamp = os.epoch("utc"),
        Nolins = {
            name = "Nolins",
            hiveManagerTotalStored = 0,
            honeyCollected = 0
        },
    }
    processed.Nolins['hiveManagerTotalStored'] = totalWarehousedThisRun
    processed.Nolins['honeyCollected'] = honey_collected
    print('\n\nItems warehoused:', totalWarehousedThisRun)
    print('\n\nHoney Stored:', honey_collected)
end

function TransferItem(sourceStorage, sourceSlot, dest)
    sourceStorage.pushItems(peripheral.getName(dest), sourceSlot)
end

function TransferItemWithSlot(sourceStorage, sourceSlot, dest, limit, destSlot)
    sourceStorage.pushItems(peripheral.getName(dest), sourceSlot, limit, destSlot)
end

function DepositInAnyWarehouse(sourceStorage, sourceSlot)
    local movedItemCount = 0
    local peripherals = peripheral.getNames()
    local warehouses_list = {}
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, warehouses) then
            warehouses_list[#warehouses_list + 1] = attached_peripheral
        end
    end
    for whi, warehouse in pairs(warehouses_list) do
        movedItemCount = movedItemCount + sourceStorage.pushItems(warehouse, sourceSlot)
    end
    return movedItemCount
end

function GetFromAnyWarehouse(itemName, destination, itemCount, guess)
    -- COLLECT WAREHOUSE NAMES
    local peripherals = peripheral.getNames()
    local warehouses_list = {}
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, warehouses) then
            -- print(attached_peripheral)
            warehouses_list[#warehouses_list + 1] = attached_peripheral
        end
    end

    -- SEARCH EACH WAREHOUSE FOR ITEM
    local foundCount = 0
    for whi, warehouse in pairs(warehouses_list) do
        local whp = peripheral.wrap(warehouse)
        for slot, item in pairs(whp.list()) do
            -- must be exact name match
            if not guess then
                if item.name == itemName then
                    local pushedCount = whp.pushItems(destination, slot, itemCount - foundCount)
                    foundCount = foundCount + pushedCount
                    if foundCount >= itemCount then
                        print('Order successfully filled!')
                        -- EXIT WHEN WE HAVE DELIVERED ENOUGH
                        print('Returned', itemCount, itemName)
                        goto found
                    end
                end
            end
            -- TODO fuzzy match here
            -- end fuzzy
        end
        if itemCount < foundCount then print('Only located', foundCount, 'of', itemCount) end
        ::found::
    end
    return foundCount
end

function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end

LOOPS = 0
print('Starting HIVE MANAGER...')

while true do
    -- if redstone.getInput('top') then
    -- pcall(Main)
    Main()
    -- else
    --     print('Service Offline - Flip the lever on top!')
    -- end
    LOOPS = LOOPS + 1
    print('Sleeping', WAIT_SECONDS, 'seconds. Loop #', LOOPS, 'of', REBOOT_AFTER_LOOPS)

    -- write data
    WriteToFile(json.encode(processed), "monitorData.json", "w")

    -- clear data STORAGE
    processed = {}

    sleep(WAIT_SECONDS)
    if LOOPS >= REBOOT_AFTER_LOOPS then os.reboot() end
end
