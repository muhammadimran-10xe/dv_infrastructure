`ifndef AXI_BASE_SEQ_SV
`define AXI_BASE_SEQ_SV

class axi_base_seq extends uvm_sequence #(axi_transaction);
    `uvm_object_utils(axi_base_seq)
    
    function new(string name = "axi_base_seq");
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

endclass


class sanity_seq extends axi_base_seq;

    `uvm_object_utils(sanity_seq)
    `uvm_declare_p_sequencer(axi_sequencer)
    
    function new(string name = "sanity_seq");
        super.new(name);
    endfunction


    task body();
        // axi_transaction axi_tr = axi_transaction::type_id::create("axi_tr");
        `uvm_info(get_type_name(), "Software Reset (SRR=0x0A)", UVM_LOW)
        axi_write(`SPI_SRR, 32'h0000_000A);   // SRR at 0x40
        axi_write(`SPI_DGIER,  32'h8000_0000);   // global interrupt enable
        axi_write(`SPI_IPIER,  32'h0000_0004);   // enable TX_EMPTY interrupt
        `uvm_info(get_type_name(),"Configure CR=0x186 (SPE|MASTER|INHIBIT)", UVM_LOW)
        axi_write(`SPI_CR, 32'h0000_0186);   // CR at 0x60

        axi_write(`SPI_SSR, 32'h0000_0000);
        `uvm_info(get_type_name(), "Load TX FIFO (DTR=0xA)", UVM_LOW)
        axi_write(`SPI_DTR, 32'h0000_00AA);   // DTR at 0x68

        `uvm_info(get_type_name(), "Load TX FIFO (DTR=0xA)", UVM_LOW)
        axi_write(`SPI_DTR, 32'h0000_00FF);   // DTR at 0x68

        axi_write(`SPI_CR, 32'h0000_0086);   // CR at 0x60
        axi_read(`SPI_SR);
        while(p_sequencer.rdata[0] ) begin
            axi_read(`SPI_SR);
        end
        axi_read(`SPI_DRR);
        // axi_read(`SPI_SR);
        // while(p_sequencer.rdata[0] ) begin
        //     axi_read(`SPI_SR);
        // end
        // axi_read(`SPI_DRR);
        `uvm_info(get_type_name(), "=== Transfer complete ===", UVM_LOW)

    endtask
endclass

class hw_reset_registers_seq extends axi_base_seq;
    `uvm_object_utils(hw_reset_registers_seq)

    function new(string name = "hw_reset_registers_seq");
        super.new(name);
    endfunction

    task body();
        // rst_i is asserted by testbench_top at time 0
        // Sequences run after reset drops — registers should be at reset values
        `uvm_info(get_type_name(), "Checking reset values of all 9 registers", UVM_LOW)

        axi_read(`SPI_CR  );
        axi_read(`SPI_SR  );
        axi_read(`SPI_SSR );
        axi_read(`SPI_DGIER);
        axi_read(`SPI_IPISR);
        axi_read(`SPI_IPIER);

        `uvm_info(get_type_name(), "hw_reset_registers done", UVM_LOW)
    endtask
endclass

`endif