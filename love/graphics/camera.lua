camera = {

  width = 32,
  x = 0,
  y = 0,
  z = -24,

  EXPLORED = 1000,
  solidMapColor = love.graphics.newColor(64,64,128),
  wallMapColor = love.graphics.newColor(112,112,168),
  
  colors = {
    love.graphics.newColor(0,0,0),
    love.graphics.newColor(96,64,32),
    love.graphics.newColor(192,128,64),
  },
  
  render = function(c,plane, planeZ, levelColors)
    
    local zDiff = planeZ - c.z
    
    local fovX = (c.width/2)*(zDiff/24)
    local fovY = fovX*0.75
    
    local minX, maxX = math.max(1,math.floor(c.x - fovX)), math.min(table.getn(plane),math.ceil(c.x + fovX))
    local minY, maxY = math.max(1,math.floor(c.y - fovY)), math.min(table.getn(plane[minX]),math.ceil(c.y + fovY))
    
    for col = minX, maxX do
      local column = plane[col]
      local xVal = 800*(col - c.x)/fovX + 400
      for square = minY,maxY do
        if column[square]~=nil then
          local yVal = 800*(square - c.y)/fovX + 300
          if column[square] > 0 and column[square] ~= c.EXPLORED then
            if column[square]==1 or column[square]==(1+c.EXPLORED) then
              love.graphics.setColor(levelColors[square].normal)
              column[square] = 1 + c.EXPLORED
            elseif column[square]==2 or column[square]==(2+c.EXPLORED) then
              love.graphics.setColor(levelColors[square].highlight)
              column[square] = 2 + c.EXPLORED
            end
            love.graphics.rectangle(love.draw_fill,xVal,yVal,800/fovX,800/fovX)
          end
        end
      end
    end
  end,

  renderMap = function(c,tiles, displayFull) 
    local tlx,tly, sc = c:xyMap(1,1)
    local brx,bry, sc = c:xyMap(L.maxCol,L.maxRow)
    local subsampling = 1
    sc = sc * subsampling
    for col = 1,L.maxCol,subsampling do
      local column = tiles[col]
      local xVal = util.interpolate(tlx,brx,col/L.maxCol)
      for square = 1,L.maxRow,subsampling do
        if column[square]~=nil and (column[square] >= c.EXPLORED or displayFull) then
          local yVal = util.interpolate(tly,bry,square/L.maxRow)
          local sq = column[square] % c.EXPLORED
          if sq == 1 then
            love.graphics.setColor(c.solidMapColor)
            love.graphics.rectangle(love.draw_fill,xVal,yVal,sc,sc)
          elseif sq == 2 then
            love.graphics.setColor(c.wallMapColor)
            love.graphics.rectangle(love.draw_fill,xVal,yVal,sc,sc)
          end
        end
      end
    end
  end,
  
  xy = function(c, wx, wy, wz)
    if wx == nil or wy == nil then return 0,0,1 end
    local zDiff = wz - c.z
    local fovX = (c.width/2)*(zDiff/24)
    return 800*(wx - c.x)/fovX + 400, 800*(wy - c.y)/fovX + 300, 800/fovX
  end,
  
  xyMap = function(c, wx, wy)
    if wx == nil or wy == nil then return 0,0,1 end
    local tilesAspectRatio = L.maxCol / L.maxRow
    local mapAspectRatio = 800/600
    local xOffset, yOffset, scale
    
    if tilesAspectRatio > mapAspectRatio then
      scale = 800/L.maxCol
      xOffset = 0
      yOffset = (600-L.maxRow*scale)/2
    elseif tilesAspectRatio == mapAspectRatio then
      scale = 600/L.maxRow
      xOffset = 0
      yOffset = 0
    else
      scale = 600/L.maxRow
      xOffset = (800-L.maxCol*scale)/2
      yOffset = 0
    end
    
    return (wx-1)*scale + xOffset, (wy-1)*scale + yOffset, scale
  end
}
