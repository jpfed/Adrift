# This is OSX specific in places (open, etc.) but might be useful?
NAME=adrift
LUA=lua

#.SILENT:

all: clean tests build run

clean:
	rm $(NAME).love

tests:
	cd test && $(LUA) test_Explosion.lua

build: clean
	cd love && zip -q -r ../$(NAME).zip .
	mv $(NAME).zip $(NAME).love

run: build
	open $(NAME).love	
