local whi = require 'lib/whi'


local orderDest = "enderstorage:ender_chest_0"
local WAREHOUSE = 'minecolonies:warehouse'
local protocol = "ender_orders"
local MAX_ITEM_COUNT = 64
local ITEM_NAME_MIN = 3
print("Starting Ender Order API:", protocol)

rednet.open('top')

function DeliverItem(itemName, itemCount)
    if itemName == nil then return true end
    -- ENFORCE MINIMUM ITEM NAME
    if string.len(itemName) < 3 then print('Supplied item name must be at least', ITEM_NAME_MIN, 'letters.') return true end

    if itemCount == nil or itemCount == 'nil' then itemCount = 64 end
    -- ENFORCE ITEM LIMITS
    if itemCount > MAX_ITEM_COUNT then print('Max item count allowed is', MAX_ITEM_COUNT)
        itemCount = MAX_ITEM_COUNT
    end
    local foundCount = 0

    -- FIND WAREHOUSES
    local warehouses = {}
    local peripherals = peripheral.getNames()
    for _, perName in pairs(peripherals) do
        if string.find(perName, WAREHOUSE) then
            print('Checking location:', perName)
            warehouses[#warehouses+1] = perName
        end
    end

    -- MOVE THE ITEMS
    for _, warehouseName in pairs(warehouses) do
        local warehouse = peripheral.wrap(warehouseName)
        local foundCount = 0
        for slot, item in pairs(warehouse.list()) do
            if string.find(item.name, itemName) then
                local deliveredItemName = item.name
                foundCount = foundCount + warehouse.pushItems(orderDest, slot, itemCount)
                -- EXIT WHEN WE HAVE DELIVERED ENOUGH
                if foundCount >= itemCount then print('Order successfully filled!')
                    goto found
                end
            end
        end
        ::found::
    end
    print('delivered', foundCount, deliveredItemName)

    return true
end


function FulfillOrder(order, count)
    print('Attempting to get your', order, count)
    DeliverItem(order, count)
end


while true do
    local sender, message = rednet.receive();
    print(sender, ":", message)
    local words = {}
    for word in message:gmatch("%S+") do
        local s = pcall(table.insert, words, word)
        if not s then print('failure') else print('success') end
    end
    -- print(words[1], words[2])
    -- pcall(FulfillOrder, message)
    FulfillOrder(words[1], words[2])
end