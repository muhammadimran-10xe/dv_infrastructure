class axi_environment extends uvm_env;

    `uvm_component_utils(axi_environment)

    function new(string name = "axi_environment", uvm_component parent);
        super.new(name, parent);
    endfunction

    axi_agent agent;
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = axi_agent::type_id::create("agent", this);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Running Simulation...", UVM_HIGH);
    endfunction
    
endclass