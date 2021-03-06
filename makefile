HOST1		= root@192.168.122.10
HOST2		= root@192.168.122.20

INSTALL_PATH	= $(CURDIR)/install
NTRDMA_PATH	= $(CURDIR)/ntrdma
NTRDMA_LIB_PATH	= $(CURDIR)/ntrdma-lib

LX_OPTS	= INSTALL_MOD_PATH=$(INSTALL_PATH)
AM_OPTS	= DESTDIR=$(INSTALL_PATH)

LX_VERS = `cat $(NTRDMA_PATH)/include/config/kernel.release 2> /dev/null`

all: ntrdma ntrdma-lib

ntrdma:
	cp config-ntrdma $(NTRDMA_PATH)/.config
	mkdir -p $(INSTALL_PATH){,/boot,/lib/modules}
	$(MAKE) -C $(NTRDMA_PATH) $(LX_OPTS) olddefconfig
	$(MAKE) -C $(NTRDMA_PATH) $(LX_OPTS)
	$(MAKE) -C $(NTRDMA_PATH) $(LX_OPTS) modules_install
	cp $(NTRDMA_PATH)/arch/x86/boot/bzImage $(INSTALL_PATH)/boot/vmlinuz-$(LX_VERS)
	cp $(NTRDMA_PATH)/System.map $(INSTALL_PATH)/boot/System.map-$(LX_VERS)
	cp $(NTRDMA_PATH)/.config $(INSTALL_PATH)/boot/config-$(LX_VERS)

ntrdma-ext:
	$(MAKE) -C $(NTRDMA_PATH) $(LX_OPTS) M=drivers/ntb
	$(MAKE) -C $(NTRDMA_PATH) $(LX_OPTS) M=drivers/ntb modules_install
	$(MAKE) -C $(NTRDMA_PATH) $(LX_OPTS) M=drivers/ntc
	$(MAKE) -C $(NTRDMA_PATH) $(LX_OPTS) M=drivers/ntc modules_install
	$(MAKE) -C $(NTRDMA_PATH) $(LX_OPTS) M=drivers/infiniband
	$(MAKE) -C $(NTRDMA_PATH) $(LX_OPTS) M=drivers/infiniband modules_install

ntrdma-lib:
	mkdir -p $(INSTALL_PATH){,/usr/lib64,/etc/libibverbs.d}
	cd $(NTRDMA_LIB_PATH) && libtoolize
	cd $(NTRDMA_LIB_PATH) && aclocal
	cd $(NTRDMA_LIB_PATH) && autoconf
	cd $(NTRDMA_LIB_PATH) && autoheader
	cd $(NTRDMA_LIB_PATH) && automake --add-missing
	cd $(NTRDMA_LIB_PATH) && ./configure --libdir=/usr/lib64 --sysconfdir=/etc
	$(MAKE) -C $(NTRDMA_LIB_PATH) $(AM_OPTS)
	$(MAKE) -C $(NTRDMA_LIB_PATH) $(AM_OPTS) install
	cp $(NTRDMA_LIB_PATH)/ntrdma.driver $(INSTALL_PATH)/etc/libibverbs.d

deploy-files:
	mkdir -p $(INSTALL_PATH){,/etc/modprobe.d}
	cp modprobe.d/{,node_1/}*.conf $(INSTALL_PATH)/etc/modprobe.d
	./deploy-files.sh $(HOST1) $(LX_VERS)
	cp modprobe.d/{,node_2/}*.conf $(INSTALL_PATH)/etc/modprobe.d
	./deploy-files.sh $(HOST2) $(LX_VERS)

deploy-bootstrap:
	./deploy-bootstrap.sh $(HOST1) $(LX_VERS)
	./deploy-bootstrap.sh $(HOST2) $(LX_VERS)

deploy: deploy-files deploy-bootstrap

.PHONY: all ntrdma ntrdma-ext ntrdma-lib deploy-files deploy-bootstrap deploy
