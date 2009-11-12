BoomOperator = {
  distance = 32,

  normalize = function(t)
    local u = {}
    local total = 0
    for i,v in ipairs(t) do total = total + v[2] end

    local subtotal = 0
    for i,v in ipairs(t) do 
      local width = v[2] / total
      u[i] = {v[1],subtotal,subtotal+width}
      subtotal = subtotal + width
    end
    return u
  end,

  create = function(self, difficulty)
    local r = {}
    mixin(r, BoomOperator)
    r.class = BoomOperator
    r.difficulty = difficulty

    r.depth = state.game.levelNumber

    r.resourceDistribution = r.normalize({
      {MineralChunk, math.random(5,10)},
      {EnergyChunk,  math.random(2,5)},
    })

    local teleportProb = 0
    if r.depth >= 3 then teleportProb = math.random(10) + r.depth + difficulty end
    r.powerupDistribution = r.normalize({
      {ArmorPowerup, 100},
      {MaxArmorPowerup, math.random(5,10)},
      {HomingMissilePowerup, math.random(2) + r.depth + difficulty},
      {ProximityMinePowerup, math.random(3,6) + r.depth + difficulty},
      {BoosterPowerup, math.random(1,5)},
      {TeleportPowerup, teleportProb},
    })

    -- NOTE: Eventually we will want to track enemies that prefer to be 
    -- created on the ground/walls... this simplistic method doesn't care 
    -- about that at all...
    if r.depth == 1 then
      r.enemyDistribution = r.normalize({
        {HornetEgg, math.random(2)},
        {Grasshopper, math.random(4) + 2},
        {Eel, math.random(2) + 2},
        {Bomber, math.random(2)},
      })
    elseif r.depth < 4 then
      r.enemyDistribution = r.normalize({
        {HornetEgg, math.random(2)},
        {Hornet, math.random(2 + difficulty)},
        {Grasshopper, math.random(4) + 2},
        {Eel, math.random(4) + 2},
        {Bomber, math.random(1 + difficulty)},
        {Turret, math.random(2)},
      })
    else
      r.enemyDistribution = r.normalize({
        {HornetEgg, math.random(2)},
        {Hornet, math.random(4) + difficulty},
        {Grasshopper, math.random(3) + 2},
        {Eel, math.random(3) + 2},
        {Bomber, math.random(2 + difficulty)},
        {Turret, math.random(2)},
      })
    end

    return r
  end,

  getKind = function(self, t)
    local r = math.random()
    for k,v in pairs(t) do 
      if r >= v[2] and r <= v[3] then return v[1] end
    end
    error "No kind found in probability table"
  end,

  addResource = function(self, v)
    local kind = self:getKind(self.resourceDistribution)
    L:addObject(DelayedPowerup(kind, v, self.distance * 2))
  end,

  addPowerup = function(self, v)
    local kind = self:getKind(self.powerupDistribution)
    L:addObject(DelayedPowerup(kind, v, self.distance * 2))
  end,

  addEnemy = function(self, v)
    local kind = self:getKind(self.enemyDistribution)
    L:addObject(DelayedEnemy(kind, v.x, v.y, self.difficulty, self.distance))
  end,

  startObjects = function(self)
    for k,v in ipairs(L.nodes) do
      if v.startingSpot then 
        table.insert(L.objects, objects:getStartingSpot(v)) 
      else
        if v.warpCrystal then 
          table.insert(L.objects, objects:getWarpCrystal(v)) 
        end
        if v.enemy then 
          for i=0,math.random(1,self.depth) do
            self:addEnemy(v)
          end
        end
        if v.powerup then 
          self:addPowerup(v)
        end
        if math.random() < 0.5 then
          for i=0,math.random(1,4) do
            self:addResource(v)
          end
        end
      end
    end
  end,

  addDefenders = function(self)
    for k,v in ipairs(L.nodes) do
      if v.startingspot then 
        for i in 1,self.difficulty+self.depth do
          self:addEnemy(v)
        end
      else
        if math.random() < 0.3 then
          self:addEnemy(v)
        end
      end
    end
  end,

}
