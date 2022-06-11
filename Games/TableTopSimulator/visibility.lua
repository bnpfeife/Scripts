-- /BEG VISIBILITY SECTION --

TAG_VISIBLE   = "Visible"
TAG_INVISIBLE = "Invisible"

PLAYER_COLORS = {
    "Blue",
    "Green",
    "Grey",
    "Orange",
    "Pink",
    "Purple",
    "Red",
    "Teal",
    "White",
    "Yellow",
}

-- VISIBILITY PER-INSTANCE VARIABLES --

playerVisibility = {}

-- VISIBILITY FUNCTIONS --

function VISUpdateTags()
  -- For each color within `PLAYER_COLORS`, remove both the `Visible<Color>`
  -- and the `Invisible<Color>` tag. This is so we can write the tags from
  -- a "blank" slate. I've noticed that this function does not work when
  -- the "tags" submenu is open.
  for item, color in pairs(PLAYER_COLORS) do
    self.removeTag(TAG_VISIBLE   .. color)
    self.removeTag(TAG_INVISIBLE .. color)
  end

  -- Iterate through each element within `playerVisiblity`. If the color
  -- is assigned to `true`, write the `Visible<Color>` tag. Otherwise,
  -- write the `Invisible<Color>` tag.
  for color, state in pairs(playerVisibility) do
    self.addTag((state and TAG_VISIBLE or TAG_INVISIBLE) .. color)
  end
end

function VISUpdateObject()
  local invisible = {}
  -- For each color within `PLAYER_COLORS`, determine if it is invisible.
  -- If it is, write it to the end of the `invisible` "list".
  for item, color in pairs(PLAYER_COLORS) do
    if not playerVisibility[color] then
      invisible[#invisible + 1] = color
    end
  end

  -- There does not exist a `setVisibleTo` function. However, this function
  -- overwrites the previous invocation. Thus, if you pass `Blue`, and then
  -- you pass `Red`, only `Red` will be invisible after the second
  -- invocation.
  self.setInvisibleTo(invisible)
end

function VISInit()
  -- Instead of a button, `VISUpdate` can be executed every frame. However,
  -- Tabletop Simulator is **incredibly** slow. When I executed `VISUpdate`
  -- every frame by placing it in `onUpdate` OR every 180 ticks by placing
  -- it in `onFixedUpdate`, Tabletop Simulator lagged to sub-60FPS. This
  -- shouldn't be the case, so something is screwed.
  self.createButton({
    click_function = "VISUpdate",
    function_owner = self,
    label          = "Update Visibility",
    tooltip        = "Update Visibility",
    position       = { 0.0, 0.25, 1.5 },
    width          = 230,
    height         = 180,
    font_size      = 150,
    color          = { 0.25, 0.25, 0.25, 0.7 },
    font_color     = { 1, 1, 1, 100 }
  })

  -- initially visible to all players --
  for item, color in pairs(PLAYER_COLORS) do
    playerVisibility[color] = true
  end

  VISUpdateTags()
  VISUpdateObject()
end

function VISUpdate()
  local cachedTags = self.getTags()

  local tags = {}
  -- Iterate through each `tag` in `cachedTags`. If the `tag` matches the
  -- `TAG_VISIBLE` pattern, insert it into the `tags` dictionary. This
  -- uses a dictionary as lookups tend to be faster than with arrays.
  for item, tag in pairs(cachedTags) do
    local match = tag:match("^" .. TAG_VISIBLE .. "(%S+)$")
    if match then
      tags[match] = true
    end
  end

  -- Iterate through each `tag` in `cachedTags`. If the `tag` matches the
  -- `TAG_INVISIBLE` pattern, insert it into the `tags` dictionary. This
  -- uses a dictionary as lookups tend to be faster than with arrays.
  for item, tag in pairs(cachedTags) do
    local match = tag:match("^" .. TAG_INVISIBLE .. "(%S+)$")
    if match then
      tags[match] = true
    end
  end

  for item, color in pairs(PLAYER_COLORS) do
    -- If the `color` does not exist within `tags`, then the corresponding
    -- tag must have been clicked within the "tags" menu. The label within
    -- the "tags" menu does not matter, flip the visiblity state.
    if not tags[color] then
      playerVisibility[color] = not playerVisibility[color]
    end
  end

  VISUpdateTags()
  VISUpdateObject()

  print("Visibility updated...")
end

-- /END VISIBILITY SECTION --

function onLoad()
  VISInit()
end
