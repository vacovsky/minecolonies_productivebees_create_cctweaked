shell.openTab("warehouse_returns")
shell.openTab("warehouse_pruner")
-- shell.openTab("incinerator")

local WAREHOUSE = 'minecolonies:warehouse'
local MAX_ITEM_COUNT = 64
local DESTINATION_STORAGE = 'ironchests:obsidian_chest_0'
local ITEM_NAME_MIN = 4

function DeliverItem(itemName, itemCount)
    if itemName == nil then return true end
    -- ENFORCE MINIMUM ITEM NAME
    if string.len(itemName) < 4 then print('Supplied item name must be at least', ITEM_NAME_MIN, 'letters.') return true end

    if itemCount == nil then itemCount = 64 end
    -- ENFORCE ITEM LIMITS
    if itemCount > MAX_ITEM_COUNT then print('Max item count allowed is', MAX_ITEM_COUNT)
        itemCount = MAX_ITEM_COUNT
    end
    foundCount = 0

    -- FIND WAREHOUSES
    warehouses = {}
    peripherals = peripheral.getNames()
    for pni, perName in pairs(peripherals) do
        if string.find(perName, WAREHOUSE) then
            print('Checking location:', perName)
            warehouses[#warehouses+1] = perName
        end
    end

    -- MOVE THE ITEMS
    deliveredItemName = ''
    for whi, warehouseName in pairs(warehouses) do
        warehouse = peripheral.wrap(warehouseName)
        foundCount = 0
        for slot, item in pairs(warehouse.list()) do
            if string.find(item.name, itemName) then
                deliveredItemName = item.name
                foundCount = foundCount + warehouse.pushItems(DESTINATION_STORAGE, slot, itemCount)
                -- EXIT WHEN WE HAVE DELIVERED ENOUGH
                if foundCount >= itemCount then print('Order successfully filled!') break end
                goto found
            end
        end
        ::found::
    end
    print('delivered', foundCount, deliveredItemName)

    return true
end

print('Type an item name and count - if we have any, items will be delivered instantly to the attached chest.\n\nUse format: <itemname> <count>\nexample:  iron_ingot 32')
while true do
    write("\n\nWARES_UI> ")
    local msg = read()
    if msg == nil then goto continue end

    words = {}
    for word in msg:gmatch("%S+") do
        pcall(table.insert, words, word)
    end
    pcall(DeliverItem(words[1], tonumber(words[2])))
    ::continue::
end