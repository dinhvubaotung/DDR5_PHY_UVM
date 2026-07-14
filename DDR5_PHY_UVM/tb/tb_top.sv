// Top-level UVM testbench for the DDR5 PHY DUT
`timescale 1ns / 1ps

// Import UVM package và TB package
`include "uvm_macros.svh"
import uvm_pkg::*;
import tb_pkg::*;

module tb_top;

    //==========================================================================
    // Clock Generation
    // DUT dùng 1 clock duy nhất (clk_i)
    // Chọn 10ns = 100MHz cho dễ quan sát trên waveform
    //==========================================================================
    parameter CLK_PERIOD = 10; // 10ns = 100MHz

    logic clk;
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    //==========================================================================
    // Instantiate Interface
    //==========================================================================
    ddr5_phy_if vif (.clk(clk));

    //==========================================================================
    // Instantiate DUT
    // Tham số:
    //   pDRAM_SIZE  = 4     → DQ 8-bit, mask 1-bit
    //   pNUM_RANK   = 2     → CS 2-bit
    //   pCRC_MODE   = 0     → MC tự tính CRC (không phải PHY)
    //                         → DQ output = wrdata trực tiếp (dễ verify)
    //   pFREQ_RATIO = 2'b01 → 1:2 ratio (dùng p0 và p1)
    //
    // QUAN TRỌNG: rst_i của DUT là ACTIVE-LOW (negedge rst_i trong RTL)
    //   Interface dùng tên rst_n (active-low) → nối thẳng vào rst_i DUT
    //   Driver kéo rst_n=0 để reset, rst_n=1 để normal operation
    //==========================================================================
    ddr5_phy_top #(
        .pDRAM_SIZE  (4      ),
        .pNUM_RANK   (2      ),
        .pCRC_MODE   (1'b1   ),
        .pFREQ_RATIO (2'b00  )   // 1:1 ratio
    ) dut (
        // ── Clock & Control ──────────────────────────────────────────────
        .clk_i              (clk            ),
        .rst_i              (vif.rst_n      ),  // active-LOW: 0=reset, 1=normal
        .enable_i           (vif.enable     ),

        // ── DFI CS & Reset ───────────────────────────────────────────────
        .dfi_cs_n_p0        (vif.dfi_cs_n_p0    ),
        .dfi_cs_n_p1        (vif.dfi_cs_n_p1    ),
        .dfi_cs_n_p2        (vif.dfi_cs_n_p2    ),
        .dfi_cs_n_p3        (vif.dfi_cs_n_p3    ),

        .dfi_reset_n_p0     (vif.dfi_reset_n_p0 ),
        .dfi_reset_n_p1     (vif.dfi_reset_n_p1 ),
        .dfi_reset_n_p2     (vif.dfi_reset_n_p2 ),
        .dfi_reset_n_p3     (vif.dfi_reset_n_p3 ),

        // ── DFI Address ──────────────────────────────────────────────────
        .dfi_address_p0     (vif.dfi_address_p0 ),
        .dfi_address_p1     (vif.dfi_address_p1 ),
        .dfi_address_p2     (vif.dfi_address_p2 ),
        .dfi_address_p3     (vif.dfi_address_p3 ),

        // ── DFI Write Enable ─────────────────────────────────────────────
        .dfi_wrdata_en_p0   (vif.dfi_wrdata_en_p0),
        .dfi_wrdata_en_p1   (vif.dfi_wrdata_en_p1),
        .dfi_wrdata_en_p2   (vif.dfi_wrdata_en_p2),
        .dfi_wrdata_en_p3   (vif.dfi_wrdata_en_p3),

        // ── DFI Write Data ───────────────────────────────────────────────
        .dfi_wrdata_p0      (vif.dfi_wrdata_p0  ),
        .dfi_wrdata_p1      (vif.dfi_wrdata_p1  ),
        .dfi_wrdata_p2      (vif.dfi_wrdata_p2  ),
        .dfi_wrdata_p3      (vif.dfi_wrdata_p3  ),

        // ── DFI Write Mask ───────────────────────────────────────────────
        .dfi_wrdata_mask_p0 (vif.dfi_wrdata_mask_p0),
        .dfi_wrdata_mask_p1 (vif.dfi_wrdata_mask_p1),
        .dfi_wrdata_mask_p2 (vif.dfi_wrdata_mask_p2),
        .dfi_wrdata_mask_p3 (vif.dfi_wrdata_mask_p3),

        // ── DRAM Output (PHY → DRAM) ─────────────────────────────────────
        .RESET_n            (vif.RESET_n    ),
        .CS_n               (vif.CS_n       ),
        .CA                 (vif.CA         ),
        .DQ                 (vif.DQ         ),
        .DQ_valid           (vif.DQ_valid   ),
        .DM                 (vif.DM         ),
        .DQS                (vif.DQS        ),
        .DQS_valid          (vif.DQS_valid  )
    );

    //==========================================================================
    // Đăng ký Virtual Interface vào UVM Config DB
    // Cú pháp: set(context, inst_path, key, value)
    //   - context = null → đăng ký toàn cục
    //   - inst_path = "uvm_test_top" → mọi component bên dưới test đều thấy
    //   - key = "vif" → tên để component gọi get()
    //==========================================================================
    initial begin
        uvm_config_db #(virtual ddr5_phy_if)::set(null, "uvm_test_top.*", "vif", vif);
    end

    //==========================================================================
    // Khởi động UVM — tên test lấy từ +UVM_TESTNAME=<tên>
    //==========================================================================
    initial begin
        run_test();
    end

    //==========================================================================
    // Dump waveform (tùy chọn)
    //==========================================================================
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);
    end


    //==========================================================================
    // Instantiate Assertion Module
    // Ket noi truc tiep vao interface de kiem tra giao thuc
    //==========================================================================
    ddr5_assertions u_assertions (
        .clk                  (clk                        ),
        .rst_n                (vif.rst_n                  ),
        .dfi_cs_n_p0          (vif.dfi_cs_n_p0            ),
        .dfi_address_p0       (vif.dfi_address_p0         ),
        .dfi_wrdata_en_p0     (vif.dfi_wrdata_en_p0       ),
        .dfi_wrdata_mask_p0   (vif.dfi_wrdata_mask_p0     ),
        .dfi_wrdata_p0        (vif.dfi_wrdata_p0          ),
        .CS_n                 (vif.CS_n                   ),
        .DQ_valid             (vif.DQ_valid               ),
        .DQS_valid            (vif.DQS_valid              ),
        .DQ                   (vif.DQ                     ),
        .DQS                  (vif.DQS                    )
    );

endmodule : tb_top
