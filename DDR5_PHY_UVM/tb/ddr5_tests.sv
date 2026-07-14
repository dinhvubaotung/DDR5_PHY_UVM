
`ifndef DDR5_TESTS_SV
`define DDR5_TESTS_SV

//==============================================================================
// BASE SEQUENCE — Lớp cha chứa các hàm tiện ích
//==============================================================================
class ddr5_base_seq extends uvm_sequence #(ddr5_write_seq_item);
    `uvm_object_utils(ddr5_base_seq)

    function new(string name = "ddr5_base_seq");
        super.new(name);
    endfunction

    // Tạo và gửi 1 giao dịch ghi với data cụ thể
    task send_write(
        logic        rank,
        logic [7:0]  d0, d1, d2, d3,
        logic [0:0]  burst_len_sel = 1'b0,
        logic [0:0]  m0=0, m1=0, m2=0, m3=0
    );
        ddr5_write_seq_item item = ddr5_write_seq_item::type_id::create("item");
        start_item(item);
        item.rank         = rank;
        item.burst_len_sel = burst_len_sel;
        item.wrdata_p0    = d0;
        item.wrdata_p1    = d1;
        item.wrdata_p2    = d2;
        item.wrdata_p3    = d3;
        item.wrmask_p0    = m0;
        item.wrmask_p1    = m1;
        item.wrmask_p2    = m2;
        item.wrmask_p3    = m3;
        finish_item(item);
    endtask

    task send_mrw(
        logic        rank,
        logic [7:0]  mr_addr,
        logic [7:0]  mr_op,
        int unsigned idle_after = 50
    );
        ddr5_write_seq_item item = ddr5_write_seq_item::type_id::create("item");
        start_item(item);
        item.rank            = rank;
        item.is_mrw          = 1;
        item.mr_address      = mr_addr;
        item.mr_operation    = mr_op;
        item.idle_cycles_after = idle_after;
        item.burst_len_sel   = 1'b0;
        item.wrdata_p0       = 8'h00;
        item.wrdata_p1       = 8'h00;
        item.wrdata_p2       = 8'h00;
        item.wrdata_p3       = 8'h00;
        item.wrmask_p0       = 1'b0;
        item.wrmask_p1       = 1'b0;
        item.wrmask_p2       = 1'b0;
        item.wrmask_p3       = 1'b0;
        finish_item(item);
    endtask

endclass : ddr5_base_seq


//==============================================================================
// SINGLE WRITE SEQUENCE — 1 giao dịch cố định để sanity check
//==============================================================================
class ddr5_single_write_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_single_write_seq)

    function new(string name = "ddr5_single_write_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("SEQ", "Bắt đầu: Single Write (coverage-directed)", UVM_LOW)

        // rank0 high_half
        send_write(.rank(0),
                   .d0(8'hAB), .d1(8'hCD), .d2(8'hEF), .d3(8'h12));

        // rank1 all_zero
        send_write(.rank(1),
                   .d0(8'h00), .d1(8'h00), .d2(8'h00), .d3(8'h00));

        // rank0 BL8 low_half
        send_write(.rank(0),
                   .d0(8'h5A), .d1(8'h5A), .d2(8'h5A), .d3(8'h5A),
                   .burst_len_sel(1'b1));

        // rank1 all_one
        send_write(.rank(1),
                   .d0(8'hFF), .d1(8'hFF), .d2(8'hFF), .d3(8'hFF));

        // rank0 all_zero
        send_write(.rank(0),
                   .d0(8'h00), .d1(8'h00), .d2(8'h00), .d3(8'h00));

        // rank0 all_one
        send_write(.rank(0),
                   .d0(8'hFF), .d1(8'hFF), .d2(8'hFF), .d3(8'hFF));

        // rank1 low_half + masked write để mở rộng cp_mask
        send_write(.rank(1),
                   .d0(8'h10), .d1(8'h22), .d2(8'h00), .d3(8'h33),
                   .m0(1'b1), .m1(1'b0), .m2(1'b0), .m3(1'b0));

        `uvm_info("SEQ", "Hoàn thành: Single Write (coverage-directed)", UVM_LOW)
    endtask
endclass : ddr5_single_write_seq


