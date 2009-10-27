NAME=adrift
# one of win,osx,linux
OS=linux
include Makefile.$(OS) 


#.SILENT:

all: clean tests build run

clean:
	$(RM) $(NAME).love

# Not sure how to make this run over each test_*.lua file because I am 
# makefile-stupid
#
# Also, the lunity output needs to get aggregated for all of them... not sure 
# how that should go either
tests:
	cd test && $(LUA) test_Explosion.lua
	cd test && $(LUA) test_Geom.lua
	cd test && $(LUA) test_Poly.lua
	cd test && $(LUA) test_Triangle.lua
	cd test && $(LUA) test_QuadTree.lua

build: clean
	cd love && $(ZIP) ../$(NAME).zip .
	mv $(NAME).zip $(NAME).love

run: build
	$(LOVE) $(NAME).love	
