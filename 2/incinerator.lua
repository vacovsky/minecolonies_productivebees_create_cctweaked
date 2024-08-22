local whi = require 'warehouse_interface'

JUNKLIST_CHEST = ''

-- LOAD JUNK ITEM LIST
local JUNK = {
    'productivebees:wax',
    'minecraft:snowball',
    'minecraft:carrot',
    'minecraft:potato',
    'farm_and_charm:corn',
    'farm_and_charm:kernels',
}

local TRASHCAN = 'ironchests:obsidian_barrel_1'

function IncinerateJunk()
    for _, item in pairs(JUNK) do
        print('Burned', whi.GetFromAnyWarehouse(false, item, TRASHCAN, 64), item)
    end
end

print('Starting junk incinerator...')
while true do
    -- pcall(IncinerateJunk)
    IncinerateJunk()
    sleep(15)


    -- TODO
    -- JUNK ITEMS are defined by what's in the designated trash chest.
    -- LOOP THROUGH JUNK CHEST TO CONFIRM IF ALL SHOULD BE DELETED
    -- TRANSFER ITEMS OF EACH TYPE FROM WAREHOUSE TO INCINERATOR WITH .5 SECONDS DELAY
end

