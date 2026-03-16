`ifndef SPI_ENV_SV
`define SPI_ENV_SV

class spi_env extends uvm_env;

    `uvm_component_utils(spi_env);

    axi_agent axi;
    spi_slave_agent spi_slave;

    spi_mcsequencer spi_mcseq;

    axi_config        axi_cfg;
    spi_slave_config  spi_slave_cfg;

    function new(string name = "spi_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        virtual spi_axi_intf vif;
        super.build_phase(phase);
        if (!uvm_config_db #(virtual spi_axi_intf)::get(this, "", "vif", vif))
            `uvm_fatal("[SPI_ENV]", "Virtual interface not found")
        axi_cfg            = axi_config::type_id::create("axi_cfg");
        axi_cfg.vif        = vif;
        axi_cfg.addr_width = 32;
        axi_cfg.data_width = 32;
        axi_cfg.is_active  = UVM_ACTIVE;
        uvm_config_db #(axi_config)::set(this, "axi", "axi_cfg", axi_cfg);

        spi_slave_cfg            = spi_slave_config::type_id::create("spi_slave_cfg");
        spi_slave_cfg.vif        = vif;
        spi_slave_cfg.data_width = 8;
        spi_slave_cfg.is_active  = UVM_ACTIVE;
        uvm_config_db #(spi_slave_config)::set(this, "spi_slave", "spi_slave_cfg", spi_slave_cfg);

        axi = axi_agent::type_id::create("axi", this);
        spi_slave = spi_slave_agent::type_id::create("spi_slave", this);

        spi_mcseq = spi_mcsequencer::type_id::create("spi_mcseq", this);

        `uvm_info(get_type_name(), "Build phase of spi_env is executed", UVM_HIGH)

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        spi_mcseq.spi_slave_seqr = spi_slave.seqr;
        spi_mcseq.axi_seqr = axi.seqr;
        axi.mon.ap.connect(axi.seqr.mon2seq_imp);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation...", UVM_HIGH);
    endfunction

endclass

`endif