
SPEC=librsvg2.spec
SOURCE=$(shell grep '^Source:' < $(SPEC) | sed -e 's/^Source:[ \t]*//')
PATCH=$(shell grep '^Patch:' < $(SPEC) | sed -e 's/^Patch:[ \t]*//')

rpm:
	test -r `basename $(SOURCE)` || wget $(SOURCE)
	test -r `basename $(PATCH)` || wget $(PATCH)

