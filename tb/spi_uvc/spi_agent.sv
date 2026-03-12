class spi_agent extends uvm_agent;
    `uvm_component_utils(spi_agent);

    function new(string name = "spi_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    spi_sequencer seqr;
    spi_driver drv;
    spi_monitor mon;
    uvm_analysis_port#(spi_transaction) ap;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = axi_monitor::type_id::create("mon", this);
        if(is_active == UVM_ACTIVE) begin
            seqr = axi_sequencer::type_id::create("seqr", this);
            drv = axi_driver::type_id::create("drv", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if(is_active == UVM_ACTIVE)
            drv.seq_item_port.connect(seqr.seq_item_export);

    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation...", UVM_HIGH);
    endfunction  


endclass