local wh = require("warehouse_interface")
local recipes = require("crafting_recipes")
local me = 'turtle_0'
local minBottles = 256

function CraftItemFromRecipe(recipe, count)
    -- CLEAR INVENTORY
    EmptyTurtleToWarehouse()

    -- GRAB COMPONENT FROM WH AND PLACE INTO PROPER SHAPE SLOT
    local warehouse = peripheral.find("minecolonies:warehouse")
    local tSlot = 0


    for _, row in pairs(recipe) do
        for _, item in pairs(row) do
            tSlot = tSlot + 1
            for slot, whItem in pairs(warehouse.list()) do
                
                if whItem.name == item then
                    warehouse.pushItems(me, slot, 64, tSlot)
                end
            end
        end
    end

    -- CRAFT
    turtle.craft()
    
    -- RETURN ALL TO WAREHOUSE
    EmptyTurtleToWarehouse()
end

-- https://github.com/cc-tweaked/CC-Tweaked/discussions/601
function EmptyTurtleToWarehouse()
    for f = 1, 16 do
        peripheral.find("minecolonies:warehouse").pullItems(me, f)
    end
end


while true do
    local totalInWh = 0
    local wh = peripheral.find("minecolonies:warehouse")
    for slot, item in pairs(wh.list()) do
        if item.name == 'minecraft:glass_bottle' then
            totalInWh = totalInWh + wh.getItemDetail(slot).count
        end
    end 
    if totalInWh < minBottles then
        print('Low on bottles', totalInWh, 'of', minBottles)
        print('making more!')
        -- pcall(CraftItemFromRecipe(recipes.glass_bottle))
        CraftItemFromRecipe(recipes.glass_bottle)
    else
        print('Bottle stock looks good at', totalInWh, '- checking again later!')
    end
    sleep(600)
end
-- CHECK WAREHOUSE FOR MINIMUM AMOUNT OF ITEM, THEN CRAFT IF MINIMUM NOT MET?
