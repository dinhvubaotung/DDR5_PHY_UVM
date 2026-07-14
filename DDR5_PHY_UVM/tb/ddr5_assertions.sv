`ifndef DDR5_ASSERTIONS_SV
`define DDR5_ASSERTIONS_SV

module ddr5_assertions (
    input logic        clk,
    input logic        rst_n,
    input logic [1:0]  dfi_cs_n_p0,
    input logic [13:0] dfi_address_p0,
    input logic        dfi_wrdata_en_p0,
    input logic [0:0]  dfi_wrdata_mask_p0,
    input logic [7:0]  dfi_wrdata_p0,
    input logic [1:0]  CS_n,
    input logic        DQ_valid,
    input logic        DQS_valid,
    input logic [7:0]  DQ,
    input logic [1:0]  DQS
);

    //==========================================================================
    // A1: Khi CS active, 1 cycle sau address phai hop le (khong X/Z)
    // Dung ##1 de cho address on dinh sau khi CS duoc assert
    //==========================================================================
    property p_cs_active_addr_valid;
        @(posedge clk) disable iff (!rst_n)
        (dfi_cs_n_p0 != 2'b11) |-> ##1 !$isunknown(dfi_address_p0);
    endproperty

    A1_CS_ADDR_VALID: assert property (p_cs_active_addr_valid)
    else $error("[ASSERT A1 FAIL] CS active nhung sau 1 cycle dfi_address_p0 van co X/Z = %0h",
                dfi_address_p0);

    //==========================================================================
    // A2: Khi wrdata_en=1 VA mask=0, data khong duoc la X/Z
    // Neu mask=1 (masked write): data co the la X - day la hop le
    //==========================================================================
    property p_wrdata_en_data_valid;
        @(posedge clk) disable iff (!rst_n)
        (dfi_wrdata_en_p0 == 1'b1 && dfi_wrdata_mask_p0 == 1'b0)
        |-> !$isunknown(dfi_wrdata_p0);
    endproperty

    A2_WRDATA_NOT_X: assert property (p_wrdata_en_data_valid)
    else $error("[ASSERT A2 FAIL] wrdata_en=1 mask=0 nhung dfi_wrdata_p0 co X/Z = %0h",
                dfi_wrdata_p0);

    //==========================================================================
    // A3: DQ_valid chi len cao khi DQS_valid cung dang cao
    //==========================================================================
    property p_dq_valid_after_dqs;
        @(posedge clk) disable iff (!rst_n)
        $rose(DQ_valid) |-> (DQS_valid == 1'b1);
    endproperty

    A3_DQS_BEFORE_DQ: assert property (p_dq_valid_after_dqs)
    else $error("[ASSERT A3 FAIL] DQ_valid len cao truoc DQS_valid - vi pham giao thuc DDR5");

    //==========================================================================
    // A4: DQ_valid khong duoc duy tri qua 20 cycle lien tiep
    //==========================================================================
    property p_dq_valid_max_duration;
        @(posedge clk) disable iff (!rst_n)
        $rose(DQ_valid) |-> ##[1:20] $fell(DQ_valid);
    endproperty

    A4_DQ_VALID_TIMEOUT: assert property (p_dq_valid_max_duration)
    else $error("[ASSERT A4 FAIL] DQ_valid cao hon 20 cycle lien tiep - co the DUT bi ket");

    //==========================================================================
    // A5: Khi reset active, DQ_valid va DQS_valid phai = 0
    //==========================================================================
    property p_reset_clears_output;
        @(posedge clk)
        (!rst_n) |-> (DQ_valid == 1'b0 && DQS_valid == 1'b0);
    endproperty

    A5_RESET_CLEARS_OUTPUT: assert property (p_reset_clears_output)
    else $error("[ASSERT A5 FAIL] Reset active nhung DQ_valid=%0b DQS_valid=%0b",
                DQ_valid, DQS_valid);

    //==========================================================================
    // COVER PROPERTIES
    //==========================================================================
    C1_WR_CMD_SEEN: cover property (
        @(posedge clk) disable iff (!rst_n)
        (dfi_cs_n_p0 != 2'b11) && (dfi_address_p0[4:0] == 5'b01101)
    );
    C2_DQ_VALID_SEEN: cover property (
        @(posedge clk) disable iff (!rst_n) DQ_valid == 1'b1
    );
    C3_DQS_VALID_SEEN: cover property (
        @(posedge clk) disable iff (!rst_n) DQS_valid == 1'b1
    );

endmodule : ddr5_assertions

`endif // DDR5_ASSERTIONS_SV
