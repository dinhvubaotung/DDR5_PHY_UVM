# DDR5 PHY UVM Verification Project

A professional RTL verification project for a DDR5 PHY design, implemented in SystemVerilog and UVM.

## Overview

This repository demonstrates a complete verification environment for a DDR5 PHY DUT. It focuses on:

- RTL implementation of the write path
- UVM-based testbench structure
- Transaction-driven stimulus generation
- Scoreboard and reference model checking
- Functional coverage collection
- Simulation flows for baseline and speed-oriented verification

## Repository structure

- `rtl/` — DUT RTL modules (referrence from https://github.com/Shehab-Naga/ddr5_phy)
- `tb/` — UVM testbench, interface, sequences, scoreboard, coverage, and tests
- `sim/` — simulation scripts and generated artifacts
- `images/` — Documentation images and diagrams (extracted from project report)

## What is verified

- Write transactions and burst behavior
- Rank-aware command handling
- Data masking scenarios
- CRC-related flow integration
- Speed-oriented tests for DDR5-3200 and DDR5-6400 configurations

## Prerequisites

You will need one of the following simulators:

- Siemens QuestaSim
- Mentor ModelSim

And a shell environment with `make`, such as:

- msys2
- Git Bash on Windows
- WSL
- Linux/macOS terminal

## Quick start

From the project root:

```bash
make compile_all
make sim
```

### Useful targets

```bash
make compile
make compile_speed
make sim
make sim_3200
make sim_6400
make regression
make clean
```


## Example commands

```bash
make sim | tee sim/ddr5_single_write_test.log
make sim_3200 | tee sim/ddr5_3200_speed_test.log
make sim_6400 | tee sim/ddr5_6400_speed_test.log
```

## Acknowledgments

The DDR5 PHY RTL design is based on and derived from the following open-source project:

- [Shehab-Naga/ddr5_phy](https://github.com/Shehab-Naga/ddr5_phy) — DDR5 PHY Graduation project (Verification Team) under supervision of Si-Vision

T