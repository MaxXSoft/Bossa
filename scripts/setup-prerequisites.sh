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

# Installs the specific package.
function install_pkg() {
  apt-get install -y $1
}

# Setup JDK
if ! test_cmd javac; then
  echo "Setting up JDK..."
  install_pkg default-jdk
fi

# Setup build-essential
if ! test_cmd g++ || ! test_cmd make; then
  echo "Setting up build-essential..."
  install_pkg build-essential
fi

# Setup Python 3
if ! test_cmd python3; then
  echo "Setting up Python 3..."
  install_pkg python3
fi

# Setup Verilator
if ! test_cmd verilator; then
  echo "Setting up Verilator..."
  install_pkg verilator
fi

# Setup device tree compiler
if ! test_cmd dtc; then
  echo "Setting up device tree compiler..."
  install_pkg device-tree-compiler
fi

# Setup Git
if ! test_cmd git; then
  echo "Setting up Git..."
  install_pkg git
fi
