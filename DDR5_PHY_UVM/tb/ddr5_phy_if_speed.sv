

`timescale 1ps / 1ps

interface ddr5_phy_if_speed (input logic clk);

    //==========================================================================
    // Tín hiệu phía MC → PHY (Driver drive)
    //==========================================================================
    logic        rst_n;
    logic        enable;

    logic [1:0]  dfi_cs_n_p0, dfi_cs_n_p1, dfi_cs_n_p2, dfi_cs_n_p3;
    logic [1:0]  dfi_reset_n_p0, dfi_reset_n_p1, dfi_reset_n_p2, dfi_reset_n_p3;
    logic [13:0] dfi_address_p0, dfi_address_p1, dfi_address_p2, dfi_address_p3;
    logic        dfi_wrdata_en_p0, dfi_wrdata_en_p1, dfi_wrdata_en_p2, dfi_wrdata_en_p3;
    logic [7:0]  dfi_wrdata_p0, dfi_wrdata_p1, dfi_wrdata_p2, dfi_wrdata_p3;
    logic [0:0]  dfi_wrdata_mask_p0, dfi_wrdata_mask_p1,
                 dfi_wrdata_mask_p2, dfi_wrdata_mask_p3;

    //==========================================================================
    // Tín hiệu phía PHY → DRAM (Monitor đọc)
    //==========================================================================
    logic [1:0]  CS_n;
    logic [13:0] CA;
    logic [7:0]  DQ;
    logic        DQ_valid;
    logic [0:0]  DM;
    logic [1:0]  DQS;
    logic        DQS_valid;
    logic [1:0]  RESET_n;

    clocking mc_cb @(posedge clk);
        default input #50ps output #50ps;  // <-- khác với gốc (1ns)

        output rst_n, enable;
        output dfi_cs_n_p0, dfi_cs_n_p1, dfi_cs_n_p2, dfi_cs_n_p3;
        output dfi_reset_n_p0, dfi_reset_n_p1, dfi_reset_n_p2, dfi_reset_n_p3;
        output dfi_address_p0, dfi_address_p1, dfi_address_p2, dfi_address_p3;
        output dfi_wrdata_en_p0, dfi_wrdata_en_p1, dfi_wrdata_en_p2, dfi_wrdata_en_p3;
        output dfi_wrdata_p0, dfi_wrdata_p1, dfi_wrdata_p2, dfi_wrdata_p3;
        output dfi_wrdata_mask_p0, dfi_wrdata_mask_p1,
               dfi_wrdata_mask_p2, dfi_wrdata_mask_p3;

        input  CS_n, CA, DQ, DQ_valid, DM, DQS, DQS_valid, RESET_n;
    endclocking

    clocking dram_cb @(posedge clk);
        default input #50ps;
        input  CS_n, CA, DQ, DQ_valid, DM, DQS, DQS_valid, RESET_n;
    endclocking

    modport DRIVER  (input clk,
                     output rst_n, enable,
                     output dfi_cs_n_p0, dfi_cs_n_p1, dfi_cs_n_p2, dfi_cs_n_p3,
                     output dfi_reset_n_p0, dfi_reset_n_p1, dfi_reset_n_p2, dfi_reset_n_p3,
                     output dfi_address_p0, dfi_address_p1, dfi_address_p2, dfi_address_p3,
                     output dfi_wrdata_en_p0, dfi_wrdata_en_p1, dfi_wrdata_en_p2, dfi_wrdata_en_p3,
                     output dfi_wrdata_p0, dfi_wrdata_p1, dfi_wrdata_p2, dfi_wrdata_p3,
                     output dfi_wrdata_mask_p0, dfi_wrdata_mask_p1,
                            dfi_wrdata_mask_p2, dfi_wrdata_mask_p3);

    modport MONITOR (input clk, CS_n, CA, DQ, DQ_valid, DM, DQS, DQS_valid, RESET_n);
    modport PASSIVE (input clk, CS_n, CA, DQ, DQ_valid, DM, DQS, DQS_valid, RESET_n,
                     input dfi_cs_n_p0, dfi_address_p0, dfi_wrdata_en_p0,
                           dfi_wrdata_p0, dfi_wrdata_p1, dfi_wrdata_p2, dfi_wrdata_p3,
                           dfi_wrdata_mask_p0);

endinterface : ddr5_phy_if_speed
