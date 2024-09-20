local whi = require 'lib/whi'


local minraw_before_smelt = 256
local max_result_allowed = 512

local furnaces = 'furnace'
-- local furnaces = 'minecraft:furnace'
local waxfuel = 'productivebees:wax'
local coalfuel = 'minecraft:coal'
local raw_items = {
    -- 'minecraft:cobblestone',
    -- 'minecraft:clay_ball',
    'minecraft:echo_shard',
    'create:crushed_raw_gold',
    'create:crushed_raw_copper',
    'create:crushed_raw_iron',
    'create:crushed_raw_anthralite',
    'scguns:diamond_steel_blend',
    -- 'minecraft:rotten_flesh',
    -- 'minecraft:raw_gold',
    -- 'minecraft:raw_copper',
    -- 'minecraft:raw_iron',
    -- 'scguns:raw_anthralite',
}

function GetFurnaces()
    local furnaces_list = {}
    local attached_peripherals = peripheral.getNames()
    for _, ap in pairs(attached_peripherals) do
        if string.find(ap, furnaces) then
            furnaces_list[#furnaces_list + 1] = ap
        end
    end
    return furnaces_list
end

function AttendFurnaces()
    local icm = whi.ItemCountMap()
    for _, raw_item in pairs(raw_items) do
        local moved = 0
        if icm[raw_item].count >= minraw_before_smelt then
            for _, furnace in pairs(GetFurnaces()) do
                -- Refuel furnaces
                print(whi.GetFromAnyWarehouse(false, coalfuel, furnace, 64, 2), 'fueled (coal)')
                print(whi.GetFromAnyWarehouse(false, waxfuel, furnace, 64, 2), 'fueled (wax)')
                -- move smelted items to warehouse
                print(whi.DepositInAnyWarehouse(furnace, 3), 'deposited')
                -- move item for smelting to furnace
                moved = moved + whi.GetFromAnyWarehouse(false, raw_item, furnace, 64, 1)
                if moved >= 32 then
                    goto next_item
                end
            end
        end
        ::next_item::
    end
end
while true do
    -- if not pcall(AttendFurnaces) then print('AttendFurnaces() failed to complete') end
    AttendFurnaces()
    sleep(5)
end
