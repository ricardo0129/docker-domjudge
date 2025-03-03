#!/bin/sh

set -eu

# These packages will be installed in the root of the container (build-time dependencies).
DEB_PACKAGES=""
# These packages will be installed in the chroot (run-time dependencies).
CHROOT_PACKAGES=""

install_c() {
	DEB_PACKAGES="gcc gcc-9 $DEB_PACKAGES"
	CHROOT_PACKAGES="gcc gcc-9 $DEB_PACKAGES"
}

install_cpp() {
	DEB_PACKAGES="g++ g++-9 $DEB_PACKAGES"
	CHROOT_PACKAGES="g++ g++-9 $DEB_PACKAGES"
}

install_java() {
	DEB_PACKAGES="openjdk-17-jdk-headless $DEB_PACKAGES"
	CHROOT_PACKAGES="openjdk-17-jre-headless $CHROOT_PACKAGES"
}

install_pypy3() {
	DEB_PACKAGES="python3 pypy3 $DEB_PACKAGES"
	CHROOT_PACKAGES="python3 pypy3 $CHROOT_PACKAGES"
}


#install_kotlin() {
#	echo "deb [trusted=yes] https://pc2.ecs.baylor.edu/apt focal main" >> /etc/apt/sources.list
#	echo 'Acquire::https::pc2.ecs.baylor.edu::Verify-Peer "false";
#Acquire::https::pc2.ecs.baylor.edu::Verify-Host "false";' >> /etc/apt/apt.conf.d/80trust-baylor-mirror
#
#	echo "deb [trusted=yes] https://pc2.ecs.baylor.edu/apt focal main" >> ${CHROOT}/etc/apt/sources.list
#	echo 'Acquire::https::pc2.ecs.baylor.edu::Verify-Peer "false";
#Acquire::https::pc2.ecs.baylor.edu::Verify-Host "false";' >> ${CHROOT}/etc/apt/apt.conf.d/80trust-baylor-mirror
#
#	ln -s /usr/lib/kotlinc/bin/kotlinc /usr/bin/kotlinc
#	ln -s /usr/lib/kotlinc/bin/kotlin /usr/bin/kotlin
#
#	/opt/domjudge/judgehost/bin/dj_run_chroot '
#	ln -s /usr/lib/kotlinc/bin/kotlinc /usr/bin/kotlinc
#	ln -s /usr/lib/kotlinc/bin/kotlin /usr/bin/kotlin
#	'
#
#	DEB_PACKAGES="icpc-kotlinc $DEB_PACKAGES"
#	CHROOT_PACKAGES="icpc-kotlinc $CHROOT_PACKAGES"
#}

install_csharp() {
	DEB_PACKAGES="mono-devel $DEB_PACKAGES"
	CHROOT_PACKAGES="mono-runtime $CHROOT_PACKAGES"
    CHROOT_PACKAGES="mono-mcs $CHROOT_PACKAGES"
}


install_debs() {
	apt update && apt install -y software-properties-common gnupg && apt-add-repository -y "deb https://ppa.launchpadcontent.net/pypy/ppa/ubuntu focal main"
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 2862D0785AFACD8C65B23DB0251104D968854915
	/opt/domjudge/judgehost/bin/dj_run_chroot '
	apt update && apt install -y software-properties-common gnupg && apt-add-repository -y "deb https://ppa.launchpadcontent.net/pypy/ppa/ubuntu focal main"
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 2862D0785AFACD8C65B23DB0251104D968854915
	'

	# execute commands in chroot
	/opt/domjudge/judgehost/bin/dj_run_chroot "export DEBIAN_FRONTEND=noninteractive &&
	apt update &&
	apt install -y --no-install-recommends --no-install-suggests ${CHROOT_PACKAGES} &&
	apt autoremove -y &&
	apt clean &&
	rm -rf /var/lib/apt/lists/* &&
	rm -rf /tmp/*"
	#execute command on home root
	apt update &&
	apt install -y --no-install-recommends --no-install-suggests ${DEB_PACKAGES} &&
	apt autoremove -y &&
	apt clean &&
	rm -rf /var/lib/apt/lists/* &&
	rm -rf /tmp/*
}

install_c
install_cpp
install_java
[ "$LANG_PYPY3" = "yes" ] && install_pypy3
[ "$LANG_CSHARP" = "yes" ] && install_csharp
#[ "$LANG_KOTLIN" = "yes" ] && install_kotlin

# Enable networking in chroot
mv ${CHROOT}/etc/resolv.conf ${CHROOT}/etc/resolv.conf.bak
cp /etc/resolv.conf ${CHROOT}/etc
cp /etc/apt/sources.list ${CHROOT}/etc/apt/sources.list

[ "$DEB_PACKAGES" != "" ] && install_debs

# Restore original state
mv ${CHROOT}/etc/resolv.conf.bak ${CHROOT}/etc/resolv.conf
