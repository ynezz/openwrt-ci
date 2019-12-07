CI_TARGET_BUILD_DOWNLOAD_URL:=https://downloads.openwrt.org/snapshots/targets
CI_TARGET_BUILD_CONFIG_URL:=$(CI_TARGET_BUILD_DOWNLOAD_URL)/$(CI_TARGET_BUILD_PLATFORM)/$(CI_TARGET_BUILD_SUBTARGET)/config.buildinfo

HELP += "ci-target-build-prepare	prepare build environment and target config\n"
ci-target-build-prepare:
	touch .config
	make prepare-tmpinfo scripts/config/conf
	$(TOPDIR)/scripts/config/conf --defconfig=.config Config.in
	make prereq

	curl -s $(CI_TARGET_BUILD_CONFIG_URL) > .config
	sed -i '/CONFIG_TARGET_DEVICE_/d' .config

	# TODO: allow -IB -SDK +BUILD_LOG configuration
	echo CONFIG_BUILD_LOG=y >> .config
	make defconfig > /dev/null
	sed -i 's/CONFIG_IB=y/# CONFIG_IB is not set/' .config
	sed -i 's/CONFIG_SDK=y/# CONFIG_SDK is not set/' .config
	sed -i 's/CONFIG_PACKAGE_kmod-acx-mac80211=m/# CONFIG_PACKAGE_kmod-acx-mac80211 is not set/' .config
	echo "$$CI_TARGET_BUILD_CONFIG_EXTRA" >> .config
	make oldconfig > /dev/null

	@echo -e "\n---- config ----\n"
	@$(TOPDIR)/scripts/diffconfig.sh
	@echo -e "\n---- config ----\n"

HELP += "ci-target-build-download	download all build sources for target\n"
ci-target-build-download:
	make $(CI_NUM_JOBS) tools/tar/compile || make -j1 tools/tar/compile V=s
	make $(CI_NUM_JOBS) download || make -j1 download V=s

HELP += "ci-target-build-run		build target profile images and packages\n"
ci-target-build-run:
	make $(CI_NUM_JOBS) tools/install || make -j1 tools/install V=s
	make $(CI_NUM_JOBS) toolchain/install || make -j1 toolchain/install V=s
	make $(CI_NUM_JOBS) target/compile 'IGNORE_ERRORS=n m'
	make $(CI_NUM_JOBS) package/compile 'IGNORE_ERRORS=n m'
	make $(CI_NUM_JOBS) package/install || make -j1 package/install V=s
	make $(CI_NUM_JOBS) package/index CONFIG_SIGNED_PACKAGES=
	make $(CI_NUM_JOBS) target/install V=s

	make -j1 prepare V=s
	make -j1 checksum V=s
	@echo "ci: ooh, victory! :-)"
