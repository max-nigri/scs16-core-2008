# SCS16 Core (2008 Release)

Project by **Max Nigri** — [GitHub](https://github.com/max-nigri) · [LinkedIn](https://www.linkedin.com/in/maxnigri)


## Overview
**SCS16** is a microcontroller core featuring a **16-bit datapath** and **single-cycle instruction execution**.  
Development of the SCS16 architecture began in **2003**, and this repository makes the **2008 version** publicly available for the first time.

The core was designed to be **highly efficient**, serving as a **programmable alternative to traditional finite state machines (FSMs)** — allowing hardware control flows to be expressed in code rather than hardwired logic.

---

## Historical Context
In the early 2000s, **communication standards** were rapidly evolving, and semiconductor companies were developing ASICs to handle various layers of the **network stack**.

At that time:
- Typical ASIC clock speeds were only a few hundred MHz.  
- At network rates of **100 Mbps**, engineers had fewer than **1000 clock cycles** to inspect and process each data packet.  
- Traditionally, such control logic was implemented using **FSMs**, which are inherently **fixed** — once fabricated, they cannot be modified to support changes in protocol or flow.

---

## Motivation
This limitation inspired the creation of **SCS16**, a **single-cycle programmable controller** designed to replace FSMs in communication and data-path designs.

Instead of hardcoding behavior into logic states, the SCS16 allows engineers to:
- Express control flows in a simple, **C-like language**.  
- **Reprogram** and **update** flow behavior even after production.  
- Maintain **FSM-level performance** while achieving software-like **flexibility**.

---

## Key Advantages
- ⚡ **Single-cycle performance** — as fast as dedicated FSM logic.  
- 🧠 **Programmable flexibility** — flow logic can be modified post-silicon.  
- 🧩 **Compact design** — suitable for integration into ASICs or FPGAs.  
- 🔁 **Ideal for network processors**, communication controllers, and hardware-based protocol engines.

---

## Summary
In short, the **SCS16 core** combines the **speed of an FSM** with the **adaptability of software**, bridging the gap between hardwired control and reconfigurable intelligence.

---

**Keywords:** scs16, microcontroller-core, fsm, single-cycle, asic, fpga, network-processing, hardware-design, reconfigurable-logic, 16-bit, programmable-hardware


## Directory Structure

### `docs/`
Start here.  
- Begin with the **Executive Summary**, then the **Overview** PDFs.  
- Next, review the presentations:
  - `zorba_cores5`
  - `scsu`
  - `packet_filtering_use_case`
- Finally, check out the **QRC (Quick Reference Card)** for a concise summary.

---

### `scs16_comp/`
Contains the **compiler and translator**, written in **Perl**.

Tools included:
- **`scs16_asm.pl <customer_script>`**  
  Takes a user script and generates the **microcode file** for the simulator, along with multiple debug and visualization outputs.  
- **`scs16_line.pl`**  
  Allows compilation of a single line directly from the shell prompt — convenient for quick tests.

---

### `scripts/`
Holds **user-level C-like code examples** using the `.scs` file extension.  
Most should compile successfully, though minor dependency issues may occur.

---

### `verilog/`
Contains all **HDL source files** (Verilog) and **testbench collateral**.  
- The reference simulator is **ModelSim**.  
- `.do` simulation scripts are provided and may require small adjustments depending on your environment.

---

### `examples/`
Includes several **application-specific use cases**.  
Navigate into any subfolder and compile the script — it will create an `out/` directory with the generated **microcode** and related **simulation collateral**.

---

### `regressions/`
Contains selected **test cases** and **use scenarios** that were used during the core’s original development and verification process.










