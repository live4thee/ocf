#
# Copyright(c) 2012-2018 Intel Corporation
# SPDX-License-Identifier: BSD-3-Clause-Clear
#

PWD:=$(shell pwd)

ifneq ($(strip $(O)),)
OUTDIR:=$(shell cd $(O) && pwd)
endif

validate:
ifeq ($(strip $(OUTDIR)),)
	$(error No output specified for installing sources or headers)
endif

ifeq ($(strip $(CMD)),)
INSTALL=ln -s
else ifeq ($(strip $(CMD)),cp)
INSTALL=cp
else ifeq ($(strip $(CMD)),install)
INSTALL=install
else
$(error Not allowed program command)
endif

#
# Installing headers
#
INC_IN=$(shell find $(PWD)/inc -name '*.[h]' -type f)
INC_OUT=$(patsubst $(PWD)/inc/%,$(OUTDIR)/include/ocf/%,$(INC_IN))
INC_RM=$(shell find $(OUTDIR)/include/ocf -name '*.[h]' -xtype l 2>/dev/null)

inc: $(INC_OUT) $(INC_RM)
	@$(MAKE) distcleandir

$(INC_OUT):
ifeq ($(strip $(OUTDIR)),)
	$(error No output specified for installing headers)
endif
	@echo " INSTALL  $@"
	@mkdir -p $(dir $@)
	@$(INSTALL) $(subst $(OUTDIR)/include/ocf,$(PWD)/inc,$@) $@

$(INC_RM): validate
	$(if $(shell readlink $@ | grep $(PWD)/inc), \
		@echo "  RM      $@"; rm $@,)

#
# Installing sources
#
SRC_IN=$(shell find $(PWD)/src -name '*.[c|h]' -type f)
SRC_OUT=$(patsubst $(PWD)/src/%,$(OUTDIR)/src/ocf/%,$(SRC_IN))
SRC_RM=$(shell find $(OUTDIR)/src/ocf -name '*.[c|h]' -xtype l 2>/dev/null)

src: $(SRC_OUT) $(SRC_RM)
	@$(MAKE) distcleandir

$(SRC_OUT):
ifeq ($(strip $(OUTDIR)),)
	$(error No output specified for installing sources)
endif
	@echo " INSTALL  $@"
	@mkdir -p $(dir $@)
	@$(INSTALL) $(subst $(OUTDIR)/src/ocf,$(PWD)/src,$@) $@

$(SRC_RM): validate
	$(if $(shell readlink $@ | grep $(PWD)/src), \
		@echo "  RM      $@"; rm $@,)

#
# Distclean
#
dist_dir=$(foreach dir,$(shell find $(OUTDIR) -type d -empty), \
$(if $(wildcard $(subst $(OUTDIR)/src/ocf,$(PWD)/src,$(dir))),$(dir),))

distclean: validate
	@rm -f $(SRC_OUT) $(INC_OUT)
	@$(MAKE) distcleandir

distcleandir:
	$(if $(strip $(dist_dir)), rm -r $(dist_dir),)

#
# Printing help
#
help:
	$(info Available targets:)
	$(info inc O=<OUTDIR> [CMD=cp|install]  Install include files into specified directory)
	$(info src O=<OUTDIR> [CMD=cp|install]  Install source files into specified directory)
	$(info distclean O=<OUTDIR>             Uninstall source and headers from specified directory)

doc: validate
	@cd doc && rm -rf html
	@cd doc && doxygen doxygen.cfg
	@mkdir -p $(OUTDIR)/doc
	@cd doc && mv html $(OUTDIR)/doc/ocf

.PHONY: inc src validate help distclean distcleandir doc \
    $(INC_RM) $(SRC_RM) $(DIST_DIR)