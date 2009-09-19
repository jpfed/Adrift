love.filesystem.require("oo.lua")
love.filesystem.require("objects/SimplePhysicsObject.lua")

DamageableObject = {
  super = SimplePhysicsObject,
  armor = 1,
  create = function(d,body,shape,hp)
    local result = SimplePhysicsObject:create(body,shape)
    mixin(result, DamageableObject)
    result.class = DamageableObject
    result.armor = hp
    return result
  end
}
