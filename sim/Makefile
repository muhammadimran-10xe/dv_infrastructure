# Directory definitions
RTL := ../dut
TB  := ../tb
SIM := .

# Compile Options for Synopsys VCS
COMP_OPT += -ntb_opts uvm
COMP_OPT += -sverilog
COMP_OPT += -full64
COMP_OPT += -timescale=1ns/1ps
COMP_OPT += -debug_pp
COMP_OPT += +v2k
COMP_OPT += -lca
COMP_OPT += -kdb
COMP_OPT += -cm line+cond+branch+tgl
COMP_OPT += -acc +vpi +lint=TFIPC-L

# Simulation options
SIM_OPT += +UVM_VERBOSITY=UVM_MEDIUM
SIM_OPT += +vcs+initreg+0

# DUT files
DUT_FILES = \
$(RTL)/spi_lite_defs.v \
$(RTL)/spi_lite.v

# Interface files
INTF_FILES = \
$(TB)/interface/spi_axi_intf.sv

# AXI UVC files
AXI_UVC = \
$(TB)/axi_uvc/axi_transaction.sv \
$(TB)/axi_uvc/axi_sequencer.sv \
$(TB)/axi_uvc/axi_sequence.sv \
$(TB)/axi_uvc/axi_driver.sv \
$(TB)/axi_uvc/axi_monitor.sv \
$(TB)/axi_uvc/axi_agent.sv \
$(TB)/axi_uvc/axi_environment.sv

# Testbench files
TB_FILES = \
$(TB)/test.sv \
$(TB)/testbench_top.sv

# Default target
main: compile sim

# Compile
compile:
	rm -rf csrc simv simv.daidir *.log *.vpd *.fsdb *.key
	vcs $(COMP_OPT) \
	+incdir+$(RTL) \
	+incdir+$(TB) \
	+incdir+$(TB)/interface \
	$(DUT_FILES) \
	$(INTF_FILES) \
    $(AXI_UVC) \
	$(TB_FILES) \
	-l compile.log

# Run simulation
sim:
	./simv $(SIM_OPT) -l sim.log

# Clean build
clean:
	rm -rf simv csrc simv.daidir *.log *.vpd *.fsdb *.key verdiLog novas.* vc_hdrs.h wave.vcd
