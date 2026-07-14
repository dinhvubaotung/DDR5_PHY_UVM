`ifndef TB_PKG_SV
`define TB_PKG_SV

package tb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // 1. Transaction item
    `include "ddr5_write_seq_item.sv"

    // 2. Reference Model CRC - Mo ta thuat toan CRC cua DUT
    `include "ddr5_ref_model.sv"

    // 3. DRAM observation item + DRAM Monitor
    `include "ddr5_dram_monitor.sv"

    // 4. Scoreboard
    `include "ddr5_scoreboard.sv"

    // 5. Coverage
    `include "ddr5_coverage.sv"

    // 6. MC Driver va MC Monitor
    `include "ddr5_mc_driver.sv"
    `include "ddr5_mc_monitor.sv"

    // 7. Cau truc: Sequencer, Agent, Env
    `include "ddr5_uvm_components.sv"

    // 8. Sequences va Tests
    `include "ddr5_tests.sv"

endpackage : tb_pkg

`endif // TB_PKG_SV
