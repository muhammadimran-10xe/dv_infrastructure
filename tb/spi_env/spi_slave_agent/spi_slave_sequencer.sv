class spi_slave_sequencer extends uvm_sequencer#(spi_slave_transaction);

    `uvm_component_utils(spi_slave_sequencer)

    uvm_tlm_analysis_fifo #(spi_slave_transaction) mon_to_seq_fifo;
    
    

    

    function new(string name = "spi_slave_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_to_seq_fifo = new("mon_to_seq_fifo", this); // depth 4
    endfunction
    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation....", UVM_LOW)
    endfunction


endclass