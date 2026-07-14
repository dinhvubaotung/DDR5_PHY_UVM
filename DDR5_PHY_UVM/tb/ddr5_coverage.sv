`ifndef DDR5_COVERAGE_SV
`define DDR5_COVERAGE_SV

class ddr5_coverage extends uvm_subscriber #(ddr5_write_seq_item);
    `uvm_component_utils(ddr5_coverage)

    ddr5_write_seq_item trans;

    // ---- Covergroup 1: Write cơ bản ----
    covergroup write_cg;
        cp_rank: coverpoint trans.rank {
            bins rank0 = {1'b0};
            bins rank1 = {1'b1};
        }
        cp_wrdata_p0: coverpoint trans.wrdata_p0 {
            bins all_zero  = {8'h00};
            bins low_half  = {[8'h01 : 8'h7F]};
            bins high_half = {[8'h80 : 8'hFE]};
            bins all_one   = {8'hFF};
        }
        cp_mask: coverpoint trans.wrmask_p0 {
            bins no_mask = {1'b0};
            bins masked  = {1'b1};
        }
        cx_rank_x_data: cross cp_rank, cp_wrdata_p0;
        cx_rank_x_mask: cross cp_rank, cp_mask;
    endgroup

    // ---- Covergroup 2: FSM Coverage (thay thế burst + MRW) ----
    covergroup fsm_cg;
        cp_rank: coverpoint trans.rank {
            bins rank0 = {1'b0};
            bins rank1 = {1'b1};
        }
        cp_write_state: coverpoint trans.wrmask_p0 {
            bins normal_write = {1'b0};
            bins masked_write = {1'b1};
        }
        cx_rank_x_write: cross cp_rank, cp_write_state;
    endgroup

    // ---- Covergroup 3: Data Mask ----
    covergroup mask_cg;
        cp_rank: coverpoint trans.rank {
            bins rank0 = {1'b0};
            bins rank1 = {1'b1};
        }
        cp_mask: coverpoint trans.wrmask_p0 {
            bins no_mask = {1'b0};
            bins masked  = {1'b1};
        }
        cx_rank_x_mask: cross cp_rank, cp_mask;
    endgroup

    // ---- Constructor ----
    function new(string name, uvm_component parent);
        super.new(name, parent);
        // Khởi tạo các covergroup
        write_cg = new();
        fsm_cg   = new();
        mask_cg  = new();
    endfunction

    // ---- Hàm nhận transaction ----
    function void write(ddr5_write_seq_item t);
        trans = t;
        write_cg.sample();
        fsm_cg.sample();
        mask_cg.sample();
        `uvm_info("COV",
            $sformatf("Sample tx: rank=%0d data_p0=0x%02h mask=%0b | W=%.1f%% F=%.1f%% M=%.1f%%",
                      trans.rank, trans.wrdata_p0, trans.wrmask_p0,
                      write_cg.get_coverage(), fsm_cg.get_coverage(), mask_cg.get_coverage()),
            UVM_MEDIUM)
    endfunction

    // ---- Báo cáo coverage ----
    function void report_phase(uvm_phase phase);
        `uvm_info("COV", "============================================", UVM_NONE)
        `uvm_info("COV", "         BAO CAO FUNCTIONAL COVERAGE        ", UVM_NONE)
        `uvm_info("COV", "============================================", UVM_NONE)
        `uvm_info("COV", $sformatf("  Write coverage     : %.2f%%", write_cg.get_coverage()), UVM_NONE)
        `uvm_info("COV", $sformatf("  FSM coverage       : %.2f%%", fsm_cg.get_coverage()), UVM_NONE)
        `uvm_info("COV", $sformatf("  Mask coverage      : %.2f%%", mask_cg.get_coverage()), UVM_NONE)
        `uvm_info("COV", "--------------------------------------------", UVM_NONE)
        `uvm_info("COV", $sformatf("  cp_rank            : %.2f%%", write_cg.cp_rank.get_coverage()), UVM_NONE)
        `uvm_info("COV", $sformatf("  cp_wrdata_p0       : %.2f%%", write_cg.cp_wrdata_p0.get_coverage()), UVM_NONE)
        `uvm_info("COV", $sformatf("  cp_mask            : %.2f%%", write_cg.cp_mask.get_coverage()), UVM_NONE)
        `uvm_info("COV", $sformatf("  cx_rank_x_data     : %.2f%%", write_cg.cx_rank_x_data.get_coverage()), UVM_NONE)
        `uvm_info("COV", $sformatf("  cx_rank_x_mask     : %.2f%%", write_cg.cx_rank_x_mask.get_coverage()), UVM_NONE)
        `uvm_info("COV", "============================================", UVM_NONE)

        if (write_cg.get_coverage() < 80.0 || fsm_cg.get_coverage() < 80.0 ||
            mask_cg.get_coverage() < 80.0)
            `uvm_warning("COV", "Coverage < 80% - Can them test cases!")
        else if (write_cg.get_coverage() < 100.0 || fsm_cg.get_coverage() < 100.0 ||
                 mask_cg.get_coverage() < 100.0)
            `uvm_info("COV", "Coverage >= 80% - Dat muc chap nhan duoc", UVM_NONE)
        else
            `uvm_info("COV", "Coverage = 100% - Hoan hao!", UVM_NONE)
    endfunction

endclass : ddr5_coverage

`endif