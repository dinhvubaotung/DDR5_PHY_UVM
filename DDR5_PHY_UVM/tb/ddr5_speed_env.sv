

`ifndef DDR5_SPEED_ENV_SV
`define DDR5_SPEED_ENV_SV

class ddr5_speed_mc_driver extends uvm_driver #(ddr5_write_seq_item);
    `uvm_component_utils(ddr5_speed_mc_driver)

    virtual ddr5_phy_if_speed vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual ddr5_phy_if_speed)::get(this, "", "vif_speed", vif))
            `uvm_fatal("CFG", "ddr5_speed_mc_driver: Khong tim thay vif_speed!")
    endfunction

    task run_phase(uvm_phase phase);
        drive_idle();
        reset_dut();
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("DRV_SPD", $sformatf("Drive: %s", req.convert2string()), UVM_MEDIUM)
            drive_write(req);
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
        `uvm_info("DRV_SPD", "Reset hoan tat, DUT san sang", UVM_LOW)
    endtask

    task drive_write(ddr5_write_seq_item item);
        // Cycle 0: WR command cycle 1
        @(negedge vif.clk);
        vif.dfi_cs_n_p0    = item.rank ? 2'b01 : 2'b10;
        #1;  // 1ps delta delay để tránh race
        vif.dfi_address_p0 = {8'b0, item.burst_len_sel, 1'b0, 5'b01101};

        // Cycle 1: WR command cycle 2
        @(negedge vif.clk);
        vif.dfi_cs_n_p0    = 2'b11;
        vif.dfi_address_p0 = 14'b0;

        // Cycle 2: Bắt đầu wr_en và data
        @(negedge vif.clk);
        vif.dfi_wrdata_en_p0   = 1'b1;
        vif.dfi_wrdata_p0      = item.wrdata_p0;
        vif.dfi_wrdata_mask_p0 = item.wrmask_p0;
        vif.dfi_wrdata_p1      = item.wrdata_p1;
        vif.dfi_wrdata_p2      = item.wrdata_p2;
        vif.dfi_wrdata_p3      = item.wrdata_p3;

        // Giữ wr_en đủ cho preamble + data burst (12 cycle)
        repeat(12) @(negedge vif.clk);

        // Deassert
        @(negedge vif.clk);
        vif.dfi_wrdata_en_p0   = 1'b0;
        vif.dfi_wrdata_p0      = 8'b0;
        vif.dfi_wrdata_p1      = 8'b0;
        vif.dfi_wrdata_p2      = 8'b0;
        vif.dfi_wrdata_p3      = 8'b0;
        vif.dfi_wrdata_mask_p0 = 1'b0;
        vif.dfi_cs_n_p0        = 2'b11;
        vif.dfi_address_p0     = 14'b0;

        // Inter-transaction gap: 100 clock cycles
        repeat(100) @(negedge vif.clk);
        `uvm_info("DRV_SPD", "drive_write hoan tat", UVM_MEDIUM)
    endtask

endclass : ddr5_speed_mc_driver


