local json = require "lib/json"
local vars = require "lib/constants"
local net = require "lib/network"

local xpjuice_destination = 'create_enchantment_industry:blaze_enchanter_'
local xpjuice_source = 'fluidTank_17'

while true do
    local xpjuice_pushed = 0
    local xp_source = peripheral.wrap(xpjuice_source)
    for _, enchanter in pairs(net.ListMatchingDevices(xpjuice_destination)) do
        xpjuice_pushed = xpjuice_pushed + xp_source.pushFluid(enchanter)
    end
    if xpjuice_pushed > 0 then print('Tranferred', xpjuice_pushed, 'XP to enchanters') end
    sleep(5)
    xpjuice_pushed = 0
end
