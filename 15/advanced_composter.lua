local whi = require "lib/whi"
local net = require "lib/network"

local avanced_composter_input = 'minecraft:hopper_8'
local avanced_composter_output = 'biomancy:maw_hopper_0'


local input_item = 'minecraft:apple'

function LoadComposter()
    -- add compostable items
    local input_count = 0
    input_count = input_count + whi.GetFromAnyWarehouse(true, input_item, avanced_composter_input, 64)
    if input_count > 0 then print(input_count, 'inputs') end

    -- collect outputs
    local output_count = 0
    for slot, _ in pairs(peripheral.wrap(avanced_composter_output).list()) do
        output_count = output_count + whi.DepositInAnyWarehouse(avanced_composter_output, slot)
    end
    if output_count > 0 then print(output_count, 'outputs') end
end

while true do
    LoadComposter()
    sleep(15)
end
