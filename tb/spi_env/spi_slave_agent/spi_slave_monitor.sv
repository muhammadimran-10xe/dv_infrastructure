class spi_slave_monitor extends uvm_monitor;

    `uvm_component_utils(spi_slave_monitor)

    virtual spi_axi_intf vif;
    spi_slave_config cfg;
    uvm_analysis_port#(spi_slave_transaction) ap_mon;

    function new(string name = "spi_slave_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_mon = new("ap_mon", this);
        if (!uvm_config_db #(spi_slave_config)::get(this, "", "spi_slave_cfg", cfg))
            `uvm_fatal("[SPI_MON]", "spi_slave_config not found")
        vif = cfg.vif;

    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name, "Running Simulation....", UVM_HIGH)
    endfunction
    int byte_count = 0;
    task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "SPI monitor started", UVM_LOW)
    @(negedge vif.cs_o);
    forever begin

            spi_slave_transaction trans = spi_slave_transaction::type_id::create("trans");
            bit [7:0]mosi = '0;
            bit [7:0]miso = '0;
            int i;
            if(vif.cs_o == 1) begin
                @(negedge vif.cs_o);
            end
            for(i=7; i>=0; i--) begin
                @(posedge vif.clk_o);
                mosi[i] = vif.mosi_o;
                miso[i] = vif.miso_i;
            end
            trans.mosi = mosi;
            trans.miso = miso;
            trans.cs = vif.cs_o;
            byte_count++;
            ap_mon.write(trans);
            `uvm_info(get_type_name(), $sformatf("MOSI = %0h | MISO = %0h", mosi, miso), UVM_LOW)
        end
        

    endtask


endclass