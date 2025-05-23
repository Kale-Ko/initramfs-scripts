#!/usr/bin/make -f

build: build-wireless build-openssh build-ssh-tpm-agent

build-wireless:
	cd wireless-initramfs/ && dpkg-buildpackage

build-openssh: openssh-initramfs/out/cryptroot-unlock-suid
	cd openssh-initramfs/ && dpkg-buildpackage

openssh-initramfs/out/cryptroot-unlock-suid: openssh-initramfs/cryptroot-unlock-suid.cpp
	mkdir -p openssh-initramfs/out/
	g++ -O3 -s openssh-initramfs/cryptroot-unlock-suid.cpp -o openssh-initramfs/out/cryptroot-unlock-suid

build-ssh-tpm-agent:
	cd ssh-tpm-agent/ && dpkg-buildpackage

install-default: build-wireless build-openssh
	sudo dpkg --install $$(cat wireless-initramfs/debian/files | grep -Eo '.*\.deb') $$(cat openssh-initramfs/debian/files | grep -Eo '.*\.deb') || sudo dpkg --configure --pending

install-all: build-wireless build-openssh build-ssh-tpm-agent
	sudo dpkg --install $$(cat wireless-initramfs/debian/files | grep -Eo '.*\.deb') $$(cat openssh-initramfs/debian/files | grep -Eo '.*\.deb') $$(cat ssh-tpm-agent/debian/files | grep -Eo '.*\.deb') || sudo dpkg --configure --pending

install-wireless: build-wireless
	sudo dpkg --install $$(cat wireless-initramfs/debian/files | grep -Eo '.*\.deb') || sudo dpkg --configure --pending

install-openssh: build-openssh
	sudo dpkg --install $$(cat openssh-initramfs/debian/files | grep -Eo '.*\.deb') || sudo dpkg --configure --pending

install-ssh-tpm-agent: build-ssh-tpm-agent
	sudo dpkg --install $$(cat ssh-tpm-agent/debian/files | grep -Eo '.*\.deb') || sudo dpkg --configure --pending

clean: clean-wireless clean-openssh clean-ssh-tpm-agent

cleanall: clean clean-artifacts

clean-wireless:
	rm -rf wireless-initramfs/debian/.debhelper wireless-initramfs/debian/wireless-initramfs.debhelper.log wireless-initramfs/debian/debhelper-build-stamp wireless-initramfs/debian/wireless-initramfs wireless-initramfs/debian/files wireless-initramfs/debian/*.substvars

clean-openssh:
	rm -rf openssh-initramfs/debian/.debhelper openssh-initramfs/debian/openssh-initramfs.debhelper.log openssh-initramfs/debian/debhelper-build-stamp openssh-initramfs/debian/openssh-initramfs openssh-initramfs/debian/files openssh-initramfs/debian/*.substvars

clean-ssh-tpm-agent:
	rm -rf ssh-tpm-agent/debian/.debhelper ssh-tpm-agent/debian/ssh-tpm-agent.debhelper.log ssh-tpm-agent/debian/debhelper-build-stamp ssh-tpm-agent/debian/ssh-tpm-agent ssh-tpm-agent/debian/files ssh-tpm-agent/debian/*.substvars

clean-artifacts:
	rm -rf */out/
	rm -f wireless-initramfs_*.tar.gz wireless-initramfs_*.deb wireless-initramfs_*.buildinfo wireless-initramfs_*.changes wireless-initramfs_*.dsc
	rm -f openssh-initramfs_*.tar.gz openssh-initramfs_*.deb openssh-initramfs_*.buildinfo openssh-initramfs_*.changes openssh-initramfs_*.dsc
	rm -f ssh-tpm-agent_*.tar.gz ssh-tpm-agent_*.deb ssh-tpm-agent_*.buildinfo ssh-tpm-agent_*.changes ssh-tpm-agent_*.dsc

ARCH=$(shell dpkg --print-architecture)

pull-ssh-tpm-agent:
	@ mkdir -p tmp/
	curl -sSL https://api.github.com/repos/Foxboron/ssh-tpm-agent/releases/latest -o tmp/ssh-tpm-agent-releases.json
	curl -sSL $$(cat tmp/ssh-tpm-agent-releases.json | jq -r '.assets[] | select(.name | test("^ssh-tpm-agent-v[0-9.-_]+-linux-${ARCH}\\.tar\\.gz$$")) | .browser_download_url') -o tmp/ssh-tpm-agent.tar.gz
	@ mkdir -p ssh-tpm-agent/usr/bin/${ARCH}/
	tar -xzf tmp/ssh-tpm-agent.tar.gz -C ssh-tpm-agent/usr/bin/${ARCH}/ --strip-components 1
	@ rm -f tmp/ssh-tpm-agent-releases.json tmp/ssh-tpm-agent.tar.gz
	@ rmdir tmp/
	find ssh-tpm-agent/usr/bin/${ARCH} -type f ! -name LICENSE -exec strip --strip-all {} \;

pull-ssh-tpm-agent-multiarch:
	@ mkdir -p tmp/
	curl -sSL https://api.github.com/repos/Foxboron/ssh-tpm-agent/releases/latest -o tmp/ssh-tpm-agent-releases.json
	curl -sSL $$(cat tmp/ssh-tpm-agent-releases.json | jq -r '.assets[] | select(.name | test("^ssh-tpm-agent-v[0-9.-_]+-linux-amd64\\.tar\\.gz$$")) | .browser_download_url') -o tmp/ssh-tpm-agent-amd64.tar.gz
	curl -sSL $$(cat tmp/ssh-tpm-agent-releases.json | jq -r '.assets[] | select(.name | test("^ssh-tpm-agent-v[0-9.-_]+-linux-arm64\\.tar\\.gz$$")) | .browser_download_url') -o tmp/ssh-tpm-agent-arm64.tar.gz
	@ mkdir -p ssh-tpm-agent/usr/bin/amd64/ ssh-tpm-agent/usr/bin/arm64/
	tar -xzf tmp/ssh-tpm-agent-amd64.tar.gz -C ssh-tpm-agent/usr/bin/amd64/ --strip-components 1
	tar -xzf tmp/ssh-tpm-agent-arm64.tar.gz -C ssh-tpm-agent/usr/bin/arm64/ --strip-components 1
	@ rm -f tmp/ssh-tpm-agent-releases.json tmp/ssh-tpm-agent-amd64.tar.gz tmp/ssh-tpm-agent-arm64.tar.gz
	@ rmdir tmp/
	find ssh-tpm-agent/usr/bin/amd64 -type f ! -name LICENSE -exec x86_64-linux-gnu-strip --strip-all {} \;
	find ssh-tpm-agent/usr/bin/arm64 -type f ! -name LICENSE -exec aarch64-linux-gnu-strip --strip-all {} \;
