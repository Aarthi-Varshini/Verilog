<h1 align = "center"> VERILOG HDL PORTFOLIO </h1>

## 1. OVERVIEW:
This folder contains four digital design projects implemented using Verilog Hardware Description Language (HDL). These projects demonstrate fundamental RTL design concepts, digital circuit design, memory operations, serial communication, and Clock Domain Crossing (CDC).

Each project includes RTL design files, testbenches, verification test cases, and simulation results.

## 2. 📂 PROJECT DIRECTORY OVERVIEW:
| S.No. | Project Name | Description | Key Architectural Highlights |
|---|---|---|---|
| 1 | [UART](./UART/) | Implements asynchronous serial communication using UART protocol, supporting parallel-to-serial transmission and serial-to-parallel reception. | • Finite State Machine (FSM) control logic <br> • Serial-to-parallel and parallel-to-serial conversion <br> • Start, data, and stop bit handling|
| 2 | [RAM](./RAM/) | Implements a memory module supporting data storage and retrieval through address-based read and write operations. | • Memory array implementation <br> • Address-based read and write operations <br> • Write enable control logic <br> • Data storage and retrieval|
| 3 | [Synchronous FIFO](./Synchronous_FIFO/) | Implements a First-In, First-Out (FIFO) buffer using a single clock domain with read/write pointer management and full/empty flag handling. |• Read and write pointer management <br> • FIFO operation <br> • FULL and EMPTY status flag handling|
| 4 | [Asynchronous FIFO](./Asynchronous_FIFO/) | Implements a FIFO buffer with independent read and write clock domains, including pointer synchronization for clock domain crossing. | • Independent read and write clock domains <br> • Binary-to-Gray pointer conversion <br> • Pointer synchronization across clock domains <br> • Full and empty status flag handling|

## 3. 🛠️ VERIFICATION & SIMULATION STACK:
All projects include dedicated Verilog testbenches to verify their functionality through different test scenarios, console outputs, and waveform analysis.
- **HDL:** Verilog HDL
- **Simulation:** Icarus Verilog
- **Waveform Analysis:** GTKWave

## 4. 🗂️ REPOSITORY STRUCTURE:
``` text
Verilog/
├── UART/
├── RAM/
├── Synchronous_FIFO/
└── Asynchronous_FIFO/
```
## 5. 📚 KEY LEARNINGS:
- RTL design using Verilog HDL
- Finite State Machine (FSM) implementation
- Memory read and write operations
- FIFO architecture and pointer management
- Clock Domain Crossing (CDC) fundamentals
- Testbench development and functional verification
- Simulation and waveform analysis
---
