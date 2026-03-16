class spi_base_test extends uvm_test;
    `uvm_component_utils(spi_base_test)

    function new(string name = "spi_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    spi_env env;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // uvm_config_int::set(this, "*", "recording_detail", 1);
        env = spi_env::type_id::create("env", this);
        uvm_config_db #(uvm_active_passive_enum)::set(this,"env.axi", "is_active", UVM_ACTIVE );
        uvm_config_db #(uvm_active_passive_enum)::set(this,"env.spi_slave", "is_active", UVM_ACTIVE );
        `uvm_info("BUILD_PHASE", "Build Phase of base_test is running", UVM_LOW)
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        spi_axi_seq vseq;
        phase.raise_objection(this);
        vseq = spi_axi_seq::type_id::create("vseq", this);
        vseq.start(env.spi_mcseq);
        #500;
        phase.drop_objection(this);

    endtask

endclass