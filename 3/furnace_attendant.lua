local whi = require 'warehouse_interface'

local furnace = 'minecraft:furnace_5'
local fuel = 'minecraft:coal'
local raw_item = 'minecraft:sand'

while true do
    print(whi.GetFromAnyWarehouse(false, fuel,furnace, 16, 1))
    print(whi.GetFromAnyWarehouse(false, raw_item, furnace, 16, 2))
    print(whi.DepositInAnyWarehouse(furnace, 3))
    sleep(300)
end