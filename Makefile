.PHONY: all custom

all: clean
	mkdir -p build
	docker build -t rpi-rt-linux .
	docker rm tmp-rpi-rt-linux || true
	docker run --privileged --name tmp-rpi-rt-linux rpi-rt-linux /raspios/build.sh
	docker cp tmp-rpi-rt-linux:/raspios/build/ ./
	docker rm tmp-rpi-rt-linux

custom:
	docker run --rm --privileged -it rpi-rt-linux bash

clean:
	rm -fr build
