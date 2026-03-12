class axi_base_test extends uvm_test;
    `uvm_component_utils(axi_base_test)

    function new(string name = "axi_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    axi_environment env;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // uvm_config_int::set(this, "*", "recording_detail", 1);
        env = axi_environment::type_id::create("env", this);
        uvm_config_db #(uvm_active_passive_enum)::set(this,"env.agent", "is_active", UVM_ACTIVE );
        `uvm_info("BUILD_PHASE", "Build Phase of base_test is running", UVM_LOW)
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        axi_simple_seq seq = axi_simple_seq::type_id::create("seq", this);
        phase.raise_objection(this);
        seq.start(env.agent.seqr);
        #1000;
        phase.drop_objection(this);

    endtask

endclass