.PHONY: all custom

all: clean
	cp Dockerfiles/Dockerfile-newer Dockerfile
	$(MAKE) build

Pi1 Pi2 PiZero PiCM1: clean
	cp Dockerfiles/Dockerfile-older Dockerfile
	$(MAKE) build

Pi3 Pi4 Pi400 PiZero2 PiCM3 PiCM4: clean
	cp Dockerfiles/Dockerfile-newer Dockerfile
	$(MAKE) build

build:
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
	rm Dockerfile || true
