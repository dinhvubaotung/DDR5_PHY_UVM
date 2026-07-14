`ifndef DDR5_SCOREBOARD_SV
`define DDR5_SCOREBOARD_SV

`uvm_analysis_imp_decl(_mc)
`uvm_analysis_imp_decl(_dram)

class ddr5_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ddr5_scoreboard)

    uvm_analysis_imp_mc   #(ddr5_write_seq_item, ddr5_scoreboard) mc_export;
    uvm_analysis_imp_dram #(ddr5_dram_obs_item,  ddr5_scoreboard) dram_export;

    ddr5_write_seq_item expected_q[$];
    logic [7:0] predicted_crc_q[$];

    int pass_count;
    int fail_count;
    int total_tx;

    bit prev_dq_valid;
    bit dang_trong_burst;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        pass_count = 0;
        fail_count = 0;
        total_tx = 0;
        prev_dq_valid = 0;
        dang_trong_burst = 0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mc_export = new("mc_export", this);
        dram_export = new("dram_export", this);
    endfunction

    // CRC-8 reference model (đầy đủ 8 bước)
    function automatic logic [7:0] compute_crc8(logic [7:0] d);
        logic [7:0] r;
        // B0
        r[0] = d[0]^d[6]^d[7];
        r[1] = d[0]^d[1]^d[6];
        r[2] = d[0]^d[1]^d[2]^d[6];
        r[3] = d[1]^d[2]^d[3]^d[7];
        r[4] = d[2]^d[3]^d[4];
        r[5] = d[3]^d[4]^d[5];
        r[6] = d[4]^d[5]^d[6];
        r[7] = d[5]^d[6]^d[7];
        // B1
        r[0] = r[0] ^ d[0] ^ d[4] ^ d[6];
        r[1] = r[1] ^ d[1] ^ d[4] ^ d[5] ^ d[6] ^ d[7];
        r[2] = r[2] ^ d[0] ^ d[2] ^ d[4] ^ d[5] ^ d[7];
        r[3] = r[3] ^ d[1] ^ d[3] ^ d[5] ^ d[6];
        r[4] = r[4] ^ d[0] ^ d[2] ^ d[4] ^ d[6] ^ d[7];
        r[5] = r[5] ^ d[1] ^ d[3] ^ d[5] ^ d[7];
        r[6] = r[6] ^ d[2] ^ d[4] ^ d[6];
        r[7] = r[7] ^ d[3] ^ d[5] ^ d[7];
        // B2
        r[0] = r[0] ^ d[0] ^ d[2] ^ d[3] ^ d[5] ^ d[7];
        r[1] = r[1] ^ d[0] ^ d[1] ^ d[2] ^ d[4] ^ d[5] ^ d[6] ^ d[7];
        r[2] = r[2] ^ d[1] ^ d[6];
        r[3] = r[3] ^ d[0] ^ d[2] ^ d[7];
        r[4] = r[4] ^ d[1] ^ d[3];
        r[5] = r[5] ^ d[0] ^ d[2] ^ d[4];
        r[6] = r[6] ^ d[0] ^ d[1] ^ d[3] ^ d[5];
        r[7] = r[7] ^ d[1] ^ d[2] ^ d[4] ^ d[6];
        // B3
        r[0] = r[0] ^ d[4] ^ d[6] ^ d[7];
        r[1] = r[1] ^ d[0] ^ d[4] ^ d[5] ^ d[6];
        r[2] = r[2] ^ d[0] ^ d[1] ^ d[4] ^ d[5];
        r[3] = r[3] ^ d[1] ^ d[2] ^ d[5] ^ d[6];
        r[4] = r[4] ^ d[0] ^ d[2] ^ d[3] ^ d[6] ^ d[7];
        r[5] = r[5] ^ d[1] ^ d[3] ^ d[4] ^ d[7];
        r[6] = r[6] ^ d[2] ^ d[4] ^ d[5];
        r[7] = r[7] ^ d[3] ^ d[5] ^ d[6];
        // B4
        r[0] = r[0] ^ d[2] ^ d[3] ^ d[7];
        r[1] = r[1] ^ d[0] ^ d[2] ^ d[4] ^ d[7];
        r[2] = r[2] ^ d[1] ^ d[2] ^ d[5] ^ d[7];
        r[3] = r[3] ^ d[2] ^ d[3] ^ d[6];
        r[4] = r[4] ^ d[3] ^ d[4] ^ d[7];
        r[5] = r[5] ^ d[0] ^ d[4] ^ d[5];
        r[6] = r[6] ^ d[0] ^ d[1] ^ d[5] ^ d[6];
        r[7] = r[7] ^ d[1] ^ d[2] ^ d[6] ^ d[7];
        // B5
        r[0] = r[0] ^ d[0] ^ d[3] ^ d[5];
        r[1] = r[1] ^ d[1] ^ d[3] ^ d[4] ^ d[5] ^ d[6];
        r[2] = r[2] ^ d[2] ^ d[3] ^ d[4] ^ d[6] ^ d[7];
        r[3] = r[3] ^ d[0] ^ d[3] ^ d[4] ^ d[5] ^ d[7];
        r[4] = r[4] ^ d[1] ^ d[4] ^ d[5] ^ d[6];
        r[5] = r[5] ^ d[0] ^ d[2] ^ d[5] ^ d[6] ^ d[7];
        r[6] = r[6] ^ d[1] ^ d[3] ^ d[6] ^ d[7];
        r[7] = r[7] ^ d[2] ^ d[4] ^ d[7];
        // B6
        r[0] = r[0] ^ d[0] ^ d[1] ^ d[2] ^ d[4] ^ d[5] ^ d[6];
        r[1] = r[1] ^ d[0] ^ d[3] ^ d[4] ^ d[7];
        r[2] = r[2] ^ d[0] ^ d[2] ^ d[6];
        r[3] = r[3] ^ d[0] ^ d[1] ^ d[3] ^ d[7];
        r[4] = r[4] ^ d[0] ^ d[1] ^ d[2] ^ d[4];
        r[5] = r[5] ^ d[1] ^ d[2] ^ d[3] ^ d[5];
        r[6] = r[6] ^ d[0] ^ d[2] ^ d[3] ^ d[4] ^ d[6];
        r[7] = r[7] ^ d[0] ^ d[1] ^ d[3] ^ d[4] ^ d[5] ^ d[7];
        // B7
        r[0] = r[0] ^ d[0] ^ d[4] ^ d[7];
        r[1] = r[1] ^ d[0] ^ d[1] ^ d[4] ^ d[5] ^ d[7];
        r[2] = r[2] ^ d[1] ^ d[2] ^ d[4] ^ d[5] ^ d[6] ^ d[7];
        r[3] = r[3] ^ d[2] ^ d[3] ^ d[5] ^ d[6] ^ d[7];
        r[4] = r[4] ^ d[0] ^ d[3] ^ d[4] ^ d[6] ^ d[7];
        r[5] = r[5] ^ d[1] ^ d[4] ^ d[5] ^ d[7];
        r[6] = r[6] ^ d[2] ^ d[5] ^ d[6];
        r[7] = r[7] ^ d[3] ^ d[6] ^ d[7];
        return r;
    endfunction

    function void write_mc(ddr5_write_seq_item item);
        logic [7:0] crc_pred = compute_crc8(item.wrdata_p0);
        expected_q.push_back(item);
        predicted_crc_q.push_back(crc_pred);
        total_tx++;
        `uvm_info("SB", $sformatf("[MC] Nhan tx #%0d: %s", total_tx, item.convert2string()), UVM_MEDIUM)
        `uvm_info("SB", $sformatf("[CRC_REF] data=0x%02h -> CRC-8 = 0x%02h", item.wrdata_p0, crc_pred), UVM_MEDIUM)
    endfunction

    function void write_dram(ddr5_dram_obs_item obs);
        if (prev_dq_valid == 1'b0 && obs.DQ_valid == 1'b1) begin
            if (expected_q.size() > 0) begin
                compare_transaction(obs.DQ);
            end else begin
                `uvm_error("SB", $sformatf("Khong co expected transaction cho DQ=0x%02h tai t=%0t", obs.DQ, $time))
            end
        end
        prev_dq_valid = obs.DQ_valid;
    endfunction

    function void compare_transaction(logic [7:0] actual_dq);
        ddr5_write_seq_item exp_item = expected_q.pop_front();
        logic [7:0] crc_ref = predicted_crc_q.pop_front();
        if (actual_dq === exp_item.wrdata_p0) begin
            pass_count++;
            `uvm_info("SB", $sformatf("[PASS #%0d] DQ khop: expected=0x%02h actual=0x%02h | CRC_ref=0x%02h",
                      pass_count, exp_item.wrdata_p0, actual_dq, crc_ref), UVM_LOW)
        end else begin
            fail_count++;
            `uvm_error("SB", $sformatf("[FAIL #%0d] DQ KHONG KHOP!\n  Expected = 0x%02h, Actual = 0x%02h, CRC_ref=0x%02h\n  TX: %s",
                      fail_count, exp_item.wrdata_p0, actual_dq, crc_ref, exp_item.convert2string()))
        end
    endfunction

    function void check_phase(uvm_phase phase);
        if (expected_q.size() > 0)
            `uvm_warning("SB", $sformatf("%0d giao dich CHUA duoc so sanh", expected_q.size()))
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SB", "============================================", UVM_NONE)
        `uvm_info("SB", "         KET QUA XAC MINH                  ", UVM_NONE)
        `uvm_info("SB", "============================================", UVM_NONE)
        `uvm_info("SB", $sformatf("  Tong giao dich  : %0d", total_tx),   UVM_NONE)
        `uvm_info("SB", $sformatf("  PASS            : %0d", pass_count), UVM_NONE)
        `uvm_info("SB", $sformatf("  FAIL            : %0d", fail_count), UVM_NONE)
        `uvm_info("SB", "============================================", UVM_NONE)
        if (fail_count == 0 && pass_count > 0)
            `uvm_info("SB", ">>> TEST PASSED <<<", UVM_NONE)
        else if (fail_count > 0)
            `uvm_error("SB", ">>> TEST FAILED <<<")
        else
            `uvm_warning("SB", ">>> KHONG CO GIAO DICH NAO DUOC SO SANH - KIEM TRA TIMING <<<")
    endfunction

endclass

`endif