local tsdb = require "lib/tsdb"
local whi = require "lib/whi"

local CRUSHER_INPUT = 'ironchests:iron_barrel_2'
local CRUSHER_OUTPUT = 'ironchests:gold_barrel_1'
local ORE_PREFIX = ':raw_'
local CRUSHED_ORE_PREFIX = ':crushed_'

local furnaces = 'furnace'
-- local rawsrc = 'enderstorage:ender_chest_1'

function Main()
    -- grab all raw ores from warehouse and place into chest_1
    local crushingCnt = whi.GetFromAnyWarehouse(true, ORE_PREFIX, CRUSHER_INPUT)
    if crushingCnt > 0 then print(crushingCnt, 'crushing') end

    -- collect crushed ores and place into warehouse
    local crushed_raw_source = peripheral.wrap(CRUSHER_OUTPUT)
    for slot, item in pairs(crushed_raw_source.list()) do
        if string.find(item.name, CRUSHED_ORE_PREFIX) then
            local crushedCnt = whi.DepositInAnyWarehouse(CRUSHER_OUTPUT, slot)
            if crushedCnt > 0 then print(crushedCnt, 'crushed') end
        end
    end
end

while true do
    if not pcall(Main) then print('Main() failed to complete') end

    -- Main()
    sleep(5)
end
