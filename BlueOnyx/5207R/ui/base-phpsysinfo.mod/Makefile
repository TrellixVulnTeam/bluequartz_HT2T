# specify the following variables:
VENDOR=base

# if the VENDOR field is an alias, this should be the real name.
# otherwise, set it to VENDOR.
VENDORNAME='Project BlueOnyx'
SERVICE=phpsysinfo

VERSION=1.2.0
RELEASE=0BX07

# add a buildarch if desired
BUILDARCH=noarch

# locale exclude pattern
#XLOCALEPAT=

BUILDUI=new
BUILDGLUE=yes
BUILDLOCALE=yes
BUILDSRC=no
REQUIRES= php-xml phpsysinfo

#########
# some useful defines
INSTALL=install
INSTALL_BIN=$(INSTALL) -m 755
INSTALL_OTH=$(INSTALL) -m 644
TMPDIR=/tmp

include /usr/sausalito/devel/module.mk
