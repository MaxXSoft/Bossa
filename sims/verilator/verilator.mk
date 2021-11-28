################################################################################
# Verilator flags
################################################################################

# Directories
DRAMSIM_DIR := $(BOSSA_DIR)/tools/DRAMSim2

# Tracing flags
TRACING_OPTS := $(if $(filter $(VERILATOR_FST_MODE),0),\
	                  --trace,--trace-fst --trace-threads 1)
TRACING_CFLAGS := $(if $(filter $(VERILATOR_FST_MODE),0),,-DCY_FST_TRACE)

# C++/linker flags
SIM_CXXFLAGS := \
	-std=c++11 \
	-I$(ISA_SIM_INSTALL_DIR)/include \
	-I$(DRAMSIM_DIR) \
	-I$(BUILD_DIR)
SIM_LDFLAGS := \
	-L$(ISA_SIM_INSTALL_DIR)/lib \
	-Wl,-rpath,$(ISA_SIM_INSTALL_DIR)/lib \
	-L$(TOP_DIR) \
	-L$(DRAMSIM_DIR) \
	-lfesvr \
	-ldramsim

# Verilator C++/linker flags
VERILATOR_CXXFLAGS := \
	$(SIM_CXXFLAGS) \
	$(TRACING_CFLAGS) \
	-D__STDC_FORMAT_MACROS \
	-DTEST_HARNESS=V$(TOP_MODULE) \
	-DVERILATOR \
	-include $(BUILD_DIR)/$(CIRCUIT_NAME).plusArgs \
	-include $(BUILD_DIR)/verilator.h
VERILATOR_LDFLAGS := $(SIM_LDFLAGS)
VERILATOR_CC_OPTS := \
	-CFLAGS "$(VERILATOR_CXXFLAGS)" \
	-LDFLAGS "$(VERILATOR_LDFLAGS)"

# Multi-threading related flags
RUNTIME_THREADS := --threads $(VERILATOR_THREADS) --threads-dpi all

# Optimization flags
VERILATOR_OPT_FLAGS ?= \
	-O2 \
	--x-assign fast \
	--x-initial fast \
	--output-split 30000 \
	--output-split-cfuncs 30000

# Other flags
CHIPYARD_VERILATOR_FLAGS := \
	--assert
TIMESCALE_OPTS := $(shell verilator --version | perl -lne 'if (/(\d.\d+)/ && $$1 >= 4.034) { print "--timescale 1ns/1ps"; }')
MAX_WIDTH_OPTS = $(shell verilator --version | perl -lne 'if (/(\d.\d+)/ && $$1 > 4.016) { print "--max-num-width 1048576"; }')
PREPROC_DEFINES := \
	+define+PRINTF_COND=\$$c\(\"verbose\",\"\&\&\"\,\"done_reset\"\) \
	+define+STOP_COND=\$$c\(\"done_reset\"\)

# Verilator non-C++ flags
VERILATOR_NONCC_OPTS := \
	$(RUNTIME_THREADS) \
	$(VERILATOR_OPT_FLAGS) \
	$(CHIPYARD_VERILATOR_FLAGS) \
	-Wno-fatal \
	$(TIMESCALE_OPTS) \
	$(MAX_WIDTH_OPTS) \
	$(PREPROC_DEFINES) \
	--top-module $(TOP_MODULE) \
	--vpi \
	-f $(SIM_COMMON_FILES) \
	-f $(VERILOG_FILES)

# All Verilator related flags
VERILATOR_OPTS := $(VERILATOR_CC_OPTS) $(VERILATOR_NONCC_OPTS)
