################################################################################
# Toolchain settings
################################################################################

# Directories
BOSSA_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
JAVA_TMP_DIR := $(BOSSA_DIR)/.java_tmp

# SBT
SBT_JAR := $(BOSSA_DIR)/generators/rocket-chip/sbt-launch.jar
SBT := java -Xmx8G -Xss8M -XX:MaxPermSize=256M -Djava.io.tmpdir=$(JAVA_TMP_DIR) -jar $(SBT_JAR)
SBT_BOSSA := cd $(BOSSA_DIR) && $(SBT)

# Blackbox resolver
BLACKBOX_RESOLVER := $(BOSSA_DIR)/scripts/blackbox_resolver.py -r $(BOSSA_DIR)
