shell.openTab("rednet_chatter")

local id = 8

local PROTOCOL = 'ender_orders'

while true do
    write("\n\nWARES_UI> ")
    local msg = read()
    print('requesting', msg)
    rednet.broadcast(msg, PROTOCOL)
    ::continue::
end