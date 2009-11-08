local title = {
  banner = love.graphics.newImage("graphics/adrift_banner.png"),
  banner_color = love.graphics.newColor(255,255,255),
  banner_color_glitch = love.graphics.newColor(200,220,255,50),

  pings = {},
  PING_LIFE = 10,
  PING_SPEED = 50,
  PING_ACCEL = -0.1,
  PING_X = 488,
  PING_Y = 30,
  t = 0,
  cooldown = 6,

  update = function(self,dt)
    self.t = self.t + dt
    self.cooldown = self.cooldown + dt
    self.ix = self.PING_X + (math.sin(self.t / 2) * 20)
    self.iy = self.PING_Y

    for k,ping in ipairs(self.pings) do
      if ping then
        ping.t = ping.t + (dt * ping.speed)
        if ping.speed > 1 then ping.speed = ping.speed + (dt * self.PING_ACCEL) end
        if ping.speed < 1 then ping.speed = 1 end
      end
    end
    if #self.pings < 10 and self.cooldown > 6 then
      self:addPing()
    end
  end,

  addPing = function(self)
    self.cooldown = 0
    local ping = {
      speed = self.PING_SPEED,
      x = self.ix,
      y = self.iy,
      t = 0,
    }
    table.insert(self.pings, ping)
  end,

  draw = function(self,s)
    love.graphics.setBlendMode(love.blend_additive)
    love.graphics.setBlendMode(love.color_modulate)

    for k,ping in ipairs(self.pings) do
      local alpha = 100 - (ping.t / 2)
      if alpha < 10 then alpha = 10 end
      love.graphics.setColor(love.graphics.newColor(255,255,255,alpha / 5 - 2))
      love.graphics.circle(love.draw_fill,ping.x,ping.y,ping.t,64)
      love.graphics.setColor(love.graphics.newColor(255,255,255,alpha))
      love.graphics.circle(love.draw_line,ping.x,ping.y,ping.t,64)
    end

    if math.random() <0.005 then
      -- GLITCH OUT!
      love.graphics.setColor(self.banner_color_glitch)
      for i = 1,4 do
        love.graphics.draw(self.banner,380 + math.random(40),90 + math.random(20),math.random() * 10 - 5,1,math.random())
        love.graphics.draw(self.banner,self.ix,self.iy,math.random(360),math.random()/10,math.random()/3)
      end
    else
      love.graphics.setColor(self.banner_color)
      love.graphics.draw(self.banner,400,100,0,1)
      love.graphics.rectangle(love.draw_fill,self.ix-15,self.iy-15,30,30)
    end

    love.graphics.setBlendMode(love.blend_normal)
    love.graphics.setBlendMode(love.color_normal)
  end
}

getMenu = function(opts, extras)
  
  return {
    
    normalColor = love.graphics.newColor(128,128,128),
    highlightColor = love.graphics.newColor(255,255,255),
    
    xMargin = 15,
    yMargin = 13,
    
    cursor = {
      
      selected = 1,
      cooldown = 0,
      
      draw = function(c,s) 
        love.graphics.setColor(s.highlightColor)
        local so = s.options[c.selected]
        love.graphics.rectangle(love.draw_line,so.x - s.xMargin,so.y - s.yMargin,so.w,so.h)
      end,
    },

    options = opts,
    supplemental = extras,
    title = title,
    
    update = function(s,dt)
      s.title:update(dt)
      local x,y = 0,0
      if useJoystick then x, y = love.joystick.getAxes(0) end
      local gamepad = -1
      if useJoystick then gamepad = love.joystick.getHat(0,0) end
      local c = s.cursor
      if useJoystick then
        x,y = love.joystick.getAxes(0)
        gamepad = love.joystick.getHat(0,0)
      end  
      local up = gamepad == love.joystick_hat_up or y < -0.25 or love.keyboard.isDown(love.key_up)
      local down = gamepad == love.joystick_hat_down or y > 0.25 or love.keyboard.isDown(love.key_down)
      local left = gamepad == love.joystick_hat_left or x < -0.25 or love.keyboard.isDown(love.key_left)
      local right = gamepad == love.joystick_hat_right or x > 0.25 or love.keyboard.isDown(love.key_right)
      
      
      local select = love.keyboard.isDown(love.key_return) 
      
      if c.cooldown == 0 then
        if select then c.cooldown = c.cooldown + 0.125; s.options[c.selected].action(); return end
        if up then c.selected = s.options[c.selected].up; c.cooldown = c.cooldown + 0.125
        elseif down then c.selected = s.options[c.selected].down; c.cooldown = c.cooldown + 0.125
        elseif left then c.selected = s.options[c.selected].left; c.cooldown = c.cooldown + 0.125
        elseif right then c.selected = s.options[c.selected].right; c.cooldown = c.cooldown + 0.125
        end
        if up or down or left or right or select then s.title:addPing() end
      else
        s.cursor.cooldown = math.max(0,s.cursor.cooldown - dt)
      end
    end,
    
    draw = function(s) 
      s.title:draw(s)
      s.cursor:draw(s)
      if s.supplemental then s.supplemental:draw(s) end
      love.graphics.setColor(s.normalColor)
      for k,v in ipairs(s.options) do
        love.graphics.draw(v.text,v.x,v.y)
      end
    end,
    
    mousepressed = function(s,x,y,button) 
      if s.cursor.selected > 0 then s.options[s.cursor.selected].action() end
    end,
    
    keypressed = function(s,key) 
    end,
    
    joystickpressed = function(s,j,b)
      s.options[s.cursor.selected].action()
    end
    
  }
end

local options = {
  
  {text = "Start Game", x = 480, y = 200, w = 95, h = 20,
    action = function()  
      state.game:load()
  end,
  up = 4, down = 2, left = 1, right = 1,
  },
  
  {text = "Options", x = 480, y = 300, w = 75, h = 20,
    action = function()  
      state.current = state.options
  end,
  up = 1, down = 3, left = 2, right = 2,
  },
  
  {text = "Help", x = 480, y = 350, w = 60, h = 20,
    action = function()
      state.current = state.help
  end,
  up = 2, down = 4, left = 3, right = 3,
  },
  
  {text = "Quit", x = 480, y = 400, w = 60, h = 20,
    action = function() 
      love.system.exit()
  end,
  up = 3, down = 1, left = 4, right = 4,
  }
}


state.menu = getMenu(options)
