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
    
    update = function(s,dt)
      local x,y = love.joystick.getAxes(0)
      local gamepad = love.joystick.getHat(0,0)
      local c = s.cursor
      
      local up = gamepad == love.joystick_hat_up or y < -0.25 or love.keyboard.isDown(love.key_up)
      local down = gamepad == love.joystick_hat_down or y > 0.25 or love.keyboard.isDown(love.key_down)
      local left = gamepad == love.joystick_hat_left or x < -0.25 or love.keyboard.isDown(love.key_left)
      local right = gamepad == love.joystick_hat_right or x > 0.25 or love.keyboard.isDown(love.key_right)
      
      local select = love.keyboard.isDown(love.key_return) 
      
      if c.cooldown == 0 then
        if select then s.options[c.selected].action(); return end
        if up then c.selected = s.options[c.selected].up; c.cooldown = c.cooldown + 0.125
        elseif down then c.selected = s.options[c.selected].down; c.cooldown = c.cooldown + 0.125
        elseif left then c.selected = s.options[c.selected].left; c.cooldown = c.cooldown + 0.125
        elseif right then c.selected = s.options[c.selected].right; c.cooldown = c.cooldown + 0.125
        end
      else
        s.cursor.cooldown = math.max(0,s.cursor.cooldown - dt)
      end
    end,
    
    draw = function(s) 
      s.cursor:draw(s)
      s.supplemental:draw(s)
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

local supplemental = {
  draw = function(sup,s)
    love.graphics.setColor(s.normalColor)
    love.graphics.line(425,150,425,450)
    love.graphics.line(600,150,600,450)
    love.graphics.line(275,0,425,150)
    love.graphics.line(750,0,600,150)
    love.graphics.line(425,450,275,600)
    love.graphics.line(600,450,750,600)
  end
}

state.menu = getMenu(options, supplemental)