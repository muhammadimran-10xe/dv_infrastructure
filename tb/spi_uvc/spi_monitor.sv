class spi_monitor extends uvm_monitor;

    `uvm_component_utils(spi_monitor)

    virtual spi_axi_intf vif;
    // uvm_analysis_port#(axi_transaction) ap;

    function new(string name = "spi_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // ap = new("ap", this);
        if(!uvm_config_db#(virtual spi_axi_intf)::get(this, "", "vif", vif))
        `uvm_fatal("[AXI MON]", "No virtual Interface for AXI SPI")

    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name, "Running Simulation....", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);

    endtask

endclass