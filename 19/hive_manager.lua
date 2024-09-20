local json = require "lib/json"
local tsdb = require "lib/tsdb"
local vars = require "lib/constants"
local whi = require "lib/whi"

function Main()
    local honey_collected = 0
    local peripherals = peripheral.getNames()
    local honey_storage = 'fluidTank_16'
    local generators_list = {}
    local blast_furnaces_list = {}
    local fuge_list = {}
    local furnaces_list = {}
    local heated_fuge_list = {}


    local totalWarehousedThisRun = 0
    -- CREATE LISTS OF PERIPHERAL PROCESSORS
    for _, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, vars.fuges) then
            fuge_list[#fuge_list + 1] = attached_peripheral
        end

        if string.find(attached_peripheral, vars.furnaces) then
            furnaces_list[#furnaces_list + 1] = attached_peripheral
        end

        if string.find(attached_peripheral, vars.generators) then
            generators_list[#generators_list + 1] = attached_peripheral
        end

        if string.find(attached_peripheral, vars.blast_furnaces) then
            blast_furnaces_list[#blast_furnaces_list + 1] = attached_peripheral
        end
        if string.find(attached_peripheral, vars.heated_fuges) then
            heated_fuge_list[#heated_fuge_list + 1] = attached_peripheral
        end
    end


    for _, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, vars.hives) then
            -- RESTOCK BOTTLES
            local bottles_replenished = whi.GetFromAnyWarehouse('minecraft:glass_bottle', attached_peripheral, 4, false)
            print('Stocked', bottles_replenished, 'bottles to', attached_peripheral)

            -- TRANSFER COMBS TO FUGES
            local hive = peripheral.wrap(attached_peripheral)

            for slot, item in pairs(hive.list()) do
                if string.find(item.name, 'productivebees:') then
                    for f, fuge in pairs(fuge_list) do
                        pcall(hive.pushItems(fuge, slot))
                        -- TransferItem(hive, slot, fuge)
                    end
                end
                if string.find(item.name, 'productivebees:') then
                    for f, fuge in pairs(fuge_list) do
                        pcall(hive.pushItems(fuge, slot))
                        -- TransferItem(hive, slot, fuge)
                    end
                end
                
                -- TRANSFER WOOD/STONE/HONEY BOTTLES TO WAREHOUSE
                for slot, item in pairs(hive.list()) do
                    if not string.find(item.name, 'productivebees:') and not string.find(item.name, 'minecrfaft:glass_bottle') then
                        totalWarehousedThisRun = totalWarehousedThisRun + whi.DepositInAnyWarehouse(attached_peripheral, slot)
                        print('Warehoused:', item.name)
                    end
                end
            end
            -- END HIVES
        end

        -- REMOVE SMELTED ITEMS FROM BLAST FURNACES
        if string.find(attached_peripheral, vars.blast_furnaces) then
            local container = peripheral.wrap(attached_peripheral)
            totalWarehousedThisRun = totalWarehousedThisRun + whi.DepositInAnyWarehouse(container, 3)
        end

        -- REMOVE SMELTED ITEMS FROM FURNACES
        if string.find(attached_peripheral, vars.furnaces) then
            local container = peripheral.wrap(attached_peripheral)
            totalWarehousedThisRun = totalWarehousedThisRun + whi.DepositInAnyWarehouse(container, 3)
        end


        -- TRANSFER FUGE-PROCESSED MATERIALS TO WAREHOUSE
        if string.find(attached_peripheral, vars.fuges) then
            local container = peripheral.wrap(attached_peripheral)
            -- PUSH HONEY TO HONEY STORAGE VESSEL
            honey_collected = honey_collected + container.pushFluid(honey_storage)
            print('honey ->', honey_collected)

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
                    if vars.SMELT_FLESH and string.find(item.name, 'rotten_flesh') then
                        for f, furnace in pairs(furnaces_list) do
                            print('Firing:', item.name, furnace)
                            local dest_furnace = peripheral.wrap(furnace)
                            TransferItemWithSlot(container, slot, dest_furnace, 64, 1)
                        end
                    end
                    -- OTHERWISE, SEND TO WAREHOUSE
                    totalWarehousedThisRun = totalWarehousedThisRun +
                    whi.DepositInAnyWarehouse(attached_peripheral, slot)
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
                    totalWarehousedThisRun = totalWarehousedThisRun +
                    whi.DepositInAnyWarehouse(attached_peripheral, slot)
                elseif string.find(item.name, 'productivebees:draconic_') then
                    -- SEND TO WAREHOUSE
                    totalWarehousedThisRun = totalWarehousedThisRun +
                    whi.DepositInAnyWarehouse(attached_peripheral, slot)
                elseif string.find(item.name, 'productivebees:wither_') then
                    -- SEND TO WAREHOUSE
                    totalWarehousedThisRun = totalWarehousedThisRun +
                    whi.DepositInAnyWarehouse(attached_peripheral, slot)
                elseif string.find(item.name, 'productivebees:sugarbag_honeycomb') then
                    totalWarehousedThisRun = totalWarehousedThisRun +
                    whi.DepositInAnyWarehouse(attached_peripheral, slot)
                end
            end
        end
    end

    local data = {
        hiveManagerTotalStored = totalWarehousedThisRun,
        honeyCollected = honey_collected,
    }

    tsdb.WriteOutput(vars.COLONY_NAME, data, vars.OUTPUT_FILE)
end

function TransferItem(sourceStorage, sourceSlot, dest)
    sourceStorage.pushItems(dest, sourceSlot)
end

function TransferItemWithSlot(sourceStorage, sourceSlot, dest, limit, destSlot)
    sourceStorage.pushItems(peripheral.getName(dest), sourceSlot, limit, destSlot)
end

LOOPS = 0
print('Starting HIVE MANAGER 2...')

while true do
    -- if redstone.getInput('top') then
    pcall(Main)
    -- Main()


    LOOPS = LOOPS + 1
    print('Sleeping', vars.WAIT_SECONDS, 'Loop #', LOOPS, 'of', vars.REBOOT_AFTER_LOOPS)
    sleep(vars.WAIT_SECONDS)
    if LOOPS >= vars.REBOOT_AFTER_LOOPS then os.reboot() end
end
