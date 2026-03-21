`ifndef SPI_SLAVE_AGENT_SV
`define SPI_SLAVE_AGENT_SV

class spi_slave_agent extends uvm_agent;
    `uvm_component_utils(spi_slave_agent);

    function new(string name = "spi_slave_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    spi_slave_config cfg;
    spi_slave_sequencer seqr;
    spi_slave_driver drv;
    spi_slave_monitor mon;
    uvm_analysis_port#(spi_slave_transaction) ap_mon;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_mon = new("ap_mon", this);
        if (!uvm_config_db #(spi_slave_config)::get(this, "", "spi_slave_cfg", cfg))
            `uvm_fatal("[SPI_AGT]", "spi_slave_config not found")

        uvm_config_db #(spi_slave_config)::set(this, "drv", "spi_slave_cfg", cfg);
        uvm_config_db #(spi_slave_config)::set(this, "mon", "spi_slave_cfg", cfg);
        mon = spi_slave_monitor::type_id::create("mon", this);
        if(cfg.is_active == UVM_ACTIVE) begin
            seqr = spi_slave_sequencer::type_id::create("seqr", this);
            drv = spi_slave_driver::type_id::create("drv", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        mon.ap_mon.connect(ap_mon);
        if(cfg.is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation...", UVM_HIGH);
    endfunction  


endclass

`endif