# This is OSX specific in places (open, etc.) but might be useful?
NAME=adrift

all: clean test build run

clean:
	rm $(NAME).love

test:
	echo "Yeah, right..."

build: clean
	cd love && zip -q -r ../$(NAME).zip .
	mv $(NAME).zip $(NAME).love

run: build
	open $(NAME).love	
