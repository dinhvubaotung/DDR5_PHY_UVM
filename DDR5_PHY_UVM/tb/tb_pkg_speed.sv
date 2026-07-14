`ifndef TB_PKG_SPEED_SV
`define TB_PKG_SPEED_SV

package tb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // 1. Transaction item
    `include "ddr5_write_seq_item.sv"

    // 2. Reference Model CRC
    `include "ddr5_ref_model.sv"

    // 3. DRAM observation item + DRAM Monitor (dùng lại class gốc)
    `include "ddr5_dram_monitor.sv"

    // 4. Scoreboard (dùng lại)
    `include "ddr5_scoreboard.sv"

    // 5. Coverage (dùng lại)
    `include "ddr5_coverage.sv"

    // 6. MC Driver và Monitor gốc (cần để dùng chung class)
    `include "ddr5_mc_driver.sv"
    `include "ddr5_mc_monitor.sv"

    // 7. Cấu trúc UVM gốc (cần vì ddr5_speed_env kế thừa)
    `include "ddr5_uvm_components.sv"

    // 8. Sequences và Tests gốc (bao gồm ddr5_speed_seq)
    `include "ddr5_tests.sv"

    // 9. Speed test environment và tests
    //    (dùng ddr5_phy_if_speed thay vì ddr5_phy_if)
    `include "ddr5_speed_env.sv"

endpackage : tb_pkg

`endif // TB_PKG_SPEED_SV
