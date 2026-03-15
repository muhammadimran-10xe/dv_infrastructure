class spi_slave_driver extends uvm_driver #(spi_slave_transaction);
    `uvm_component_utils(spi_slave_driver);

    function new(string name = "spi_slave_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual spi_axi_intf vif;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual spi_axi_intf)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "No virtual Interface for AXI_SPI")

    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "SPI driver started", UVM_LOW)
        forever begin
            spi_slave_transaction trans = spi_slave_transaction::type_id::create("trans");
            seq_item_port.get_next_item(trans);
            wait(vif.cs_o == 1'b0);
            drive_miso(trans);
            seq_item_port.item_done();
        end
    endtask


    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name, "Running Simulation....", UVM_HIGH)
    endfunction

    task drive_miso(spi_slave_transaction trans);
        if(vif.cs_o == 1'b0) begin
            for (int i=7; i>=0; i--) begin
                vif.miso_i <= trans.miso[i];
                @(posedge vif.clk_o iff (vif.cs_o == 0));
                // `uvm_info(get_type_name(), $sformatf("MISO [%0d] = [%0b]",i, vif.miso_i), UVM_LOW )
            end
            `uvm_info(get_type_name(), "MISO driven ", UVM_LOW)
        end
    endtask

endclass