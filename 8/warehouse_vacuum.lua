local whi = require 'lib/warehouse_interface'
local json = require "lib/json"

local COLONY_NAME = 'Nolins'


local source_inventories = {
    'create_mechanical_extruder:mechanical_extruder_1',
    -- 'ironchests:gold_barrel_0',
    'minecraft:chest_1',
    'enderstorage:ender_chest_1'
}

function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end

function Vacuum()
    local deposited = 0
    for _, inventory in pairs(source_inventories) do
        for _, p in pairs(peripheral.getNames()) do
            if string.find(p, inventory) then
                local inv = peripheral.wrap(inventory)
                for slot, item in pairs(inv.list()) do
                    print('Moving', item.name, 'to warehouse')
                    deposited = deposited + whi.DepositInAnyWarehouse(inventory, slot)
                end
            end
        end
    end

    local data = {
        timeStamp = os.epoch("utc"),
        turtlePower = {
            name = COLONY_NAME,
            vacuumedItems = deposited
        }
    }
    WriteToFile(json.encode(data), "warehouseVacuum.json", "w")
end

print('Starting warehouse vacuum...')
while true do
    Vacuum()
    sleep(15)
end
