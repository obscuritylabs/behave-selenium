current_dir = $(shell pwd)
image_name = behave-selenium

build :
	docker build -t $(image_name) .

run : 
	docker run --rm -it -v $(current_dir):/behave $(image_name)

exec :
	docker run --rm -it -v $(current_dir):/behave --entrypoint /bin/bash $(image_name)