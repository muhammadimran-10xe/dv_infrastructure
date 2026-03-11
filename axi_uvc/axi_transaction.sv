class axi_transaction extends uvm_sequence_item;

typedef enum {WRITE, READ} spi_trans_type;

    `uvm_object_utils_begin(axi_transaction)
      `uvm_field_enum(spi_trans_type, trans_type,  UVM_ALL_ON)
      `uvm_field_int (addr, UVM_ALL_ON | UVM_HEX)
      `uvm_field_int (wdata, UVM_ALL_ON | UVM_HEX)
      `uvm_field_int (wstrb, UVM_ALL_ON | UVM_HEX)
      `uvm_field_int (rdata, UVM_ALL_ON | UVM_HEX)
      `uvm_field_int (wresp, UVM_ALL_ON)
      `uvm_field_int (rresp, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name = "axi_transaction");
        super.new(name);
    endfunction

    rand spi_trans_type trans_type;
    rand logic [31:0] addr;
    rand logic [31:0] wdata;
    rand logic [3:0] wstrb;
    logic [31:0] rdata;
    logic [1:0] rresp;
    logic [1:0] wresp;

    constraint valid_addr {
        addr inside {32'h1C, 32'h20, 32'h28, 32'h40,
                 32'h60, 32'h64, 32'h68, 32'h6C, 32'h70};
    }
    constraint first_byte_strb { wstrb == 4'b1; }

    function string convert2string();
      if (trans_type == WRITE)
        return $sformatf("WR addr=0x%08h data=0x%08h strb=%04b resp=%02b",
                          addr, wdata, wstrb, wresp);
      else
        return $sformatf("RD addr=0x%08h rdata=0x%08h resp=%02b",
                          addr, rdata, rresp);
    endfunction

endclass: axi_transaction