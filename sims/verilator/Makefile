################################################################################
# Global settings
################################################################################

# Parameters
CONFIG ?= SmallBoomConfig
FRENDA_THREADS ?= $(shell nproc)
FRENDA_CLEAN_BUILD ?= 0
VERILATOR_THREADS ?= 1
VERILATOR_FST_MODE ?= 0
TOP_MODULE ?= TestHarness
CIRCUIT_NAME := $(TOP_MODULE).$(CONFIG)

# Directories
TOP_DIR := $(shell pwd)
BUILD_DIR := $(TOP_DIR)/build/$(CIRCUIT_NAME)

# Targets
SIM := $(TOP_DIR)/simulator-$(CONFIG)
SIM_DEBUG := $(TOP_DIR)/simulator-$(CONFIG)-debug

include $(TOP_DIR)/../tools.mk

.PHONY: default debug clean
default: $(SIM)
debug: $(SIM_DEBUG)
clean:
	-rm -rf $(BUILD_DIR) $(SIM) $(SIM_DEBUG)


################################################################################
# riscv-isa-sim
################################################################################

# Directories
ISA_SIM_DIR := $(BOSSA_DIR)/toolchains/riscv-isa-sim
ISA_SIM_BUILD_DIR := $(ISA_SIM_DIR)/build
ISA_SIM_INSTALL_DIR := $(BOSSA_DIR)/toolchain-install/riscv-isa-sim

# Targets
ISA_SIM_LIBFESVR := $(ISA_SIM_INSTALL_DIR)/lib/libfesvr.a

$(ISA_SIM_LIBFESVR):
	mkdir -p $(ISA_SIM_BUILD_DIR)
	cd $(ISA_SIM_BUILD_DIR) && $(ISA_SIM_DIR)/configure --prefix=$(ISA_SIM_INSTALL_DIR)
	$(MAKE) -C $(ISA_SIM_BUILD_DIR) install


################################################################################
# Frenda
################################################################################

# Directories
FRENDA_DIR := $(BOSSA_DIR)/tools/frenda

# Targets
FRENDA := $(FRENDA_DIR)/utils/bin/frenda
FRENDA_JAR := $(FRENDA).jar

$(FRENDA_JAR):
	cd $(FRENDA_DIR) && $(SBT) "assembly"


################################################################################
# FIRRTL circuit elaboration
################################################################################

# Directories
BOOTROM_DIR := $(BOSSA_DIR)/generators/testchipip/bootrom

# Files
SCALA_SRCS := $(shell find $(BOSSA_DIR) -name "*.scala")
BOOTROM_FILES := $(BOOTROM_DIR)/bootrom.rv64.img $(BOOTROM_DIR)/bootrom.rv32.img

# Targets
BOOTROM_TARGETS := $(BUILD_DIR)/bootrom.rv64.img $(BUILD_DIR)/bootrom.rv32.img
FIR_CIRCUIT := $(BUILD_DIR)/$(CIRCUIT_NAME).fir
FIR_ANNO := $(BUILD_DIR)/$(CIRCUIT_NAME).anno.json

$(FIR_CIRCUIT): $(SCALA_SRCS) $(BOOTROM_TARGETS)
	mkdir -p $(dir $@)
	$(SBT_BOSSA) "project chipyard; runMain chipyard.Generator --target-dir $(BUILD_DIR) --name $(CIRCUIT_NAME) --top-module chipyard.$(TOP_MODULE) --legacy-configs chipyard:$(CONFIG)"

$(FIR_ANNO): $(FIR_CIRCUIT)

$(BUILD_DIR)/bootrom.%.img: $(BOOTROM_DIR)/bootrom.%.img
	mkdir -p $(dir $@)
	cp -f $^ $@


################################################################################
# FIRRTL circuit compilation
################################################################################

# Flags
FRENDA_FLAGS := $(if $(filter $(FRENDA_CLEAN_BUILD),0),,-cb)

# Directories
VERILOG_DIR := $(BUILD_DIR)/verilog

# Targets
VERILOG_FILES := $(BUILD_DIR)/verilog_files.f

$(VERILOG_FILES): $(FIR_CIRCUIT) $(FRENDA_JAR)
	mkdir -p $(dir $@)
	$(FRENDA) $(FRENDA_FLAGS) -i $(FIR_CIRCUIT) -j $(FRENDA_THREADS) -td $(VERILOG_DIR) -off $(VERILOG_FILES)


################################################################################
# Dot f files generation
################################################################################

# Directories
ROCKET_RES_DIR := $(BOSSA_DIR)/generators/rocket-chip/src/main/resources
CHIPYARD_RES_DIR := $(BOSSA_DIR)/generators/chipyard/src/main/resources
TESTCHIP_RES_DIR := $(BOSSA_DIR)/generators/testchipip/src/main/resources

