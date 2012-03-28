# mark 'all' as default target; add dependencies later
all:

deps.inc:
	./linkextor.pl > $@

update:
	rm -f deps.inc
	$(MAKE)

include deps.inc

ALL_PKGS=
define pkg_template
$(info > $($(1)))
$($(1)):
	$$(info downloading $$@ from $$($(1)_URL))
	@curl -s -L -o $$@ $$($(1)_URL) && echo finished downloading $$@

ALL_PKGS+=$$($(1))
endef

$(info Package Versions:)
$(foreach pkg,$(ALL_PKGS_NAMES),$(eval $(call pkg_template,$(pkg))))

all: $(ALL_PKGS)

clean:
	rm -f $(ALL_PKGS)

veryclean: clean
	rm -f deps.inc
