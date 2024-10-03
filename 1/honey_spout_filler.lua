
local honey_storage = 'fluidTank_13'
local honey_dispenser = 'create:spout_0'

while true do
    local container = peripheral.wrap(honey_storage)
    -- FILL DISPENSER
    local moved     = container.pushFluid(honey_dispenser)
    print('Tranferred', moved, 'honey to spout')
    sleep(5)
end
