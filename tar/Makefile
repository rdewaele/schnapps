# mark 'all' as default target; add dependencies later
all:

deps.inc:
	./linkextor.pl > $@

update:
	rm -f deps.inc
	$(MAKE)

include deps.inc

# $(1)=>filename; $(2)=>url
define download
@curl -s -L -o $(1) $(2) &&\
	echo finished downloading $(1)
endef

# $(1)=>filename; $(2)=>url; $(3)=>directory name
define dowload_lpc21isp
@curl -s -L -o $(1) $(2) &&\
	rm -rf $(3) &&\
	mkdir $(3) &&\
	tar xf $(1) -C $(3) &&\
	tar caf $(1) $(3) &&\
	rm -rf $(3) &&\
	echo finished downloading $(1)
endef

ALL_PKGS=
define pkg_template
$(1): $($(1))
$($(1)):
	$$(shell rm -f $(1)*.tar.*)
	$$(info downloading $$@ from $$($(1)_URL))
	$$(if $$(findstring lpc21isp,$(1)),\
		$$(call dowload_lpc21isp,$($(1)),$($(1)_URL),$(basename $($(1)))),\
		$$(call download,$($(1)),$($(1)_URL)))

ALL_PKGS+=$$($(1))
endef

$(foreach pkg,$(ALL_PKGS_NAMES),$(eval $(call pkg_template,$(pkg))))

ifdef DEBUG
 $(info Package Versions:)
 $(foreach pkg,$(ALL_PKGS),$(info > $(pkg)))
endif

all: $(ALL_PKGS)

clean:
	rm -f $(ALL_PKGS)

veryclean: clean
	rm -f deps.inc

.PHONY: all update clean veryclean
