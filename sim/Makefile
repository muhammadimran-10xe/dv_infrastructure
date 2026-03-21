# Directory definitions
RTL := ../dut
TB  := ../tb
RM  := ../ref_model
SIM := .

TEST ?= spi_base_test
# Compile Options for Synopsys VCS
COMP_OPT += -ntb_opts uvm
COMP_OPT += -sverilog
COMP_OPT += -full64
COMP_OPT += -timescale=1ns/1ps
COMP_OPT += -debug_pp
COMP_OPT += +v2k
COMP_OPT += -cm line+cond+branch+tgl
COMP_OPT += -acc +vpi +lint=TFIPC-L

# Simulation options
SIM_OPT += +UVM_TESTNAME=$(TEST)
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
$(TB)/spi_env/axi_agent/axi_transaction.sv \
$(TB)/spi_env/axi_agent/axi_config.sv \
$(TB)/spi_env/axi_agent/axi_sequencer.sv \
$(TB)/spi_env/spi_mcsequencer.sv \
$(TB)/spi_env/axi_agent/axi_sequence.sv \
$(TB)/spi_env/axi_agent/axi_driver.sv \
$(TB)/spi_env/axi_agent/axi_monitor.sv \
$(TB)/spi_env/axi_agent/axi_agent.sv

SPI_UVC = \
$(TB)/spi_env/spi_slave_agent/spi_slave_transaction.sv \
$(TB)/spi_env/spi_slave_agent/spi_slave_config.sv \
$(TB)/spi_env/spi_slave_agent/spi_slave_sequencer.sv \
$(TB)/spi_env/spi_slave_agent/spi_slave_sequence.sv \
$(TB)/spi_env/spi_slave_agent/spi_slave_driver.sv \
$(TB)/spi_env/spi_slave_agent/spi_slave_monitor.sv \
$(TB)/spi_env/spi_slave_agent/spi_slave_agent.sv

SPI_ENV = \
$(RM)/dpi_pkg.sv \
$(TB)/spi_env/spi_env_pkg.sv

REF_MODEL = \
$(RM)/spi_lite.c \
$(RM)/ref_wrapper.c

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
	+incdir+$(TB)/spi_env \
	+incdir+$(RM) \
	$(DUT_FILES) \
	$(INTF_FILES) \
	$(SPI_UVC) \
    $(AXI_UVC) \
	$(REF_MODEL) \
	$(SPI_ENV) \
	$(TB_FILES) \
	-l compile.log

# Run simulation
sim:
	./simv $(SIM_OPT) -l sim.log

# Clean build
clean:
	rm -rf simv csrc simv.daidir *.log *.vpd *.fsdb *.key verdiLog novas.* vc_hdrs.h wave.vcd simv.vdb
