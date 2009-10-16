RepresentableAsImage = {
  image = {},
  imageSize = 1,
  draw = function(o) 
    local x,y,scale = L:xy(o.x,o.y,0)
    if o.angle == nil then 
      love.graphics.draw(o.image,x,y,0,scale/(25*o.imageSize))
    else
      love.graphics.draw(o.image,x,y,o.angle,scale/(25*o.imageSize))
    end
  end
}

