local WAIT_SECONDS = 30
local REBOOT_AFTER_LOOPS = 60 -- REBOOT AFTER THIS MANY LOOPS
local MAXHONEYBOTTLES = 128

local warehouses = "minecolonies:warehouse"
local honey_storage = 'fluidTank_5'
local honey_bottler = 'create:depot_5'
local honey_dispenser = 'create:spout_0'

function Main()
    

    local peripherals = peripheral.getNames()
    print('\n')
    -- HONEY BOTTLER
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, honey_bottler) then
            container = peripheral.wrap(attached_peripheral)
            -- PLACE FILLED BOTTLES IN WAREHOUSE
            for slot, item in pairs(container.list()) do
                if item.name == 'minecraft:honey_bottle' then
                    local depositNum = DepositInAnyWarehouse(container, slot)
                    if depositNum > 0 then print('Warehoused', depositNum, 'honey bottles') end
                end
            end
            -- REFILL WITH EMPTY BOTTLES
            local restockNum = GetFromAnyWarehouse('minecraft:glass_bottle', peripheral.getName(container), 64, false)
            if restockNum > 0 then print('Restocked', restockNum, 'glass bottles') end
        end
    end
    print('\n')
end

function DepositInAnyWarehouse(sourceStorage, sourceSlot)
    local movedItemCount = 0
    local peripherals = peripheral.getNames()
    local warehouses_list = {}
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, warehouses) then
            warehouses_list[#warehouses_list+1] = attached_peripheral
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
            warehouses_list[#warehouses_list+1] = attached_peripheral
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
                    if foundCount >= itemCount then print('Order successfully filled!')
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


local LOOPS = 0
print('Starting HONEY BOTTLER')
while true do
    -- if redstone.getInput('top') then
        -- pcall(Main)
        Main()
    -- else
        -- print('Service Offline - Flip the lever on top!')
    -- end
    LOOPS = LOOPS + 1
    print('Sleeping', WAIT_SECONDS, 'seconds. Loop #', LOOPS, 'of', REBOOT_AFTER_LOOPS )
    sleep(WAIT_SECONDS)
    if LOOPS >= REBOOT_AFTER_LOOPS then os.reboot() end
end