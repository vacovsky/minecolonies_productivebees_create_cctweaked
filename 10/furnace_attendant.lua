local whi = require 'warehouse_interface'


local minraw_before_smelt = 256
local max_result_allowed = 512

local furnaces = 'minecraft:furnace'
local fuel = 'minecraft:coal'
local raw_items = {
    -- 'minecraft:cobblestone',
    -- 'minecraft:clay_ball',
    -- 'minecraft:sand',
    'minecraft:rotten_flesh',
    -- 'scguns:raw_anthralite',
    -- 'scguns:diamond_steel_blend',
}



while true do
    local furnaces_list = {}
    local attached_peripherals = peripheral.getNames()
    for _, ap in pairs(attached_peripherals) do
        if string.find(ap, furnaces) then
            furnaces_list[#furnaces_list + 1] = ap
        end
    end
    local icm = whi.ItemCountMap()
    for _, raw_item in pairs(raw_items) do
        local moved = 0
        
        if icm[raw_item].count >= minraw_before_smelt then
            for _, furnace in pairs(furnaces_list) do

                -- move item for smelting to furnace
                moved = moved +  whi.GetFromAnyWarehouse(false, raw_item, furnace, 64, 1)
                if moved >= 32 then
                    goto next_item
                end
                -- Refuel furnaces
                print(whi.GetFromAnyWarehouse(false, fuel, furnace, 64, 2))
                -- move smelted items to warehouse
                print(whi.DepositInAnyWarehouse(furnace, 3))
            end
        end
        ::next_item::
    end
    sleep(120)
end
