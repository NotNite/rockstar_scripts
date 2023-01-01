-- SETTINGS --------------------------------------------------------------------
local play_every_key = true -- play every key or just alphabet
local sound_mode = "hashcode" -- "random" or "hashcode" - how to determine the sound to play
local trigger_mode = "downstroke" -- "downstroke", "upstroke" or "both" - when to play the sound
local hashcode_random = true -- whether to make downstroke and upstroke different when sound_mode is hashcode
--------------------------------------------------------------------------------

local script_dir = rockstar.script_path:match("(.*)amenbreak.lua$")
local dir = script_dir .. "sounds"

local files = {}

for _, file in pairs(rockstar.system.list_dir(dir)) do
  if not file.is_dir and file.name:match("%.wav$") then
    table.insert(files, file.name)
  end
end

local function hashcode(s, modifier)
  local h = 0
  for i = 1, #s do
    h = h * 31 + s:byte(i)
  end
  return h + modifier
end

local function do_it(data, modifier)
  local should_play = play_every_key or data.key:match("Key") ~= nil

  if should_play then
    local idx = nil

    if sound_mode == "random" then
      idx = math.random(1, #files)
    elseif sound_mode == "hashcode" then
      idx = hashcode(data.key, modifier) % #files + 1
    end

    local path = dir .. "/" .. files[idx]
    rockstar.sound.play(path)
  end
end

if trigger_mode == "downstroke" or trigger_mode == "both" then
  rockstar.on("key_press", function(data)
    do_it(data, 0)
  end)
end

if trigger_mode == "upstroke" or trigger_mode == "both" then
  rockstar.on("key_release", function(data)
    do_it(data, hashcode_random and 1 or 0)
  end)
end
