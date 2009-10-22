state.repl = {
  start = function(s)
    s.input = ""
  end,

  draw = function(s) 
    local str = "repl: " .. s.input
    love.graphics.draw(str,10,500)
  end,

  keypressed = function(s,key) 
    if key == love.key_return then
      local validFunc, errorMessage = loadstring("return " .. s.input)
      if validFunc then
        logger:add(tostring(validFunc()))
      else
        logger:add("Compilation failed: " .. errorMessage)
      end
      s.input = ""
    elseif key == love.key_backspace then
      s.input = s.input:sub(1, s.input:len() - 1)
    elseif key < 200 then
      local toAdd = string.char(key)
      if love.keyboard.isDown(love.key_lshift) or love.keyboard.isDown(love.key_rshift) then
        toAdd = s.shiftMap[toAdd]
      end
      s.input = s.input .. toAdd
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
