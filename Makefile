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

DOC = README.md
SHELLCHECK_OPTS = -eSC2053,SC2064,SC2086,SC1117,SC2162,SC2181,SC2034,SC1090,SC2115

DOCOUT = $(DOC:.md=.html)

all:
	@echo "Type sudo make install|uninstall"

install:
	@./libinput-gestures-setup -d "$(DESTDIR)" install

uninstall:
	@./libinput-gestures-setup -d "$(DESTDIR)" uninstall

check:
	flake8 libinput-gestures internal internal-test
	shellcheck $(SHELLCHECK_OPTS) libinput-gestures-setup list-version-hashes libinput-dummy
	vermin -i -q -t 3.5 --no-tips libinput-gestures
	vermin -i -q --no-tips internal internal-test

doc:	$(DOCOUT)

$(DOCOUT): $(DOC)
	markdown $< >$@

test:
	@./internal-test

clean:
	rm -rf $(DOCOUT)
