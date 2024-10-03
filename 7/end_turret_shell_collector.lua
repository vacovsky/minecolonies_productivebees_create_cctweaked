local net = require 'lib/network'

local shell_source = 'catcher'
local shell_dest = 'enderstorage:ender_chest_2'

function LoadTurrets()
    local catchers = net.ListMatchingDevices(shell_source)
    local shells = 0
    for _, t in pairs(catchers) do
        for slot, item in pairs(peripheral.wrap(t).list()) do
            shells = shells + peripheral.wrap(t).pushItems(shell_dest, slot)
        end
    end
    if shells > 0 then
        print(shells, 'shells reclaimed')
    end
end

while true do
    LoadTurrets()
    sleep(15)
end
