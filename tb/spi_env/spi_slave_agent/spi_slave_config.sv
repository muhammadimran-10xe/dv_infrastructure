`ifndef SPI_SLAVE_CONFIG_SV
`define SPI_SLAVE_CONFIG_SV

class spi_slave_config extends uvm_object;
    `uvm_object_utils_begin(spi_slave_config)
        `uvm_field_int (data_width,   UVM_ALL_ON)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_object_utils_end

    int unsigned data_width = 8;    // bits per transfer 

    uvm_active_passive_enum is_active    = UVM_ACTIVE;
    virtual spi_axi_intf vif;
    function new(string name = "spi_slave_config");
        super.new(name);
    endfunction

endclass
`endif