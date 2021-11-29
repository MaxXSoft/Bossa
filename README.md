# Boosa: BOOM's Simulation Accelerator

Bossa is a [Chipyard](https://github.com/ucb-bar/chipyard)-based framework designed to accelerate the BOOM simulation process.

Bossa keeps only the necessary components for simulating BOOM, and the submodules in Chipyard, such as Gemmini, Hwacha, IceNet, NVDLA, etc. are all removed.

Bossa will use [Frenda](https://github.com/MaxXSoft/Frenda) to incrementally compile the generated FIRRTL. This will be very helpful if you keep modifying the BOOM and then run simulation again and again, it can save you a lot of time.

Bossa currently supports only Verilator-based simulations.

## Prerequisites

* Ubuntu.
* JDK.
* C++ compiler and Make (`build-essential`).
* Python 3.7+.
* Verilator.
* Device tree compiler (for building `riscv-isa-sim`).
* Git.

You can run the following command to setup prerequisites on Ubuntu:

```sh
sudo scripts/setup-prerequisites.sh
```

## Getting Started

### Cloning and Setting Up Prerequisites

```sh
git clone --recursive --shallow-submodules --single-branch --depth 1 https://github.com/MaxXSoft/Bossa.git
sudo scripts/setup-prerequisites.sh
```

### Building for Simulation

```sh
cd sims/verilator
# build simulation for small BOOM
make CONFIG=SmallBoomConfig -j`nproc`
# or, enable multi-threading
make CONFIG=SmallBoomConfig VERILATOR_THREADS=8 -j`nproc`
# or, enable debugging with VCD waveform dump
make CONFIG=SmallBoomConfig debug -j`nproc`
# or, enable debugging with FST waveform dump
make CONFIG=SmallBoomConfig VERILATOR_FST_MODE=1 debug -j`nproc`
```

### Bulding and Running Simulator

```sh
cd sims/verilator
make CONFIG=SmallBoomConfig -j`nproc`
./simulator-SmallBoomConfig path/to/riscv/program
```

## Make Options Supported during Simulator Build

* `CONFIG`: the configuration class to give the parameters for the project (default `SmallBoomConfig`).
* `FRENDA_THREADS`: how many threads the incremental FIRRTL compiler will use (default `nproc`).
* `FRENDA_CLEAN_BUILD`: perform clean FIRRTL build instead of incremental FIRRTL build.
* `VERILATOR_THREADS`: how many threads the simulator will use (default 1).
* `VERILATOR_FST_MODE`: enable FST waveform instead of VCD. use with debug build.
* `TOP_MODULE`: the top level module of the project (default `TestHarness`).
* `VERILATOR_OPT_FLAGS`: Verilator optimization flags (default `-O2 --x-assign fast --x-initial fast --output-split 30000 --output-split-cfuncs 30000`).
