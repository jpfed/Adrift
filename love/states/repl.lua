state.repl = {
  history = {},
  
  start = function(s)
    s.input = ""
    s.historyCursor = #s.history
  end,

  draw = function(s) 
    local str = "repl: " .. s.input
    love.graphics.draw(str,10,500)
  end,

  keypressed = function(s,key) 
    if key == love.key_return then
      local isValidFunction, value = s:tryExecuting("return " .. s.input)
      if isValidFunction then
        logger:add(tostring(value))
      else
        local isValidProcedure, val = s:tryExecuting(s.input)
        logger:add(tostring(val))
      end
      table.insert(s.history, s.input)
      s.historyCursor = #s.history
      s:save(s.input)
      s.input = ""
    elseif key == love.key_up then
      if s.historyCursor > 0 and s.historyCursor <= #s.history then s.input = s.history[s.historyCursor] end
      s.historyCursor = math.max(1,s.historyCursor - 1)
    elseif key == love.key_down then
      s.historyCursor = math.min(s.historyCursor + 1, #s.history)
      if s.historyCursor > 0 and s.historyCursor <= #s.history then s.input = s.history[s.historyCursor] end
    elseif key == love.key_backspace then
      s.input = s.input:sub(1, s.input:len() - 1)
    elseif key < 200 then
      local toAdd = string.char(key)
      if love.keyboard.isDown(love.key_lshift) or love.keyboard.isDown(love.key_rshift) then
        toAdd = s.shiftMap[toAdd]
      end
      s.input = s.input .. toAdd
    end
  end,
  
  tryExecuting = function(s,input)
    local validFunc, errorMessage = loadstring(input)
    if validFunc then
      local status, value = pcall(validFunc)
      if status then
        return true, tostring(value)
      else
        return false, "Evaluation failed: " .. value
      end
    else
      return false, "Compilation failed" .. errorMessage
    end
  end
}



state.repl.shiftMap = {}
local sm = state.repl.shiftMap

sm["1"] = "!"
sm["2"] = "@"
sm["3"] = "#"
sm["4"] = "$"
sm["5"] = "%"
sm["6"] = "^"
sm["7"] = "&"
sm["8"] = "*"
sm["9"] = "("
sm["0"] = ")"
sm["-"] = "_"
sm["="] = "+"
sm["\\"] = "|"
sm["["] = "{"
sm["]"] = "}"
sm[";"] = ":"
sm["'"] = "\""
sm[","] = "<"
sm["."] = ">"
sm["/"] = "?"

-- translate small letter + shift into capital letter
for asciiCode = 97,122 do
  sm[string.char(asciiCode)] = string.char(asciiCode - 32)
end

state.repl.save = function(self, value)
  local savePath = "repl"
  local saveFile 
  if love.filesystem.exists(savePath) then 
    saveFile = love.filesystem.newFile(savePath, love.file_append)
  else
    saveFile = love.filesystem.newFile(savePath, love.file_write)
  end
  love.filesystem.open(saveFile)
  love.filesystem.write(saveFile, "table.insert(state.repl.history, \"" .. value .. "\")\n")
  love.filesystem.close(saveFile)
end

state.repl.load = function(self)
  local savePath = "repl"
  if love.filesystem.exists(savePath) then love.filesystem.include(savePath) end
end
