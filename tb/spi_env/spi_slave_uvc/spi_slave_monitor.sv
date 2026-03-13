class spi_slave_monitor extends uvm_monitor;

    `uvm_component_utils(spi_slave_monitor)

    virtual spi_axi_intf vif;
    // uvm_analysis_port#(axi_transaction) ap;

    function new(string name = "spi_slave_monitor", uvm_component parent);
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
    `uvm_info(get_type_name(), "SPI monitor started", UVM_LOW)
    forever begin
        int byte_count = 0;
        @(negedge vif.cs_o);
        while(vif.cs_o == 1'b0) begin
            spi_slave_transaction trans = spi_slave_transaction::type_id::create("trans");
            bit [7:0]mosi = '0;
            bit [7:0]miso = '0;
            int i;
            for(i=7; i>=0; i--) begin
                @(posedge vif.clk_o or posedge vif.cs_o);
                if(vif.cs_o == 1'b1) break;
                mosi[i] = vif.mosi_o;
                miso[i] = vif.miso_i;
            end
            trans.mosi = mosi;
            trans.miso = miso;
            trans.cs = vif.cs_o;
            byte_count++;
            `uvm_info(get_type_name(), $sformatf("MOSI = %0h | MISO = %0h", mosi, miso), UVM_LOW)
        end
        
    end

    endtask

endclass