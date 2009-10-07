Engine = {
  
  create = function(self, parent, thrust, thrustRate, turnRate)
    local result = {}
    result.parent = parent
    result.thrust = thrust
    result.thrustRate = thrustRate
    result.turnRate = turnRate
    result.vector = Engine.vector
    return result
  end,
  
  vector = function(self, forceX, forceY, dt)
    local theta, targetSpin, existingSpin = math.rad(self.parent.angle), 0, self.parent.body:getSpin()
    local pointingX,pointingY = math.cos(theta), math.sin(theta)
    local forceNormX, forceNormY = geom.normalize(forceX, forceY)
    local cp = geom.cross_product(pointingX,pointingY,forceNormX,forceNormY)

    targetSpin = cp*360
    
    local spinRetain = math.exp(-self.turnRate*dt*4)
    local spinChange = 1 - spinRetain
    
    self.parent.body:setSpin(existingSpin * spinRetain + targetSpin * spinChange)
    
    local velRetain = math.exp(-self.thrustRate*dt)
    local velChange = 1 - velRetain
    
    local overallThrust = self.thrust*(pointingX * forceX + pointingY * forceY)
    local thrustX, thrustY = pointingX * overallThrust, pointingY * overallThrust
    
    local vx, vy = self.parent.body:getVelocity()
    self.parent.body:setVelocity(vx * velRetain + thrustX * velChange, vy * velRetain + thrustY * velChange)
    return overallThrust
  end

}
