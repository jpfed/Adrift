# This is OSX specific in places (open, etc.) but might be useful?
NAME=adrift
LUA=lua

#.SILENT:

all: clean tests build run

clean:
	rm -f $(NAME).love

tests:
	# Not sure how to make this run over each test_*.lua file because I am 
	# makefile-stupid
	cd test && $(LUA) test_Explosion.lua
	cd test && $(LUA) test_Geom.lua
	cd test && $(LUA) test_Triangle.lua

build: clean
	cd love && zip -q -r ../$(NAME).zip .
	mv $(NAME).zip $(NAME).love

run: build
	open $(NAME).love	
