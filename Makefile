SHELL := /bin/bash
TOPDIR := ${CURDIR}
HELP := "Following targets are available:\n\n"
CI_SOURCE_URL ?= https://gitlab.com/ynezz/openwrt-ci/raw/master

CI_INCLUDE := \
	openwrt-ci/common.mk \
	openwrt-ci/pre-build.mk \
	openwrt-ci/native-build.mk \
	openwrt-ci/sdk-build.mk

all: $(CI_PREPARED)
	@echo -en $(HELP)

CI_PREPARED := openwrt-ci/.prepared
ci-prepare: $(CI_PREPARED)
$(CI_PREPARED):
	if [ ! -d $(TOPDIR)/openwrt-ci ]; then \
		mkdir -p $(TOPDIR)/openwrt-ci && \
		for file in $(CI_INCLUDE); do \
			wget -q $(CI_SOURCE_URL)/$$file -O $(TOPDIR)/$$file; \
		done \
	fi
	touch $@

-include $(CI_INCLUDE)
