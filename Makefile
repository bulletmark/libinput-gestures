# Copyright (C) 2015 Mark Blakeney. This program is distributed under
# the terms of the GNU General Public License.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or any
# later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License at <http://www.gnu.org/licenses/> for more
# details.

SHELLCHECK_OPTS = -eSC2053,SC2064,SC2086,SC1117,SC2162,SC2181,SC2034,SC1090,SC2115
PYFILES = libinput-gestures internal internal-test
SHFILES = libinput-gestures-setup list-version-hashes libinput-dummy

all:
	@echo "Type sudo make install|uninstall"

install:
	@./libinput-gestures-setup -d "$(DESTDIR)" install

uninstall:
	@./libinput-gestures-setup -d "$(DESTDIR)" uninstall

check:
	ruff check $(PYFILES)
	shellcheck $(SHELLCHECK_OPTS) $(SHFILES)
	for f in $(PYFILES); do mypy $$f; done

test:
	@./internal-test

format:
	ruff check --select I --fix $(PYFILES) && ruff format $(PYFILES)

clean:
	rm -rf __pycache__
