define sdk_var
	$(shell \
		if [ -f "$(CI_OPENWRT_ROOT)/rules.mk" ]; then \
			make -s \
				TOPDIR=$(CI_OPENWRT_ROOT) \
				-f $(CI_OPENWRT_ROOT)/rules.mk \
				val.$(1) ; \
		fi \
	)
endef

define gen_toolchain_cmake
	( \
		echo "SET(CMAKE_SYSTEM_NAME Linux)" ; \
		echo "SET(CMAKE_FIND_ROOT_PATH $(strip $(call sdk_var,STAGING_DIR)))" ; \
		echo "SET(OWRT_CROSS $(strip $(call sdk_var,TOOLCHAIN_DIR))/bin/$(strip $(call sdk_var,TARGET_CROSS)))" ; \
		echo 'SET(CMAKE_C_COMPILER $${OWRT_CROSS}gcc)' ; \
		echo 'SET(CMAKE_CXX_COMPILER $${OWRT_CROSS}g++)' ; \
		echo "SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)" ; \
		echo "SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)" ; \
		echo "SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)" ; \
		echo "ADD_DEFINITIONS($(strip $(call sdk_var,TARGET_CFLAGS)))" ; \
	) > $(1)
endef

CI_SDK_PREPARED := $(CI_OPENWRT_ROOT)/tmp/.ci-sdk-prepared
$(CI_SDK_PREPARED):
	mkdir -p $(dir $(CI_SDK_PREPARED))
	cd $(CI_OPENWRT_ROOT) && ./scripts/feeds update base

ifneq ($(CI_TARGET_BUILD_DEPENDS),)
	cd $(CI_OPENWRT_ROOT) && ./scripts/feeds install $(CI_TARGET_BUILD_DEPENDS)
endif

	cd $(CI_OPENWRT_ROOT) && make defconfig

ifneq ($(CI_TARGET_BUILD_DEPENDS),)
	cd $(CI_OPENWRT_ROOT) && \
		for pkg in $(CI_TARGET_BUILD_DEPENDS); do \
			make package/$${pkg}/{clean,compile} \
				PKG_ABI_VERSION=$(shell date +%Y%m%d) \
				V=s -j$$((nproc+1)) ; \
		done
endif

	touch $@

HELP += "ci-sdk-oot-build		build out of tree for target with SDK (WIP)\n"
ci-sdk-oot-build: CI_CMAKE := $(strip $(call sdk_var,STAGING_DIR_HOST))/bin/cmake
ci-sdk-oot-build: CI_CMAKE_EXTRA_BUILD_ARGS += -D CMAKE_TOOLCHAIN_FILE=toolchain.cmake
ci-sdk-oot-build: export STAGING_DIR:=$(strip $(call sdk_var,STAGING_DIR))
ci-sdk-oot-build: export LDFLAGS+=-L$(strip $(call sdk_var,STAGING_DIR))/usr/lib -L$(strip $(call sdk_var,STAGING_DIR))/lib
ci-sdk-oot-build: export CFLAGS+=-I$(strip $(call sdk_var,STAGING_DIR))/usr/include
ci-sdk-oot-build: export STAGING_PREFIX=$(strip $(call sdk_var,STAGING_DIR))/usr
ci-sdk-oot-build: export PKG_CONFIG_PATH=$(strip $(call sdk_var,STAGING_DIR))/usr/lib/pkgconfig
ci-sdk-oot-build: export PATH:=$(strip $(call sdk_var,STAGING_DIR_HOST))/bin:$(PATH)
ci-sdk-oot-build: $(CI_SDK_PREPARED)
	$(call gen_toolchain_cmake,toolchain.cmake)
	$(call cmake_build_debug)
	$(call cmake_build_release)
