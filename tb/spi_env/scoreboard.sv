`ifndef SPI_SCOREBOARD_SV
`define SPI_SCOREBOARD_SV

`uvm_analysis_imp_decl(_drv)
`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_spi)

class spi_scoreboard #(parameter WIDTH=8, parameter DEPTH=4) extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp_drv #(axi_transaction,       spi_scoreboard) axi_drv2scb_imp;
    uvm_analysis_imp_mon #(axi_transaction,       spi_scoreboard) axi_mon2scb_imp;
    uvm_analysis_imp_spi #(spi_slave_transaction, spi_scoreboard) spi_mon2scb_imp;

    axi_transaction       stim_q[$]; // stimulus queue
    axi_transaction       dtr_q[$];  // data transmit queue
    axi_transaction       drr_q[$];  // data receive queue
    spi_slave_transaction spi_q[$];  // SPI slave transactions

    spi_refrence_model #(WIDTH, DEPTH) ref_model;
    axi_transaction axi_trans;
    int pass_cnt = 0;
    int fail_cnt = 0;


    function new(string name = "spi_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_drv2scb_imp = new("axi_drv2scb_imp", this);
        axi_mon2scb_imp = new("axi_mon2scb_imp", this);
        spi_mon2scb_imp = new("spi_mon2scb_imp", this);
        ref_model = spi_refrence_model #(WIDTH, DEPTH)::type_id::create("ref_model", this);
    endfunction

    function void write_drv(axi_transaction tr);
        if (tr.trans_type == axi_transaction::WRITE) begin
            ref_model.update_model(tr);
            if (tr.addr[7:0] == `SPI_DTR) begin
                dtr_q.push_back(tr);  
            end
        end
        stim_q.push_back(tr);
    endfunction

    function void write_mon(axi_transaction tr);
        axi_transaction stim;
        if (stim_q.size() == 0) begin
            `uvm_error("[SCBD]","Response received but stim_q empty — check driver ap_drv connection")
            return;
        end
        stim = stim_q.pop_front();
        if (stim.addr !== tr.addr || stim.trans_type !== tr.trans_type) begin
            `uvm_error("[SCBD]",
                $sformatf("STIM/RESP MISMATCH  stim:%s 0x%02h  resp:%s 0x%02h",
                           stim.trans_type.name(), stim.addr,
                           tr.trans_type.name(),   tr.addr))
            return;
        end
        check_axi_protocol   (stim, tr);
        check_register_layer (stim, tr);
        check_spi_functional (stim, tr);
    endfunction

    function void check_axi_protocol(axi_transaction stim, axi_transaction resp);
        if (stim.trans_type == axi_transaction::WRITE) begin
            if (resp.wresp === 2'b00) begin
                pass_cnt++;
                `uvm_info("[SCBD/L1]",
                    $sformatf("PASS [BRESP] addr=0x%02h OKAY", stim.addr), UVM_HIGH)
            end else begin
                fail_cnt++;
                `uvm_error("[SCBD/L1]",
                    $sformatf("FAIL [BRESP] addr=0x%02h got=0b%02b exp=OKAY",
                               stim.addr, resp.wresp))
            end
        end else begin
            if (resp.rresp === 2'b00) begin
                pass_cnt++;
                `uvm_info("[SCBD/L1]",
                    $sformatf("PASS [RRESP] addr=0x%02h OKAY", stim.addr), UVM_HIGH)
            end else begin
                fail_cnt++;
                `uvm_error("[SCBD/L1]",
                    $sformatf("FAIL [RRESP] addr=0x%02h got=0b%02b exp=OKAY",
                               stim.addr, resp.rresp))
            end
        end
    endfunction

    function void check_register_layer(axi_transaction stim, axi_transaction resp);
        logic [31:0] expected;

        // Writes: model already updated in write_drv — nothing to check here
        if (stim.trans_type == axi_transaction::WRITE) return;

        // DRR handled by Layer 3
        if (stim.addr[7:0] == `SPI_DRR) return;

        // Ask reference model for prediction
        expected = ref_model.rdata_out(stim.addr);

        // X means skip this check (ref model signalled not to check)
        if (^expected === 1'bX) return;

        if (resp.rdata[31:0] === expected) begin
            pass_cnt++;
            `uvm_info("[SCBD/L2]",
                $sformatf("PASS [REG] addr=0x%02h  got=0x%08h  exp=0x%08h",
                           stim.addr, resp.rdata[31:0], expected), UVM_LOW)
        end else begin
            fail_cnt++;
            `uvm_error("[SCBD/L2]",
                $sformatf("FAIL [REG] addr=0x%02h  got=0x%08h  exp=0x%08h",
                           stim.addr, resp.rdata[31:0], expected))
        end
    endfunction

    function void check_spi_functional(axi_transaction stim, axi_transaction resp);
        if (stim.trans_type == axi_transaction::READ &&
            stim.addr[7:0]  == `SPI_DRR) begin
            drr_q.push_back(resp);
            ref_model.drr_pop();       // tell model RX FIFO was read
            try_miso_check();
        end
    endfunction

    function void write_spi(spi_slave_transaction tr);
        `uvm_info("[SCBD/L3]",
            $sformatf("SPI  MOSI=0x%02h  MISO=0x%02h", tr.mosi, tr.miso),
            UVM_MEDIUM)
        spi_q.push_back(tr);
        ref_model.spi_transfer();      // model moves byte TX FIFO → RX FIFO
        try_mosi_check();
        try_miso_check();
    endfunction

    function void try_mosi_check();
        while (spi_q.size() > 0 && dtr_q.size() > 0) begin
            spi_slave_transaction spi_tr = spi_q[0];
            axi_transaction       dtr_tr = dtr_q.pop_front();
            if (dtr_tr.wdata[`SPI_DTR_DATA_R] === spi_tr.mosi) begin
                pass_cnt++;
                `uvm_info("[SCBD/L3]",
                    $sformatf("PASS [MOSI] DTR=0x%02h == MOSI=0x%02h",
                               dtr_tr.wdata[`SPI_DTR_DATA_R], spi_tr.mosi),
                    UVM_LOW)
            end else begin
                fail_cnt++;
                `uvm_error("[SCBD/L3]",
                    $sformatf("FAIL [MOSI] DTR=0x%02h != MOSI=0x%02h",
                               dtr_tr.wdata[`SPI_DTR_DATA_R], spi_tr.mosi))
            end
        end
    endfunction

    function void try_miso_check();
        while (spi_q.size() > 0 && drr_q.size() > 0) begin
            spi_slave_transaction spi_tr = spi_q.pop_front();
            axi_transaction       drr_tr = drr_q.pop_front();
            if (drr_tr.rdata[`SPI_DRR_DATA_R] === spi_tr.miso) begin
                pass_cnt++;
                `uvm_info("[SCBD/L3]",
                    $sformatf("PASS [MISO] DRR=0x%02h == MISO=0x%02h",
                               drr_tr.rdata[`SPI_DRR_DATA_R], spi_tr.miso),
                    UVM_LOW)
            end else begin
                fail_cnt++;
                `uvm_error("[SCBD/L3]",
                    $sformatf("FAIL [MISO] DRR=0x%02h != MISO=0x%02h",
                               drr_tr.rdata[`SPI_DRR_DATA_R], spi_tr.miso))
            end
        end
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