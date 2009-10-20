love.filesystem.require("util/geom.lua")
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
  
  -- distanceFunction(currentNode, endingNode) should be the best estimate we have of how far currentNode is from endingNode
  -- make sure distanceFunction(currentNode) is never greater than the true distance; underestimating is ok
  shortestPath = function(self, startingNode, endingNode, distanceFunction)
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
      openSetIndex[current] = nil
      
      if current == endingNode then 
        -- woohoo! you found it! TODO: Work out the path using blah.previous and then return it
      else
        closedSet[current] = true
        for arcK, arcV in pairs(current.arcs) do
          if not closedSet[arcV] then
            local nextNode = arcV.head
            local tentativeTravelled = travelled[current] + arcV.weight
            
            if openSetIndex[nextNode] == nil then
              travelled[nextNode] = tentativeTravelled
              heuristic[nextNode] = distanceFunction(nextNode, endingNode)
              nextNode.priority = travelled[nextNode] + heuristic[nextNode]
              openSet:insert(nextNode)
              openSetIndex[nextNode] = true
              nextNode.previous = current
            elseif tentativeTravelled < travelled[nextNode] then
              travelled[nextNode] = tentativeTravelled
              nextNode.priority = travelled[nextNode] + heuristic[nextNode]
              -- TODO: raise priority of nextNode
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