levelGenerator = {
  margin = 1,
  maxCol = 100,
  maxRow = 100,
  minNodeRadius = 30,
  maxNodeRadius = 100,
  minArcThickness = 5,
  maxArcThickness = 20,
}
getLevel = function(difficulty)
  local enemyProbability = 1-math.exp(-difficulty/10)
  local powerupProbability = (0.25 + math.exp(-difficulty/20))/2
  
  local _nodes = {}
  local _arcs = {}
  
  local start = createNode(-1000,-1000,1000,-1000)
  start.startingSpot = true
  start.dist = 0
  table.insert(_nodes, start)
  
  local elaboration = 1
  local tries = 0
  local maxTries = 1000
  local minStep = 25
  local maxStep = 100
  while elaboration<difficulty do
    local oIndex = math.random(table.getn(_nodes))
    local origin = _nodes[oIndex]
 
    local angle = 2*math.random()*math.pi
    local dist = math.random()*(maxStep-minStep) + minStep
    local x,y = origin.x + dist*math.cos(angle), origin.y + dist*math.sin(angle)

    local target = createNode(x,y,x,y)
    if math.random()<enemyProbability then target.enemy = true end
    if math.random()<powerupProbability then target.powerup = true end
    
    target.dist = origin.dist + 1
    local path = createArc(origin, target)
    
    if noIntersections(_arcs, {path}) and enoughDistance(_nodes, _arcs, target, path, minStep) then
      table.insert(_nodes,target)
      table.insert(_arcs,path)
      elaboration = elaboration + 1
    else
      tries = tries + 1
      if tries > maxTries then 
        elaboration = elaboration + 1
        tries = 0
      end
    end
  end
  
  -- add a few random connections just to be interesting
  local cycles = 0
  local maxCycles = 6
  tries = 0
  while cycles<maxCycles do
    local niA = _nodes[math.random(table.getn(_nodes))]
    local niB
    repeat
      niB = _nodes[math.random(table.getn(_nodes))]
    until niB~=niA
    
    local cycleArc = createArc(niA, niB)
    
    if noIntersections(_arcs, {cycleArc}) and enoughDistance(_nodes, _arcs, nil, cycleArc, minStep) then
      table.insert(_arcs, cycleArc)
      cycles = cycles + 1
    else
      tries = tries + 1
      if tries > maxTries then 
        cycles = cycles + 1
        tries = 0
      end
    end
    
    
  end
  
    -- normalization
  local minX, maxX, minY, maxY = math.huge, -math.huge, math.huge, -math.huge
  local minYindex, maxYindex = -1, -1
  local maxDistIndex, maxDist = -1, -math.huge
  for k,v in ipairs(_nodes) do
    minX, maxX = math.min(minX, v.x-v.radius), math.max(maxX, v.x+v.radius)
    minY, maxY = math.min(minY, v.y-v.radius), math.max(maxY, v.y+v.radius)
    if v.dist > maxDist then
      maxDist = v.dist
      maxDistIndex = k
    end
  end
  
  local sizeX, sizeY = levelGenerator.maxCol - levelGenerator.margin, levelGenerator.maxRow - levelGenerator.margin
  local scaleX, scaleY = sizeX / (maxX-minX), sizeY / (maxY - minY)
  for k,v in ipairs(_nodes) do
    v.x = (v.x-minX) * scaleX + levelGenerator.margin
    v.y = (v.y-minY) * scaleY + levelGenerator.margin
  end
  
  _nodes[maxDistIndex].warpCrystal = true
  camera.x = _nodes[1].x
  camera_y = _nodes[1].y
  local result = {nodes = _nodes, tiles = rasterize(_nodes,_arcs)}
  highlight(result.tiles)
  return result
end



createNode = function(lx,ly,ux,uy)
  local locX, locY = lx, ly
  if lx ~= ux then locX = math.random(lx, ux) end
  if ly ~= uy then locY = math.random(ly, uy) end
  return {x = locX, y = locY, radius = math.random(levelGenerator.minNodeRadius,levelGenerator.maxNodeRadius)/10}
end

createArc = function(tl, hd)
  return {tail = tl, head = hd, thickness = math.random(levelGenerator.minArcThickness,levelGenerator.maxArcThickness)/10}
end


noIntersections = function(arcSet1, arcSet2)
  for k1,v1 in ipairs(arcSet1) do
    for k2,v2 in ipairs(arcSet2) do
      if not (v1.head == v2.head or v1.head == v2.tail or v1.tail == v2.head or v1.tail == v2.tail) then
        if geom.intersection_point_t(v1.head,v1.tail, v2.head,v2.tail, true) ~= nil then return false end
      end
    end
  end
  return true
end

enoughDistance = function(nodeSet, arcSet, node, arc, minDist)
  for k,v in ipairs(nodeSet) do
    if node~=nil and v~=node and geom.distance_t(v,node)<minDist then return false end
    if v~=arc.head and v~=arc.tail and geom.dist_to_line_t(v,arc.head, arc.tail)<minDist then return false end
  end
  for k,v in ipairs(arcSet) do
    if node~=nil and geom.dist_to_line_t(node, v.head, v.tail) < minDist then return false end
  end
  return true
