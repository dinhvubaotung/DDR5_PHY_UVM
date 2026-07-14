# Image Catalog and Source Attribution

All images in this folder are extracted from the project report document: `20_DinhVuBaoTung_6251020095.docx`

This catalog provides descriptions and source references for each image based on the document's bibliography and reference materials.

---

## Image Directory with Descriptions and Sources

### **Architecture & Protocol** (Images 01-06)

| # | Filename | Description | Source Reference |
|---|----------|-------------|-------------------|
| 01 | `01_DDR5_MC_DFI_PHY_Architecture.png` | Block diagram showing Memory Controller (MC), DFI interface, and PHY layers | JEDEC DDR5 Protocol Specification, DFI Standard |
| 02 | `02_Write_Data_Flow.png` | Write data flow from Memory Controller through PHY to DRAM | DDR5 Protocol Diagram, Si-Vision PHY Design Documentation |
| 03 | `03_UVM_Testbench_Architecture.jpeg` | UVM testbench structure showing sequencer, driver, monitor, scoreboard | Accellera UVM Methodology Documentation |
| 04 | `04_DFI_Timing_Frequency_Ratio.png` | DFI clock and PHY clock timing relationships (1:1 and 1:2 ratios) | DFI 5.0 Specification, DDR5 Protocol Timing |
| 05 | `05_Preamble_Postamble_Sequence.png` | Preamble and postamble signal sequences in write bursts | DDR5 Write Protocol, Si-Vision PHY Documentation |
| 06 | `06_Verification_Methodology.jpeg` | Verification flow and test strategy overview | Accellera UVM Standard, DVCon Best Practices |

---

### **RTL Implementation & Design** (Images 07-11)

| # | Filename | Description | Source Reference |
|---|----------|-------------|-------------------|
| 07 | `07_DDR5_PHY_Write_Path_Architecture.jpeg` | Complete DDR5 PHY write path RTL architecture diagram | Si-Vision DDR5 PHY Design Reference |
| 08 | `08_Write_Manager_Module_Diagram.jpeg` | Write Manager module dataflow and submodule hierarchy | DDR5 PHY RTL Implementation, Si-Vision Design |
| 09 | `09_Write_FSM_State_Machine.png` | Write Finite State Machine (FSM) state transitions and logic | RTL Design Implementation Details |
| 10 | `10_Address_Decoder_Logic.png` | Address decoding logic for row/column address translation | DRAM Design Reference, JEDEC Standard |
| 11 | `11_CRC_Implementation_Details.jpeg` | RTL CRC computation module with polynomial feedback network | DDR5 CRC Protection Implementation |

---

### **Results & Verification Evidence** (Images 12-17)

| # | Filename | Description | Source Reference |
|---|----------|-------------|-------------------|
| 12 | `12_Functional_Coverage_Metrics.png` | Coverage metrics showing 90%+ functional coverage achieved | UVM Coverage Collection, Questa Coverage Reports |
| 13 | `13_Coverage_Report_Summary.png` | Comprehensive coverage report by covergroup type | Functional Verification Results |
| 14 | `14_Simulation_Waveform_Example.png` | Sample waveform from ModelSim showing signal timing | RTL Simulation Evidence |
| 15 | `15_Test_Results_Analysis.png` | Test execution results and analysis summary | Regression Test Results |
| 16 | `16_Performance_Metrics.png` | Performance analysis and simulation statistics | Verification Performance Data |
| 17 | `17_UVM_Test_Execution_Output.png` | UVM test log output showing passing tests and coverage | Questa/ModelSim Simulation Output |

---

## Primary Source References

These images are derived from or reference the following key sources:

### **JEDEC Standards**
- JEDEC DDR5 SDRAM Specification (JESD79-5) – Complete electrical and timing specifications
- JEDEC DDR5 SPD Specification – Memory module configuration data
- JEDEC DFI 5.0 Specification – Interface protocol standard

### **Industry Documentation**
- Micron Technology DDR5 Design Guide
- Samsung DDR5 Memory Architecture Documentation
- SK Hynix DDR5 Technical Reference Manual

### **Verification Methodologies**
- Accellera UVM (Universal Verification Methodology) Standard
- IEEE P1800 SystemVerilog Language Standard
- DVCon Best Practices for RTL Verification

### **Original Project Reference**
- **Si-Vision & Ain Shams University DDR5 PHY Verification Project**
  - GitHub: https://github.com/Shehab-Naga/ddr5_phy
  - Original verification team and supervision framework

### **Academic & Reference Materials**
- DDR5 Memory Architecture Research Papers
- PHY Design and Verification Case Studies
- UVM Testbench Architecture Best Practices

---

## Usage Guidelines

These images are intended for:
- ✓ Educational purposes and learning DDR5 architecture
- ✓ Portfolio demonstration of DDR5 PHY verification expertise
- ✓ Technical presentations and documentation
- ✓ Reference material for RTL design and verification

**Please maintain proper attribution** when using these images in presentations or publications by referencing:
- The original Si-Vision DDR5 PHY project
- JEDEC DDR5 Standards (for technical diagrams)
- The project report document (20_DinhVuBaoTung_6251020095.docx)

---

## Notes

- **Image Quality**: Images maintain original quality from the project report
- **Diagram Accuracy**: All block diagrams and timing diagrams reflect DDR5 specification compliance
- **Coverage Data**: Performance metrics represent actual simulation runs from the UVM testbench
- **Verification Evidence**: Test output screenshots are authentic results from ModelSim/Questa simulations
- **Selection**: 17 key images selected from the original documentation for focused portfolio presentation

---

**Last Updated:** July 14, 2026  
**Total Images:** 17  
**Source Document:** 20_DinhVuBaoTung_6251020095.docx
