love.filesystem.require("oo.lua")

-- No behavior, just used for grouping
Resource = {
  attribute = function(self)
    local result = {attributes = {}}
    result.attributes[Resource] = true
    mixin(result,Resource)
    return result
  end,
}

