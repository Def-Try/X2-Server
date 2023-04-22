local component = require("component")
local os = require("os")
local json = require("json")
local fs = require("filesystem")
local event = require("event")
local gpu = component.gpu
local computer = component.computer
if not gpu or not component.screen then
  computer.beep(5000, 0.5)
  os.exit()
end

local w, h = gpu.maxResolution()

gpu.fill(1,1,w,h," ")

local y = 1
local function print(...)
  if y >= h then
    gpu.copy(1,1,w,h,1,0)
    y = h - 1
  end
  gpu.set(1, y, ...)
  y = y + 1
end

print("Initialising X2 server")

local path = "/usr/x2/config.json"

if not fs.exists(path) then
  local file = io.open(path, "w")
  file:write('{\n    "de": "t-os",\n    "resolution": "80x25"\n}')
  file:close()
end

local config = io.open(path, "r")
local cfg = json.decode(config:read(2048))
config:close()

local DE = cfg.de
local RESOLUTION = cfg.resolution

print("DE: "..DE)
print("Resolution: "..RESOLUTION)

local de_path = "/usr/x2/"..DE
if not fs.exists(de_path.."/main.lua") then
  print("Total failure: DE does not exists (missing "..de_path.."/main.lua)")
  os.exit()
end

--gpu.setResolution()
local de_main, reason = loadfile(de_path.."/main.lua")
if reason then
  print(reason)
end

local fakeGPU = require("XServer-GPU")

fakeGPU.bind(component.screen.address)
fakeGPU.direct.clear()
fakeGPU.flip(true)
local de_table = de_main(fakeGPU, computer, fs, de_path, RESOLUTION)
while true do
  local act = nil
  if de_table.buffered then
    local event, a1, a2, a3, a4, a5, a6 = event.pull()
    if not de_table.loop(event) then
      de_table.draw()
    end
    act = de_table.handle(event, a1, a2, a3, a4, a5, a6)
  else
    local event, a1, a2, a3, a4, a5, a6 = event.pull(0.1)
    if not de_table.loop(event) then
      de_table.draw()
    end
    if event ~= nil then
      act = de_table.handle(event, a1, a2, a3, a4, a5, a6)
    end
  end
  fakeGPU.flip(false)
  if act == "exit" then de_table.exit() break end
  if act == "next" then
    local event, a1, a2, a3, a4, a5, a6 = event.pull(0.1)
    if not de_table.loop(event) then
      de_table.draw()
    end
    if event ~= nil then
      act = de_table.handle(event, a1, a2, a3, a4, a5, a6)
    end
  end
  if act == "draw" then
    de_table.draw()
  end
end