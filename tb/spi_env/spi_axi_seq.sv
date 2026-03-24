`ifndef VSEQ_BASE_SV
`define VSEQ_BASE_SV

class base_vseq extends uvm_sequence;
    `uvm_object_utils(base_vseq)
    `uvm_declare_p_sequencer(spi_mcsequencer)

    function new(string name = "base_vseq");
        super.new(name);
    endfunction

    task run_axi_seq(uvm_sequence #(axi_transaction) seq);
        seq.start(p_sequencer.axi_seqr);
    endtask

    task run_transfer_seq(uvm_sequence #(axi_transaction)       axi_seq,
                          uvm_sequence #(spi_slave_transaction) spi_seq);
        fork
            spi_seq.start(p_sequencer.spi_slave_seqr);
            axi_seq.start(p_sequencer.axi_seqr);
        join
    endtask

endclass

class srr_vseq extends base_vseq;

    `uvm_object_utils(srr_vseq);

    function new(string name = "srr_vseq");
        super.new(name);
    endfunction

    task body();
        srr_seq seq;
        seq = srr_seq::type_id::create("seq");
        run_axi_seq(seq);   // no SPI bus activity needed
    endtask
endclass

class sanity_vseq extends base_vseq;

    `uvm_object_utils(sanity_vseq)
    `uvm_declare_p_sequencer(spi_mcsequencer)

    sanity_seq       axi_seq;
    spi_slave_sequence   spi_seq;

    function new(string name = "sanity_vseq");
        super.new(name);
    endfunction

    task body();
        axi_seq = sanity_seq::type_id::create("axi_seq");
        spi_seq = spi_slave_sequence::type_id::create("spi_seq");

        run_transfer_seq(axi_seq, spi_seq);
    endtask

endclass

class hw_reset_registers_vseq extends base_vseq;
    `uvm_object_utils(hw_reset_registers_vseq)

    function new(string name = "hw_reset_registers_vseq");
        super.new(name);
    endfunction

    task body();
        hw_reset_registers_seq seq;
        seq = hw_reset_registers_seq::type_id::create("seq");
        run_axi_seq(seq);   // no SPI bus activity needed
    endtask
endclass

class loop_vseq extends base_vseq;

    `uvm_object_utils(loop_vseq);

    function new(string name = "loop_vseq");
        super.new(name);
    endfunction

    task body();
        loop_seq seq;
        seq = loop_seq::type_id::create("seq");
        run_axi_seq(seq);   
    endtask
endclass

class lsb_vseq extends base_vseq;

    `uvm_object_utils(lsb_vseq);

    lsb_seq       axi_seq;
    spi_slave_sequence   spi_seq;

    function new(string name = "lsb_vseq");
        super.new(name);
    endfunction

    task body();
        axi_seq = lsb_seq::type_id::create("axi_seq");
        spi_seq = spi_slave_sequence::type_id::create("spi_seq");

        run_transfer_seq(axi_seq, spi_seq);
    endtask
endclass

`endif