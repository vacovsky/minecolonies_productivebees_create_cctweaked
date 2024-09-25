local json = require "lib/json"
local vars = require "lib/constants"

local honey_destination = 'enderstorage:ender_tank_2'

function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end

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
    local honeyPushed = 0
    for _, fuge in pairs(ListCentrifuges()) do
        local pfuge = peripheral.wrap(fuge)
        honeyPushed = honeyPushed + pfuge.pushFluid(honey_destination)
    end
    if honeyPushed > 0 then print('Tranferred', honeyPushed, 'honey to ender tank') end
    sleep(5)
    honeyPushed = 0
end
