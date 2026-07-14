# ==============================================================================
# MAKEFILE — XAC MINH CHUC NANG GHI DDR5 PHY BANG UVM
# Bao gom: Speed Test DDR5-3200 va DDR5-6400
#
# Cau truc:
#   - Target goc (compile, sim, regression): dung tb_top.sv, clock 100MHz
#   - Target speed: dung tb_top_3200.sv / tb_top_6400.sv, clock 1600/3200 MHz
#
# UVM Setup (2026-06-21):
#   - Supports auto-detection of UVM library or local UVM source
#   - See SETUP_UVM.md for complete UVM 1.1d installation guide
# ==============================================================================

RTL_DIR  = ../rtl
TB_DIR   = ../tb
TB_TOP       = tb_top
TB_TOP_3200  = tb_top_3200
TB_TOP_6400  = tb_top_6400

TEST     = ddr5_single_write_test
UVM_VERB = UVM_MEDIUM

# ==============================================================================
# UVM Configuration (Optional - for library-based UVM)
# ==============================================================================
# Uncomment and set if you have UVM installed as a library:
# UVM_LIB = -L uvm_lib
# Otherwise, uses system library search path (recommended)

# ==============================================================================
# DEFAULT
# ==============================================================================
all: clean compile_all sim_gui

# ==============================================================================
# CLEAN
# ==============================================================================
clean:
	rm -rf work transcript modelsim.ini vsim.wlf dump.vcd dump_3200.vcd dump_6400.vcd *.log

# ==============================================================================
# COMPILE — TESTBENCH GOC (5 buoc)
# ==============================================================================
compile: 
	vlib work
	vmap work work
	@echo "=== [1/6] Bien dich RTL (DUT) ==="
	vlog -timescale 1ns/1ps \
	    $(RTL_DIR)/ddr5_phy_register_file.sv \
	    $(RTL_DIR)/ddr5_phy_frequency_ratio.sv \
	    $(RTL_DIR)/ddr5_phy_command_address.sv \
	    $(RTL_DIR)/ddr5_phy_crc_x4.sv \
	    $(RTL_DIR)/ddr5_phy_crc.sv \
	    $(RTL_DIR)/ddr5_phy_write_counter.sv \
	    $(RTL_DIR)/ddr5_phy_write_shift.sv \
	    $(RTL_DIR)/ddr5_phy_write_fsm.sv \
	    $(RTL_DIR)/ddr5_phy_write_manager.sv \
	    $(RTL_DIR)/ddr5_phy_top.sv
	@echo "=== [2/6] Bien dich Interface goc ==="
	vlog -timescale 1ns/1ps \
	    $(TB_DIR)/ddr5_phy_if.sv
	@echo "=== [3/6] Bien dich Assertion Module ==="
	vlog -timescale 1ns/1ps \
	    $(TB_DIR)/ddr5_assertions.sv
	@echo "=== [4/6] Bien dich TB Package (UVM) ==="
	vlog -timescale 1ns/1ps \
	    $(UVM_LIB) \
	    +incdir+$(TB_DIR) \
	    $(TB_DIR)/tb_pkg.sv
	@echo "=== [5/6] Bien dich Top Testbench goc ==="
	vlog -timescale 1ns/1ps \
	    $(UVM_LIB) \
	    +incdir+$(TB_DIR) \
	    $(TB_DIR)/tb_top.sv
	@echo "=== Compile HOAN TAT (5 buoc) ==="

# ==============================================================================
# COMPILE SPEED — THEM TOP SPEED (buoc 6)
# ==============================================================================
compile_speed: compile
	@echo "=== [6/6] Bien dich Speed Test Top Modules ==="
	@echo "    tb_top_3200: DDR5-3200 (clock ~1603 MHz, half-period=312ps) ==="
	vlog -timescale 1ps/1fs \
	    +incdir+$(TB_DIR) \
	    $(TB_DIR)/tb_top_3200.sv
	@echo "    tb_top_6400: DDR5-6400 (clock ~3205 MHz, half-period=156ps) ==="
	vlog -timescale 1ps/1fs \
	    +incdir+$(TB_DIR) \
	    $(TB_DIR)/tb_top_6400.sv
	@echo "=== Compile Speed HOAN TAT (6/6 buoc) ==="

# ==============================================================================
# COMPILE ALL — CHAY CA 6 BUOC TRONG MOT LAN
# ==============================================================================
compile_all: compile_speed