# Files
SIM_FILE_REQS := \
	$(ROCKET_RES_DIR)/vsrc/EICG_wrapper.v \
	$(CHIPYARD_RES_DIR)/csrc/emulator.cc \
	$(ROCKET_RES_DIR)/csrc/verilator.h \
	$(TESTCHIP_RES_DIR)/testchipip/csrc/SimSerial.cc \
	$(TESTCHIP_RES_DIR)/testchipip/csrc/testchip_tsi.cc \
	$(TESTCHIP_RES_DIR)/testchipip/csrc/testchip_tsi.h \
	$(TESTCHIP_RES_DIR)/testchipip/csrc/SimDRAM.cc \
	$(TESTCHIP_RES_DIR)/testchipip/csrc/mm.h \
	$(TESTCHIP_RES_DIR)/testchipip/csrc/mm.cc \
	$(TESTCHIP_RES_DIR)/testchipip/csrc/mm_dramsim2.h \
	$(TESTCHIP_RES_DIR)/testchipip/csrc/mm_dramsim2.cc \
	$(ROCKET_RES_DIR)/csrc/SimDTM.cc \
	$(ROCKET_RES_DIR)/csrc/SimJTAG.cc \
	$(ROCKET_RES_DIR)/csrc/remote_bitbang.h \
	$(ROCKET_RES_DIR)/csrc/remote_bitbang.cc

# Targets
SIM_FILES := $(BUILD_DIR)/sim_files.f
BLACKBOX_FILES := $(BUILD_DIR)/blackbox_files.f
SIM_COMMON_FILES := $(BUILD_DIR)/sim_files.common.f

$(SIM_COMMON_FILES): $(SIM_FILES) $(BLACKBOX_FILES)
	awk '{print $1;}' $^ | sort -u | grep -v '.*\.\(svh\|h\)$$' > $@

$(SIM_FILES): $(SIM_FILE_REQS)
	mkdir -p $(dir $@)
	cp -f $^ $(BUILD_DIR)
	$(foreach file,\
		$^,\
		$(if $(filter %.h,$(file)),\
			echo "-FI $(addprefix $(BUILD_DIR)/, $(notdir $(file)))" >> $@;,\
			echo "$(addprefix $(BUILD_DIR)/, $(notdir $(file)))" >> $@;))

$(BLACKBOX_FILES): $(FIR_ANNO)
	mkdir -p $(dir $@)
	$(BLACKBOX_RESOLVER) $^ -c $(BUILD_DIR) -f $@


################################################################################
# Verilator
################################################################################

include $(TOP_DIR)/verilator.mk

# Directories
MODEL_DIR := $(BUILD_DIR)/model
MODEL_DEBUG_DIR := $(BUILD_DIR)/model.debug

# Files
MODEL_HEADER = $(MODEL_DIR)/V$(TOP_MODULE).h
MODEL_DEBUG_HEADER = $(MODEL_DEBUG_DIR)/V$(TOP_MODULE).h

# Targets
MODEL_MK := $(MODEL_DIR)/V$(TOP_MODULE).mk
MODEL_DEBUG_MK := $(MODEL_DEBUG_DIR)/V$(TOP_MODULE).mk

$(MODEL_MK): $(SIM_COMMON_FILES) $(VERILOG_FILES)
	verilator --cc --exe $(VERILATOR_OPTS) -o $(SIM) -Mdir $(MODEL_DIR) -CFLAGS "-include $(MODEL_HEADER)"

$(MODEL_DEBUG_MK): $(SIM_COMMON_FILES) $(VERILOG_FILES)
	verilator --cc --exe $(VERILATOR_OPTS) -o $(SIM_DEBUG) $(TRACING_OPTS) -Mdir $(MODEL_DEBUG_DIR) -CFLAGS "-include $(MODEL_DEBUG_HEADER)"


################################################################################
# DRAMSim library
################################################################################

# Directories
DRAMSIM_DIR = $(BOSSA_DIR)/tools/DRAMSim2

# Targets
DRAMSIM_LIB = $(DRAMSIM_DIR)/libdramsim.a

$(DRAMSIM_LIB):
	$(MAKE) -C $(DRAMSIM_DIR) $(notdir $@)


################################################################################
# Simulator targets
################################################################################

$(SIM): $(MODEL_MK) $(DRAMSIM_LIB) $(ISA_SIM_LIBFESVR)
	$(MAKE) VM_PARALLEL_BUILDS=1 OPT_FAST="-O3" -C $(MODEL_DIR) -f V$(TOP_MODULE).mk

$(SIM_DEBUG): $(MODEL_DEBUG_MK) $(DRAMSIM_LIB) $(ISA_SIM_LIBFESVR)
	$(MAKE) VM_PARALLEL_BUILDS=1 OPT_FAST="-O3" -C $(MODEL_DEBUG_DIR) -f V$(TOP_MODULE).mk
