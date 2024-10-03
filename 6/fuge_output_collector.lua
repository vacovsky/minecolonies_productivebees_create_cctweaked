local json = require "lib/json"
local vars = require "lib/constants"

-- local combs_source = 'enderstorage:ender_chest_5'
local combs_dest = 'enderstorage:ender_chest_4'


function ListCentrifuges()
    local fuge_list = {}
    local peripherals = peripheral.getNames()
    for _, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, vars.fuges) then
            fuge_list[#fuge_list + 1] = attached_peripheral
        end
    end
    return fuge_list
end

while true do
    local combsMoved = 0
    for _, fuge in pairs(ListCentrifuges()) do
        local pfuge = peripheral.wrap(fuge)
        local pcombdest = peripheral.wrap(combs_dest)
        for slot, item in pairs(pfuge.list()) do
            if not string.find(item.name, 'comb') then
                pcombdest.pullItems(fuge, slot)
            end
        end
    end

    print('Tranferred', combsMoved, 'combs')
    sleep(5)
end
