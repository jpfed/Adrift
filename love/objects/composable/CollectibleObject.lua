love.filesystem.require("oo.lua")

CollectibleObject = {
   
  attribute = function(self,snd,effectFunc)
    local result = {attributes = {}, sound = snd, collectEffect = effectFunc}
    result.attributes[CollectibleObject] = true
    mixin(result,CollectibleObject)
    return result
  end,
    
  collected = function(self, collector)
    love.audio.play(self.sound)
    self:collectEffect(collector)
  end
  
}
