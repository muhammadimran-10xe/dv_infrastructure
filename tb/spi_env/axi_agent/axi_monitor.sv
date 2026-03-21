class axi_monitor extends uvm_monitor;

    `uvm_component_utils(axi_monitor)

    virtual spi_axi_intf vif;
    axi_config   cfg;
    uvm_analysis_port#(axi_transaction) ap_mon;

    function new(string name = "axi_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_mon = new("ap_mon", this);
        if (!uvm_config_db #(axi_config)::get(this, "", "axi_cfg", cfg))
            `uvm_fatal("[AXI_MON]", "axi_config not found")
        vif = cfg.vif;

    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name, "Running Simulation....", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Monitor Run Phase.....", UVM_LOW)
        fork
            monitor_writes();
            monitor_reads();
        join ///

    endtask

    task monitor_writes();
        axi_transaction trans;
        @(posedge vif.clk_i);
        wait (vif.rst_i === 1'b0);
        forever begin
            trans  = axi_transaction::type_id::create("trans");
            trans.trans_type = axi_transaction::WRITE;
            @(negedge vif.clk_i iff (vif.awvalid_i && vif.awready_o));
            trans.addr  = vif.awaddr_i;
            if (vif.wvalid_i && vif.wready_o) begin
                trans.wdata = vif.wdata_i;
                trans.wstrb = vif.wstrb_i;
            end else begin
                @(negedge vif.clk_i iff (vif.wvalid_i && vif.wready_o));
                trans.wdata = vif.wdata_i;
                trans.wstrb = vif.wstrb_i;
            end
            @(negedge vif.clk_i iff (vif.bvalid_o && vif.bready_i));
            trans.wresp = vif.bresp_o;
            ap_mon.write(trans);
            trans.print();
            `uvm_info("[MON]", "MON Write Task", UVM_LOW)
        end
    endtask

    task monitor_reads();
        axi_transaction trans;
        forever begin
            trans  = axi_transaction::type_id::create("trans");
            trans.trans_type = axi_transaction::READ;
            @(negedge vif.clk_i iff (vif.arvalid_i && vif.arready_o));
            trans.addr  = vif.araddr_i;
            @(negedge vif.clk_i iff (vif.rvalid_o && vif.rready_i));
            trans.rdata = vif.rdata_o;
            trans.rresp = vif.rresp_o;
            ap_mon.write(trans);
            trans.print();
            `uvm_info("[MON]", "MON Read Task", UVM_LOW)
        end
    endtask
endclass