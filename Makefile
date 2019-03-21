
SPEC=librsvg2.spec
SOURCE=$(shell grep '^Source:' < $(SPEC) | sed -e 's/^Source:[ \t]*//')
PATCH=$(shell grep '^Patch:' < $(SPEC) | sed -e 's/^Patch:[ \t]*//')
SOURCEBASE=$(shell basename $(SOURCE))
PATCHBASE=$(shell basename $(PATCH))

rpm:
	test -r "$(SOURCEBASE)" || curl -o "$(SOURCEBASE)" $(SOURCE)
	test -r "$(PATCHBASE)" || curl -o "$(PATCHBASE)" $(PATCH)
	rpmbuild --define "_sourcedir $(PWD)" -ba $(SPEC)

test:
