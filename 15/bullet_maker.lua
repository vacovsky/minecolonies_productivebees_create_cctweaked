local json = require "lib/json"
local whi = require 'lib/warehouse_interface'

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

function Main()
    local turrets = {}
    local gunpresses = {}

    local peripherals = peripheral.getNames()
    for _, perName in pairs(peripherals) do
        if string.find(perName, gunpress) then
            gunpresses[#gunpresses + 1] = perName
        end
        if string.find(perName, turret) then
            turrets[#turrets + 1] = perName
        end
    end

    -- MOVE EMPTY CASINGS IN TURRETS TO WAREHOUSE
    for _, t in pairs(turrets) do
        local tur = peripheral.wrap(t)
        for slot, item in pairs(tur.list()) do
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

        -- SEND FINISHED ROUNDS TO WAREHOUSE, or TURRET?
        for _, t in pairs(turrets) do
            peripheral.wrap(t).pullItems(p, 6)
        end
        -- whi.DepositInAnyWarehouse(p, 7)
    end
end


while true do
    Main()
    sleep(10)
end