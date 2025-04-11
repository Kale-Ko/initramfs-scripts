#!/usr/bin/make -f

BUILD_PATH=openssh-wifi-initramfs/

build:
	dpkg-buildpackage $(BUILD_PATH)

install: build
	sudo dpkg --remove openssh-wifi-initramfs
	sudo dpkg --install $$(cat openssh-wifi-initramfs/debian/files | grep -o *.deb) || sudo dpkg --configure --pending

clean:
	rm -rf $(BUILD_PATH)/debian/.debhelper $(BUILD_PATH)/debian/debhelper-build-stamp $(BUILD_PATH)/debian/openssh-wifi-initramfs $(BUILD_PATH)/debian/files $(BUILD_PATH)/debian/*.substvars
