#!/usr/bin/make -f

BUILD_PATH=openssh-wifi-initramfs/

build:
	dpkg-buildpackage $(BUILD_PATH)

clean:
	rm -rf $(BUILD_PATH)/debian/.debhelper $(BUILD_PATH)/debian/debhelper-build-stamp $(BUILD_PATH)/debian/openssh-wifi-initramfs $(BUILD_PATH)/debian/files $(BUILD_PATH)/debian/*.substvars
