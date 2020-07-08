CI_TARGET_BUILD_DOWNLOAD_URL:=https://downloads.openwrt.org/snapshots/targets
CI_TARGET_BUILD_CONFIG_URL:=$(CI_TARGET_BUILD_DOWNLOAD_URL)/$(CI_TARGET_BUILD_PLATFORM)/$(CI_TARGET_BUILD_SUBTARGET)/config.buildinfo
CONFIG_EXTRA_EXPANDED :=
$(foreach option,$(CI_TARGET_BUILD_CONFIG_EXTRA),\
	$(eval CONFIG_EXTRA_EXPANDED += $(patsubst +%,CONFIG_%=y,\
		$(patsubst -%,CONFIG_%=n, $(option))))\
)

HELP += "ci-target-build-prepare	prepare build environment and target config\n"
ci-target-build-prepare:
	touch .config
	make prepare-tmpinfo scripts/config/conf
	$(TOPDIR)/scripts/config/conf --defconfig=.config Config.in
	make prereq

	curl -s $(CI_TARGET_BUILD_CONFIG_URL) > .config
	echo "$(CONFIG_EXTRA_EXPANDED)" | tr ' ' '\n'>> .config
	make defconfig > /dev/null

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
	make $(CI_NUM_JOBS) target/compile 'IGNORE_ERRORS=n m' || make -j1 target/compile V=s
	make $(CI_NUM_JOBS) package/compile 'IGNORE_ERRORS=n m' || make -j1 package/compile V=s
	make $(CI_NUM_JOBS) package/install || make -j1 package/install V=s
	make $(CI_NUM_JOBS) package/index CONFIG_SIGNED_PACKAGES=
	make $(CI_NUM_JOBS) target/install V=s

	make -j1 prepare V=s
	make -j1 checksum V=s
	make -j1 json_overview_image_info V=s
	@echo "ci: ooh, victory! :-)"
