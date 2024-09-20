local tsdb = require "lib/tsdb"
local whi = require "lib/whi"

local CRUSHER_INPUT = 'ironchests:iron_barrel_2'
local CRUSHER_OUTPUT = 'ironchests:gold_barrel_1'
local ORE_PREFIX = ':raw_'
local CRUSHED_ORE_PREFIX = ':crushed_'

local furnaces = 'furnace'
-- local rawsrc = 'enderstorage:ender_chest_1'

function Main()
    local furnaces_list = {}
    local peripherals = peripheral.getNames()
    for _, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, furnaces) then
            furnaces_list[#furnaces_list + 1] = attached_peripheral
        end
    end

    -- grab all raw ores from warehouse and place into chest_1
    local crushingCnt = whi.GetFromAnyWarehouse(true, ORE_PREFIX, CRUSHER_INPUT)
    if crushingCnt > 0 then print(crushingCnt, 'crushing') end

    -- collect crushed ores and place into furnaces
    local crushed_raw_source = peripheral.wrap(CRUSHER_OUTPUT)
    for slot, item in pairs(crushed_raw_source.list()) do
        for _, furnaces in pairs(furnaces_list) do
            if string.find(item.name, CRUSHED_ORE_PREFIX) then
                local crushedCnt = crushed_raw_source.pushItems(furnaces, slot)
                if crushedCnt > 0 then print(crushedCnt, 'crushed') end
            end
        end
    end
end

while true do
    if not pcall(Main) then print('Main() failed to complete') end

    -- Main()
    sleep(5)
end
