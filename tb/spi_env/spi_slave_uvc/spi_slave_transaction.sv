class spi_slave_transaction extends uvm_sequence_item;

    `uvm_object_utils_begin(spi_slave_transaction)
    `uvm_field_int(mosi, UVM_ALL_ON + UVM_HEX)
    `uvm_field_int(miso, UVM_ALL_ON + UVM_HEX)
    `uvm_field_int(cs, UVM_ALL_ON)
    `uvm_object_utils_end

    function new (string name = "spi_slave_transaction");
        super.new(name);
    endfunction

    logic [7:0] mosi;
    rand logic [7:0] miso;
    logic cs;
    logic clk_s;


endclass