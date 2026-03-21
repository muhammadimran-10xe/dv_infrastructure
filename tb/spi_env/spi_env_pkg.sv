package spi_env_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Import the DPI functions
    import dpi_pkg::*;

    // Include the actual class files (remove them from the Makefile list)
    `include "spi_reference_model.sv"
    `include "scoreboard.sv"
    `include "spi_env.sv"
endpackage