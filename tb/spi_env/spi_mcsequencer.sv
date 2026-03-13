`ifndef SPI_MCSEQUENCER_SV
`define SPI_MCSEQUENCER_SV

class spi_mcsequencer extends uvm_sequencer;

    `uvm_component_utils(spi_mcsequencer)

    axi_sequencer axi_seqr;
    spi_slave_sequencer spi_slave_seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass

`endif