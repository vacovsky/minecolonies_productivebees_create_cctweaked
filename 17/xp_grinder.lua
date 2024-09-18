local CRUSHER_INPUT = 'ironchests:iron_barrel_2'
local CRUSHER_OUTPUT = 'ironchests:gold_barrel_1'
local ORE_PREFIX = ':raw_'
local CRUSHED_ORE_PREFIX = ':crushed_'

local fuges = 'productivebees:centrifuge'
local furnaces = 'furnace'


function Main()
    local fuge_list = {}
    local furnaces_list = {}
    local peripherals = peripheral.getNames()
    for _, attached_peripheral in pairs(peripherals) do
        if string.find(attached_peripheral, fuges) then
            fuge_list[#fuge_list + 1] = attached_peripheral
        end
        if string.find(attached_peripheral, furnaces) then
            furnaces_list[#furnaces_list + 1] = attached_peripheral
        end
    end

    -- grab all raw ores from centrifuges and place into chest_1
    for _, fuge in pairs(fuge_list) do
        local raw_source = peripheral.wrap(fuge)
        for slot, item in pairs(raw_source.list()) do
            if string.find(item.name, ORE_PREFIX) then
                raw_source.pushItems(CRUSHER_INPUT, slot)
            end
        end
    end

    -- collect crushed ores and place into furnaces
    local crushed_raw_source = peripheral.wrap(CRUSHER_OUTPUT)
    for slot, item in pairs(crushed_raw_source.list()) do
        for _, furance in pairs(furnaces_list) do
            if string.find(item.name, CRUSHED_ORE_PREFIX) then
                crushed_raw_source.pushItems(furance, slot)
            end
        end
    end
end

while true do
    Main()
    sleep(15)
end
