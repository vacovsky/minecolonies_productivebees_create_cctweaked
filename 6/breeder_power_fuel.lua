local json = require "lib/json"
local vars = require "lib/constants"
local net = require "lib/network"
local whi = require "lib/whi"

local pg_name = 'scguns:polar_generator'
local fuel_name = 'minecraft:coal'

while true do
    local moved = 0
    local pgs = net.ListMatchingDevices(pg_name)
    for _, pg in pairs(pgs) do
        moved = moved + whi.GetFromAnyWarehouse(false, fuel_name, pg)
    end
    if moved > 0 then print('xfer', moved, 'fuel') end
    sleep(10)
end
