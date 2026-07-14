/*==============================================================================
** File    : tb_top_6400.sv
** Purpose : Testbench cho DDR5-6400 Speed Test
**
** DDR5-6400 theo JEDEC:
**   Data Rate   = 6400 MT/s
**   Clock (PHY) = 3200 MHz  →  period = 0.3125 ns = 312.5 ps
**
** Khác biệt duy nhất so với tb_top.sv:
**   - half-period = 156 ps → period = 312 ps ≈ 0.312 ns (3205 MHz)
**   - Module name = tb_top_6400
**   - Mọi thứ khác: giữ nguyên hoàn toàn
==============================================================================*/

`timescale 1ps / 1fs

`include "uvm_macros.svh"
import uvm_pkg::*;
import tb_pkg::*;

module tb_top_6400;

    // DDR5-6400: clock 3200 MHz → half period = 156 ps
    logic clk;
    initial clk = 0;
    always #156 clk = ~clk;   // 156ps × 2 = 312ps ≈ 0.3125ns (3205 MHz)

    // Dùng lại interface GỐC
    ddr5_phy_if vif (.clk(clk));

    ddr5_phy_top #(
        .pDRAM_SIZE  (4     ),
        .pNUM_RANK   (2     ),
        .pCRC_MODE   (1'b1  ),
        .pFREQ_RATIO (2'b00 )
    ) dut (
        .clk_i              (clk                    ),
        .rst_i              (vif.rst_n              ),
        .enable_i           (vif.enable             ),
        .dfi_cs_n_p0        (vif.dfi_cs_n_p0        ),
        .dfi_cs_n_p1        (vif.dfi_cs_n_p1        ),
        .dfi_cs_n_p2        (vif.dfi_cs_n_p2        ),
        .dfi_cs_n_p3        (vif.dfi_cs_n_p3        ),
        .dfi_reset_n_p0     (vif.dfi_reset_n_p0     ),
        .dfi_reset_n_p1     (vif.dfi_reset_n_p1     ),
        .dfi_reset_n_p2     (vif.dfi_reset_n_p2     ),
        .dfi_reset_n_p3     (vif.dfi_reset_n_p3     ),
        .dfi_address_p0     (vif.dfi_address_p0     ),
        .dfi_address_p1     (vif.dfi_address_p1     ),
        .dfi_address_p2     (vif.dfi_address_p2     ),
        .dfi_address_p3     (vif.dfi_address_p3     ),
        .dfi_wrdata_en_p0   (vif.dfi_wrdata_en_p0   ),
        .dfi_wrdata_en_p1   (vif.dfi_wrdata_en_p1   ),
        .dfi_wrdata_en_p2   (vif.dfi_wrdata_en_p2   ),
        .dfi_wrdata_en_p3   (vif.dfi_wrdata_en_p3   ),
        .dfi_wrdata_p0      (vif.dfi_wrdata_p0      ),
        .dfi_wrdata_p1      (vif.dfi_wrdata_p1      ),
        .dfi_wrdata_p2      (vif.dfi_wrdata_p2      ),
        .dfi_wrdata_p3      (vif.dfi_wrdata_p3      ),
        .dfi_wrdata_mask_p0 (vif.dfi_wrdata_mask_p0 ),
        .dfi_wrdata_mask_p1 (vif.dfi_wrdata_mask_p1 ),
        .dfi_wrdata_mask_p2 (vif.dfi_wrdata_mask_p2 ),
        .dfi_wrdata_mask_p3 (vif.dfi_wrdata_mask_p3 ),
        .RESET_n            (vif.RESET_n            ),
        .CS_n               (vif.CS_n               ),
        .CA                 (vif.CA                 ),
        .DQ                 (vif.DQ                 ),
        .DQ_valid           (vif.DQ_valid           ),
        .DM                 (vif.DM                 ),
        .DQS                (vif.DQS                ),
        .DQS_valid          (vif.DQS_valid          )
    );

    initial begin
        uvm_config_db #(virtual ddr5_phy_if)::set(null, "uvm_test_top.*", "vif", vif);
        $display("==============================================================");
        $display("  SPEED TEST : DDR5-6400");
        $display("  Clock      : ~3205 MHz  (half-period = 156 ps)");
        $display("  Data Rate  : ~6400 MT/s");
        $display("==============================================================");
    end

    initial begin
        run_test();
    end

    initial begin
        $dumpfile("dump_6400.vcd");
        $dumpvars(0, tb_top_6400);
    end

    ddr5_assertions u_assertions (
        .clk                (clk                    ),
        .rst_n              (vif.rst_n              ),
        .dfi_cs_n_p0        (vif.dfi_cs_n_p0        ),
        .dfi_address_p0     (vif.dfi_address_p0     ),
        .dfi_wrdata_en_p0   (vif.dfi_wrdata_en_p0   ),
        .dfi_wrdata_mask_p0 (vif.dfi_wrdata_mask_p0 ),
        .dfi_wrdata_p0      (vif.dfi_wrdata_p0      ),
        .CS_n               (vif.CS_n               ),
        .DQ_valid           (vif.DQ_valid           ),
        .DQS_valid          (vif.DQS_valid          ),
        .DQ                 (vif.DQ                 ),
        .DQS                (vif.DQS                )
    );

endmodule : tb_top_6400
