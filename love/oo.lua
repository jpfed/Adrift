mixin = function(destination, source)
  for k,v in pairs(source) do
    if k == "attributes" then
      if destination.attributes == nil then destination.attributes = {} end
      for ak, av in pairs(v) do
        destination.attributes[ak] = av
      end
    else
      destination[k] = v
    end
  end
end

AisInstanceOfB = function(object, class)
  if object == nil then return false end
  if object == class or object.class == class then return true end
  return AisInstanceOfB(object.super,class)
end

AhasAttributeB = function(object, attrib)
  if object == nil then return false end
  if object.attributes == nil then return false end
  return object.attributes[attrib] ~= nil
end

printall = function(object, name)
  print(name .. ": " .. tostring(object))
  for k,v in pairs(object) do
    print(name .. ": " .. tostring(k) .. ": " .. tostring(v))
  end
end