end

rasterize = function(nodes, arcs)
  local result = {}
  
  for col = 1,levelGenerator.maxCol do
    table.insert(result,{})
    for row = 1,levelGenerator.maxRow do
      result[col][row] = 1
    end
  end

  for k,v in ipairs(nodes) do
    local minX, maxX = math.max(1+levelGenerator.margin,math.floor(v.x - v.radius)), math.min(levelGenerator.maxCol-levelGenerator.margin,math.ceil(v.x + v.radius))
    local minY, maxY = math.max(1+levelGenerator.margin,math.floor(v.y - v.radius)), math.min(levelGenerator.maxRow-levelGenerator.margin,math.ceil(v.y + v.radius))
    for x = minX, maxX do
      for y = minY, maxY do
        if geom.distance(v.x,v.y,x,y) <= v.radius then result[x][y] = 0 end
      end
    end
  end
  
  for k,v in ipairs(arcs) do
    local t = 0
    local inc = v.thickness/(2*geom.distance_t(v.head,v.tail))
    while t <= 1 do
      local m = util.interpolate2d(v.head,v.tail,t)
      local minX, maxX = math.max(1+levelGenerator.margin,math.floor(m.x - v.thickness)), math.min(levelGenerator.maxCol-levelGenerator.margin,math.ceil(m.x + v.thickness))
      local minY, maxY = math.max(1+levelGenerator.margin,math.floor(m.y - v.thickness)), math.min(levelGenerator.maxRow-levelGenerator.margin,math.ceil(m.y + v.thickness))
      for x = minX, maxX do
        for y = minY, maxY do
          result[x][y] = 0
        end
      end
      t = t + inc
    end
  end
  
  return result
end

solidify = function(world, tiles)
  local result = {type = "level", rows={}}
  result.body = love.physics.newBody(world,0,0,0)
  for row = 1,levelGenerator.maxRow do
    result.rows[row] = {}
    local wasSolid = false
    local leftMost = 0
    for col = 1,levelGenerator.maxCol+1 do
      local isSolid = (tiles[col]~=nil and tiles[col][row]~=nil and tiles[col][row]>0)
      if isSolid then
        if not wasSolid then
          leftMost = col
        end
      else
        if wasSolid then
          rightMost = col
          local newShape = love.physics.newRectangleShape(result.body,(leftMost+rightMost)/2,row+0.5,rightMost-leftMost,1)
          newShape:setRestitution(0.25)
          newShape:setData(result)
          table.insert(result.rows[row], newShape)
        end
      end
      wasSolid = isSolid
    end
  end
  return result
end

highlight = function(tiles)
  for colK, col in ipairs(tiles) do
    for rowK, square in ipairs(col) do
      if (tiles[colK-1]~=nil and tiles[colK-1][rowK]==0) or 
         (tiles[colK+1]~=nil and tiles[colK+1][rowK]==0) or 
         (tiles[colK][rowK-1]==0) or 
         (tiles[colK][rowK+1]==0) then
          if tiles[colK][rowK] == 1 then tiles[colK][rowK] = 2 end 
      end
    end
  end
end

coloration = function(brightness)
  local strata = {}
  local fineVariations = util.randomVector(levelGenerator.maxRow,0.125)
  local bigVariationsR = util.randomVector(levelGenerator.maxRow/8,0.5)
  local bigVariationsG = util.randomVector(levelGenerator.maxRow/8,0.5)
  local bigVariationsB = util.randomVector(levelGenerator.maxRow/8,0.5)
  for k,v in ipairs(fineVariations) do
    local lumR = brightness*((v*0.25 + util.interpolatedVector(bigVariationsR,k/8)*0.75)*0.625+0.375)
    local lumG = brightness*((v*0.25 + util.interpolatedVector(bigVariationsG,k/8)*0.75)*0.625+0.375)
    local lumB = brightness*((v*0.25 + util.interpolatedVector(bigVariationsB,k/8)*0.75)*0.625+0.375)
    lumR = math.min(1,math.max(0,lumR))
    lumG = math.min(1,math.max(0,lumG))
    lumB = math.min(1,math.max(0,lumB))
    local col1 = love.graphics.newColor(96*lumR,64*lumG,32*lumB)
    local col2 = love.graphics.newColor(196*lumR, 128*lumG, 64*lumB)
    local colors = {normal = col1, highlight = col2}
    table.insert(strata,colors)
  end
  return strata
end

getObjects = function(world, nodeSet, difficulty)
  local result = {}
  for k,v in ipairs(nodeSet) do
    if v.startingSpot then 
      table.insert(result, objects:getStartingSpot(world, v)) 
    end
    if v.warpCrystal then 
      table.insert(result, objects:getWarpCrystal(world, v)) 
    end
    if v.enemy then 
      table.insert(result, objects:getEnemy(world, v, difficulty)) 
    end
    if v.powerup then 
      table.insert(result, objects:getPowerup(world, v, difficulty)) 
    end
  end
  
  return result
end
