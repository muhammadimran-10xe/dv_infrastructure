`ifndef SPI_ENV_SV
`define SPI_ENV_SV

class spi_env extends uvm_env;

    `uvm_component_utils(spi_env);

    axi_agent axi;
    spi_slave_agent spi_slave;

    spi_mcsequencer spi_mcseq;

    function new(string name = "spi_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi = axi_agent::type_id::create("axi", this);
        spi_slave = spi_slave_agent::type_id::create("spi_slave", this);

        spi_mcseq = spi_mcsequencer::type_id::create("spi_mcseq", this);

        `uvm_info(get_type_name(), "Build phase of spi_env is executed", UVM_HIGH)

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        spi_mcseq.spi_slave_seqr = spi_slave.seqr;
        spi_mcseq.axi_seqr = axi.seqr;

    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation...", UVM_HIGH);
    endfunction

endclass

`endif