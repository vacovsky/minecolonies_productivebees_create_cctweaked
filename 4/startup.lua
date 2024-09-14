shell.openTab("rednet_chatter")


local PROTOCOL = 'ender_orders'

while true do
    write("\n\nWARES_UI> ")
    local msg = read()
    local id = os.getComputerID()
    print(id, 'requesting', msg)
    rednet.broadcast(msg, PROTOCOL)
    print('sent')
    ::continue::
end