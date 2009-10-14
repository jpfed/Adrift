love.filesystem.require("oo.lua")

Power = {
  cooldown = 0,
  
  trigger = function(self) 
    if self.cooldown_time >= self.cooldown_speed then
      self.active = true
      self.active_time = 0
      self.cooldown_time = 0
      self.fstart(self,self.parent)
    end
  end,

  update = function(self, dt)
    if self.cooldown_time < self.cooldown_speed then
      self.cooldown_time = self.cooldown_time + dt
    end
    if self.active then
      self.active_time = self.active_time + dt
      if self.active_time >= self.duration then
        self.active = false
        if not self.parent.dead then self.fend(self,self.parent) end
      else
        if not self.parent.dead then self.factive(self,self.parent) end
      end
    end
  end,
  
  create = function(self,parent,cooldown_speed,duration,fstart,factive,fend)
    local r = {}
    mixin(r, Power)
    r.class = Power
    r.parent = parent
    r.cooldown_speed = cooldown_speed
    r.cooldown_time = 0
    r.active_time = 0
    r.duration = duration
    r.fstart  = fstart  or function() end
    r.factive = factive or function() end
    r.fend    = fend    or function() end
    r.active = false
    return r
  end
}

