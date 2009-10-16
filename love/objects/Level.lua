love.filesystem.require("oo.lua")

-- levelGenerator is now Level
-- getLevel is now Level:create
-- TODO: Change Level refs to state.game.level, or internalize them
-- state.objects is now part of level

Level = {
  margin = 1,
  maxCol = 100,
  maxRow = 100,
  minNodeRadius = 30,
  maxNodeRadius = 100,
  minArcThickness = 5,
  maxArcThickness = 20,

  create = function(self, difficulty, color)
    local r = {}
    mixin(r, Level)
    r.nodes = {}
    r.arcs = {}
    r:generate(difficulty)
    r:rasterize()
    r:highlight()
    if color then r:coloration(color) end
    return r
  end,



  generate = function(level, difficulty)    
    local enemyProbability = 1-math.exp(-difficulty/10)
    local powerupProbability = (0.25 + math.exp(-difficulty/20))/2
    
    local start = level:createNode(-1000,-1000,1000,-1000)
    start.startingSpot = true
    start.dist = 0
    table.insert(level.nodes, start)
    
    local elaboration = 1
    local tries = 0
    local maxTries = 1000
    local minStep = 25
    local maxStep = 100
    while elaboration<difficulty do
      local oIndex = math.random(table.getn(level.nodes))
      local origin = level.nodes[oIndex]
  
      local angle = 2*math.random()*math.pi
      local dist = math.random()*(maxStep-minStep) + minStep
      local x,y = origin.x + dist*math.cos(angle), origin.y + dist*math.sin(angle)

      local target = level:createNode(x,y,x,y)
      if math.random()<enemyProbability then target.enemy = true end
      if math.random()<powerupProbability then target.powerup = true end
      
      target.dist = origin.dist + 1
      local path = level:createArc(origin, target)
      
      if level:noIntersections({path}) and level:enoughDistance(target, path, minStep) then
        table.insert(level.nodes,target)
        table.insert(level.arcs,path)
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
      local niA = level:randomNode()
      local niB
      repeat
        niB = level:randomNode()
      until niB ~= niA
      
      local cycleArc = level:createArc(niA, niB)
      
      if level:noIntersections({cycleArc}) and level:enoughDistance(nil, cycleArc, minStep) then
        table.insert(level.arcs, cycleArc)
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
    for k,v in ipairs(level.nodes) do
      minX, maxX = math.min(minX, v.x-v.radius), math.max(maxX, v.x+v.radius)
      minY, maxY = math.min(minY, v.y-v.radius), math.max(maxY, v.y+v.radius)
      if v.dist > maxDist then
        maxDist = v.dist
        maxDistIndex = k
      end
    end
    
    local sizeX, sizeY = level.maxCol - level.margin, level.maxRow - level.margin
    local scaleX, scaleY = sizeX / (maxX-minX), sizeY / (maxY - minY)
    for k,v in ipairs(level.nodes) do
      v.x = (v.x-minX) * scaleX + level.margin
      v.y = (v.y-minY) * scaleY + level.margin
    end
    
    level.nodes[maxDistIndex].warpCrystal = true
    -- Should this camera stuff really be initialized here? 
    camera.x = level.nodes[1].x
    camera_y = level.nodes[1].y

    return level
  end,

  randomNode = function(level)
    return level.nodes[math.random(table.getn(level.nodes))]
  end,

  createNode = function(level,lx,ly,ux,uy)
    local locX, locY = lx, ly
    if lx ~= ux then locX = math.random(lx, ux) end
    if ly ~= uy then locY = math.random(ly, uy) end
    return {x = locX, y = locY, radius = math.random(level.minNodeRadius,level.maxNodeRadius)/10}
  end,

  createArc = function(level, tl, hd)
    return {tail = tl, head = hd, thickness = math.random(level.minArcThickness,level.maxArcThickness)/10}
  end,


  noIntersections = function(level, arcSet2)
    local arcSet1 = level.arcs
    for k1,v1 in ipairs(arcSet1) do
      for k2,v2 in ipairs(arcSet2) do
        if not (v1.head == v2.head or v1.head == v2.tail or v1.tail == v2.head or v1.tail == v2.tail) then
          if geom.intersection_point_t(v1.head,v1.tail, v2.head,v2.tail, true) ~= nil then return false end
        end
      end
    end
    return true
  end,

  enoughDistance = function(level, node, arc, minDist)
    for k,v in ipairs(level.nodes) do
      if node~=nil and v~=node and geom.distance_t(v,node)<minDist then return false end
      if v~=arc.head and v~=arc.tail and geom.dist_to_line_t(v,arc.head, arc.tail)<minDist then return false end
    end
    for k,v in ipairs(level.arcs) do
      if node~=nil and geom.dist_to_line_t(node, v.head, v.tail) < minDist then return false end
    end
    return true
  end,

  rasterize = function(level)
    local result = {}
    
    for col = 1,level.maxCol do
      table.insert(result,{})
      for row = 1,level.maxRow do
        result[col][row] = 1
      end
    end

    for k,v in ipairs(level.nodes) do
      local minX, maxX = math.max(1+level.margin,math.floor(v.x - v.radius)), math.min(level.maxCol-level.margin,math.ceil(v.x + v.radius))
      local minY, maxY = math.max(1+level.margin,math.floor(v.y - v.radius)), math.min(level.maxRow-level.margin,math.ceil(v.y + v.radius))
      for x = minX, maxX do
        for y = minY, maxY do
          if geom.distance(v.x,v.y,x,y) <= v.radius then result[x][y] = 0 end
        end
      end
    end
    
    for k,v in ipairs(level.arcs) do
      local t = 0
      local inc = v.thickness/(2*geom.distance_t(v.head,v.tail))
      while t <= 1 do
        local m = util.interpolate2d(v.head,v.tail,t)
        local minX, maxX = math.max(1+level.margin,math.floor(m.x - v.thickness)), math.min(level.maxCol-level.margin,math.ceil(m.x + v.thickness))
        local minY, maxY = math.max(1+level.margin,math.floor(m.y - v.thickness)), math.min(level.maxRow-level.margin,math.ceil(m.y + v.thickness))
        for x = minX, maxX do
          for y = minY, maxY do
            result[x][y] = 0
          end
        end
        t = t + inc
      end
    end
    
    level.tiles = result
  end,

  solidify = function(level, world)
    level.world = world
    local result = {type = "level", rows={}}
    result.body = love.physics.newBody(world,0,0,0)
    for row = 1,level.maxRow do
      result.rows[row] = {}
      local wasSolid = false
      local leftMost = 0
      for col = 1,level.maxCol+1 do
        local isSolid = (level.tiles[col]~=nil and level.tiles[col][row]~=nil and level.tiles[col][row]>0)
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
    level.physics = result
  end,

  highlight = function(level)
    local tiles = level.tiles
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
  end,

  coloration = function(level, brightness)
    level.colors = {}
    local fineVariations = util.randomVector(level.maxRow,0.125)
    local bigVariationsR = util.randomVector(level.maxRow/8,0.5)
    local bigVariationsG = util.randomVector(level.maxRow/8,0.5)
    local bigVariationsB = util.randomVector(level.maxRow/8,0.5)
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
      table.insert(level.colors,colors)
    end
  end,

  generateObjects = function(level, difficulty)
    local world = level.world
    local result = {}
    for k,v in ipairs(level.nodes) do
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

}



