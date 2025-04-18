#!/usr/bin/make -f

build:
	dpkg-buildpackage wifi-initramfs/
	dpkg-buildpackage openssh-initramfs/
	dpkg-buildpackage openssh-tpm-initramfs/

install: build
	sudo dpkg --install $$(cat wifi-initramfs/debian/files | grep -Eo '.*\.deb') $$(cat openssh-initramfs/debian/files | grep -Eo '.*\.deb') || sudo dpkg --configure --pending

installall: build
	sudo dpkg --install $$(cat wifi-initramfs/debian/files | grep -Eo '.*\.deb') $$(cat openssh-initramfs/debian/files | grep -Eo '.*\.deb') $$(cat openssh-tpm-initramfs/debian/files | grep -Eo '.*\.deb') || sudo dpkg --configure --pending

clean:
	rm -rf wifi-initramfs/debian/.debhelper wifi-initramfs/debian/debhelper-build-stamp wifi-initramfs/debian/wifi-initramfs wifi-initramfs/debian/files wifi-initramfs/debian/*.substvars
	rm -rf openssh-initramfs/debian/.debhelper openssh-initramfs/debian/debhelper-build-stamp openssh-initramfs/debian/openssh-initramfs openssh-initramfs/debian/files openssh-initramfs/debian/*.substvars
	rm -rf openssh-tpm-initramfs/debian/.debhelper openssh-tpm-initramfs/debian/debhelper-build-stamp openssh-tpm-initramfs/debian/openssh-tpm-initramfs openssh-tpm-initramfs/debian/files openssh-tpm-initramfs/debian/*.substvars

cleanartifacts:
	rm -f wifi-initramfs_*.tar.gz wifi-initramfs_*.deb wifi-initramfs_*.buildinfo wifi-initramfs_*.changes wifi-initramfs_*.dsc
	rm -f openssh-initramfs_*.tar.gz openssh-initramfs_*.deb openssh-initramfs_*.buildinfo openssh-initramfs_*.changes openssh-initramfs_*.dsc
	rm -f openssh-tpm-initramfs_*.tar.gz openssh-tpm-initramfs_*.deb openssh-tpm-initramfs_*.buildinfo openssh-tpm-initramfs_*.changes openssh-tpm-initramfs_*.dsc

cleanall: clean cleanartifacts

pull:
	curl -sSL https://api.github.com/repos/Foxboron/ssh-tpm-agent/releases/latest -o .ssh-tpm-agent-releases.json
	curl -sSL $$(cat .ssh-tpm-agent-releases.json | jq -r '.assets[] | select(.name | test("^ssh-tpm-agent-v[0-9.-_]+-linux-amd64\\.tar\\.gz$$")) | .browser_download_url') -o .ssh-tpm-agent.tar.gz
	rm -rf openssh-tpm-initramfs/usr/share/ssh-tpm-agent/
	mkdir -p openssh-tpm-initramfs/usr/share/ssh-tpm-agent/
	tar -xzf .ssh-tpm-agent.tar.gz -C openssh-tpm-initramfs/usr/share/ssh-tpm-agent/ --strip-components 1
	rm -f .ssh-tpm-agent-releases.json .ssh-tpm-agent.tar.gz