# Boosa: BOOM's Simulation Accelerator

Bossa is a [Chipyard](https://github.com/ucb-bar/chipyard)-based framework designed to accelerate the BOOM simulation process.

Bossa keeps only the necessary components for simulating BOOM, and the submodules in Chipyard, such as Gemmini, Hwacha, IceNet, NVDLA, etc. are all removed.

Bossa will use [Frenda](https://github.com/MaxXSoft/Frenda) to incrementally compile the generated FIRRTL. This will be very helpful if you keep modifying the BOOM and then run simulation again and again, it can save you a lot of time.

Bossa currently supports only Verilator-based simulations.

## Prerequisites

* Ubuntu.
* JDK.
* C++ compiler.
* Python 3.7+.
* Verilator.
* Device tree compiler (for building `riscv-isa-sim`).

You can run the following command to setup prerequisites on Ubuntu:

```sh
sudo make setup
```

## Getting Started

### Setting Up Prerequisites

```sh
sudo make setup
```

### Building for Simulation

```sh
cd sims/verilator
# build simulation for small BOOM
make CONFIG=SmallBoomConfig -j`nproc`
# or, enable multi-threading
make CONFIG=SmallBoomConfig THREADS=8 -j`nproc`
# or, enable debugging with VCD waveform dump
make CONFIG=SmallBoomConfig debug -j`nproc`
# or, enable debugging with FST waveform dump
make CONFIG=SmallBoomConfig FST_MODE=1 debug -j`nproc`
```

### Bulding and Running Simulator

```sh
cd sims/verilator
make CONFIG=SmallBoomConfig -j`nproc`
./simulator-SmallBoomConfig path/to/riscv/program
```
