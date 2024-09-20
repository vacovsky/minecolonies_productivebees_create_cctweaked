-- puts fire aspect on stocked diamond swords to kill aliens
local whi = require 'lib/warehouse_interface'
local FIRE_ASPECT = 'create_enchantment_industry:blaze_enchanter_2'

while true do
    whi.GetFromAnyWarehouse(false, 'minecraft:netherite_sword', FIRE_ASPECT, 1)
    sleep(30)
end