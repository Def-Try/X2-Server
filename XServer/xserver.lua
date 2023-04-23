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

print("Initialising X2 server")

function table.slice(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do sliced[#sliced+1] = tbl[i] end
  return sliced
end

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
  local ev = nil
  if de_table.buffered then
    ev = table.pack(event.pull())
  else
    ev = table.pack(event.pull(0.02))
  end

  local ev, args = ev[1], table.slice(ev, 2, #ev, 1)
  if not de_table.loop(ev) then
    de_table.draw()
  end
  act = de_table.handle(ev, table.unpack(args))

  fakeGPU.flip(false)
  if act == "exit" then de_table.exit() break end
  if act == "next" then
    local event = table.pack(event.pull(0.02))
    local event, args = event[1], table.slice(event, 2, #event, 1)
    if not de_table.loop(event) then
      de_table.draw()
    end
    if event ~= nil then
      act = de_table.handle(event, table.unpack(args))
    end
  end
  if act == "draw" then
    de_table.draw()
  end
end
