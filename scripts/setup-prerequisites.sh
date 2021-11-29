#!/bin/bash
set -e

# Tests if the command exists.
updated=0
function test_cmd() {
  command -v $1 &> /dev/null
  local ret=$?
  if [ $ret -ne 0 ] && [ $updated -eq 0 ]; then
    apt-get update
    updated=1
  fi
  return $ret
}

# Prints messages to `stderr`.
function echoe() {
  echo -e "\033[31m\033[1m$1\033[0m" 1>&2
}

# Installs the specific package.
function install_pkg() {
  DEBIAN_FRONTEND="noninteractive" apt-get install -y $1
}

# Setup JDK
if ! test_cmd javac; then
  echoe "Setting up JDK..."
  # TODO: tzdata stucked
  install_pkg default-jdk
fi

# Setup build-essential
if ! test_cmd g++ || ! test_cmd make; then
  echoe "Setting up build-essential..."
  install_pkg build-essential
fi

# Setup Python 3
if ! test_cmd python3; then
  echoe "Setting up Python 3..."
  install_pkg python3
fi

# Setup Verilator
if ! test_cmd verilator; then
  echoe "Setting up Verilator..."
  install_pkg verilator
fi

# Setup device tree compiler
if ! test_cmd dtc; then
  echoe "Setting up device tree compiler..."
  install_pkg device-tree-compiler
fi

# Setup Git
if ! test_cmd git; then
  echoe "Setting up Git..."
  install_pkg git
fi
