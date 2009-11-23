love.filesystem.require("util/persistence.lua")

Opt = { difficulty = 2, controlScheme = 1 }

local opts = {

  {text = "Radial Keyboard Controls", x = 100, y = 225, w = 180, h = 20,
    action = function()  
      state.options.controlScheme = 1
  end,
  up = 6, down = 2, left = 7, right = 7, 
  },

  {text = "Eight-directional Keyboard Controls", x = 100, y = 275, w = 245, h = 20,
    action = function()  
      state.options.controlScheme = 2
  end,
  up = 1, down = 3, left = 7, right = 7,
  },

  {text = "Radial Gamepad Controls", x = 100, y = 325, w = 180, h = 20,
    action = function()  
      state.options.controlScheme = 3
  end,
  up = 2, down = 4, left = 7, right = 7,
  },

  {text = "Eight-directional Gamepad Controls", x = 100, y = 375, w = 245, h = 20,
    action = function()  
      state.options.controlScheme = 4
  end,
  up = 3, down = 5, left = 7, right = 7,
  },
  
  {text = "Radial Joystick Controls", x = 100, y = 425, w = 165, h = 20,
    action = function()  
      state.options.controlScheme = 5
  end,
  up = 4, down = 6, left = 7, right = 7,
  },

  {text = "Omni-directional Joystick Controls", x = 100, y = 475, w = 230, h = 20,
    action = function()  
      state.options.controlScheme = 6
  end,
  up = 5, down = 1, left = 7, right = 7,
  },
  
  
  
  {text = "Easy", x = 500, y = 225, w = 75, h = 20,
    action = function()
      Opt.difficulty = 1
  end,
  up = 10, down = 8, left = 1, right = 1,
  },
  
  {text = "Normal", x = 500, y = 275, w = 60, h = 20,
    action = function() 
      Opt.difficulty = 2
  end,
  up = 7, down = 9, left = 1, right = 1,
  },
  
  {text = "Hard", x = 500, y = 325, w = 75, h = 20,
    action = function() 
      Opt.difficulty = 3
  end,
  up = 8, down = 10, left = 1, right = 1,
  },
  
  {text = "Insane", x = 500, y = 375, w = 75, h = 20,
    action = function() 
      Opt.difficulty = 4
  end,
  up = 9, down = 11, left = 1, right = 1,
  },

  {text = "Done", x = 500, y = 500, w = 60, h = 20,
    action = function() 
      
      state.options:save()
      
      state.current = state.menu
  end,
  up = 10, down = 7, left = 1, right = 1,
  },
}

local supplemental = {
  draw = function(sup, s)
    local controlsOption = s.options[Opt.controlScheme]
    local difficultyOption = s.options[Opt.difficulty + 6]
    love.graphics.setColor(s.highlightColor)
    love.graphics.circle(love.draw_fill, controlsOption.x - 30, controlsOption.y - 4, 8, 32)
    love.graphics.circle(love.draw_fill, difficultyOption.x - 30, difficultyOption.y - 4, 8, 32)
  end
}

state.options = getMenu(opts, supplemental)

state.options.save = function(self)
  persistence.store("options", Opt)
end

state.options.load = function(self)
  local loaded = persistence.load("options")
  if loaded ~= nil then Opt = loaded end
end

