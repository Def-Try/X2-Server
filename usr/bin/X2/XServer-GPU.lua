local rgpu = require("component").gpu
local screen = require("Screen")

local BG, FG = 0x000000, 0xFFFFFF

local xgpu = {}

xgpu.direct = screen

screen.setGPUAddress(rgpu.address)

function xgpu.setResolution(w,h) screen.setResolution(w,h) end
function xgpu.getResolution() return screen.getResolution() end
function xgpu.maxResolution() return screen.getMaxResolution() end
function xgpu.setBackground(color) BG = color end
function xgpu.setForeground(color) FG = color end
function xgpu.getBackground() return BG end
function xgpu.getForeground() return FG end
function xgpu.flip(force) screen.update(force) end
function xgpu.bind(scr) screen.setScreenAddress(scr) end
function xgpu.set(x, y, text)
  screen.drawRectangle(x,y,#text,1,BG,FG," ")
  screen.drawText(x, y, FG, text)
end
function xgpu.fill(x, y, w, h, symbol) screen.drawRectangle(x, y, w, h, BG, FG, symbol) end

return xgpu