local whi = require 'warehouse_interface'

local furnace = 'minecraft:furnace_13'
local fuel = 'minecraft:coal'
local raw_item = 'minecraft:rotten_flesh'

while true do
    print(whi.GetFromAnyWarehouse(false, raw_item, furnace, 64, 1))
    print(whi.GetFromAnyWarehouse(false, fuel, furnace, 64, 2))
    print(whi.DepositInAnyWarehouse(furnace, 3))
    sleep(120)
end