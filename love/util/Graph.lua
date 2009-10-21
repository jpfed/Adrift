love.filesystem.require("util/geom.lua")
love.filesystem.require("util/PriorityQueue.lua")
love.filesystem.require("oo.lua")

Graph = {

  addNode = function(self)
    local n = GraphNode:create()
    table.insert(self.nodes, n)
    return n
  end,
  
  addArc = function(self, tail, head, weight)
    local a = GraphArc:create(head, tail, weight)
    table.insert(self.arcs, a)
    table.insert(tail.arcs, a)
    return a
  end,

  create = function(self)
    local result = {nodes = {}, arcs = {}}
    mixin(result, Graph)
    result.class = Graph
    
    return result
  end,
  
  defaultDistanceFunction = function(startingNode, endingNode)
    return 0
  end,
  
  -- distanceFunction(currentNode, endingNode) should be the best estimate we have of how far currentNode is from endingNode
  -- make sure distanceFunction(currentNode) is never greater than the true distance; underestimating is ok
  shortestPath = function(self, startingNode, endingNode, distanceFunction)
    if distanceFunction == nil then distanceFunction = Graph.defaultDistanceFunction end
    closedSet = {}
    openSetIndex = {}
    openSet = PriorityQueue:create()
    openSet:insert(startingNode)
    openSetIndex[startingNode] = true
    
    local travelled, heuristic = {}, {}, {}
    travelled[startingNode] = 0
    heuristic[startingNode] = distanceFunction(startingNode, endingNode)
    startingNode.priority = travelled[startingNode] + heuristic[startingNode]
    
    while openSet:checkTop() ~= nil do
      local current = openSet:removeTop()
      
      if current == endingNode then 
        
        -- woohoo! you found it!
        local path, reversePath = {},{}
        while current ~= nil do
          table.insert(reversePath, current)
          current = current.previous
        end
        
        for k = #reversePath,1,-1 do
          table.insert(path, reversePath[k])
        end
        
        return path 
        
      else
        closedSet[current] = true
        for arcK, arcV in pairs(current.arcs) do
          if not closedSet[arcV.head] then
            local nextNode = arcV.head
            local tentativeTravelled = travelled[current] + arcV.weight
            
            local inOpenSet = openSet:indexOf(nextNode) ~= nil
            
            if not inOpenSet then
              travelled[nextNode] = tentativeTravelled
              heuristic[nextNode] = distanceFunction(nextNode, endingNode)
              
              nextNode.priority = travelled[nextNode] + heuristic[nextNode]
              openSet:insert(nextNode)
              
              nextNode.previous = current
              
            elseif tentativeTravelled < travelled[nextNode] then
              travelled[nextNode] = tentativeTravelled
              
              nextNode.priority = travelled[nextNode] + heuristic[nextNode]
              openSet:priorityRaised(nextNode)
              
              nextNode.previous = current
            end
          end
        end
      end
    end
    return nil
  end,
  
  -- embedding a graph is essentially placing its nodes onto the plane
  embed = function(self)
  
  end
}

GraphNode = {
  create = function(self)
    return {arcs = {}}
  end
}

GraphArc = {
  create = function(self, tailNode, headNode, weight)
    local result = {head = headNode, tail = tailNode, weight = weight}
    if weight == nil then result.weight = 1 end
    return result
  end
}