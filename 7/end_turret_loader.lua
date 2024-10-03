
local net = require 'lib/network'
local bullet_source = 'enderstorage:ender_chest_9'

function LoadTurrets()
    local turrets = net.ListMatchingDevices('scguns:basic_turret')
    local bullets = 0
    for _, t in pairs(turrets) do
        for slot, item in pairs(peripheral.wrap(bullet_source).list()) do
            -- print(item.name, t)
            if item.name == 'scguns:standard_copper_round' then
                bullets = bullets + peripheral.wrap(t).pullItems(bullet_source, slot)
            end
        end
    end
    if bullets > 0 then print(bullets, 'rounds used') end
end

while true do
    LoadTurrets()
    sleep(15)
end
