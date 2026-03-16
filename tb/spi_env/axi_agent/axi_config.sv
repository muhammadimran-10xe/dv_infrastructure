`ifndef AXI_CONFIG_SV
`define AXI_CONFIG_SV
// =============================================================================
class axi_config extends uvm_object;
    `uvm_object_utils_begin(axi_config)
        `uvm_field_int (addr_width,    UVM_ALL_ON)
        `uvm_field_int (data_width,    UVM_ALL_ON)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_object_utils_end

    // ── bus width parameters ───────────────────────────────────────────
    int unsigned addr_width = 32;   // AXI address bus width
    int unsigned data_width = 32;   // AXI data bus width

    uvm_active_passive_enum is_active   = UVM_ACTIVE;

    virtual spi_axi_intf vif;

    function new(string name = "axi_config");
        super.new(name);
    endfunction

endclass

`endif