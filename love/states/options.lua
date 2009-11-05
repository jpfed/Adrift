local opts = {

  {text = "Radial Keyboard Controls", x = 100, y = 125, w = 180, h = 20,
    action = function()  
      state.options.controlScheme = 1
  end,
  up = 6, down = 2, left = 7, right = 7, 
  },

  {text = "Eight-directional Keyboard Controls", x = 100, y = 175, w = 245, h = 20,
    action = function()  
      state.options.controlScheme = 2
  end,
  up = 1, down = 3, left = 7, right = 7,
  },

  {text = "Radial Gamepad Controls", x = 100, y = 225, w = 180, h = 20,
    action = function()  
      state.options.controlScheme = 3
  end,
  up = 2, down = 4, left = 7, right = 7,
  },

  {text = "Eight-directional Gamepad Controls", x = 100, y = 275, w = 245, h = 20,
    action = function()  
      state.options.controlScheme = 4
  end,
  up = 3, down = 5, left = 7, right = 7,
  },
  
  {text = "Radial Joystick Controls", x = 100, y = 325, w = 165, h = 20,
    action = function()  
      state.options.controlScheme = 5
  end,
  up = 4, down = 6, left = 7, right = 7,
  },

  {text = "Omni-directional Joystick Controls", x = 100, y = 375, w = 230, h = 20,
    action = function()  
      state.options.controlScheme = 6
  end,
  up = 5, down = 1, left = 7, right = 7,
  },
  
  
  
  {text = "Easy", x = 500, y = 200, w = 75, h = 20,
    action = function()
      state.options.difficulty = 1
  end,
  up = 10, down = 8, left = 1, right = 1,
  },
  
  {text = "Normal", x = 500, y = 250, w = 60, h = 20,
    action = function() 
      state.options.difficulty = 2
  end,
  up = 7, down = 9, left = 1, right = 1,
  },
  
  {text = "Hard", x = 500, y = 300, w = 75, h = 20,
    action = function() 
      state.options.difficulty = 3
  end,
  up = 8, down = 10, left = 1, right = 1,
  },
  
  {text = "Insane", x = 500, y = 350, w = 75, h = 20,
    action = function() 
      state.options.difficulty = 4
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
    local controlsOption = s.options[state.options.controlScheme]
    local difficultyOption = s.options[state.options.difficulty + 6]
    love.graphics.setColor(s.highlightColor)
    love.graphics.circle(love.draw_fill, controlsOption.x - 30, controlsOption.y - 4, 8, 32)
    love.graphics.circle(love.draw_fill, difficultyOption.x - 30, difficultyOption.y - 4, 8, 32)
    love.graphics.setColor(s.normalColor)
    love.graphics.line(400,425,400,600)
    love.graphics.line(400,425,000,425)
    love.graphics.line(650,75,000,75)
    love.graphics.line(650,75,650,600)
  end
}

state.options = getMenu(opts, supplemental)

if state.options.difficulty == nil then state.options.difficulty = 2 end
if state.options.controlScheme == nil then state.options.controlScheme = 1 end

state.options.save = function(self)
  local savePath = "options"
  local diff = "state.options.difficulty = " .. tostring(self.difficulty) .. "\n"
  local ctrl = "state.options.controlScheme = " .. tostring(self.controlScheme) .. "\n"
  
  local saveFile = love.filesystem.newFile(savePath, love.file_write)
  love.filesystem.open(saveFile)
  love.filesystem.write(saveFile, diff)
  love.filesystem.write(saveFile, ctrl)
  love.filesystem.close(saveFile)
end

state.options.load = function(self)
  local savePath = "options"
  if love.filesystem.exists(savePath) then love.filesystem.include(savePath) end
end

