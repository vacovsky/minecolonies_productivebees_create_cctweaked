rednet.open('top')

while true do
    local sender, message = rednet.receive('ender_orders');
    print(sender, message)
end
