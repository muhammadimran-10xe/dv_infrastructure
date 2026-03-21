`ifndef SPI_SCOREBOARD_SV
`define SPI_SCOREBOARD_SV

// `uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_spi)

class spi_scoreboard extends uvm_scoreboard#(axi_transaction);

    `uvm_component_utils(spi_scoreboard)

    spi_reference_model         ref_model;
    // uvm_analysis_imp_drv #(axi_transaction,       spi_scoreboard) axi_drv2scb_imp;
    uvm_analysis_imp_mon #(axi_transaction,       spi_scoreboard) axi_mon2scb_imp;

    uvm_analysis_imp_spi #(spi_slave_transaction, spi_scoreboard) spi_mon2scb_imp;

    // axi_transaction axi_trans;
    // spi_slave_transaction spi_trans;
    int pass_cnt = 0;
    int fail_cnt = 0;


    function new(string name = "spi_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // axi_drv2scb_imp = new("axi_drv2scb_imp", this);
        axi_mon2scb_imp = new("axi_mon2scb_imp", this);
        spi_mon2scb_imp = new("spi_mon2scb_imp", this);
        ref_model = spi_reference_model::type_id::create("ref_model", this);
    endfunction

    // Logic: AXI Monitor sends a write -> Tell Ref Model to predict
    function void write_mon(axi_transaction tr);
        if (tr.trans_type == axi_transaction::WRITE) begin
            m_ref_model.predict_axi_write(tr);
        end
    endfunction

    // Logic: SPI Monitor sends data -> Get prediction from Ref Model & Compare
    function void write_spi(spi_slave_transaction tr);
        byte expected = m_ref_model.get_expected_mosi();
        if (tr.mosi_data !== expected) 
            `uvm_error("FAIL", $sformatf("Exp: %h Act: %h", expected, tr.mosi_data))
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