
class axi_simple_seq extends uvm_sequence#(axi_transaction);
    `uvm_object_utils(axi_simple_seq)

    function new(string name = "axi_simple_seq");
        super.new(name);
    endfunction

    task body();
        axi_transaction tr;
        `uvm_info(get_type_name(), "Executing axi_simple_seq", UVM_LOW)
        tr = axi_transaction::type_id::create("tr");
        start_item(tr);
        tr.trans_type = axi_transaction::WRITE;
        tr.addr = 32'h68;
        tr.wdata = 32'hAA;
        finish_item(tr);
    endtask

endclass