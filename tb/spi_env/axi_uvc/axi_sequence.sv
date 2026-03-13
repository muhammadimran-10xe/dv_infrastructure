class axi_simple_seq extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(axi_simple_seq)

    function new(string name = "axi_simple_seq");
        super.new(name);
    endfunction

    task axi_write(input logic [31:0] addr,
                   input logic [31:0] data);
        axi_transaction tr;
        tr = axi_transaction::type_id::create("tr");
        start_item(tr);
        tr.trans_type = axi_transaction::WRITE;
        tr.addr  = addr;
        tr.wdata = data;
        tr.wstrb = 4'd1;
        finish_item(tr);
    endtask

    task axi_read(input logic [31:0] addr);
        axi_transaction tr;
        tr = axi_transaction::type_id::create("tr");
        start_item(tr);
            tr.trans_type = axi_transaction::READ;
            tr.addr  = addr;
        finish_item(tr);
    endtask

    task body();
        `uvm_info(get_type_name(), "Software Reset (SRR=0x0A)", UVM_LOW)
        axi_write(`SPI_SRR, 32'h0000_000A);   // SRR at 0x40

        `uvm_info(get_type_name(),"Configure CR=0x186 (SPE|MASTER|INHIBIT)", UVM_LOW)
        axi_write(`SPI_CR, 32'h0000_0186);   // CR at 0x60

        axi_write(`SPI_SSR, 32'h0000_0000);
        `uvm_info(get_type_name(), "Load TX FIFO (DTR=0xA)", UVM_LOW)
        axi_write(`SPI_DTR, 32'h0000_000A);   // DTR at 0x68

        `uvm_info(get_type_name(), "Load TX FIFO (DTR=0xA)", UVM_LOW)
        axi_write(`SPI_DTR, 32'h0000_0088);   // DTR at 0x68
        axi_write(`SPI_CR, 32'h0000_0086);   // CR at 0x60

        `uvm_info(get_type_name(), "=== Transfer complete ===", UVM_LOW)

    endtask

endclass