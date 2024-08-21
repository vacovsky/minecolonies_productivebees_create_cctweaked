local warehouses = "minecolonies:warehouse"

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
        movedItemCount = movedItemCount + peripheral.wrap(warehouse).pullItems(sourceStorage, sourceSlot)
    end
    return movedItemCount
end

function GetFromAnyWarehouse(itemName, destination, itemCount, guess)
    -- COLLECT WAREHOUSE NAMES
    local peripherals = peripheral.getNames()
    local warehouses_list = {}
    for index, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, warehouses) then
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