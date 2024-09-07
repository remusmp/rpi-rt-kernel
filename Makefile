.PHONY: all custom

# Default build for Pi5
all: clean Pi5

# 64 bits
Pi3 Pi4 Pi400 PiZero2 PiCM3 PiCM4: clean
	$(MAKE) build \
		raspios=raspios_lite_arm64 \
		defconfig=bcm2711_defconfig \
		kernel=kernel8 \
		arch=arm64 \
		compiler=aarch64-linux-gnu- \
		target=$@

Pi5: clean
	$(MAKE) build \
		raspios=raspios_lite_arm64 \
		defconfig=bcm2712_defconfig \
		kernel=kernel_2712 \
		arch=arm64 \
		compiler=aarch64-linux-gnu- \
		target=$@

# 32 bits
Pi1 PiZero PiCM1: clean
	$(MAKE) build \
		raspios=raspios_lite_armhf \
		defconfig=bcmrpi_defconfig \
		kernel=kernel \
		arch=arm \
		compiler=arm-linux-gnueabihf- \
		target=$@

Pi2: clean
	$(MAKE) build \
		raspios=raspios_lite_armhf \
		defconfig=bcm2709_defconfig \
		kernel=kernel7 \
		arch=arm \
		compiler=arm-linux-gnueabihf- \
		target=$@

Pi3-32 PiCM3-32 PiZero2-32: clean Pi2

Pi4-32 Pi400-32 PiCM4-32: clean
	$(MAKE) build \
		raspios=raspios_lite_armhf \
		defconfig=bcm2711_defconfig \
		kernel=kernel7l \
		arch=arm \
		compiler=arm-linux-gnueabihf- \
		target=$@

build:
	mkdir -p build
	docker build \
		--build-arg RASPIOS=$(raspios) \
		--build-arg DEFCONFIG=$(defconfig) \
		--build-arg KERNEL=$(kernel) \
		--build-arg ARCH=$(arch) \
		--build-arg CROSS_COMPILE=$(compiler) \
		--build-arg TARGET=$(target) \
		-t rpi-rt-linux .
	docker rm tmp-rpi-rt-linux || true
	docker run --privileged --name tmp-rpi-rt-linux rpi-rt-linux /raspios/build.sh
	docker cp tmp-rpi-rt-linux:/raspios/build/ ./
	docker rm tmp-rpi-rt-linux

custom:
	docker run --rm --privileged -it rpi-rt-linux bash

clean:
	rm -fr build
