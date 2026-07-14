

`timescale 1ns / 1ps

interface ddr5_phy_if (input logic clk);

    //==========================================================================
    // [1] PHÍA MC → PHY : Driver sẽ ghi vào các tín hiệu này
    //==========================================================================

    // Reset và Enable
    // rst_i: active-LOW async reset (kéo xuống 0 để reset DUT)
    logic        rst_n;       // ánh xạ tới rst_i của DUT (chú ý: đảo tên cho rõ)
    logic        enable;      // ánh xạ tới enable_i

    // Chip Select: active-LOW, [1:0] = 2 rank
    // Để chọn rank 0: dfi_cs_n_p0 = 2'b10 (bit[0]=0 là active)
    // Để deselect:    dfi_cs_n_p0 = 2'b11
    logic [1:0]  dfi_cs_n_p0, dfi_cs_n_p1, dfi_cs_n_p2, dfi_cs_n_p3;

    // DRAM Reset: active-LOW
    logic [1:0]  dfi_reset_n_p0, dfi_reset_n_p1, dfi_reset_n_p2, dfi_reset_n_p3;

    // Address/Command: 14-bit, encode lệnh WRITE theo DDR5 JEDEC
    logic [13:0] dfi_address_p0, dfi_address_p1, dfi_address_p2, dfi_address_p3;

    // Write Enable: 1 = có data hợp lệ trên dfi_wrdata
    logic        dfi_wrdata_en_p0, dfi_wrdata_en_p1, dfi_wrdata_en_p2, dfi_wrdata_en_p3;

    // Write Data: 8-bit mỗi phase (2 * pDRAM_SIZE = 2*4 = 8)
    logic [7:0]  dfi_wrdata_p0, dfi_wrdata_p1, dfi_wrdata_p2, dfi_wrdata_p3;

    // Write Data Mask: 1-bit mỗi phase (pDRAM_SIZE/4 = 4/4 = 1)
    // 0 = data hợp lệ, 1 = mask (bỏ qua byte đó)
    logic [0:0]  dfi_wrdata_mask_p0, dfi_wrdata_mask_p1,
                 dfi_wrdata_mask_p2, dfi_wrdata_mask_p3;

    //==========================================================================
    // [2] PHÍA PHY → DRAM : Monitor sẽ đọc các tín hiệu này (wire, không drive)
    //==========================================================================

    // Chip Select tới DRAM chip
    logic [1:0]  CS_n;

    // Command/Address tới DRAM chip
    logic [13:0] CA;

    // Data bus tới DRAM chip (8-bit = 2*4)
    logic [7:0]  DQ;
    logic        DQ_valid;

    // Data Mask tới DRAM chip
    logic [0:0]  DM;

    // Data Strobe
    logic [1:0]  DQS;
    logic        DQS_valid;

    // DRAM Reset output
    logic [1:0]  RESET_n;


    clocking mc_cb @(posedge clk);
        default input  #1ns output #1ns;

        // Driver ghi vào những tín hiệu này (output từ góc nhìn TB)
        output rst_n;
        output enable;
        output dfi_cs_n_p0, dfi_cs_n_p1, dfi_cs_n_p2, dfi_cs_n_p3;
        output dfi_reset_n_p0, dfi_reset_n_p1, dfi_reset_n_p2, dfi_reset_n_p3;
        output dfi_address_p0, dfi_address_p1, dfi_address_p2, dfi_address_p3;
        output dfi_wrdata_en_p0, dfi_wrdata_en_p1, dfi_wrdata_en_p2, dfi_wrdata_en_p3;
        output dfi_wrdata_p0, dfi_wrdata_p1, dfi_wrdata_p2, dfi_wrdata_p3;
        output dfi_wrdata_mask_p0, dfi_wrdata_mask_p1, dfi_wrdata_mask_p2, dfi_wrdata_mask_p3;

        // Monitor đọc output của DUT (input từ góc nhìn TB)
        input  CS_n;
        input  CA;
        input  DQ;
        input  DQ_valid;
        input  DM;
        input  DQS;
        input  DQS_valid;
        input  RESET_n;
    endclocking

    // Clocking block riêng cho Monitor (chỉ đọc, không ghi)
    clocking dram_cb @(posedge clk);
        default input #1ns;
        input  CS_n;
        input  CA;
        input  DQ;
        input  DQ_valid;
        input  DM;
        input  DQS;
        input  DQS_valid;
        input  RESET_n;
    endclocking


// Modport cho Driver: truy cập trực tiếp signal (không qua CB)
modport DRIVER  (input clk,
                 output rst_n, enable,
                 output dfi_cs_n_p0, dfi_cs_n_p1, dfi_cs_n_p2, dfi_cs_n_p3,
                 output dfi_reset_n_p0, dfi_reset_n_p1, dfi_reset_n_p2, dfi_reset_n_p3,
                 output dfi_address_p0, dfi_address_p1, dfi_address_p2, dfi_address_p3,
                 output dfi_wrdata_en_p0, dfi_wrdata_en_p1, dfi_wrdata_en_p2, dfi_wrdata_en_p3,
                 output dfi_wrdata_p0, dfi_wrdata_p1, dfi_wrdata_p2, dfi_wrdata_p3,
                 output dfi_wrdata_mask_p0, dfi_wrdata_mask_p1,
                        dfi_wrdata_mask_p2, dfi_wrdata_mask_p3);

// Modport cho Monitor: chỉ đọc output DUT
modport MONITOR (input clk, CS_n, CA, DQ, DQ_valid, DM, DQS, DQS_valid, RESET_n);
modport PASSIVE (input clk, CS_n, CA, DQ, DQ_valid, DM, DQS, DQS_valid, RESET_n,
                 input dfi_cs_n_p0, dfi_address_p0, dfi_wrdata_en_p0,
                       dfi_wrdata_p0, dfi_wrdata_p1, dfi_wrdata_p2, dfi_wrdata_p3,
                       dfi_wrdata_mask_p0);

endinterface : ddr5_phy_if
