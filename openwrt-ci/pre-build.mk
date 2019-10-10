HELP += "ci-shellcheck			checks all shell scripts with shellcheck\n"
ci-shellcheck: $(CI_PREPARED)
	shellcheck --version
	find -name '*.sh' | xargs --no-run-if-empty shellcheck
