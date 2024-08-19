local DROPBOX = 'minecraft:barrel_0'

function ReturnWares()
    dropbox = peripheral.wrap(DROPBOX)
    warehouses = {}
    peripherals = peripheral.getNames()
    for pni, perName in pairs(peripherals) do
        if string.find(perName, WAREHOUSE) then
            print('Checking location:', perName)
            warehouses[#warehouses+1] = perName
        end
    end

    for slot, item in pairs(dropbox) do
        for whi, warehouse in warehouses(pairs) do 
            dropbox.pushItems(peripheral.getName(warehouse), slot)
        end
        print('Returned', item.name)
    end

    return true
end

while true do
    pcall(ReturnWares)
    sleep(15)
end