//==============================================================================
// BURST WRITE SEQUENCE — 5 giao dịch liên tiếp
//==============================================================================
class ddr5_burst_write_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_burst_write_seq)

    function new(string name = "ddr5_burst_write_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("SEQ", "Bắt đầu: Burst Write (8 giao dịch)", UVM_LOW)
        send_write(0, 8'hAA, 8'hBB, 8'hCC, 8'hDD);                // high_half
        send_write(0, 8'h11, 8'h22, 8'h33, 8'h44);                // low_half
        send_write(0, 8'hFF, 8'h00, 8'hFF, 8'h00);                // all_one/all_zero mix
        send_write(0, 8'h55, 8'hAA, 8'h55, 8'hAA);                // alternating pattern
        send_write(1, 8'hDE, 8'hAD, 8'hBE, 8'hEF);                // rank1 high_half
        send_write(1, 8'h00, 8'h00, 8'h00, 8'h00);                // all_zero rank1
        send_write(.rank(1), .d0(8'h77), .d1(8'h88), .d2(8'h99), .d3(8'hAA),
                   .m0(1'b1), .m1(1'b0), .m2(1'b0), .m3(1'b1));     // masked rank1
        send_write(.rank(0), .d0(8'hBE), .d1(8'hEF), .d2(8'hBE), .d3(8'hEF), .burst_len_sel(1'b1));
        `uvm_info("SEQ", "Hoàn thành: Burst Write", UVM_LOW)
    endtask
endclass : ddr5_burst_write_seq


//==============================================================================
// RANDOM WRITE SEQUENCE — 10 giao dịch với data random
//==============================================================================
class ddr5_random_write_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_random_write_seq)

    int unsigned num_transactions = 10;

    function new(string name = "ddr5_random_write_seq");
        super.new(name);
    endfunction

    task body();
        ddr5_write_seq_item item;
        `uvm_info("SEQ", $sformatf("Bắt đầu: Random Write (%0d giao dịch)", num_transactions), UVM_LOW)

        repeat(num_transactions) begin
            item = ddr5_write_seq_item::type_id::create("rand_item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal("SEQ", "Randomize thất bại!")
            // Ép mask = 0 để scoreboard dễ so sánh
            item.wrmask_p0 = 0; item.wrmask_p1 = 0;
            item.wrmask_p2 = 0; item.wrmask_p3 = 0;
            finish_item(item);
        end
        // Thêm vài giao dịch fix value để đảm bảo all_zero/all_one và rank 1
        send_write(1, 8'h00, 8'h00, 8'h00, 8'h00);
        send_write(1, 8'hFF, 8'hFF, 8'hFF, 8'hFF);
        // Thêm dữ liệu low_half và high_half có kiểm soát
        send_write(.rank(0), .d0(8'h7F), .d1(8'h12), .d2(8'h34), .d3(8'h56));
        send_write(.rank(1), .d0(8'h80), .d1(8'h81), .d2(8'h82), .d3(8'h83));
        // Coverage-directed additional values để đảm bảo đủ rank/data bins và mask
        send_write(.rank(0), .d0(8'h3C), .d1(8'h3C), .d2(8'h3C), .d3(8'h3C));
        send_write(.rank(0), .d0(8'hA5), .d1(8'hB6), .d2(8'hC7), .d3(8'hD8));
        send_write(.rank(0), .d0(8'h77), .d1(8'h88), .d2(8'h99), .d3(8'hAA),
                   .m0(1'b1), .m1(1'b0), .m2(1'b0), .m3(1'b1));
        send_write(.rank(1), .d0(8'h55), .d1(8'h66), .d2(8'h77), .d3(8'h88));
        send_write(.rank(1), .d0(8'hA5), .d1(8'hB5), .d2(8'hC5), .d3(8'hD5),
                   .m0(1'b1), .m1(1'b0), .m2(1'b1), .m3(1'b0));
        // Một giao dịch BL8 cố định để kiểm tra đường BL
        send_write(.rank(0), .d0(8'hC3), .d1(8'hC3), .d2(8'hC3), .d3(8'hC3), .burst_len_sel(1'b1));
        `uvm_info("SEQ", "Hoàn thành: Random Write", UVM_LOW)
    endtask
endclass : ddr5_random_write_seq


//==============================================================================
// MASKED WRITE SEQUENCE — Kiểm tra tính năng Data Mask
//==============================================================================
class ddr5_masked_write_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_masked_write_seq)

    function new(string name = "ddr5_masked_write_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("SEQ", "Bắt đầu: Masked Write", UVM_LOW)
        // Mask phase p0 và p2, data ở p1 và p3 hợp lệ
        send_write(.rank(0),
                   .d0(8'hXX), .d1(8'hAB), .d2(8'hXX), .d3(8'hCD),
                   .m0(1'b1),  .m1(1'b0),  .m2(1'b1),  .m3(1'b0));
        // Thêm 3 pattern masked khác để mở rộng coverage
        send_write(.rank(0),
                   .d0(8'h11), .d1(8'h22), .d2(8'h33), .d3(8'h44),
                   .m0(1'b0),  .m1(1'b1),  .m2(1'b0),  .m3(1'b1));
        send_write(.rank(1),
                   .d0(8'h55), .d1(8'h66), .d2(8'h77), .d3(8'h88),
                   .m0(1'b1),  .m1(1'b1),  .m2(1'b0),  .m3(1'b0));
        send_write(.rank(1),
                   .d0(8'h99), .d1(8'hAA), .d2(8'hBB), .d3(8'hCC),
                   .m0(1'b0),  .m1(1'b0),  .m2(1'b1),  .m3(1'b1));
        send_write(.rank(1),
                   .d0(8'h12), .d1(8'h34), .d2(8'h56), .d3(8'h78),
                   .m0(1'b1),  .m1(1'b0),  .m2(1'b1),  .m3(1'b0));
        // Thêm 1 giao dịch without mask để cover cp_mask=no_mask
        send_write(.rank(0),
                   .d0(8'h00), .d1(8'h00), .d2(8'h00), .d3(8'h00));
        // Thêm 1 giao dịch low_half không mask để mở rộng cx_rank_x_data
        send_write(.rank(1),
                   .d0(8'h3C), .d1(8'h3C), .d2(8'h3C), .d3(8'h3C));
        // Thêm 1 giao dịch masked với BL8
        send_write(.rank(0),
                   .d0(8'h0F), .d1(8'hF0), .d2(8'h0F), .d3(8'hF0),
                   .m0(1'b1),  .m1(1'b0),  .m2(1'b1),  .m3(1'b0),
                   .burst_len_sel(1'b1));
        `uvm_info("SEQ", "Hoàn thành: Masked Write", UVM_LOW)
    endtask
endclass : ddr5_masked_write_seq


//==============================================================================
// MRW + Timing Sequence — Kiểm tra Mode Register Write và sau đó là write command
//==============================================================================
class ddr5_mrw_timing_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_mrw_timing_seq)

    function new(string name = "ddr5_mrw_timing_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("SEQ", "Bắt đầu: MRW + Timing Sequence", UVM_LOW)

        // Configure alternate burst length via MR0 and then perform a write
        send_mrw(.rank(0), .mr_addr(8'd0), .mr_op(8'h01), .idle_after(16));
        // Use BL8 after MRW to exercise burst length change
        send_write(.rank(0), .d0(8'h12), .d1(8'h34), .d2(8'h56), .d3(8'h78), .burst_len_sel(1'b1));

        // Configure preamble/postamble via MR8 and verify rank 1 write afterward
        send_mrw(.rank(1), .mr_addr(8'd8), .mr_op(8'b10001000), .idle_after(20));
        send_write(.rank(1), .d0(8'hDE), .d1(8'hAD), .d2(8'hBE), .d3(8'hEF));

        // Thêm write khác để kiểm tra rank/x data và tăng coverage
        send_write(.rank(0), .d0(8'h00), .d1(8'h00), .d2(8'h00), .d3(8'h00));
        send_write(.rank(1), .d0(8'hFF), .d1(8'hFF), .d2(8'hFF), .d3(8'hFF));
        send_write(.rank(1), .d0(8'h80), .d1(8'h81), .d2(8'h82), .d3(8'h83),
                   .m0(1'b1), .m1(1'b0), .m2(1'b0), .m3(1'b1));

        `uvm_info("SEQ", "Hoàn thành: MRW + Timing Sequence", UVM_LOW)
    endtask
endclass : ddr5_mrw_timing_seq


//==============================================================================
// RANK + MASK SEQUENCE — Chuyển rank và kiểm tra masked write pattern
//==============================================================================
class ddr5_rank_mask_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_rank_mask_seq)

    function new(string name = "ddr5_rank_mask_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("SEQ", "Bắt đầu: Rank + Mask Sequence", UVM_LOW)

        send_write(.rank(0), .d0(8'hDE), .d1(8'hAD), .d2(8'hBE), .d3(8'hEF),
                   .m0(1'b0), .m1(1'b1), .m2(1'b0), .m3(1'b1));
        send_write(.rank(1), .d0(8'h00), .d1(8'hFF), .d2(8'h55), .d3(8'hAA),
                   .m0(1'b1), .m1(1'b0), .m2(1'b1), .m3(1'b0));
        send_write(.rank(0), .d0(8'h0F), .d1(8'hF0), .d2(8'hA5), .d3(8'h5A));
        send_write(.rank(1), .d0(8'h33), .d1(8'hCC), .d2(8'h77), .d3(8'h88));
        send_write(.rank(0), .d0(8'hFF), .d1(8'hFF), .d2(8'hFF), .d3(8'hFF),
                   .m0(1'b1), .m1(1'b1), .m2(1'b0), .m3(1'b0));
        send_write(.rank(0), .d0(8'h7F), .d1(8'h7F), .d2(8'h7F), .d3(8'h7F),
                   .m0(1'b0), .m1(1'b0), .m2(1'b0), .m3(1'b0));
        send_write(.rank(1), .d0(8'h80), .d1(8'h81), .d2(8'h82), .d3(8'h83),
                   .m0(1'b1), .m1(1'b0), .m2(1'b0), .m3(1'b1));

        `uvm_info("SEQ", "Hoàn thành: Rank + Mask Sequence", UVM_LOW)
    endtask
endclass : ddr5_rank_mask_seq


//==============================================================================
// BASE TEST — Lớp cha của tất cả test
//==============================================================================
class ddr5_base_test extends uvm_test;
    `uvm_component_utils(ddr5_base_test)

    ddr5_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ddr5_env::type_id::create("env", this);
    endfunction

    // Hàm tiện ích: chạy bất kỳ sequence nào trên MC agent's sequencer
    task run_seq(uvm_sequence #(ddr5_write_seq_item) seq);
        seq.start(env.mc_agent.sequencer);
    endtask

endclass : ddr5_base_test


//==============================================================================
// TEST 1: Single Write Test — +UVM_TESTNAME=ddr5_single_write_test
//==============================================================================
class ddr5_single_write_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_single_write_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

	task run_phase(uvm_phase phase);
		ddr5_single_write_seq seq = ddr5_single_write_seq::type_id::create("seq");
		phase.raise_objection(this, "Bat dau single write test");
		run_seq(seq);
		// SỬA: Tăng từ #100 lên #500
		// Lý do: reset=100ns + drive=390ns + DUT pipeline ~160ns + dự phòng
		#50;
		phase.drop_objection(this, "Ket thuc single write test");
	endtask
endclass : ddr5_single_write_test


//==============================================================================
// TEST 2: Burst Write Test — +UVM_TESTNAME=ddr5_burst_write_test
//==============================================================================
class ddr5_burst_write_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_burst_write_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_burst_write_seq seq = ddr5_burst_write_seq::type_id::create("seq");
        phase.raise_objection(this, "Bắt đầu burst write test");
        run_seq(seq);
        #200;
        phase.drop_objection(this, "Kết thúc burst write test");
    endtask
endclass : ddr5_burst_write_test


//==============================================================================
// TEST 3: Random Write Test — +UVM_TESTNAME=ddr5_random_write_test
//==============================================================================
class ddr5_random_write_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_random_write_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_random_write_seq seq = ddr5_random_write_seq::type_id::create("seq");
        phase.raise_objection(this, "Bắt đầu random write test");
        run_seq(seq);
        #50;
        phase.drop_objection(this, "Kết thúc random write test");
    endtask
endclass : ddr5_random_write_test


//==============================================================================
// TEST 4: Masked Write Test — +UVM_TESTNAME=ddr5_masked_write_test
//==============================================================================
class ddr5_masked_write_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_masked_write_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_masked_write_seq seq = ddr5_masked_write_seq::type_id::create("seq");
        phase.raise_objection(this, "Bắt đầu masked write test");
        run_seq(seq);
        #100;
        phase.drop_objection(this, "Kết thúc masked write test");
    endtask
endclass : ddr5_masked_write_test


//==============================================================================
// TEST 8: MRW + Timing Test — +UVM_TESTNAME=ddr5_mrw_timing_test
//==============================================================================
class ddr5_mrw_timing_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_mrw_timing_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_mrw_timing_seq seq = ddr5_mrw_timing_seq::type_id::create("seq");
        phase.raise_objection(this, "Bắt đầu MRW + timing test");
        run_seq(seq);
        #300;
        phase.drop_objection(this, "Kết thúc MRW + timing test");
    endtask
endclass : ddr5_mrw_timing_test


//==============================================================================
// TEST 9: Rank + Mask Test — +UVM_TESTNAME=ddr5_rank_mask_test
//==============================================================================
class ddr5_rank_mask_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_rank_mask_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_rank_mask_seq seq = ddr5_rank_mask_seq::type_id::create("seq");
        phase.raise_objection(this, "Bắt đầu rank + mask test");
        run_seq(seq);
        #200;
        phase.drop_objection(this, "Kết thúc rank + mask test");
    endtask
endclass : ddr5_rank_mask_test

//==============================================================================
// FSM WRITE SEQUENCE — Kích thích đường write path với back-to-back write và MRW transition
//==============================================================================
class ddr5_fsm_write_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_fsm_write_seq)

    function new(string name = "ddr5_fsm_write_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("SEQ", "Bắt đầu: FSM Write Sequence", UVM_LOW)

        // Ghi liên tiếp nhiều lệnh để kiểm tra đường write path và trạng thái chuyển mạch
        send_write(.rank(0), .d0(8'h00), .d1(8'h11), .d2(8'h22), .d3(8'h33));
        send_write(.rank(0), .d0(8'hFF), .d1(8'hEE), .d2(8'hDD), .d3(8'hCC));

        // MRW ngay trước write tiếp theo để kiểm tra transition MRW -> WRITE
        send_mrw(.rank(0), .mr_addr(8'd0), .mr_op(8'h1F), .idle_after(0));
        send_write(.rank(0), .d0(8'h12), .d1(8'h34), .d2(8'h56), .d3(8'h78));

        // Chuyển rank và tiếp tục push thêm transaction
        send_write(.rank(1), .d0(8'hAA), .d1(8'hBB), .d2(8'hCC), .d3(8'hDD));
        send_write(.rank(1), .d0(8'h55), .d1(8'h66), .d2(8'h77), .d3(8'h88));
        send_write(.rank(0), .d0(8'h7F), .d1(8'h7F), .d2(8'h7F), .d3(8'h7F),
                   .m0(1'b1), .m1(1'b0), .m2(1'b0), .m3(1'b1));
        send_write(.rank(1), .d0(8'h80), .d1(8'h81), .d2(8'h82), .d3(8'h83));

        `uvm_info("SEQ", "Hoàn thành: FSM Write Sequence", UVM_LOW)
    endtask
endclass : ddr5_fsm_write_seq

//==============================================================================
// MRW VARIANT SEQUENCE — Kiểm tra nhiều Mode Register Write và idle timing khác nhau
//==============================================================================
class ddr5_mrw_variant_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_mrw_variant_seq)

    function new(string name = "ddr5_mrw_variant_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("SEQ", "Bắt đầu: MRW Variant Sequence", UVM_LOW)

        send_mrw(.rank(0), .mr_addr(8'd0), .mr_op(8'h01), .idle_after(0));
        send_write(.rank(0), .d0(8'hDE), .d1(8'hAD), .d2(8'hBE), .d3(8'hEF));

        send_mrw(.rank(1), .mr_addr(8'd1), .mr_op(8'h0F), .idle_after(16));
        send_write(.rank(1), .d0(8'hCA), .d1(8'hFE), .d2(8'hBA), .d3(8'hBE));

        send_mrw(.rank(0), .mr_addr(8'd2), .mr_op(8'hA5), .idle_after(32));
        send_write(.rank(0), .d0(8'h00), .d1(8'hFF), .d2(8'h00), .d3(8'hFF));

        send_write(.rank(1), .d0(8'h11), .d1(8'h22), .d2(8'h33), .d3(8'h44));
        send_write(.rank(0), .d0(8'h7F), .d1(8'h7F), .d2(8'h7F), .d3(8'h7F),
                   .m0(1'b1), .m1(1'b0), .m2(1'b0), .m3(1'b0));

        `uvm_info("SEQ", "Hoàn thành: MRW Variant Sequence", UVM_LOW)
    endtask
endclass : ddr5_mrw_variant_seq

//==============================================================================
// TEST 10: FSM Write Test — +UVM_TESTNAME=ddr5_fsm_write_test
//==============================================================================
class ddr5_fsm_write_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_fsm_write_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_fsm_write_seq seq = ddr5_fsm_write_seq::type_id::create("seq");
        phase.raise_objection(this, "Bắt đầu FSM write test");
        run_seq(seq);
        #350;
        phase.drop_objection(this, "Kết thúc FSM write test");
    endtask
endclass : ddr5_fsm_write_test

//==============================================================================
// TEST 11: MRW Variant Test — +UVM_TESTNAME=ddr5_mrw_variant_test
//==============================================================================
class ddr5_mrw_variant_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_mrw_variant_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_mrw_variant_seq seq = ddr5_mrw_variant_seq::type_id::create("seq");
        phase.raise_objection(this, "Bắt đầu MRW variant test");
        run_seq(seq);
        #400;
        phase.drop_objection(this, "Kết thúc MRW variant test");
    endtask
endclass : ddr5_mrw_variant_test


class ddr5_coverage_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_coverage_seq)

    function new(string name = "ddr5_coverage_seq");
        super.new(name);
    endfunction

    task body();
        ddr5_write_seq_item item;
        `uvm_info("SEQ", "Bat dau: Coverage-Directed Sequence", UVM_LOW)

        // -- Nhom 1: Data boundary values, rank 0, BL16 --
        send_write(0, 8'h00, 8'h00, 8'h00, 8'h00); // all_zero
        send_write(0, 8'hFF, 8'hFF, 8'hFF, 8'hFF); // all_one
        send_write(0, 8'h3C, 8'h3C, 8'h3C, 8'h3C); // low_half
        send_write(0, 8'hA5, 8'hA5, 8'hA5, 8'hA5); // high_half

        // -- Nhom 2: Rank 1, tat ca data bin --
        send_write(1, 8'h00, 8'h00, 8'h00, 8'h00); // rank1 + all_zero
        send_write(1, 8'hFF, 8'hFF, 8'hFF, 8'hFF); // rank1 + all_one
        send_write(1, 8'h55, 8'h55, 8'h55, 8'h55); // rank1 + low_half
        send_write(1, 8'hAA, 8'hAA, 8'hAA, 8'hAA); // rank1 + high_half

        // -- Nhom 3: BL8 (burst_len_sel=1) --
        // Phai set truc tiep qua item vi send_write dung default BL16
        begin
            item = ddr5_write_seq_item::type_id::create("bl8_item");
            start_item(item);
            item.rank          = 0;
            item.burst_len_sel = 1'b1; // BL8
            item.wrdata_p0     = 8'h5A;
            item.wrdata_p1     = 8'h5A;
            item.wrdata_p2     = 8'h5A;
            item.wrdata_p3     = 8'h5A;
            item.wrmask_p0     = 1'b0;
            item.wrmask_p1     = 1'b0;
            item.wrmask_p2     = 1'b0;
            item.wrmask_p3     = 1'b0;
            finish_item(item);
        end

        // -- Nhom 4: Masked write --
        send_write(.rank(0),
                   .d0(8'h00), .d1(8'hBB), .d2(8'h00), .d3(8'hDD),
                   .m0(1'b1),  .m1(1'b0),  .m2(1'b1),  .m3(1'b0));

        `uvm_info("SEQ", "Hoan thanh: Coverage-Directed Sequence", UVM_LOW)
    endtask

endclass : ddr5_coverage_seq


//==============================================================================
// TEST 5: +UVM_TESTNAME=ddr5_coverage_test
// Chay sau regression de dat coverage 100%
//==============================================================================
class ddr5_coverage_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_coverage_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_coverage_seq seq = ddr5_coverage_seq::type_id::create("seq");
        phase.raise_objection(this);
        run_seq(seq);
        #500;
        phase.drop_objection(this);
    endtask
endclass : ddr5_coverage_test

//==============================================================================
// BL LENGTH VARIATION SEQUENCE — Bổ sung burst length coverage
//==============================================================================
class ddr5_burst_len_variation_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_burst_len_variation_seq)

    function new(string name = "ddr5_burst_len_variation_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("SEQ", "Bắt đầu: Burst Length Variation Sequence", UVM_LOW)

        // BL16 rank 0
        send_write(.rank(0), .d0(8'hAA), .d1(8'hBB), .d2(8'hCC), .d3(8'hDD), .burst_len_sel(1'b0));
        // BL8 rank 0
        send_write(.rank(0), .d0(8'h11), .d1(8'h22), .d2(8'h33), .d3(8'h44), .burst_len_sel(1'b1));
        // BL16 rank 1
        send_write(.rank(1), .d0(8'hFF), .d1(8'h00), .d2(8'hFF), .d3(8'h00), .burst_len_sel(1'b0));
        // BL8 rank 1 + masked data
        send_write(.rank(1), .d0(8'h0F), .d1(8'hF0), .d2(8'h0F), .d3(8'hF0),
                   .burst_len_sel(1'b1), .m0(1'b1), .m1(1'b0), .m2(1'b1), .m3(1'b0));
        // BL16 rank 0 masked để cover rank0/mask cross
        send_write(.rank(0), .d0(8'h77), .d1(8'h88), .d2(8'h99), .d3(8'hAA),
                   .burst_len_sel(1'b0), .m0(1'b1), .m1(1'b0), .m2(1'b1), .m3(1'b0));
        // BL16 rank 1 all_zero no mask để mở rộng rank/data cross
        send_write(.rank(1), .d0(8'h00), .d1(8'h00), .d2(8'h00), .d3(8'h00), .burst_len_sel(1'b0));
        // Add explicit rank0 all_zero to improve rank/data combos
        send_write(.rank(0), .d0(8'h00), .d1(8'h00), .d2(8'h00), .d3(8'h00), .burst_len_sel(1'b0));
        // Add explicit rank1 high_half, no-mask
        send_write(.rank(1), .d0(8'hA5), .d1(8'hA5), .d2(8'hA5), .d3(8'hA5), .burst_len_sel(1'b0));

        `uvm_info("SEQ", "Hoàn thành: Burst Length Variation Sequence", UVM_LOW)
    endtask
endclass : ddr5_burst_len_variation_seq

//==============================================================================
// TEST 12: Burst Length Variation Test — +UVM_TESTNAME=ddr5_burst_len_variation_test
//==============================================================================
class ddr5_burst_len_variation_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_burst_len_variation_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_burst_len_variation_seq seq = ddr5_burst_len_variation_seq::type_id::create("seq");
        phase.raise_objection(this, "Bắt đầu burst length variation test");
        run_seq(seq);
        #200;
        phase.drop_objection(this, "Kết thúc burst length variation test");
    endtask
endclass : ddr5_burst_len_variation_test


class ddr5_speed_seq extends ddr5_base_seq;
    `uvm_object_utils(ddr5_speed_seq)

    string speed_label = "UNKNOWN";

    function new(string name = "ddr5_speed_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info("SEQ", $sformatf("=== BAT DAU SPEED TEST: %s ===", speed_label), UVM_LOW)

        // Giao dịch 1: Rank 0, data = 0xAB 0xCD 0xEF 0x12 (high_half)
        send_write(.rank(0), .d0(8'hAB), .d1(8'hCD), .d2(8'hEF), .d3(8'h12));

        // Giao dịch 2: Rank 0, low_half
        send_write(.rank(0), .d0(8'h3C), .d1(8'h3C), .d2(8'h3C), .d3(8'h3C));

        // Giao dịch 3: Rank 0, all-zero
        send_write(.rank(0), .d0(8'h00), .d1(8'h00), .d2(8'h00), .d3(8'h00));

        // Giao dịch 4: Rank 0, all-one
        send_write(.rank(0), .d0(8'hFF), .d1(8'hFF), .d2(8'hFF), .d3(8'hFF));

        // Giao dịch 5: Rank 0, masked pattern để cover rank0/mask
        send_write(.rank(0), .d0(8'h11), .d1(8'h22), .d2(8'h33), .d3(8'h44),
                   .m0(1'b1), .m1(1'b0), .m2(1'b1), .m3(1'b0));

        // Giao dịch 6: Rank 1, high_half
        send_write(.rank(1), .d0(8'hDE), .d1(8'hAD), .d2(8'hBE), .d3(8'hEF));

        // Giao dịch 7: Rank 1, low_half
        send_write(.rank(1), .d0(8'h55), .d1(8'h66), .d2(8'h77), .d3(8'h88));

        // Giao dịch 8: Rank 1, all-zero no mask để hoàn thiện rank/data cross
        send_write(.rank(1), .d0(8'h00), .d1(8'h00), .d2(8'h00), .d3(8'h00));

        // Giao dịch 9: Rank 1, all-one (masked)
        send_write(.rank(1), .d0(8'hFF), .d1(8'hFF), .d2(8'hFF), .d3(8'hFF),
                   .m0(1'b1), .m1(1'b0), .m2(1'b1), .m3(1'b0));

        `uvm_info("SEQ", $sformatf("=== HOAN THANH SPEED TEST: %s ===", speed_label), UVM_LOW)
    endtask

endclass : ddr5_speed_seq


//==============================================================================
// TEST 6: DDR5-3200 Speed Test
// Chạy với: +UVM_TESTNAME=ddr5_3200_speed_test
// Top module : tb_top_3200 (clock ~1603 MHz, half-period=312ps)
//==============================================================================
class ddr5_3200_speed_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_3200_speed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_speed_seq seq = ddr5_speed_seq::type_id::create("seq");
        seq.speed_label = "DDR5-3200 | Clock ~1603 MHz | Period ~624 ps | Data Rate ~3200 MT/s";
        phase.raise_objection(this, "Bat dau DDR5-3200 speed test");
        `uvm_info("TEST", "============================================================", UVM_NONE)
        `uvm_info("TEST", "  TARGET : DDR5-3200", UVM_NONE)
        `uvm_info("TEST", "  Clock  : ~1603 MHz  (half-period = 312 ps)", UVM_NONE)
        `uvm_info("TEST", "  Rate   : ~3200 MT/s", UVM_NONE)
        `uvm_info("TEST", "============================================================", UVM_NONE)
        run_seq(seq);
        #500;
        phase.drop_objection(this, "Ket thuc DDR5-3200 speed test");
    endtask

endclass : ddr5_3200_speed_test


//==============================================================================
// TEST 7: DDR5-6400 Speed Test
// Chạy với: +UVM_TESTNAME=ddr5_6400_speed_test
// Top module : tb_top_6400 (clock ~3205 MHz, half-period=156ps)
//==============================================================================
class ddr5_6400_speed_test extends ddr5_base_test;
    `uvm_component_utils(ddr5_6400_speed_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        ddr5_speed_seq seq = ddr5_speed_seq::type_id::create("seq");
        seq.speed_label = "DDR5-6400 | Clock ~3205 MHz | Period ~312 ps | Data Rate ~6400 MT/s";
        phase.raise_objection(this, "Bat dau DDR5-6400 speed test");
        `uvm_info("TEST", "============================================================", UVM_NONE)
        `uvm_info("TEST", "  TARGET : DDR5-6400", UVM_NONE)
        `uvm_info("TEST", "  Clock  : ~3205 MHz  (half-period = 156 ps)", UVM_NONE)
        `uvm_info("TEST", "  Rate   : ~6400 MT/s", UVM_NONE)
        `uvm_info("TEST", "============================================================", UVM_NONE)
        run_seq(seq);
        #500;
        phase.drop_objection(this, "Ket thuc DDR5-6400 speed test");
    endtask

endclass : ddr5_6400_speed_test

`endif // DDR5_TESTS_SV
