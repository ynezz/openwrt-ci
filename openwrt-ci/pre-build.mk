CI_VENV_DIR:=$(TOPDIR)/.venv/openwrt-ci
CI_VENV_BIN:=$(CI_VENV_DIR)/bin
CI_PIP_VENV:=$(CI_VENV_BIN)/pip3
CI_PYTHON_VENV:=$(CI_VENV_BIN)/python3
CI_BLACK_VENV:=$(CI_VENV_BIN)/black
CI_FLAKE8_VENV:=$(CI_VENV_BIN)/flake8
CI_VENV_PREPARED:=$(CI_VENV_BIN)/.prepared

$(CI_VENV_PREPARED):
	python3 -m venv $(CI_VENV_DIR)
	$(CI_PIP_VENV) install --upgrade pip
	$(CI_PIP_VENV) install black flake8
	@touch $@

HELP += "ci-shellcheck			checks all shell scripts with shellcheck\n"
ci-shellcheck: $(CI_PREPARED)
	shellcheck --version
	find -name '*.sh' | xargs --no-run-if-empty shellcheck

HELP += "ci-py-codestyle		checks coding style on Python scripts with black\n"
ci-py-codestyle: $(CI_PREPARED) $(CI_VENV_PREPARED)
	$(CI_BLACK_VENV) --version
	$(CI_BLACK_VENV) --verbose --diff --check $(TOPDIR)

HELP += "ci-py-flake8			run flake8 Python code linter on Python scripts\n"
ci-py-flake8: $(CI_PREPARED) $(CI_VENV_PREPARED)
	$(CI_FLAKE8_VENV) --version
	find $(TOPDIR) -type d -path *.venv* -prune -o -iname '*.py' -print | \
		xargs --no-run-if-empty $(CI_FLAKE8_VENV)

HELP += "ci-py-checks			run complete suite of Python checks\n"
ci-py-checks: \
	ci-py-codestyle \
	ci-py-flake8
