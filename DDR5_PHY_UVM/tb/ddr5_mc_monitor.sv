`ifndef DDR5_MC_MONITOR_SV
`define DDR5_MC_MONITOR_SV

class ddr5_mc_monitor extends uvm_monitor;
    `uvm_component_utils(ddr5_mc_monitor)
    uvm_analysis_port #(ddr5_write_seq_item) ap;
    virtual ddr5_phy_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual ddr5_phy_if)::get(this, "", "vif", vif))
            `uvm_fatal("CFG", "ddr5_mc_monitor: Khong tim thay vif!")
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_write_seq_item item;
        forever begin
            @(posedge vif.clk);
            if ((vif.dfi_cs_n_p0 != 2'b11) && (vif.dfi_address_p0[4:0] == 5'b01101)) begin
                item = ddr5_write_seq_item::type_id::create("mc_mon_item");
                if      (vif.dfi_cs_n_p0[0] == 1'b0) item.rank = 0;
                else if (vif.dfi_cs_n_p0[1] == 1'b0) item.rank = 1;
                else                                  item.rank = 0;
                item.burst_len_sel = vif.dfi_address_p0[5];
                @(posedge vif.clk);
                @(posedge vif.clk);
                item.wrdata_p0 = vif.dfi_wrdata_p0;
                item.wrdata_p1 = vif.dfi_wrdata_p1;
                item.wrdata_p2 = vif.dfi_wrdata_p2;
                item.wrdata_p3 = vif.dfi_wrdata_p3;
                item.wrmask_p0 = vif.dfi_wrdata_mask_p0;
                item.wrmask_p1 = vif.dfi_wrdata_mask_p1;
                item.wrmask_p2 = vif.dfi_wrdata_mask_p2;
                item.wrmask_p3 = vif.dfi_wrdata_mask_p3;
                `uvm_info("MC_MON", $sformatf("Captured WRITE: %s", item.convert2string()), UVM_MEDIUM)
                ap.write(item);
            end
        end
    endtask
endclass
`endif