#!/usr/bin/env bash
# vim: set ts=8 sts=8 noet:

set -euo pipefail

OWRT_REPO_URL="git://git.openwrt.org/project"

BUILD_REPO_URLS=" \
	${OWRT_REPO_URL}/libubox.git \
	${OWRT_REPO_URL}/uci.git \
	${OWRT_REPO_URL}/ubus.git \
	${OWRT_REPO_URL}/ubox.git \
	${OWRT_REPO_URL}/ustream-ssl.git \
	${OWRT_REPO_URL}/libnl-tiny.git \
"

log() {
	echo "[*] build: " "$@"
}

dir_from_url() {
	local url dir
	url="$1"
	dir=$(basename "$url")
	echo "${dir%.git}"
}

clone_repo() {
	local url="$1"
	log "cloning $url"
	git clone "$url" "$(dir_from_url "$url")"
}

build_repo() {
	local url="$1"

	pushd "$(dir_from_url "$url")" > /dev/null

	export VERBOSE=1
	mkdir build; cd build
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr; cd ..
	make -j$(($(nproc)+1)) -C build
	sudo make install -C build

	popd > /dev/null
}

main() {
	for url in $BUILD_REPO_URLS; do
		clone_repo "$url"
		build_repo "$url"
	done
}

main
