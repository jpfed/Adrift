love.filesystem.require("oo.lua")
love.filesystem.require("util/geom.lua")

-- return up, left, down, right, fire
keyboardInput = function()
  local up = love.keyboard.isDown(love.key_up)
  local left = love.keyboard.isDown(love.key_left)
  local down = love.keyboard.isDown(love.key_down)
  local right = love.keyboard.isDown(love.key_right)
  local fire = love.keyboard.isDown(love.key_f)
  local mod1 = love.keyboard.isDown(love.key_space)
  return up,left,down,right,fire,mod1
end

gamepadInput = function()
  if useJoystick then
    local dpad = love.joystick.getHat(0,0)
    local up = dpad == love.joystick_hat_leftup or dpad == love.joystick_hat_up or dpad == love.joystick_hat_rightup
    local left = dpad == love.joystick_hat_leftdown or dpad == love.joystick_hat_left or dpad == love.joystick_hat_leftup
    local right = dpad == love.joystick_hat_rightup or dpad == love.joystick_hat_right or dpad == love.joystick_hat_rightdown
    local down = dpad == love.joystick_hat_rightdown or dpad == love.joystick_hat_down or dpad == love.joystick_hat_leftdown
    local fire = love.joystick.isDown(0,0)
    local mod1 = love.joystick.isDown(0,1)
    return up, left, down, right, fire, mod1
  else
    return false, false, false, false, false, false
  end
end

-- return x, y, fire
joystickInput = function()
  if useJoystick then
    local axis1, axis2 = love.joystick.getAxes(0)
    local fire = love.joystick.isDown(0,0)
    local mod1 = love.joystick.isDown(0,1)
    return axis1, axis2, fire, mod1
  else
    return 0,0,false,false
  end
end

discreteTurnAndThrust = function(self, parent, inputFunc, dt)
  local targVx, targVy = 0, 0
  local theta = math.rad(parent.angle)
  local up, left, down, right, fire, mod1 = inputFunc()
  
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
  return targVx, targVy, fire, mod1
end

continuousTurnAndThrust = function(self, parent, inputFunc, dt)
  local targVx, targVy = 0, 0
  local theta = math.rad(parent.angle)
  local turn, thrust, fire, mod1 = inputFunc() 
  
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
  return targVx, targVy, fire, mod1
end

discreteDirectional = function(self, parent, inputFunc, dt)
  local targVx, targVy = 0, 0
  local up, left, down, right, fire, mod1 = inputFunc()
  if up then targVy = targVy - 1 end
  if down then targVy = targVy + 1 end
  if left then targVx = targVx - 1 end
  if right then targVx = targVx + 1 end
  targVx, targVy = geom.normalize(targVx, targVy)
  return targVx, targVy, fire, mod1
end

continuousDirectional = function(self, parent, inputFunc, dt)
  return inputFunc()
end

local action = function(f,input)
  return function(self, parent, dt) return f(self,parent,input,dt) end
end

ControlSchemes = {

  {leftT = 0, rightT = 0, input = keyboardInput, getAction = action(discreteTurnAndThrust, keyboardInput)},
  {directional = true,    input = keyboardInput, getAction = action(discreteDirectional, keyboardInput)},
  {leftT = 0, rightT = 0, input = gamepadInput,  getAction = action(discreteTurnAndThrust, gamepadInput)},
  {directional = true,    input = gamepadInput,  getAction = action(discreteDirectional, gamepadInput)},
  {leftT = 0, rightT = 0, input = joystickInput, getAction = action(continuousTurnAndThrust, joystickInput)},
  {directional = true,    input = joystickInput, getAction = action(continuousDirectional, joystickInput)},
  
}
