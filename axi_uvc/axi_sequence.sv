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
        finish_item(tr);
    endtask

    task body();

        `uvm_info(get_type_name(),           
             "=== SPI MOSI Test: configuring registers then sending data ===",UVM_LOW)

        `uvm_info(get_type_name(), "Step 1: Software Reset (SRR=0x0A)", UVM_LOW)
        axi_write(32'h40, 32'h0000_000A);   // SRR at offset 0x40

        // `uvm_info(get_type_name(),
        //     "Step 2: Configure CR=0x186 (SPE|MASTER|MANUAL_SS|INHIBIT)", UVM_LOW)
        // axi_write(32'h60, 32'h0000_0186);   // CR at offset 0x60

        // `uvm_info(get_type_name(),
        //     "Step 3: Assert CS_N (SSR=0x0)", UVM_LOW)
        // axi_write(32'h70, 32'h0000_0000);   // SSR at offset 0x70
 
        // `uvm_info(get_type_name(),
        //     "Step 4: Load TX FIFO (DTR=0xAA)", UVM_LOW)
        // axi_write(32'h68, 32'h0000_00AA);   // DTR at offset 0x68
 
        // `uvm_info(get_type_name(),
        //     "Step 5: START transfer (CR=0x086, clears TRANS_INHIBIT)", UVM_LOW)
        // axi_write(32'h60, 32'h0000_0086);   // CR at offset 0x60

        // `uvm_info(get_type_name(),
        //     "Step 6: Polling SR[TX_EMPTY] bit[2]...", UVM_LOW)
        // begin
        //     axi_transaction tr;
        //     int timeout = 0;
        //     tr = axi_transaction::type_id::create("sr_poll");
        //     forever begin
        //         start_item(tr);
        //             tr.trans_type = axi_transaction::READ;
        //             tr.addr       = 32'h64;   // SR at offset 0x64
        //         finish_item(tr);

        //         if (tr.rdata[2] == 1'b1) begin
        //             `uvm_info(get_type_name(),
        //                 $sformatf("SR=0x%08h  TX_EMPTY=1  transfer done", tr.rdata),
        //                 UVM_LOW)
        //             break;
        //         end

        //         timeout++;
        //         if (timeout > 5000)
        //             `uvm_fatal(get_type_name(),
        //                 "TIMEOUT waiting for TX_EMPTY – check CR/DTR sequence")
        //     end
        // end

        // `uvm_info(get_type_name(),
        //     "Step 7: Deassert CS_N (SSR=0x1)", UVM_LOW)
        // axi_write(32'h70, 32'h0000_0001);   // SSR at offset 0x70

        // axi_write(32'h60, 32'h0000_0186);   // CR back to INHIBIT=1

        // `uvm_info(get_type_name(), "=== Transfer complete ===", UVM_LOW)

    endtask

endclass