love.filesystem.require("oo.lua")

-- No behavior, just used for grouping
Powerup = {
  attribute = function(self)
    local result = {attributes = {}}
    result.attributes[Powerup] = true
    mixin(result,Powerup)
    return result
  end,
}

