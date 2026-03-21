`ifndef SPI_TEST_LIB_SV
`define SPI_TEST_LIB_SV

class spi_base_test extends uvm_test;
    `uvm_component_utils(spi_base_test)

    function new(string name = "spi_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    spi_env env;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = spi_env::type_id::create("env", this);
        uvm_config_db #(uvm_active_passive_enum)::set(this,"env.axi", "is_active", UVM_ACTIVE );
        uvm_config_db #(uvm_active_passive_enum)::set(this,"env.spi_slave", "is_active", UVM_ACTIVE );
        `uvm_info("BUILD_PHASE", "Build Phase of base_test is running", UVM_LOW)
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

endclass


class sanity_test extends spi_base_test;
    `uvm_component_utils(sanity_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        sanity_vseq vseq;
        phase.raise_objection(this);
        vseq = sanity_vseq::type_id::create("vseq", this);
        vseq.start(env.spi_mcseq);
        #500;
        phase.drop_objection(this);
    endtask
endclass

class hw_reset_registers_test extends spi_base_test;
    `uvm_component_utils(hw_reset_registers_test)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    task run_phase(uvm_phase phase);
        hw_reset_registers_vseq vseq;
        phase.raise_objection(this);
        vseq = hw_reset_registers_vseq::type_id::create("vseq", this);
        vseq.start(env.spi_mcseq);
        #100;
        phase.drop_objection(this);
    endtask
endclass




// class sanity_test extends spi_base_test;

//     `uvm_component_utils(sanity_test)

//     function new(string name = "sanity_test", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//     endfunction

//     task run_phase(uvm_phase phase);
//         spi_axi_seq vseq;
//         phase.raise_objection(this);
//         vseq = spi_axi_seq::type_id::create("vseq", this);
//         vseq.start(env.spi_mcseq);
//         #500;
//         phase.drop_objection(this);

//     endtask

// endclass

`endif