Graph = {

  create = function(self, numNodes)
    local result = {nodes = {}, arcs = {}}
    
    local numArcs = (1 + 2*completeness)*numNodes

    for highNodeIndex = 1,numNodes do
      local highNode = GraphNode:create()
      table.insert(result.nodes, highNode)
      for lowNodeIndex = 1,highNodeIndex-1 do
        local lowNode = result.nodes[lowNodeIndex]
        local possibleArc = GraphArc:create(lowNode,highNode)
        local len = geom.length(lowNode, highNode)
        local conflicts = {}
        local allowArc = true
        for k,v in pairs(result.arcs) do
          if geom.intersectionPoint(v.tail, v.head, lowNode, highNode, false) ~= nil then
            if geom.length(v.tail, v.head) < len then 
              allowArc = false
              break
            else
              table.insert(conflicts, v)
            end
          end
        end
        if allowArc then
          for k,v in pairs(conflicts) do
            table.remove(result.arcs, conflicts)
          end
          table.insert(result.arcs, possibleArc)
        end
      end
    end
    
  end
}

GraphNode = {
  create = function(self)
    return {x = math.random(), y = math.random()}
  end
}

GraphArc = {
  create = function(self, headNode, tailNode)
    return {head = headNode, tail = tailNode}
  end
}