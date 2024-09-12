local json = require "lib/json"
local whi = require 'lib/warehouse_interface'

local COLONY_NAME = 'Nolins'

-- 1, 2, 3 are input slots
-- 4 is mold
-- 5 is fuel slot
-- 6 is output
local casing = 'scguns:medium_copper_casing'
local powder = 'scguns:gunpowder_dust'
local slug = 'minecraft:iron_nugget'
local fuel = 'minecraft:coal'

local gunpress = 'scguns:mechanical_press'
local turret = 'scguns:basic_turret'
local shellcatcher = 'scguns:shell_catcher_module'

function Main()
    local bullets_made = 0
    local turrets = {}
    local gunpresses = {}
    local shellcatchers = {}

    local peripherals = peripheral.getNames()
    for _, perName in pairs(peripherals) do
        if string.find(perName, gunpress) then
            gunpresses[#gunpresses + 1] = perName
        end
        if string.find(perName, turret) then
            turrets[#turrets + 1] = perName
        end
        if string.find(perName, shellcatcher) then
            shellcatchers[#shellcatchers + 1] = perName
        end
    end

    -- MOVE EMPTY CASINGS TO WAREHOUSE
    for _, t in pairs(shellcatchers) do
        local sc = peripheral.wrap(t)
        for slot, item in pairs(sc.list()) do
            if string.find(item.name, casing) then
                whi.DepositInAnyWarehouse(t, slot)
            end
        end
    end

    for _, p in pairs(gunpresses) do
        -- FILL PRESSES WITH FUEL
        whi.GetFromAnyWarehouse(false, fuel, p, 64, 5)
        -- FILL PRESSES WITH INGREDIENTS FOR scguns:standard_copper_round
        whi.GetFromAnyWarehouse(false, casing, p, 64, 1)
        whi.GetFromAnyWarehouse(false, powder, p, 64, 2)
        whi.GetFromAnyWarehouse(false, slug, p, 64, 3)

        -- SEND FINISHED ROUNDS TO TURRET?
        for _, t in pairs(turrets) do
            bullets_made = bullets_made + peripheral.wrap(t).pullItems(p, 6)
        end
        --  WAREHOUSE
        -- whi.DepositInAnyWarehouse(p, 6)
    end
    local data = {
        timeStamp = os.epoch("utc"),
        bullets = {
            name = COLONY_NAME,
            bulletsMadeCount = bullets_made
        }
    }
    print('Made', bullets_made, 'Standard Copper Round')
    WriteToFile(json.encode(data), "bulletUse.json", "w")
end

function WriteToFile(input, fileName, mode)
    local file = io.open(fileName, mode)
    io.output(file)
    io.write(input)
    io.close(file)
end

while true do
    Main()
    sleep(10)
end
