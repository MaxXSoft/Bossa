# Boosa: BOOM's Simulation Accelerator

Bossa is a [Chipyard](https://github.com/ucb-bar/chipyard)-based framework designed to accelerate the BOOM simulation process.

Bossa keeps only the necessary components for simulating BOOM, and the submodules in Chipyard, such as Gemmini, Hwacha, icenet, NVDLA, etc. are all removed.

Bossa will use [Frenda](https://github.com/MaxXSoft/Frenda) to incrementally compile the generated FIRRTL. This will be very helpful if you keep modifying the BOOM and then run simulation again and again, it can save you a lot of time.

## Getting Started

> WIP.
