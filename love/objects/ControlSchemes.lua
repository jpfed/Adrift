love.filesystem.require("oo.lua")
love.filesystem.require("util/geom.lua")

-- return up, left, down, right, fire
keyboardInput = function()
  local up = love.keyboard.isDown(love.key_up)
  local left = love.keyboard.isDown(love.key_left)
  local down = love.keyboard.isDown(love.key_down)
  local right = love.keyboard.isDown(love.key_right)
  local fire = love.keyboard.isDown(love.key_f)
  return up,left,down,right,fire
end

gamepadInput = function()
  local dpad = love.joystick.getHat(0,0)
  local up = dpad == love.joystick_hat_leftup or dpad == love.joystick_hat_up or dpad == love.joystick_hat_rightup
  local left = dpad == love.joystick_hat_leftdown or dpad == love.joystick_hat_left or dpad == love.joystick_hat_leftup
  local right = dpad == love.joystick_hat_rightup or dpad == love.joystick_hat_right or dpad == love.joystick_hat_rightdown
  local down = dpad == love.joystick_hat_rightdown or dpad == love.joystick_hat_down or dpad == love.joystick_hat_leftdown
  local fire = love.joystick.isDown(0,0)
  return up, left, down, right, fire
end

-- return x, y, fire
joystickInput = function()
  local axis1, axis2 = love.joystick.getAxes(0)
  local fire = love.joystick.isDown(0,0)
  return axis1, axis2, fire
end

discreteTurnAndThrust = function(self, parent, inputFunc, dt)
  local targVx, targVy = 0, 0
  local theta = math.rad(parent.angle)
  local up, left, down, right, fire = inputFunc()
  
  if up then targVx, targVy = targVx + math.cos(theta), targVy + math.sin(theta) end
  if down then targVx, targVy = targVx - math.cos(theta), targVy - math.sin(theta) end
  
  if left then 
    self.leftT = self.leftT + dt
    local leftTurnPower = 1 - math.exp(-10*self.leftT)
    targVx, targVy = targVx + leftTurnPower*math.cos(theta-math.pi/2), targVy + leftTurnPower*math.sin(theta-math.pi/2) 
  else
    self.leftT = 0
  end
  
  if right then 
    self.rightT = self.rightT + dt
    local rightTurnPower = 1 - math.exp(-10*self.rightT)
    targVx, targVy = targVx + rightTurnPower*math.cos(theta+math.pi/2), targVy + rightTurnPower*math.sin(theta+math.pi/2) 
  else
    self.rightT = 0
  end
  
  targVx, targVy = geom.normalize(targVx, targVy)
  return targVx, targVy, fire
end

continuousTurnAndThrust = function(self, parent, inputFunc, dt)
  local targVx, targVy = 0, 0
  local theta = math.rad(parent.angle)
  local turn, thrust, fire = inputFunc() 
  
  if math.abs(thrust) < 0.25 then 
    thrust = 0
  else
    thrust = (thrust - 0.25)/0.75
  end
  
  if math.abs(turn) < 0.25 then 
    turn = 0
  else
    turn = (turn - 0.25)/0.75
  end
  
  local turnPower = 0
  if turn < 0 then
    self.leftT = self.leftT - turn*dt
    self.rightT = 0
    turnPower = 1 - math.exp(-self.leftT)
  elseif turn > 0 then
    self.leftT = 0
    self.rightT = self.rightT + turn*dt
    turnPower = 1 - math.exp(-self.rightT)
  else
    self.leftT = 0
    self.rightT = 0
    turnPower = 0
  end
  
  targVx, targVy = targVx - thrust*math.cos(theta), targVy - thrust*math.sin(theta)
  targVx, targVy = targVx + turn*math.cos(theta + math.pi/2), targVy + turn*math.sin(theta + math.pi/2)
  targVx, targVy = geom.normalize(targVx, targVy)
  return targVx, targVy, fire
end

discreteDirectional = function(self, parent, inputFunc, dt)
  local targVx, targVy = 0, 0
  local up, left, down, right, fire = inputFunc()
  if up then targVy = targVy - 1 end
  if down then targVy = targVy + 1 end
  if left then targVx = targVx - 1 end
  if right then targVx = targVx + 1 end
  targVx, targVy = geom.normalize(targVx, targVy)
  return targVx, targVy, fire
end

continuousDirectional = function(self, parent, inputFunc, dt)
  return inputFunc()
end

ControlSchemes = {

  {leftT = 0, rightT = 0, getAction = function(self, parent, dt) return discreteTurnAndThrust(self,parent,keyboardInput,dt) end},
  {directional = true, getAction = function(self, parent, dt) return discreteDirectional(self, parent, keyboardInput, dt) end},
  {leftT = 0, rightT = 0, getAction = function(self, parent, dt) return discreteTurnAndThrust(self,parent,gamepadInput,dt) end},
  {directional = true, getAction = function(self, parent, dt) return discreteDirectional(self, parent, gamepadInput, dt) end},
  {leftT = 0, rightT = 0, getAction = function(self, parent, dt) return continuousTurnAndThrust(self,parent,joystickInput,dt) end},
  {directional = true, getAction = function(self, parent, dt) return continuousDirectional(self, parent, joystickInput, dt) end},
  
}