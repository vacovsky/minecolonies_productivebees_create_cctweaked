local json = require "lib/json"
local vars = require "lib/constants"
local whi = require "lib/whi"

-- local combs_source = 'enderstorage:ender_chest_5'
local combs_dest = 'enderstorage:ender_chest_3'


function ListHives()
    local list = {}
    local peripherals = peripheral.getNames()
    for _, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, vars.hives) then
            list[#list + 1] = attached_peripheral
        end
    end
    return list
end

while true do
    local combsMoved = 0
    for _, hive in pairs(ListHives()) do
        local phive = peripheral.wrap(hive)
        local pcombdest = peripheral.wrap(combs_dest)
        for slot, item in pairs(phive.list()) do
            if not string.find(item.name, 'minecraft:') and
                string.find(item.name, 'comb') and not string.find(item.name, 'sugarbag') then
                pcombdest.pullItems(hive, slot)
            else
                whi.DepositInAnyWarehouse(hive, slot)
            end
        end
    end

    if combsMoved > 0 then print('Tranferred', combsMoved, 'combs') end
    sleep(5)
end
