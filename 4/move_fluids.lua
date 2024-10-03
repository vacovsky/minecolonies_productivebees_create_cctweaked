local source = 'fluidTank_12'
local dest = 'fluidTank_10'

local st = peripheral.wrap(source)
st.pushFluid(dest)
