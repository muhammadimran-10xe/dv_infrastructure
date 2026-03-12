class spi_sequencer extends uvm_sequencer#(spi_transaction);
    `uvm_component_utils(spi_sequencer)

    function new(string name = "spi_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation....", UVM_LOW)
    endfunction

endclass