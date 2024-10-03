local json = require "json"

local honey_storage = 'fluidTank_16'
local honey_dispenser = 'create:spout_0'
local COLONY_NAME = "Nolins"

function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end

while true do

    local honeyFed = 0
    local container = peripheral.wrap(honey_storage)
    -- FILL DISPENSER
    honeyFed = honeyFed + container.pushFluid(honey_dispenser)
    print('Tranferred', honeyFed, 'honey to spout')

    local data = {
        timeStamp = os.epoch("utc"),
        honeyFed = {
            name = COLONY_NAME,
            honeyFed = honeyFed
        }
    }
    WriteToFile(json.encode(data), "foodHoney.json", "w")

    sleep(5)
    honeyFed = 0
end
