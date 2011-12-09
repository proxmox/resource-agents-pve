RELEASE=2.0

PACKAGE=resource-agents-pve
PKGREL=1
RAVER=3.9.2
RADIR=resource-agents-${RAVER}
RASRC=${RADIR}.tar.bz2


DEB=${PACKAGE}_${RAVER}-${PKGREL}_amd64.deb

all: ${DEB}

${DEB} deb: ${RASRC}
	rm -rf ${RADIR}
	tar xf ${RASRC}
	cp -av debian ${RADIR}/debian
	cat ${RADIR}/AUTHORS >>${RADIR}/debian/copyright
	cd ${RADIR}; dpkg-buildpackage -rfakeroot -b -us -uc
	lintian ${DEB}

.PHONY: upload
upload: ${DEB}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/${PACKAGE}*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEB} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

distclean: clean

clean:
	rm -rf *~ debian/*~ *.deb ${RADIR} ${PACKAGE}_*

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}
