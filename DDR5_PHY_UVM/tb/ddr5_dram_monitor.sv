
`ifndef DDR5_DRAM_MONITOR_SV
`define DDR5_DRAM_MONITOR_SV

class ddr5_dram_obs_item extends uvm_sequence_item;

    logic [1:0]  CS_n;
    logic [13:0] CA;
    logic [7:0]  DQ;
    logic [0:0]  DM;
    logic [1:0]  DQS;
    logic        DQ_valid;
    logic        DQS_valid;

    `uvm_object_utils_begin(ddr5_dram_obs_item)
        `uvm_field_int(CS_n,      UVM_ALL_ON)
        `uvm_field_int(CA,        UVM_ALL_ON)
        `uvm_field_int(DQ,        UVM_ALL_ON)
        `uvm_field_int(DM,        UVM_ALL_ON)
        `uvm_field_int(DQS,       UVM_ALL_ON)
        `uvm_field_int(DQ_valid,  UVM_ALL_ON)
        `uvm_field_int(DQS_valid, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "ddr5_dram_obs_item");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf(
            "DRAM_OUT: CS_n=%02b CA=0x%04h DQ=0x%02h DM=%b DQS=%02b DQ_v=%b DQS_v=%b",
            CS_n, CA, DQ, DM, DQS, DQ_valid, DQS_valid
        );
    endfunction

endclass : ddr5_dram_obs_item


class ddr5_dram_monitor extends uvm_monitor;

    `uvm_component_utils(ddr5_dram_monitor)

    uvm_analysis_port #(ddr5_dram_obs_item) ap;
    virtual ddr5_phy_if vif;
    int unsigned dq_valid_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        dq_valid_count = 0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual ddr5_phy_if)::get(this, "", "vif", vif))
            `uvm_fatal("CFG", "ddr5_dram_monitor: Khong tim thay virtual interface 'vif'!")
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_dram_obs_item obs;
        forever begin
            // Sample tai posedge + 1ns (sau khi DUT output on dinh)
            @(posedge vif.clk);

            // === FIX: GUI MOI CYCLE ===
            // Truoc: chi gui khi DQ_valid=1 → scoreboard khong biet khi DQ_valid=0
            // Nay: gui tat ca → scoreboard phat hien canh len VA canh xuong
            obs = ddr5_dram_obs_item::type_id::create("dram_obs");
            obs.CS_n      = vif.CS_n;
            obs.CA        = vif.CA;
            obs.DQ        = vif.DQ;
            obs.DM        = vif.DM;
            obs.DQS       = vif.DQS;
            obs.DQ_valid  = vif.DQ_valid;
            obs.DQS_valid = vif.DQS_valid;

            if (vif.DQ_valid) dq_valid_count++;

            // Chi log khi DQ_valid=1 (tranh spam log)
            if (vif.DQ_valid)
                `uvm_info("DRAM_MON", obs.convert2string(), UVM_HIGH)

            ap.write(obs);
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("DRAM_MON",
            $sformatf("Tong so cycle DQ_valid = %0d", dq_valid_count),
            UVM_LOW)
    endfunction

endclass : ddr5_dram_monitor

`endif // DDR5_DRAM_MONITOR_SV
