require("util/geom.lua")

util = {
  randomVector = function(len, smoothing) 
  local result = {}
    local prevElement = 0
    for element = 1,len do
      local newElement = math.random()*(1-smoothing) + prevElement*smoothing
      table.insert(result, newElement)
      prevElement = newElement
    end
    return result
  end,
  
  interpolate = function(first, last, progress)
    return last*progress + first*(1-progress)
  end,
  
  interpolate2d = function(first, last, progress)
    return {x = util.interpolate(first.x,last.x,progress), y=util.interpolate(first.y,last.y,progress)}
  end,
  
  interpolatedVector = function(vec, pos)
    local len = table.getn(vec)
    local prevVal = math.max(1,math.floor(pos))
    local postVal = math.min(len,math.ceil(pos))
    local progress = pos - prevVal
    return util.interpolate(vec[prevVal],vec[postVal],progress)
  end
  
}
