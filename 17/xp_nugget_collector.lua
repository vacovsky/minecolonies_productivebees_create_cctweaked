local tsdb = require "lib/tsdb"
local DRAIN_INPUT = 'create_enchantment_industry:disenchanter_0'
local CRUSHER_OUTPUT = 'ironchests:gold_barrel_1'
local XP_ITEM = 'create:experience_nugget'


function CollectXP()
    -- collect xp nuggets, move to disenchanter
    local pushed = 0
    local xp_nugget_source = peripheral.wrap(CRUSHER_OUTPUT)
    for slot, item in pairs(xp_nugget_source.list()) do
        if string.find(item.name, XP_ITEM) then
            pushed = xp_nugget_source.pushItems(DRAIN_INPUT, slot)
        end
    end

    if pushed > 0 then
        print(pushed, 'nuggets pushed')
        tsdb.WriteOutput('Nolins', { xp_nugget_count = pushed }, 'xp_drain_1.json')
    end
end

while true do
    CollectXP()
    sleep(2)
end
