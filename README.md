🔵 FPGA Single-Layer Neural Network Inference (VHDL)

Hardware implementation of a single-layer Fully Connected neural network on the Intel/Altera DE2-115 FPGA board.
The design performs fixed-point inference using dedicated MAC hardware, ROM-based weights, and an FSM-controlled datapath.

🧠 Project Overview

This project was developed as part of an academic hardware design course.
It demonstrates how a simple neural network can be accelerated using FPGA resources by implementing:

Fixed-point arithmetic

A custom Multiply–Accumulate (MAC) hardware block

ROM-based weight storage

A deterministic, cycle-accurate control FSM

RTL design in VHDL + ModelSim simulation + Quartus compilation for DE2-115

The project includes a full PDF report (~80 pages) detailing the architecture, implementation, results, and design trade-offs.

🔧 Key Features

Single-layer Fully Connected neural network (FC)

MAC hardware unit for multiply–accumulate operations

Fixed-point quantization for efficient FPGA resource usage

Weight ROMs using Intel .mif files

Top-level RTL architecture in VHDL

Control FSM managing loading, computation, and output

Testbenches for every major module (MAC, FC, top)

Compatible with DE2-115 Cyclone IV FPGA board

Fully synthesizable design verified with Quartus & ModelSim

⚙️ Applications

Hardware acceleration

Real-time neural inference

Edge AI on low-cost FPGAs

Educational FPGA/ML demonstration

Deterministic ML cores for embedded systems


packages/   – VHDL packages (types, constants, fixed-point)
rtl/        – RTL VHDL source code (MAC, FC layer, ROM, FSM, top level)
mif/        – Memory Initialization Files (.mif) for network weights and inputs
tb/         – Testbenches + ModelSim scripts
quartus/    – Quartus project (.qpf, .qsf, constraints)
docs/       – Full project report (PDF) and architecture diagrams
README.md   – Project overview (this file)
LICENSE     – MIT License


📘 Documentation

A full project report (~80 pages) is included, containing:

System architecture

Neural model description

Fixed-point math

RTL block diagrams

MAC datapath explanation

State machine description

Simulation results (ModelSim)

Synthesis + resource utilization on DE2-115

Timing closure and hardware verification

📄 Full Report: docs/Project_Report.pdf

📦 Downloadable ZIP Package

A downloadable ZIP containing the full Quartus project, RTL source, weight files, and diagrams will be added soon.


👨‍💻 Author

Naor David
FPGA & Embedded Systems Engineer

💡 Hardware-accelerated AI. Cycle-accurate. Fully deterministic.
