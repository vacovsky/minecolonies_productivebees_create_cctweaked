local whi = require "lib/whi"
local net = require "lib/network"

local avanced_composter_input = 'minecraft:hopper_8'
local avanced_composter_output = 'minecraft:hopper_7'


local input_item = 'minecraft:wheat'

function LoadComposter()
    local input_count = 0
    local output_count = 0
    input_count = input_count + whi.GetFromAnyWarehouse(true, input_item, avanced_composter_input, 64)
    if input_count > 0 then print(count, 'inputs') end
    output_count = output_count + whi.DepositInAnyWarehouse(avanced_composter_output)
    if output_count > 0 then print(count, 'outputs') end
end

while true do
    LoadComposter()
    sleep(20)
end
