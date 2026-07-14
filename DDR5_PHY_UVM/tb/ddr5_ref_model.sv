
`ifndef DDR5_REF_MODEL_SV
`define DDR5_REF_MODEL_SV

class ddr5_ref_model;


    static function logic [7:0] calc_crc_x4(input logic [7:0] data_in);
        logic [7:0] dr; // data_register sau 8 buoc tinh

        // Counter 0 (bit 0..7 cua data_in)
        dr[0] = data_in[0] ^ data_in[6] ^ data_in[7];
        dr[1] = data_in[0] ^ data_in[1] ^ data_in[6];
        dr[2] = data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[6];
        dr[3] = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7];
        dr[4] = data_in[2] ^ data_in[3] ^ data_in[4];
        dr[5] = data_in[3] ^ data_in[4] ^ data_in[5];
        dr[6] = data_in[4] ^ data_in[5] ^ data_in[6];
        dr[7] = data_in[5] ^ data_in[6] ^ data_in[7];

        // Counter 1 (bit 8..15 - dung lai data_in vi DUT xu ly 1 byte lien tuc)
        dr[0] = dr[0] ^ data_in[4] ^ data_in[6] ^ data_in[0];
        dr[1] = dr[1] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
        dr[2] = dr[2] ^ data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[7];
        dr[3] = dr[3] ^ data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[6];
        dr[4] = dr[4] ^ data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[6] ^ data_in[7];
        dr[5] = dr[5] ^ data_in[1] ^ data_in[3] ^ data_in[5] ^ data_in[7];
        dr[6] = dr[6] ^ data_in[2] ^ data_in[4] ^ data_in[6];
        dr[7] = dr[7] ^ data_in[3] ^ data_in[5] ^ data_in[7];

        // Counter 2
        dr[0] = dr[0] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[7];
        dr[1] = dr[1] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
        dr[2] = dr[2] ^ data_in[1] ^ data_in[6];
        dr[3] = dr[3] ^ data_in[0] ^ data_in[2] ^ data_in[7];
        dr[4] = dr[4] ^ data_in[1] ^ data_in[3];
        dr[5] = dr[5] ^ data_in[0] ^ data_in[2] ^ data_in[4];
        dr[6] = dr[6] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[5];
        dr[7] = dr[7] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[6];

        // Counter 3
        dr[0] = dr[0] ^ data_in[4] ^ data_in[6] ^ data_in[7];
        dr[1] = dr[1] ^ data_in[0] ^ data_in[4] ^ data_in[5] ^ data_in[6];
        dr[2] = dr[2] ^ data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5];
        dr[3] = dr[3] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[6];
        dr[4] = dr[4] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[6] ^ data_in[7];
        dr[5] = dr[5] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[7];
        dr[6] = dr[6] ^ data_in[2] ^ data_in[4] ^ data_in[5];
        dr[7] = dr[7] ^ data_in[3] ^ data_in[5] ^ data_in[6];

        // Counter 4
        dr[0] = dr[0] ^ data_in[2] ^ data_in[3] ^ data_in[7];
        dr[1] = dr[1] ^ data_in[0] ^ data_in[2] ^ data_in[4] ^ data_in[7];
        dr[2] = dr[2] ^ data_in[1] ^ data_in[2] ^ data_in[5] ^ data_in[7];
        dr[3] = dr[3] ^ data_in[2] ^ data_in[3] ^ data_in[6];
        dr[4] = dr[4] ^ data_in[3] ^ data_in[4] ^ data_in[7];
        dr[5] = dr[5] ^ data_in[0] ^ data_in[4] ^ data_in[5];
        dr[6] = dr[6] ^ data_in[0] ^ data_in[1] ^ data_in[5] ^ data_in[6];
        dr[7] = dr[7] ^ data_in[1] ^ data_in[2] ^ data_in[6] ^ data_in[7];

        // Counter 5
        dr[0] = dr[0] ^ data_in[0] ^ data_in[3] ^ data_in[5];
        dr[1] = dr[1] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[6];
        dr[2] = dr[2] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7];
        dr[3] = dr[3] ^ data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[7];
        dr[4] = dr[4] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[6];
        dr[5] = dr[5] ^ data_in[0] ^ data_in[2] ^ data_in[5] ^ data_in[6] ^ data_in[7];
        dr[6] = dr[6] ^ data_in[1] ^ data_in[3] ^ data_in[6] ^ data_in[7];
        dr[7] = dr[7] ^ data_in[2] ^ data_in[4] ^ data_in[7];

        // Counter 6
        dr[0] = dr[0] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6];
        dr[1] = dr[1] ^ data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[7];
        dr[2] = dr[2] ^ data_in[0] ^ data_in[2] ^ data_in[6];
        dr[3] = dr[3] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[7];
        dr[4] = dr[4] ^ data_in[0] ^ data_in[1] ^ data_in[2] ^ data_in[4];
        dr[5] = dr[5] ^ data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[5];
        dr[6] = dr[6] ^ data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[4] ^ data_in[6];
        dr[7] = dr[7] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[5] ^ data_in[7];

        // Counter 7
        dr[0] = dr[0] ^ data_in[0] ^ data_in[4] ^ data_in[7];
        dr[1] = dr[1] ^ data_in[0] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7];
        dr[2] = dr[2] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];
        dr[3] = dr[3] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6] ^ data_in[7];
        dr[4] = dr[4] ^ data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[6] ^ data_in[7];
        dr[5] = dr[5] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7];
        dr[6] = dr[6] ^ data_in[2] ^ data_in[5] ^ data_in[6];
        dr[7] = dr[7] ^ data_in[3] ^ data_in[6] ^ data_in[7];

        return dr;
    endfunction

    //==========================================================================
    // predict_dq: du doan gia tri DQ output tu wrdata
    // Khi pCRC_MODE=0 (che do hien tai): DQ = wrdata truc tiep (khong CRC)
    // Khi pCRC_MODE=1 (che do day du):  DQ = calc_crc_x4(wrdata)
    //==========================================================================
    static function logic [7:0] predict_dq(
        input logic [7:0] wrdata,
        input logic       crc_mode  // 0=no CRC, 1=PHY CRC
    );
        if (crc_mode == 1'b0)
            return wrdata;           // MC tu tinh CRC, DUT xuyen thang data
        else
            return calc_crc_x4(wrdata); // PHY tinh CRC
    endfunction

endclass : ddr5_ref_model

`endif // DDR5_REF_MODEL_SV
