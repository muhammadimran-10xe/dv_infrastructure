`ifndef SPI_SCOREBOARD_SV
`define SPI_SCOREBOARD_SV

`uvm_analysis_imp_decl(_axi)
`uvm_analysis_imp_decl(_spi)

class spi_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp_axi #(axi_transaction,       spi_scoreboard) axi_export;
    uvm_analysis_imp_spi #(spi_slave_transaction, spi_scoreboard) spi_export;

    spi_slave_transaction spi_mosi_q[$];
    spi_slave_transaction spi_miso_q[$];
    axi_transaction       dtr_q[$];
    axi_transaction       drr_q[$];

    int pass_cnt = 0;
    int fail_cnt = 0;


    function new(string name = "spi_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_export = new("axi_export", this);
        spi_export = new("spi_export", this);
    endfunction

    function void write_spi(spi_slave_transaction tr);

    endfunction

    function void write_axi(axi_transaction tr);

    endfunction


    function void report_phase(uvm_phase phase);
        `uvm_info("[SCBD]", $sformatf(
            "\n================================================\n  PASS=%0d  FAIL=%0d\n================================================",
            pass_cnt, fail_cnt), UVM_NONE)
        if (fail_cnt > 0) `uvm_error("[SCBD]", "TEST FAILED")
        else               `uvm_info("[SCBD]",  "TEST PASSED", UVM_NONE)
    endfunction
endclass

`endif