# ==============================================================================
# SIM GUI — Testbench goc
# ==============================================================================
sim_gui:
	vsim -t 1ps \
	    -suppress 3009 \
	    -voptargs="+acc" \
	    +UVM_TESTNAME=$(TEST) \
	    +UVM_VERBOSITY=$(UVM_VERB) \
	    -do " \
	        add wave -divider {=== CLOCK & RESET ===}; \
	        add wave -color Gold   /tb_top/clk; \
	        add wave -color Gold   /tb_top/vif/rst_n; \
	        add wave -color Gold   /tb_top/vif/enable; \
	        add wave -divider {=== DFI INPUT (MC->PHY) ===}; \
	        add wave -color Cyan   /tb_top/vif/dfi_cs_n_p0; \
	        add wave -color Cyan   /tb_top/vif/dfi_address_p0; \
	        add wave -color Cyan   /tb_top/vif/dfi_wrdata_en_p0; \
	        add wave -color Cyan   /tb_top/vif/dfi_wrdata_p0; \
	        add wave -color Cyan   /tb_top/vif/dfi_wrdata_p1; \
	        add wave -color Cyan   /tb_top/vif/dfi_wrdata_p2; \
	        add wave -color Cyan   /tb_top/vif/dfi_wrdata_p3; \
	        add wave -color Cyan   /tb_top/vif/dfi_wrdata_mask_p0; \
	        add wave -divider {=== DRAM OUTPUT (PHY->DRAM) ===}; \
	        add wave -color Magenta /tb_top/vif/CS_n; \
	        add wave -color Magenta /tb_top/vif/CA; \
	        add wave -color Yellow  /tb_top/vif/DQS; \
	        add wave -color Yellow  /tb_top/vif/DQS_valid; \
	        add wave -color Green   /tb_top/vif/DQ; \
	        add wave -color Green   /tb_top/vif/DQ_valid; \
	        add wave -color Green   /tb_top/vif/DM; \
	        run -all; \
	    " \
	    $(TB_TOP)

# ==============================================================================
# SIM BATCH — Testbench goc
# ==============================================================================
sim:
	vsim -t 1ps \
	    -suppress 3009 \
	    -c \
	    +UVM_TESTNAME=$(TEST) \
	    +UVM_VERBOSITY=$(UVM_VERB) \
	    -do "run -all; quit -f;" \
	    $(TB_TOP) \
	    | tee $(TEST).log
	@echo ""
	@echo "=== Log da luu vao: $(TEST).log ==="
	@grep -E "UVM_ERROR|UVM_FATAL|PASS|FAIL|ASSERT|Report counts" $(TEST).log || true

# ==============================================================================
# SPEED SIM — DDR5-3200 (1600 MHz, period~0.624 ns)
# ==============================================================================
sim_3200:
	@echo "======================================================"
	@echo "  CHAY: DDR5-3200 Speed Test"
	@echo "  Clock: ~1600 MHz | Period: ~0.624 ns"
	@echo "======================================================"
	vsim -t 1ps \
	    -suppress 3009 \
	    -c \
	    +UVM_TESTNAME=ddr5_3200_speed_test \
	    +UVM_VERBOSITY=$(UVM_VERB) \
	    -do "run -all; quit -f;" \
	    $(TB_TOP_3200) \
	    | tee ddr5_3200_speed_test.log
	@echo ""
	@echo "=== Log da luu vao: ddr5_3200_speed_test.log ==="
	@grep -E "UVM_ERROR|UVM_FATAL|TARGET SPEED|PASS|FAIL|Report counts" ddr5_3200_speed_test.log || true

# DDR5-3200 co GUI (de xem waveform)
sim_3200_gui:
	vsim -t 1ps \
	    -suppress 3009 \
	    -voptargs="+acc" \
	    +UVM_TESTNAME=ddr5_3200_speed_test \
	    +UVM_VERBOSITY=$(UVM_VERB) \
	    -do " \
	        add wave -divider {=== DDR5-3200: CLOCK & RESET ===}; \
	        add wave -color Gold   /tb_top_3200/clk; \
	        add wave -color Gold   /tb_top_3200/vif/rst_n; \
	        add wave -divider {=== DFI INPUT ===}; \
	        add wave -color Cyan   /tb_top_3200/vif/dfi_cs_n_p0; \
	        add wave -color Cyan   /tb_top_3200/vif/dfi_address_p0; \
	        add wave -color Cyan   /tb_top_3200/vif/dfi_wrdata_en_p0; \
	        add wave -color Cyan   /tb_top_3200/vif/dfi_wrdata_p0; \
	        add wave -divider {=== DRAM OUTPUT ===}; \
	        add wave -color Yellow  /tb_top_3200/vif/DQS; \
	        add wave -color Green   /tb_top_3200/vif/DQ; \
	        add wave -color Green   /tb_top_3200/vif/DQ_valid; \
	        run -all; \
	    " \
	    $(TB_TOP_3200)