//==============================================================================
// SPEED MC MONITOR
//==============================================================================
class ddr5_speed_mc_monitor extends uvm_monitor;
    `uvm_component_utils(ddr5_speed_mc_monitor)

    virtual ddr5_phy_if_speed vif;
    uvm_analysis_port #(ddr5_write_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual ddr5_phy_if_speed)::get(this, "", "vif_speed", vif))
            `uvm_fatal("CFG", "ddr5_speed_mc_monitor: Khong tim thay vif_speed!")
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_write_seq_item item;
        forever begin
            @(posedge vif.clk);
            // Phát hiện WR command: dfi_address_p0[4:0] == 5'b01101 và CS active
            if (vif.dfi_cs_n_p0 !== 2'b11 && vif.dfi_address_p0[4:0] === 5'b01101) begin
                item = ddr5_write_seq_item::type_id::create("mon_item");
                item.rank         = (vif.dfi_cs_n_p0 == 2'b10) ? 1'b0 : 1'b1;
                item.burst_len_sel= vif.dfi_address_p0[5]; // fix: burst_len_sel is encoded at bit[5]
                item.wrdata_p0    = vif.dfi_wrdata_p0;
                item.wrdata_p1    = vif.dfi_wrdata_p1;
                item.wrdata_p2    = vif.dfi_wrdata_p2;
                item.wrdata_p3    = vif.dfi_wrdata_p3;
                item.wrmask_p0    = vif.dfi_wrdata_mask_p0;
                ap.write(item);
                `uvm_info("MON_MC_SPD", $sformatf("Phat hien WR command: %s", item.convert2string()), UVM_MEDIUM)
            end
        end
    endtask

endclass : ddr5_speed_mc_monitor


//==============================================================================
// SPEED DRAM MONITOR
//==============================================================================
class ddr5_speed_dram_monitor extends uvm_monitor;
    `uvm_component_utils(ddr5_speed_dram_monitor)

    virtual ddr5_phy_if_speed vif;
    uvm_analysis_port #(ddr5_dram_obs_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual ddr5_phy_if_speed)::get(this, "", "vif_speed", vif))
            `uvm_fatal("CFG", "ddr5_speed_dram_monitor: Khong tim thay vif_speed!")
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_dram_obs_item obs;
        forever begin
            @(posedge vif.clk);
            obs = ddr5_dram_obs_item::type_id::create("obs");
            obs.DQ       = vif.DQ;
            obs.DQ_valid = vif.DQ_valid;
            obs.DQS      = vif.DQS;
            obs.CS_n     = vif.CS_n;
            ap.write(obs);
        end
    endtask

endclass : ddr5_speed_dram_monitor


//==============================================================================
// SPEED MC AGENT
//==============================================================================
class ddr5_speed_mc_agent extends uvm_agent;
    `uvm_component_utils(ddr5_speed_mc_agent)

    ddr5_speed_mc_driver   driver;
    ddr5_speed_mc_monitor  monitor;
    uvm_sequencer #(ddr5_write_seq_item) sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver    = ddr5_speed_mc_driver::type_id::create("driver", this);
        monitor   = ddr5_speed_mc_monitor::type_id::create("monitor", this);
        sequencer = uvm_sequencer #(ddr5_write_seq_item)::type_id::create("sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass : ddr5_speed_mc_agent


//==============================================================================
// SPEED ENVIRONMENT
//==============================================================================
class ddr5_speed_env extends uvm_env;
    `uvm_component_utils(ddr5_speed_env)

    ddr5_speed_mc_agent       mc_agent;
    ddr5_speed_dram_monitor   dram_monitor;
    ddr5_scoreboard           scoreboard;
    ddr5_coverage             coverage;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mc_agent     = ddr5_speed_mc_agent::type_id::create("mc_agent", this);
        dram_monitor = ddr5_speed_dram_monitor::type_id::create("dram_monitor", this);
        scoreboard   = ddr5_scoreboard::type_id::create("scoreboard", this);
        coverage     = ddr5_coverage::type_id::create("coverage", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        mc_agent.monitor.ap.connect(scoreboard.mc_export);
        dram_monitor.ap.connect(scoreboard.dram_export);
        mc_agent.monitor.ap.connect(coverage.analysis_export);
    endfunction

endclass : ddr5_speed_env


//==============================================================================
// BASE SPEED TEST — override ddr5_base_test để dùng ddr5_speed_env
//==============================================================================
class ddr5_base_speed_test extends uvm_test;
    `uvm_component_utils(ddr5_base_speed_test)

    ddr5_speed_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ddr5_speed_env::type_id::create("env", this);
    endfunction

    task run_seq(uvm_sequence #(ddr5_write_seq_item) seq);
        seq.start(env.mc_agent.sequencer);
    endtask

endclass : ddr5_base_speed_test


//==============================================================================
// DDR5-3200 SPEED TEST — dùng tb_top_3200.sv (clock = 1600 MHz)
//==============================================================================
class ddr5_3200_speed_test extends ddr5_base_speed_test;
    `uvm_component_utils(ddr5_3200_speed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_speed_seq seq = ddr5_speed_seq::type_id::create("seq");
        seq.speed_label = "DDR5-3200 (1600 MHz, period~0.624 ns)";
        phase.raise_objection(this, "Bat dau DDR5-3200 speed test");
        `uvm_info("TEST", "============================================================", UVM_NONE)
        `uvm_info("TEST", "  TARGET SPEED : DDR5-3200", UVM_NONE)
        `uvm_info("TEST", "  Data Rate    : 3200 MT/s", UVM_NONE)
        `uvm_info("TEST", "  Clock Freq   : ~1600 MHz", UVM_NONE)
        `uvm_info("TEST", "  CLK_PERIOD   : ~0.624 ns (624 ps)", UVM_NONE)
        `uvm_info("TEST", "============================================================", UVM_NONE)
        run_seq(seq);
        #50;
        phase.drop_objection(this, "Ket thuc DDR5-3200 speed test");
    endtask

endclass : ddr5_3200_speed_test


//==============================================================================
// DDR5-6400 SPEED TEST — dùng tb_top_6400.sv (clock = 3200 MHz)
//==============================================================================
class ddr5_6400_speed_test extends ddr5_base_speed_test;
    `uvm_component_utils(ddr5_6400_speed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_speed_seq seq = ddr5_speed_seq::type_id::create("seq");
        seq.speed_label = "DDR5-6400 (3200 MHz, period~0.312 ns)";
        phase.raise_objection(this, "Bat dau DDR5-6400 speed test");
        `uvm_info("TEST", "============================================================", UVM_NONE)
        `uvm_info("TEST", "  TARGET SPEED : DDR5-6400", UVM_NONE)
        `uvm_info("TEST", "  Data Rate    : 6400 MT/s", UVM_NONE)
        `uvm_info("TEST", "  Clock Freq   : ~3200 MHz", UVM_NONE)
        `uvm_info("TEST", "  CLK_PERIOD   : ~0.312 ns (312 ps)", UVM_NONE)
        `uvm_info("TEST", "============================================================", UVM_NONE)
        run_seq(seq);
        #50;
        phase.drop_objection(this, "Ket thuc DDR5-6400 speed test");
    endtask

endclass : ddr5_6400_speed_test

`endif // DDR5_SPEED_ENV_SV
