# OpenWrt CI

Provide reusable bits for OpenWrt CI platform agnostic testing.

## Goals

Should provide reusable `make` targets which could be used easily during testing on developer's machine and on the CI without changes.

## Usage example

```
cd $some_project
wget -q https://gitlab.com/ynezz/openwrt-ci/raw/master/Makefile -O Makefile.ci
make ci-prepare -f Makefile.ci
make ci-shellcheck -f Makefile.ci
```

## Available make targets

 * ci-shellcheck - checks all shell scripts with shellcheck
 * ci-native-scan-build - build with clang's static analyzer
 * ci-native-cppcheck - build with cppcheck static analyzer
 * ci-native-build - build with gcc 7 8 9 and clang 9
 * ci-native-checks - run complete group of native checks
 * ci-sdk-oot-build - out of tree build for target with SDK
