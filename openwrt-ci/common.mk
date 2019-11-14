CI_CMAKE ?= cmake
CI_MAKE ?= make
CI_NUM_JOBS ?= -j$$((nproc+1))
CI_OPENWRT_ROOT ?= $(HOME)/openwrt
CI_GCC_VERSION_LIST ?= 7 8 9
CI_CLANG_VERSION_LIST ?= 10
CI_CMAKE_VERBOSE ?= 1
CI_MAKE_EXTRA_BUILD_ARGS += VERBOSE=$(CI_CMAKE_VERBOSE)

define cmake_build
	rm -fr ./build 2>/dev/null; mkdir -p ./build && \
	cd ./build && \
	$(1) $(CI_CMAKE) \
		-D CMAKE_BUILD_TYPE=$(2) \
		$(if $(3),-DUNIT_TESTING=on) \
		$(CI_CMAKE_EXTRA_BUILD_ARGS) \
		.. ; \
	ret=$$? ; \
	if [ $$ret != 0 ]; then exit $$ret; fi ; \
	$(1) $(CI_MAKE) \
		$(CI_NUM_JOBS) \
		$(CI_MAKE_EXTRA_BUILD_ARGS) \
		all $(if $(3),test CTEST_OUTPUT_ON_FAILURE=1) \
		; \
	ret=$$? ; \
	if [ $$ret != 0 ]; then exit $$ret; fi ; \
	cd ..
endef

define cmake_build_release
	$(call cmake_build,$(1),Release,$(2))
endef

define cmake_build_debug
	$(call cmake_build,$(1),Debug,$(2))
endef
