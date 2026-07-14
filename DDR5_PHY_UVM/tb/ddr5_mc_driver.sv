`ifndef DDR5_MC_DRIVER_SV
`define DDR5_MC_DRIVER_SV

class ddr5_mc_driver extends uvm_driver #(ddr5_write_seq_item);
    `uvm_component_utils(ddr5_mc_driver)
    virtual ddr5_phy_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual ddr5_phy_if)::get(this, "", "vif", vif))
            `uvm_fatal("CFG", "ddr5_mc_driver: Khong tim thay vif!")
    endfunction

    task run_phase(uvm_phase phase);
        drive_idle();
        reset_dut();
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("DRV", $sformatf("Drive: %s", req.convert2string()), UVM_MEDIUM)
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_idle();
        vif.rst_n              = 1'b1;
        vif.enable             = 1'b1;
        vif.dfi_cs_n_p0        = 2'b11;
        vif.dfi_cs_n_p1        = 2'b11;
        vif.dfi_cs_n_p2        = 2'b11;
        vif.dfi_cs_n_p3        = 2'b11;
        vif.dfi_reset_n_p0     = 2'b11;
        vif.dfi_reset_n_p1     = 2'b11;
        vif.dfi_reset_n_p2     = 2'b11;
        vif.dfi_reset_n_p3     = 2'b11;
        vif.dfi_address_p0     = 14'b0;
        vif.dfi_address_p1     = 14'b0;
        vif.dfi_address_p2     = 14'b0;
        vif.dfi_address_p3     = 14'b0;
        vif.dfi_wrdata_en_p0   = 1'b0;
        vif.dfi_wrdata_en_p1   = 1'b0;
        vif.dfi_wrdata_en_p2   = 1'b0;
        vif.dfi_wrdata_en_p3   = 1'b0;
        vif.dfi_wrdata_p0      = 8'b0;
        vif.dfi_wrdata_p1      = 8'b0;
        vif.dfi_wrdata_p2      = 8'b0;
        vif.dfi_wrdata_p3      = 8'b0;
        vif.dfi_wrdata_mask_p0 = 1'b0;
        vif.dfi_wrdata_mask_p1 = 1'b0;
        vif.dfi_wrdata_mask_p2 = 1'b0;
        vif.dfi_wrdata_mask_p3 = 1'b0;
    endtask

    task reset_dut();
        @(negedge vif.clk);
        vif.rst_n  = 1'b0;
        vif.enable = 1'b0;
        repeat(7) @(negedge vif.clk);
        vif.rst_n  = 1'b1;
        vif.enable = 1'b1;
        repeat(2) @(negedge vif.clk);
        `uvm_info("DRV", "Reset hoan tat, DUT san sang", UVM_LOW)
    endtask

    task drive_item(ddr5_write_seq_item item);
        if (item.is_mrw) begin
            drive_mrw(item);
        end else begin
            drive_write(item);
        end
    endtask

    task drive_mrw(ddr5_write_seq_item item);
        // Cycle 0: MRW command first cycle
        @(negedge vif.clk);
        vif.dfi_cs_n_p0    = item.rank ? 2'b01 : 2'b10;
        vif.dfi_address_p0 = {item.mr_address, 5'b00101};

        // Cycle 1: CS deselect second cycle begins
        @(negedge vif.clk);
        vif.dfi_cs_n_p0    = 2'b11;
        vif.dfi_address_p0 = {5'b0, 1'b0, item.mr_operation};

        // Cycle 2: leave MRW fields stable for one cycle before driving writes
        @(negedge vif.clk);
        vif.dfi_address_p0     = 14'b0;

        // Add extra idle cycles after MRW to exercise timing/stability
        repeat(item.idle_cycles_after) @(negedge vif.clk);

        `uvm_info("DRV", $sformatf("drive_mrw hoan tat (rank=%0d MR%d op=0x%02h)", item.rank, item.mr_address, item.mr_operation), UVM_MEDIUM)
    endtask

    task drive_write(ddr5_write_seq_item item);
        // Cycle 0: WR command cycle 1
        @(negedge vif.clk);
        vif.dfi_cs_n_p0    = item.rank ? 2'b01 : 2'b10;
        vif.dfi_address_p0 = {8'b0, item.burst_len_sel, 1'b0, 5'b01101};

        // Cycle 1: WR command cycle 2 (CS deselect)
        @(negedge vif.clk);
        vif.dfi_cs_n_p0    = 2'b11;
        vif.dfi_address_p0 = 14'b0;

        // Cycle 2: Bắt đầu wr_en và dữ liệu
        @(negedge vif.clk);
        vif.dfi_wrdata_en_p0   = 1'b1;
        vif.dfi_wrdata_p0      = item.wrdata_p0;
        vif.dfi_wrdata_mask_p0 = item.wrmask_p0;
        vif.dfi_wrdata_p1      = item.wrdata_p1;
        vif.dfi_wrdata_p2      = item.wrdata_p2;
        vif.dfi_wrdata_p3      = item.wrdata_p3;

        // Giữ wr_en trong 12 cycle (đủ cho preamble + data burst)
        repeat(12) @(negedge vif.clk);

        // Deassert wr_en
        @(negedge vif.clk);
        vif.dfi_wrdata_en_p0   = 1'b0;
        vif.dfi_wrdata_p0      = 8'b0;
        vif.dfi_wrdata_p1      = 8'b0;
        vif.dfi_wrdata_p2      = 8'b0;
        vif.dfi_wrdata_p3      = 8'b0;
        vif.dfi_wrdata_mask_p0 = 1'b0;
        vif.dfi_cs_n_p0        = 2'b11;
        vif.dfi_address_p0     = 14'b0;

        
        repeat(100) @(negedge vif.clk);
        `uvm_info("DRV", "drive_write hoan tat", UVM_MEDIUM)
    endtask

endclass

`endif