love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/SimplePhysicsObject.lua")

Projectile = {
  attribute = function(P)
    local result = {attributes = {}}
    result.attributes[Projectile] = true
    return result
  end
}

