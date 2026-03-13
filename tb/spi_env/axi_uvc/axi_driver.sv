class axi_driver extends uvm_driver #(axi_transaction);
    `uvm_component_utils(axi_driver);

    function new(string name = "axi_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual spi_axi_intf vif;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual spi_axi_intf)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "No virtual Interface for AXI_SPI")

    endfunction

    task run_phase(uvm_phase phase);
        axi_transaction trans;
        reset_all();
        @(posedge vif.clk_i);
        wait (vif.rst_i === 1'b0);
        `uvm_info("[AXI DRV]", "Reset Dropped", UVM_LOW)
        forever begin
            seq_item_port.get_next_item(trans);
            if(trans.trans_type == axi_transaction::WRITE)
                drive_write(trans);
            else
                drive_read(trans);
            seq_item_port.item_done();
            trans.print();
        end
    endtask


    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name, "Running Simulation....", UVM_HIGH)
    endfunction

    task reset_all();
        vif.awvalid_i <= 0; 
        vif.awaddr_i  <= '0;
        vif.wvalid_i  <= 0; 
        vif.wdata_i   <= '0; 
        vif.wstrb_i   <= '0;
        vif.bready_i  <= 0;
        vif.arvalid_i <= 0; 
        vif.araddr_i  <= '0;
        vif.rready_i  <= 0;
    endtask

    task drive_write(axi_transaction trans);
        @(posedge vif.clk_i);
        vif.awvalid_i <= 1;
        vif.awaddr_i  <= trans.addr;
        vif.wvalid_i  <= 1;
        vif.wdata_i   <= trans.wdata;
        vif.wstrb_i <= trans.wstrb;
        @(posedge vif.clk_i iff (vif.awready_o && vif.wready_o));
        vif.awvalid_i <= 0;
        vif.wvalid_i  <= 0;
        vif.bready_i <= 1;
        @(posedge vif.clk_i iff vif.bvalid_o);
        @(posedge vif.clk_i);
        vif.bready_i <= 0;
        `uvm_info("AXI DRV", "Write Transaction Driven", UVM_LOW)
    endtask

    task drive_read(axi_transaction trans);
        @(posedge vif.clk_i);
        vif.arvalid_i <= 1; 
        vif.araddr_i <= trans.addr;
        @(posedge vif.clk_i iff (vif.arvalid_i && vif.arready_o));
        vif.arvalid_i <= 0; 
        vif.araddr_i <= '0;
        vif.rready_i  <= 1;
        @(posedge vif.clk_i iff (vif.rvalid_o && vif.rready_i));
        @(posedge vif.clk_i);
        vif.rready_i <= 0;
        `uvm_info("AXI DRV", "Read Transaction Driven", UVM_LOW)

    endtask

endclass