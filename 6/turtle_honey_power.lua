local honey_storage = 'fluidTank_5'
local honey_generator = 'productivebees:honey_generator_1'
local WAIT_SECONDS = 60
local json = require "json"
local COLONY_NAME = 'Nolins'


function Main()
    local honey_source = peripheral.wrap(honey_storage)
    local honeyUsed = 0
     honeyUsed = honeyUsed + honey_source.pushFluid(honey_generator)

    local data = {
        timeStamp = os.epoch("utc"),
        turtlePower = {
            name = COLONY_NAME,
            honeyUsed = honeyUsed
        }
    }
    WriteToFile(json.encode(data), "honeyPowerData.json", "w")

    print(honeyUsed)
end


function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end


print('Starting Turtle Power (HIAHS)')
while true do
    if redstone.getInput('top') then
        -- pcall(Main)
        Main()
    else
        print('Service Offline - Flip the lever on top!')
    end
    sleep(WAIT_SECONDS)
end