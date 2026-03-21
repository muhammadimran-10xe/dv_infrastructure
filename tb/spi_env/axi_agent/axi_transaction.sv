`ifndef AXI_TRANSACTION_SV
`define AXI_TRANSACTION_SV

class axi_transaction #(int ADDR_WIDTH=32, int DATA_WIDTH=32) extends uvm_sequence_item;
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
    rand logic [ADDR_WIDTH-1:0] addr;
    rand logic [DATA_WIDTH-1:0] wdata;
    rand logic [(DATA_WIDTH/8)-1:0] wstrb;
    logic [DATA_WIDTH:0] rdata;
    logic [1:0] rresp;
    logic [1:0] wresp;
    // logic awvalid;

    constraint valid_addr {
        addr inside {32'h1C, 32'h20, 32'h28, 32'h40,
                 32'h60, 32'h64, 32'h68, 32'h6C, 32'h70};
    }
    constraint first_byte_strb { wstrb == 4'b0001; }

endclass: axi_transaction

`endif