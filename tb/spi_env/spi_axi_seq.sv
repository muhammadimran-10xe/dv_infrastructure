class spi_axi_seq extends uvm_sequence;

    `uvm_object_utils(spi_axi_seq)
    `uvm_declare_p_sequencer(spi_mcsequencer)

    axi_simple_seq axi_seq;
    spi_slave_sequence spi_seq;

    function new(string name = "spi_axi_seq");
        super.new(name);
    endfunction

    task body();
      axi_seq = axi_simple_seq::type_id::create("axi_seq");
      spi_seq = spi_slave_sequence::type_id::create("spi_seq");
        fork
            spi_seq.start(p_sequencer.spi_slave_seqr);
            axi_seq.start(p_sequencer.axi_seqr);
        join
    endtask

endclass