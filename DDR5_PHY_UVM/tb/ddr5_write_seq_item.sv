`ifndef DDR5_WRITE_SEQ_ITEM_SV
`define DDR5_WRITE_SEQ_ITEM_SV

class ddr5_write_seq_item extends uvm_sequence_item;

    rand logic        rank;
    rand logic [1:0]  bank_group;
    rand logic [1:0]  bank;
    rand logic [16:0] row_addr;
    rand logic [9:0]  col_addr;
    rand logic        burst_len_sel;
    rand logic [7:0]  wrdata_p0, wrdata_p1, wrdata_p2, wrdata_p3;
    rand logic [0:0]  wrmask_p0, wrmask_p1, wrmask_p2, wrmask_p3;

    logic              is_mrw;
    logic [7:0]        mr_address;
    logic [7:0]        mr_operation;
    int unsigned       idle_cycles_after;

    `uvm_object_utils_begin(ddr5_write_seq_item)
        `uvm_field_int(rank,            UVM_ALL_ON)
        `uvm_field_int(bank_group,      UVM_ALL_ON)
        `uvm_field_int(bank,            UVM_ALL_ON)
        `uvm_field_int(row_addr,        UVM_ALL_ON)
        `uvm_field_int(col_addr,        UVM_ALL_ON)
        `uvm_field_int(burst_len_sel,   UVM_ALL_ON)
        `uvm_field_int(wrdata_p0,       UVM_ALL_ON)
        `uvm_field_int(wrdata_p1,       UVM_ALL_ON)
        `uvm_field_int(wrdata_p2,       UVM_ALL_ON)
        `uvm_field_int(wrdata_p3,       UVM_ALL_ON)
        `uvm_field_int(wrmask_p0,       UVM_ALL_ON)
        `uvm_field_int(wrmask_p1,       UVM_ALL_ON)
        `uvm_field_int(wrmask_p2,       UVM_ALL_ON)
        `uvm_field_int(wrmask_p3,       UVM_ALL_ON)
        `uvm_field_int(is_mrw,          UVM_ALL_ON)
        `uvm_field_int(mr_address,      UVM_ALL_ON)
        `uvm_field_int(mr_operation,    UVM_ALL_ON)
        `uvm_field_int(idle_cycles_after, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint c_default_mask { wrmask_p0==0; wrmask_p1==0; wrmask_p2==0; wrmask_p3==0; }
    constraint c_default_bl   { burst_len_sel == 1'b0; }
    constraint c_col_addr     { col_addr inside {[0:10'h3FF]}; }

    function new(string name = "ddr5_write_seq_item");
        super.new(name);
        is_mrw           = 0;
        mr_address       = 8'h00;
        mr_operation     = 8'h00;
        idle_cycles_after = 0;
    endfunction

    function string convert2string();
        if (is_mrw) begin
            return $sformatf("MRW: rank=%0d addr=0x%02h op=0x%02h idle=%0d",
                rank, mr_address, mr_operation, idle_cycles_after);
        end else begin
            return $sformatf("WRITE: rank=%0d bg=%0d bk=%0d row=0x%05h col=0x%03h | DATA[p0=%02h p1=%02h p2=%02h p3=%02h] MASK[%b%b%b%b]",
                rank, bank_group, bank, row_addr, col_addr,
                wrdata_p0, wrdata_p1, wrdata_p2, wrdata_p3,
                wrmask_p0, wrmask_p1, wrmask_p2, wrmask_p3);
        end
    endfunction

endclass

`endif