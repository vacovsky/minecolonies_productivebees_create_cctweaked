rednet.open('back')
-- rednet.open('left')
-- rednet.open('right')
-- rednet.open('top')
-- rednet.open('bottom')

local PROTOCOL = 'ender_orders'

while true do
    local sender, message = rednet.receive(PROTOCOL);
    print(sender, message)
end
