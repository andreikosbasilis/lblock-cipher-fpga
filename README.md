# LBlock Lightweight Cipher: Hardware Implementation

*This project was developed collaboratively with my colleague Marianna Aisopou as part of our academic coursework. We divided the design modules and integrated the final datapath and control logic.*

## Project Overview

This is a collaborative academic project where we implemented the **LBlock** lightweight block cipher in hardware using **VHDL**.

Our hardware design supports both **Encryption** and **Decryption** and was simulated and verified using Xilinx Vivado on the **xczu7ev-ffvc1156-2-e** device part.

**Key Tools Used:**
* **RTL Design:** VHDL
* **Synthesis, Implementation, & Simulation:** Xilinx Vivado
* **Reference Model:** C


## Architecture

The design was implemented using a **top-down approach**. We split all functions into different modules, verified them separately, and then merged them to form the full architecture.

![LBlock Architecture](./img/lblock_diagram.png)


We designed a Finite State Machine (FSM) to control the modes of the design, allowing for loading inputs, encrypting, and decrypting separately.

![FSM](./img/fsm.png)

## Verification

We verified our results against the official test vectors provided in the original LBlock algorithm paper, as shown below:

![Test Vectors](./img/test_vectors.png)

To verify the intermediate results between rounds and to assist with debugging, we also wrote a software reference model of the LBlock algorithm in **C**.

**C Model Outputs:**
* **Encryption Results:**
  
  ![C Encryption](./img/c_encryption.png)
* **Decryption Results:**
  
  ![C Decryption](./img/c_decryption.png)
* **Final Results:**
  
  ![C Final](./img/c_final.png)

**Hardware Simulation:**
The RTL was simulated to ensure the waveforms perfectly matched the expected outputs from our C model.

* **Vivado Waveform for Encryption & Decryption:**
  ![Vivado Waveform](./img/vivado_waveform.png)


## Implementation Results

After synthesis and implementation on the target FPGA, we extracted the following performance metrics:

* **Utilization:**
  
  ![Utilization](./img/summary.png)

* **Power Consumption:**
  
  ![Power](./img/power.png)

**Conclusion:** The post-implementation reports demonstrate that the design consumes a very small amount of the device's logical resources and has a dynamic power consumption of only 19% of the total on-chip power, validating its "lightweight" nature.
