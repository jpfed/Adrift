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
      local func = assert(loadstring("return " .. s.input))
      logger:add(tostring(func()))
      s.input = ""
    elseif key == love.key_backspace then
      s.input = s.input:sub(1, s.input:len() - 1)
    elseif key < 200 then
      s.input = s.input .. string.char(key)
    end
  end
}

