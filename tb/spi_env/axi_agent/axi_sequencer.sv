class axi_sequencer extends uvm_sequencer#(axi_transaction);
    `uvm_component_utils(axi_sequencer)

    uvm_analysis_imp#(axi_transaction, axi_sequencer) mon2seq_imp;
    logic [31:0] rdata;

    function new(string name = "axi_sequencer", uvm_component parent);
        super.new(name, parent);
        mon2seq_imp = new("mon2seq_imp", this);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation....", UVM_LOW)
    endfunction


    //------------------------
    //  Write Method Imp
    //-----------------------
    function void write(axi_transaction pkt);
        rdata = pkt.rdata;
        `uvm_info("SEQR", "Req PKT received", UVM_MEDIUM)
    endfunction: write

endclass