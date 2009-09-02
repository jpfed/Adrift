camera = {

  width = 32,
  x = 0,
  y = 0,
  z = -24,

  colors = {
    love.graphics.newColor(0,0,0),
    love.graphics.newColor(96,64,32),
    love.graphics.newColor(192,128,64),
  },
  
  render = function(c,plane, planeZ)
    love.graphics.setColor(c.colors[2])
    love.graphics.rectangle(love.draw_fill, 0,0,800,600)
    
    local zDiff = planeZ - c.z
    
    local fovX = (c.width/2)*(zDiff/24)
    local fovY = fovX*0.75
    
    local minX, maxX = math.max(1,math.floor(c.x - fovX)), math.min(100,math.ceil(c.x + fovX))
    local minY, maxY = math.max(1,math.floor(c.y - fovY)), math.min(100,math.ceil(c.y + fovY))
    
    for col = minX, maxX do
      local column = plane[col]
      local xVal = 800*(col - c.x)/fovX + 400
      for square = minY,maxY do
        if column[square]~=nil then
          local yVal = 800*(square - c.y)/fovX + 300
          love.graphics.setColor(c.colors[column[square]+1])
          love.graphics.rectangle(love.draw_fill,xVal,yVal,800/fovX,800/fovX)
        end
      end
    end
  end,

  xy = function(c, wx, wy, wz)
    if wx == nil or wy == nil then return 0,0,1 end
    local zDiff = wz - c.z
    local fovX = (c.width/2)*(zDiff/24)
    return 800*(wx - c.x)/fovX + 400, 800*(wy - c.y)/fovX + 300, 800/fovX
  end
}