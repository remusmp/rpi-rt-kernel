all:
	rm -fr build
	mkdir -p build
	docker build -t custom-linux .
	docker run --privileged --name tmp-custom-linux custom-linux /raspios/build.sh
	docker cp tmp-custom-linux:/raspios/2021-05-07-raspios-buster-armhf-lite.zip ./build/raspios.zip
	docker rm tmp-custom-linux

custom:
	docker run --rm --privileged -it custom-linux bash
