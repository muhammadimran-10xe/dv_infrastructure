class spi_slave_sequence extends uvm_sequence #(spi_slave_transaction);
    `uvm_object_utils(spi_slave_sequence)

    function new(string name = "spi_slave_sequence");
        super.new(name);
    endfunction

    task body();
        spi_slave_transaction trans = spi_slave_transaction::type_id::create("trans");
        `uvm_do_with(trans, {miso == 8'h1b;})
        // `uvm_do_with(trans, {miso == 8'h49;})

    endtask

endclass