local args = {...}
local gpu, computer, fs, path, resol = args[1], args[2], args[3], args[4], args[5]

function string.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function table.index(tbl, item)
  for k,v in pairs(tbl) do
    if v == item then return k end
  end
  return nil
end

local wh = string.split(resol, "x")
local w, h = tonumber(wh[1]), tonumber(wh[2])


local function clear() gpu.fill(1,1,w,h," ") end
local function barHorisontal(y,s, color)
  local oldbg = gpu.getBackground()
  gpu.setBackground(color)
  gpu.fill(1,y,w,y+s-1," ")
  gpu.setBackground(oldbg)
end
local function barVertical(x,s, color)
  local oldbg = gpu.getBackground()
  gpu.setBackground(color)
  gpu.fill(x,1,x+s-1,h," ")
  gpu.setBackground(oldbg)
end

local function centeredTextHor(x,y, Tw, text)
  if #text > Tw then
    text = string.sub(text,0,Tw-3) .. "..."
    if #text > Tw then
      text = string.sub(text,0,Tw)
    end
    gpu.set(x,y,text)
    return
  end
  local dX = x + math.floor(Tw / 2 - #text / 2)
  gpu.set(dX,y,text)
end

gpu.setResolution(w,h)

t_os = {}

t_os.buffered = true

function t_os.exit()
  local w, h = gpu.maxResolution()
  gpu.setResolution(w,h)
  clear()
end

local windows = {}
windows[1] = {}
windows[1].name = "Test"
windows[1].size = {30,7}
windows[1].position = {5,5}
windows[1].buttons = {}
windows[1].buttons[1] = {}
windows[1].buttons[1].action = "close"
windows[1].buttons[1].position = {29,0}
windows[1].buttons[1].text = "X"

local lastTx, lastTy = -1, -1

function t_os.loop(eventName) end

function t_os.draw()
  clear()
  barHorisontal(1,1,0x222222)
  centeredTextHor(1,2,40,"Hello")
  for _,window in pairs(windows) do
    local ws = window.size
    local n = window.name
    local wp = window.position
    local oldbg = gpu.getBackground()
    gpu.setBackground(0x888888)
    gpu.fill(wp[1], wp[2], ws[1], ws[2], " ")
    gpu.setBackground(0x222222)
    gpu.fill(wp[1], wp[2], ws[1], 1, " ")
    gpu.set(wp[1], wp[2], n)
    for _,btn in pairs(window.buttons) do
      local bp = btn.position
      local bt = btn.text
      gpu.set(wp[1]+bp[1], wp[2]+bp[2], bt)
    end
    gpu.setBackground(oldbg)
  end
end

function t_os.handle(event, ...)
  if event == "interrupted" then return "exit" end
  local as = {...}
  local a1, a2, a3, a4, a5, a6 = as[1], as[2], as[3], as[4], as[5], as[6]
  if event == "touch" then lastTx, lastTy = a2, a3 end

  if event == "touch" and a4 == 0 then
    for _,win in pairs(windows) do
      for _,btn in pairs(win.buttons) do
        local bp = btn.position
        local bs = {#btn.text, 1}
        local bm = {bp[1]+bs[1], bp[2]+bs[2]}
        local x,y = a2, a3

        if x >= win.position[1]+bp[1] and x < win.position[1]+bm[1]
          and y >= win.position[2]+bp[2] and y < win.position[2]+bm[2] then
          if btn.action == "close" then table.remove(windows, table.index(windows, win)) break end
        end
      end
    end
  end
  if event == "drag" and a4 == 0 then
    for _,win in pairs(windows) do
      local x,y = lastTx, lastTy
      if x >= win.position[1] and x < win.position[1]+win.size[1]
        and y >= win.position[2] and y < win.position[2]+1 then
        win.position = {win.position[1]+(a2-x), win.position[2]+(a3-y)}
        lastTx, lastTy = lastTx+(a2-x), lastTy+(a3-y)
      end
    end
  end
end

return t_os