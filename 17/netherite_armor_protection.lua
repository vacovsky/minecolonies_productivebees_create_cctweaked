-- puts fire aspect on stocked diamond swords to kill aliens
local whi = require 'lib/whi'
local PROTECTION = 'create_enchantment_industry:blaze_enchanter_14'

local ARMOR_TYPES = {
    'minecraft:netherite_chestplate',
    'minecraft:netherite_leggings',
    'minecraft:netherite_boots',
    'minecraft:netherite_helmet',
    'minecraft:netherite_sword',
    'musketmod:musket',
}

while true do
    for _, armor in pairs(ARMOR_TYPES) do
        whi.GetFromAnyWarehouse(false, armor, PROTECTION, 1)
    end
    sleep(5)
end