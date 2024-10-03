local json = require "lib/json"
local vars = require "lib/constants"
local net = require "lib/network"

local lava_destination = 'create:spout_2'
local lava_source = 'fluidTank_18'

while true do
    local lava_pushed = 0
    local lava = peripheral.wrap(lava_source)
    lava_pushed = lava_pushed + lava.pushFluid(lava_destination)
    if lava_pushed > 0 then
        print('Tranferred', lava_pushed, 'lava to spouts')
    end
    sleep(5)
    lava_pushed = 0
end