# ==============================================================================
# SPEED SIM — DDR5-6400 (3200 MHz, period~0.312 ns)
# ==============================================================================
sim_6400:
	@echo "======================================================"
	@echo "  CHAY: DDR5-6400 Speed Test"
	@echo "  Clock: ~3200 MHz | Period: ~0.312 ns"
	@echo "======================================================"
	vsim -t 1ps \
	    -suppress 3009 \
	    -c \
	    +UVM_TESTNAME=ddr5_6400_speed_test \
	    +UVM_VERBOSITY=$(UVM_VERB) \
	    -do "run -all; quit -f;" \
	    $(TB_TOP_6400) \
	    | tee ddr5_6400_speed_test.log
	@echo ""
	@echo "=== Log da luu vao: ddr5_6400_speed_test.log ==="
	@grep -E "UVM_ERROR|UVM_FATAL|TARGET SPEED|PASS|FAIL|Report counts" ddr5_6400_speed_test.log || true

# DDR5-6400 co GUI
sim_6400_gui:
	vsim -t 1ps \
	    -suppress 3009 \
	    -voptargs="+acc" \
	    +UVM_TESTNAME=ddr5_6400_speed_test \
	    +UVM_VERBOSITY=$(UVM_VERB) \
	    -do " \
	        add wave -divider {=== DDR5-6400: CLOCK & RESET ===}; \
	        add wave -color Gold   /tb_top_6400/clk; \
	        add wave -color Gold   /tb_top_6400/vif/rst_n; \
	        add wave -divider {=== DFI INPUT ===}; \
	        add wave -color Cyan   /tb_top_6400/vif/dfi_cs_n_p0; \
	        add wave -color Cyan   /tb_top_6400/vif/dfi_address_p0; \
	        add wave -color Cyan   /tb_top_6400/vif/dfi_wrdata_en_p0; \
	        add wave -color Cyan   /tb_top_6400/vif/dfi_wrdata_p0; \
	        add wave -divider {=== DRAM OUTPUT ===}; \
	        add wave -color Yellow  /tb_top_6400/vif/DQS; \
	        add wave -color Green   /tb_top_6400/vif/DQ; \
	        add wave -color Green   /tb_top_6400/vif/DQ_valid; \
	        run -all; \
	    " \
	    $(TB_TOP_6400)

# ==============================================================================
# REGRESSION — 12 tests
# ==============================================================================
regression: compile_speed
	@echo "======================================"
	@echo "  REGRESSION: Chay tat ca 12 test"
	@echo "  Original 7 tests:"
	@echo "    1. ddr5_single_write_test"
	@echo "    2. ddr5_burst_write_test"
	@echo "    3. ddr5_random_write_test"
	@echo "    4. ddr5_masked_write_test"
	@echo "    5. ddr5_mrw_timing_test"
	@echo "    6. ddr5_rank_mask_test"
	@echo "    7. ddr5_coverage_test"
	@echo "  Speed tests:"
	@echo "    8. ddr5_3200_speed_test (DDR5-3200)"
	@echo "    9. ddr5_6400_speed_test (DDR5-6400)"
	@echo "  FSM/MRW tests:"
	@echo "    10. ddr5_fsm_write_test"
	@echo "    11. ddr5_mrw_variant_test"
	@echo "  Burst Length Coverage test:"
	@echo "    12. ddr5_burst_len_variation_test"
	@echo "======================================"
	$(MAKE) sim TEST=ddr5_single_write_test
	$(MAKE) sim TEST=ddr5_burst_write_test
	$(MAKE) sim TEST=ddr5_random_write_test
	$(MAKE) sim TEST=ddr5_masked_write_test
	$(MAKE) sim TEST=ddr5_mrw_timing_test
	$(MAKE) sim TEST=ddr5_rank_mask_test
	$(MAKE) sim TEST=ddr5_coverage_test
	$(MAKE) sim_3200
	$(MAKE) sim_6400
	$(MAKE) sim TEST=ddr5_fsm_write_test
	$(MAKE) sim TEST=ddr5_mrw_variant_test
	$(MAKE) sim TEST=ddr5_burst_len_variation_test
	@echo "======================================"
	@echo "  REGRESSION HOAN TAT (12/12 tests)"
	@echo "======================================"

# ==============================================================================
# SPEED REGRESSION — 2 speed test
# ==============================================================================
speed_regression: compile_speed
	@echo "=============================================="
	@echo "  SPEED REGRESSION: DDR5-3200 va DDR5-6400"
	@echo "=============================================="
	$(MAKE) sim_3200
	$(MAKE) sim_6400
	@echo "=============================================="
	@echo "  SPEED REGRESSION HOAN TAT"
	@echo "  Xem ket qua:"
	@echo "    ddr5_3200_speed_test.log"
	@echo "    ddr5_6400_speed_test.log"
	@echo "=============================================="
