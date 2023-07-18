#!/usr/bin/env bash
# https://wiki.debian.org/Packaging/Intro
#https://www.internalpointers.com/post/build-binary-deb-package-practical-guide
PKG=lncdtools
PKG_TYPES:=all make shell neuro
VER=1.0
REL=1

.PHONY: all clean
# keep intermidate DEBIAN/* files
.SECONDARY:
all: $(patsubst %,lncdtools-%_$(VER)-$(REL).deb,$(PKG_TYPES))
clean: 
	rm -r $(PKG)-*_[0-9]*/ $(PKG)-*_[0-9]*.deb

%.deb: %/DEBIAN/control %/DEBIAN/version %/DEBIAN/copyright
	dpkg-deb --build --root-owner-group $(subst .deb,,$@)

# debian files
#
%/DEBIAN/control: control | %/DEBIAN 
	sed 's/Version:.*/Version: $(VER)/' control > $@

%/DEBIAN/version: %/DEBIAN
	#sed s/.*// /etc/debian_version > $@
	echo 11 > $@

%/DEBIAN/copyright: copyright| %/DEBIAN
	cp $< $@

%/DEBIAN: %/ 
	mkdir -p $@ 

lncdtools-all_$(VER)-$(REL)/:
	mkdir -p $@
	make DESTDIR="$(PWD)/$@" -C ../.. install

lncdtools-make_$(VER)-$(REL)/:
	mkdir -p $@/DEBIAN
	make DESTDIR="$(PWD)/$@" -C ../.. install-make

lncdtools-shell_$(VER)-$(REL)/:
	mkdir -p $@/DEBIAN
	make DESTDIR="$(PWD)/$@" -C ../.. install-shell

lncdtools-neuro_$(VER)-$(REL)/:
	mkdir -p $@/DEBIAN
	make DESTDIR="$(PWD)/$@" -C ../.. install-neuro
	


#EMAIL=$(EMAIL) dch --create -v $(VER) --package $(PKG)
#printf "#!/usr/bin/make -f\n%:\n\tdh $@" > $@/rules
# update rule?
#	make DESTDIR="$(PWD)/$@" -C ../.. install
# dist/deb/
#  orig.tar.gz # contents/
#  pkg_ver-rel/
#     contents/
#     debian/
#
# pkg: $(PKG)_$(VER)-$(REL)/debian/
# 	cd $(PKG)_$(VER)-$(REL)/ && debuild -us -uc
# 
# # top level original source
# $(PKG)_$(VER).orig.tar.gz: $(filter-out dist/,$(wildcard ../../*))
# 	tar -C ../..  -cjf $@ $(subst ../../,,$?)
# 
# # re-extracted
# $(PKG)_$(VER)-$(REL)/: $(PKG)_$(VER).orig.tar.gz
# 	mkdir -p $@ 
# 	tar -C $@ -xjvf $<
