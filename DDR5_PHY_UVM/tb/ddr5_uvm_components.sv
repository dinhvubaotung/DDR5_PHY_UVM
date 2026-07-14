/*==============================================================================
** File    : ddr5_uvm_components.sv
** Purpose : Sequencer, Agent, Env - cac thanh phan cau truc UVM
==============================================================================*/

`ifndef DDR5_UVM_COMPONENTS_SV
`define DDR5_UVM_COMPONENTS_SV

//==============================================================================
// SEQUENCER
//==============================================================================
class ddr5_write_sequencer extends uvm_sequencer #(ddr5_write_seq_item);
    `uvm_component_utils(ddr5_write_sequencer)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass : ddr5_write_sequencer


//==============================================================================
// MC AGENT (ACTIVE): Sequencer + Driver + MC Monitor
//==============================================================================
class ddr5_mc_agent extends uvm_agent;
    `uvm_component_utils(ddr5_mc_agent)

    ddr5_write_sequencer sequencer;
    ddr5_mc_driver       driver;
    ddr5_mc_monitor      monitor;
    uvm_analysis_port #(ddr5_write_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap        = new("ap", this);
        sequencer = ddr5_write_sequencer::type_id::create("sequencer", this);
        driver    = ddr5_mc_driver::type_id::create("driver",    this);
        monitor   = ddr5_mc_monitor::type_id::create("monitor",  this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
        monitor.ap.connect(ap);
    endfunction
endclass : ddr5_mc_agent


//==============================================================================
// DRAM AGENT (PASSIVE): chi co Monitor
//==============================================================================
class ddr5_dram_agent extends uvm_agent;
    `uvm_component_utils(ddr5_dram_agent)

    ddr5_dram_monitor monitor;
    uvm_analysis_port #(ddr5_dram_obs_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap      = new("ap", this);
        monitor = ddr5_dram_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        monitor.ap.connect(ap);
    endfunction
endclass : ddr5_dram_agent


//==============================================================================
// ENVIRONMENT - Ket noi tat ca, bao gom ca Coverage
//
//   MC Agent
//     ├─ ap ──► Scoreboard.mc_export
//     └─ ap ──► Coverage.analysis_export   <- them moi
//   DRAM Agent
//     └─ ap ──► Scoreboard.dram_export
//==============================================================================
class ddr5_env extends uvm_env;
    `uvm_component_utils(ddr5_env)

    ddr5_mc_agent    mc_agent;
    ddr5_dram_agent  dram_agent;
    ddr5_scoreboard  scoreboard;
    ddr5_coverage    coverage;     // THEM MOI

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mc_agent   = ddr5_mc_agent::type_id::create("mc_agent",    this);
        dram_agent = ddr5_dram_agent::type_id::create("dram_agent", this);
        scoreboard = ddr5_scoreboard::type_id::create("scoreboard", this);
        coverage   = ddr5_coverage::type_id::create("coverage",    this); // THEM MOI
    endfunction

    function void connect_phase(uvm_phase phase);
        // Scoreboard nhan tu ca 2 monitor
        mc_agent.ap.connect(scoreboard.mc_export);
        dram_agent.ap.connect(scoreboard.dram_export);
        // Coverage nhan tu MC monitor (cung nguon voi scoreboard)
        mc_agent.ap.connect(coverage.analysis_export); // THEM MOI
    endfunction

endclass : ddr5_env

`endif // DDR5_UVM_COMPONENTS_SV
