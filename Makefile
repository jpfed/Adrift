NAME=adrift
# default to osx, feel free to change your ENV variable or make this actually 
# detect OS somehow
OS?=osx
include Makefile.$(OS) 


#.SILENT:

all: clean tests build run

clean:
	$(RM) $(NAME).love

tests:
	cd test && $(LUA) run_console.lua

tests_html:
	cd test && $(LUA) run_html.lua

build: clean
	cd love && $(ZIP) ../$(NAME).zip .
	mv $(NAME).zip $(NAME).love

run: build
	$(LOVE) $(NAME).love	
