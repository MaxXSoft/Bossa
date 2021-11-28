#!/bin/bash
set -e

# Tests if the command exists.
function test_cmd() {
  command -v $1 &> /dev/null
  ret=$?
  if [ $ret -ne 0 ]; then
    apt-get update
  fi
  exit $ret
}

# Setup JDK
if ! test_cmd javac; then
  echo "Setting up JDK..."
  apt install default-jdk
fi

# Setup build-essential
if ! test_cmd g++ || ! test_cmd make; then
  echo "Setting up build-essential..."
  apt-get install -y build-essential
fi

# Setup Python 3
if ! test_cmd python3; then
  echo "Setting up Python 3..."
  apt-get install -y python3
fi

# Setup Verilator
if ! test_cmd verilator; then
  echo "Setting up Verilator..."
  apt-get install -y verilator
fi

# Setup device tree compiler
if ! test_cmd dtc; then
  echo "Setting up device tree compiler..."
  apt-get install -y device-tree-compiler
fi

# Setup Git
if ! test_cmd git; then
  echo "Setting up Git..."
  apt-get install -y git
fi
