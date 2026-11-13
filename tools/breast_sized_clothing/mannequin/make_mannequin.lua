-- Builds the female mannequin sheet: 96x32 canvas (S, E, N side by side), one frame per breast size 0-8.
local dir = app.params["dir"]
local out = app.params["out"]

local spr = Sprite(96, 32, ColorMode.RGB)
local behind = spr.layers[1]
behind.name = "breasts behind (BEHIND)"
local body = spr:newLayer()
body.name = "body"
local breasts = spr:newLayer()
breasts.name = "breasts (ADJ)"
local clothing = spr:newLayer()
clothing.name = "clothing"

local parts = { { behind, "behind" }, { body, "body" }, { breasts, "breasts" } }
for i = 0, 8 do
  local frame = spr.frames[1]
  if i > 0 then
    frame = spr:newEmptyFrame()
  end
  for _, part in ipairs(parts) do
    local img = Image { fromFile = dir .. "/" .. part[2] .. "_" .. i .. ".png" }
    spr:newCel(part[1], frame, img, Point(0, 0))
  end
  local tag = spr:newTag(frame.frameNumber, frame.frameNumber)
  tag.name = "size " .. i
end

spr.gridBounds = Rectangle(0, 0, 32, 32)
behind.isEditable = false
body.isEditable = false
breasts.isEditable = false
spr:saveAs(out)
