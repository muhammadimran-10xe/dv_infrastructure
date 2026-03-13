package spi_slave_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "spi_slave_transaction.sv"
    `include "spi_slave_sequencer.sv"
    `include "spi_slave_sequence.sv"
    `include "spi_slave_driver.sv"
    `include "spi_slave_monitor.sv"
    `include "spi_slave_agent.sv"
endpackage