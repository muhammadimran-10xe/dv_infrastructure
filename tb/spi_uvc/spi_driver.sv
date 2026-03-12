class spi_driver extends uvm_driver #(spi_transaction);
    `uvm_component_utils(spi_driver);

    function new(string name = "spi_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual spi_axi_intf vif;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual spi_axi_intf)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "No virtual Interface for AXI_SPI")

    endfunction

    task run_phase(uvm_phase phase);

    endtask


    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name, "Running Simulation....", UVM_HIGH)
    endfunction



endclass