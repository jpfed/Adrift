love.filesystem.require("oo.lua")
love.filesystem.require("objects/composable/CollectibleObject.lua")

BoosterPowerup = {
  super = CollectibleObject,
  
  timer = 0, 
  
  images = {
    love.graphics.newImage("graphics/booster0.png"),
    love.graphics.newImage("graphics/booster1.png"),
    love.graphics.newImage("graphics/booster2.png"),
    love.graphics.newImage("graphics/booster3.png"),
  },
  
  sound = love.audio.newSound("sound/boosterCollect.ogg"),
  
  effect = function(self, collector) 
    if collector.powers ~= nil and collector.powers.boost ~= nil then 
      local b = collector.powers.boost
      b.thrust_increment = BoostPower.powered_thrust_increment 
      b.cooldown_speed = BoostPower.powered_cooldown_speed
    end
    if collector == state.game.ship then 
      state.game.score = state.game.score + 1000 
      logger:add("Enhanced Booster collected! Press mod-forward to activate!")
    end
  end,
  
  update = function(self, dt)
    self:superUpdate(dt)
    self.timer = self.timer + dt
  end,
  
  draw = function(self)
    local speed, numFrames = 12, #(self.images)
    local imageIndex = math.floor(self.timer*speed) % numFrames + 1
    local x, y, s = L:xy(self.x, self.y, 0)
    love.graphics.draw(self.images[imageIndex], x, y, 0, s/25)
  end,
  
  create = function(self,node)
    local bBody = love.physics.newBody(L.world,node.x,node.y,0.25)
    local bShape = love.physics.newRectangleShape(bBody,1,1)
    local result = CollectibleObject:create(bBody, bShape, BoosterPowerup.sound, BoosterPowerup.effect)
    result.superUpdate = result.update
    mixin(result, BoosterPowerup)
    result.class = BoosterPowerup
    return result
  end
}
