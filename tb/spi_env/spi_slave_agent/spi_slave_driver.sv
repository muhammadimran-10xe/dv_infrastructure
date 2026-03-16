class spi_slave_driver extends uvm_driver #(spi_slave_transaction);
    `uvm_component_utils(spi_slave_driver);

    function new(string name = "spi_slave_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual spi_axi_intf vif;
    spi_slave_config cfg;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(spi_slave_config)::get(this, "", "spi_slave_cfg", cfg))
            `uvm_fatal("[SPI_DRV]", "spi_slave_config not found")
        vif = cfg.vif;

    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "SPI driver started", UVM_LOW)
        @(negedge vif.cs_o);
        forever begin
            spi_slave_transaction trans = spi_slave_transaction::type_id::create("trans");
            seq_item_port.get_next_item(trans);
            if(vif.cs_o != 0) begin
                @(negedge vif.cs_o);
            end
            drive_miso(trans);
            seq_item_port.item_done();
        end
    endtask


    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name, "Running Simulation....", UVM_HIGH)
    endfunction

    task drive_miso(spi_slave_transaction trans);
        for (int i=7; i>=0; i--) begin
            vif.miso_i <= trans.miso[i];
            @(posedge vif.clk_o);
        end
        `uvm_info(get_type_name(), "MISO driven ", UVM_LOW)
        
    endtask

endclass