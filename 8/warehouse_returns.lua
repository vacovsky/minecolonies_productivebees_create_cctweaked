local DROPBOX = 'minecraft:barrel_9'
local WAREHOUSE = 'minecolonies:warehouse'

function ReturnWares()
    dropbox = peripheral.wrap(DROPBOX)
    warehouses = {}
    peripherals = peripheral.getNames()
    for pni, perName in pairs(peripherals) do
        if string.find(perName, WAREHOUSE) then
            warehouses[#warehouses+1] = perName
        end
    end

    for slot, item in pairs(dropbox.list()) do
        count = 0
        for whi, warehouse in pairs(warehouses) do
            count = dropbox.pushItems(warehouse, slot)
        end
        print('Returned', item.name, count)
    end

    return true
end

print('Starting automated warehouse return system...')
while true do
    pcall(ReturnWares)
    sleep(15)
end