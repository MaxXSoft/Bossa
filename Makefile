TOP_DIR = $(shell pwd)

HELP_MESSAGES := \
"Bossa: BOOM's Simulation Accelerator\n" \
"\n" \
"Usage: make <OPTIONS>\n" \
"Options:\n" \
"  help:   show this message\n" \
"  setup:  setup prerequisites\n" \
"\n" \
"To build BOOM simulator, you may want to run:\n" \
"  cd sims/verilator\n" \
"  make CONFIG=SmallBoomConfig"


.PHONY: help setup

help:
	@echo $(HELP_MESSAGES)

setup:
	@$(TOP_DIR)/scripts/setup-prerequisites.sh
