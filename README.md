# OpenWrt CI

Provide reusable bits for OpenWrt CI platform agnostic testing.

## Goals

Should provide reusable `make` targets which could be used easily during testing on developer's machine and on the CI without changes.

## Usage example

```
cd $some_openwrt_project
wget -q https://gitlab.com/ynezz/openwrt-ci/raw/master/Makefile -O Makefile.ci
make ci-prepare -f Makefile.ci
docker run --rm --tty --interactive --volume $(pwd):/home/build/openwrt \
	registry.gitlab.com/ynezz/openwrt-ci/native-testing:latest \
	make ci-native-scan-build -f Makefile.ci
```

This is going to build `$some_openwrt_project` inside the same Docker container used by the CI tests and run `ci-native-checks` Make target.

## Available make targets

 * ci-shellcheck - checks all shell scripts with shellcheck
 * ci-py-codestyle - checks coding style on Python scripts with black
 * ci-py-flake8 - run flake8 Python code linter on Python scripts
 * ci-py-checks - run complete suite of Python checks
 * ci-native-scan-build - build with clang's static analyzer
 * ci-native-cppcheck - build with cppcheck static analyzer
 * ci-native-build - build with gcc 7 8 9 and clang 9
 * ci-native-checks - run complete group of native checks
 * ci-sdk-oot-build - out of tree build for target with SDK
