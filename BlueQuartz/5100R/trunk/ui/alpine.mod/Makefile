# specify the following variables:
VENDOR=base

# if the VENDOR field is an alias, this should be the real name.
# otherwise, set it to VENDOR.
VENDORNAME='Project BlueQuartz'
SERVICE=alpine

VERSION=0.1
RELEASE=85BQ22

# add a buildarch if desired
BUILDARCH=noarch

# locale exclude pattern
#XLOCALEPAT=

BUILDUI=yes
BUILDGLUE=yes
BUILDLOCALE=yes
#BUILDSRC=yes

#########
# some useful defines
INSTALL=install
INSTALL_BIN=$(INSTALL) -m 755
INSTALL_OTH=$(INSTALL) -m 644
TMPDIR=/tmp

include /usr/sausalito/devel/module.mk
include /usr/sausalito/devel/defines.mk

# where do the manuals live
WEBROOT=$(CCEDIR)/ui/web

# defines for stuff that ends up in /etc
ETCDIR=$(PREFIX)/etc
SYSCONFIG=$(ETCDIR)/sysconfig
CONFIG_DIR=etc/sysconfig
CONFIG_FILES=firstboot

MKDIR=mkdir -p

remove:
	rm -rf /usr/sausalito/ui/web/base/alpine
	rm -rf /usr/sausalito/ui/menu/base/alpine

install: install_perl install_config
	$(MKDIR) $(CCEDIR)/ui/web
	for locale in $(XLOCALEPAT); do \
		exclude="$$exclude -and -not -path *\.$$locale"; \
	done; \
	find web -type f -not -path "*/CVS*" $$exclude -exec install -D -o root -g root -m 644 {} $(CCEDIR)/ui/{} \;
	$(MKDIR) $(CCEDIR)/ui/web/libImage
	find libImage -type f -not -path "*/CVS*" $$exclude -exec install -D -o root -g root -m 644 {} $(CCEDIR)/ui/web/{} \;
	find manuals -type f -not -path "*CVS*" -exec install {} -D -o root -g root -m 644 $(WEBROOT)/{} \;
	include="-false"; \
	for locale in $(LOCALES); do \
		include="$$include -or -path *\.$$locale"; \
	done; \
	FLIST=`find web/error -follow -type f $$include \
		2>/dev/null | grep -v CVS | grep -v '/\.'`; \
	for file in $$FLIST; do \
		isfallback=`echo $$file | grep '.$(DEFLOCALE)$$'`; \
		if [ x"$$isfallback" != x"" ]; then \
			name=`basename $$file .$(DEFLOCALE)`; \
			if [ ! -f $(CCEDIR)/ui/web/error/$$name ]; then \
			`ln -s $$name.$(DEFLOCALE) \
				$(CCEDIR)/ui/web/error/$$name`; \
			fi; \
		fi; \
	done;

install_config:
	@$(MKDIR) $(SYSCONFIG)
	@for file in $(CONFIG_FILES); do \
		echo "installing config file: $$file"; \
		$(INSTALL_OTH) -o root -g root $(CONFIG_DIR)/$$file \
			 $(SYSCONFIG)/$$file; \
	done

