class axi_agent extends uvm_agent;
    `uvm_component_utils(axi_agent);

    function new(string name = "axi_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    axi_config    cfg;
    axi_sequencer seqr;
    axi_driver drv;
    axi_monitor mon;
    // uvm_analysis_port#(axi_transaction) ap_drv;
    uvm_analysis_port#(axi_transaction) ap_mon;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // ap_drv = new("ap_drv", this);
        ap_mon = new("ap_mon", this);
        if (!uvm_config_db #(axi_config)::get(this, "", "axi_cfg", cfg))
            `uvm_fatal("[AXI_AGT]", "axi_config not found")

        uvm_config_db #(axi_config)::set(this, "drv", "axi_cfg", cfg);
        uvm_config_db #(axi_config)::set(this, "mon", "axi_cfg", cfg);
        mon = axi_monitor::type_id::create("mon", this);
        if (cfg.is_active == UVM_ACTIVE) begin
            seqr = axi_sequencer::type_id::create("seqr", this);
            drv  = axi_driver::type_id::create("drv",  this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if(cfg.is_active == UVM_ACTIVE)
            drv.seq_item_port.connect(seqr.seq_item_export);
            // drv.ap_drv.connect(ap_drv);
            mon.ap_mon.connect(ap_mon);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation...", UVM_HIGH);
    endfunction  


endclass