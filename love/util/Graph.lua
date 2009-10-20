love.filesystem.require("util/geom.lua")
love.filesystem.require("oo.lua")

Graph = {

  addNode = function(self)
    local n = GraphNode:create()
    table.insert(self.nodes, n)
    return n
  end,
  
  addArc = function(self, tail, head, weight)
    local a = GraphArc:create(head, tail)
    table.insert(self.arcs, a)
    table.insert(tail.arcs, a)
    a.weight = weight
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
  create = function(self, tailNode, headNode)
    return {head = headNode, tail = tailNode}
  end
}