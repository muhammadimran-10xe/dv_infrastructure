VCS      = vcs
SIMV     = ./simv
FILELIST = file.f
TOP      = testbench_top

VCS_FLAGS = -full64 -sverilog \
            -ntb_opts uvm-1.2 \
            -debug_access+all \
            -l compile.log

SIM_FLAGS = +UVM_VERBOSITY=UVM_LOW \
            -l sim.log

.PHONY: all compile run clean

all: clean compile run

compile:
	$(VCS) $(VCS_FLAGS) -f $(FILELIST) -top $(TOP) -o simv

run:
	$(SIMV) $(SIM_FLAGS)

clean:
	rm -rf simv* csrc *.log DVEfiles ucli.key vc_hdrs.h