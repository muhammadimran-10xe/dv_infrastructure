`ifndef SPI_SCOREBOARD_SV
`define SPI_SCOREBOARD_SV

`uvm_analysis_imp_decl(_mon)
`uvm_analysis_imp_decl(_spi)

class spi_scoreboard #(parameter WIDTH=8, parameter DEPTH=4) extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard)

    uvm_analysis_imp_mon #(axi_transaction,       spi_scoreboard) axi_mon2scb_imp;
    uvm_analysis_imp_spi #(spi_slave_transaction, spi_scoreboard) spi_mon2scb_imp;

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
        axi_mon2scb_imp = new("axi_mon2scb_imp", this);
        spi_mon2scb_imp = new("spi_mon2scb_imp", this);
        ref_model = spi_refrence_model #(WIDTH, DEPTH)::type_id::create("ref_model", this);
        axi_trans = axi_transaction::type_id::create("axi_trans");
    endfunction

    function void write_mon(axi_transaction tr);
        `uvm_info("[SCBD]",
            $sformatf("AXI %-5s addr=0x%02h wdata=0x%08h rdata=0x%08h",
                       tr.trans_type.name(), tr.addr, tr.wdata, tr.rdata),
            UVM_MEDIUM)

        if (tr.trans_type == axi_transaction::WRITE)
            ref_model.update_model(tr);

        if (tr.trans_type == axi_transaction::WRITE &&
            tr.addr[7:0] == `SPI_DTR)
            dtr_q.push_back(tr);

        check_response(tr);

        if (tr.trans_type == axi_transaction::READ && tr.addr[7:0] == `SPI_DRR) begin
            drr_q.push_back(tr);
            if (ref_model.rm.rx_fifo_count > 0)
                ref_model.rm.rx_fifo_count--;
            if (ref_model.rm.loop && dtr_q.size() > 0)
                loop_check(tr);
            miso_check();
        end

        if (tr.trans_type == axi_transaction::READ && tr.addr[7:0] != `SPI_DRR) begin
            if (tr.addr[7:0] == `SPI_SR && ref_model.rm.tx_fifo_count > 0)
                axi_trans = tr;   
            else
                check_register(tr);
        end

    endfunction
    function void loop_check(axi_transaction tr);
        axi_transaction dtr_tr = dtr_q.pop_front();
        if (tr.rdata[`SPI_DRR_DATA_R] === dtr_tr.wdata[`SPI_DTR_DATA_R]) begin
            pass_cnt++;
            `uvm_info("[SCBD]",
                $sformatf("PASS [LOOP] DTR=0x%02h == DRR=0x%02h",
                    dtr_tr.wdata[`SPI_DTR_DATA_R],
                    tr.rdata[`SPI_DRR_DATA_R]), UVM_LOW)
        end else begin
            fail_cnt++;
            `uvm_error("[SCBD]",
                $sformatf("FAIL [LOOP] DTR=0x%02h != DRR=0x%02h",
                    dtr_tr.wdata[`SPI_DTR_DATA_R],
                    tr.rdata[`SPI_DRR_DATA_R]))
        end
    endfunction

    function void check_response(axi_transaction tr);
        if (tr.trans_type == axi_transaction::WRITE) begin
            if (tr.wresp === 2'b00) begin
                pass_cnt++;
                `uvm_info("[SCBD]",
                    $sformatf("PASS [BRESP] addr=0x%02h OKAY", tr.addr), UVM_HIGH)
            end else begin
                fail_cnt++;
                `uvm_error("[SCBD]",
                    $sformatf("FAIL [BRESP] addr=0x%02h got=0b%02b exp=OKAY",
                               tr.addr, tr.wresp))
            end
        end else begin
            if (tr.rresp === 2'b00) begin
                pass_cnt++;
                `uvm_info("[SCBD]",
                    $sformatf("PASS [RRESP] addr=0x%02h OKAY", tr.addr), UVM_HIGH)
            end else begin
                fail_cnt++;
                `uvm_error("[SCBD]",
                    $sformatf("FAIL [RRESP] addr=0x%02h got=0b%02b exp=OKAY",
                               tr.addr, tr.rresp))
            end
        end
    endfunction

    function void check_register(axi_transaction tr);
        logic [31:0] expected;

        expected = ref_model.rdata_out(tr.addr);

        if (tr.rdata[31:0] === expected) begin
            pass_cnt++;
            `uvm_info("[SCBD]",
                $sformatf("PASS [REG] addr=0x%02h  got=0x%08h  exp=0x%08h",
                           tr.addr, tr.rdata[31:0], expected), UVM_LOW)
        end 
        else begin
            fail_cnt++;
            `uvm_error("[SCBD]",
                $sformatf("FAIL [REG] addr=0x%02h  got=0x%08h  exp=0x%08h",
                           tr.addr, tr.rdata[31:0], expected))
        end
    endfunction

    function void write_spi(spi_slave_transaction tr);
        `uvm_info("[SCBD]",
            $sformatf("SPI  MOSI=0x%02h  MISO=0x%02h", tr.mosi, tr.miso),
            UVM_MEDIUM)
        spi_q.push_back(tr);
        if (ref_model.rm.tx_fifo_count > 0)
            ref_model.rm.tx_fifo_count--;
        if (ref_model.rm.rx_fifo_count < DEPTH)
            ref_model.rm.rx_fifo_count++;
        if (axi_trans != null && axi_trans.addr[7:0] == `SPI_SR) begin
            check_register(axi_trans);
            axi_trans = null;   
        end
        mosi_check();
        miso_check();
    endfunction

    function void mosi_check();
        if (spi_q.size() > 0 && dtr_q.size() > 0) begin
            spi_slave_transaction spi_tr = spi_q.pop_front();
            axi_transaction       dtr_tr = dtr_q.pop_front();
            if (dtr_tr.wdata[`SPI_DTR_DATA_R] == spi_tr.mosi) begin
                pass_cnt++;
                `uvm_info("[SCBD]",
                    $sformatf("PASS [MOSI] DTR=0x%02h == MOSI=0x%02h",
                               dtr_tr.wdata[`SPI_DTR_DATA_R], spi_tr.mosi),
                    UVM_LOW)
            end 
            else begin
                fail_cnt++;
                `uvm_error("[SCBD]",
                    $sformatf("FAIL [MOSI] DTR=0x%02h != MOSI=0x%02h",
                               dtr_tr.wdata[`SPI_DTR_DATA_R], spi_tr.mosi))
            end
        end
    endfunction

    function void miso_check();
        if (spi_q.size() > 0 && drr_q.size() > 0) begin
            spi_slave_transaction spi_tr = spi_q.pop_front();
            axi_transaction       drr_tr = drr_q.pop_front();
            if (drr_tr.rdata[`SPI_DRR_DATA_R] === spi_tr.miso) begin
                pass_cnt++;
                `uvm_info("[SCBD]",
                    $sformatf("PASS [MISO] DRR=0x%02h == MISO=0x%02h",
                               drr_tr.rdata[`SPI_DRR_DATA_R], spi_tr.miso),
                    UVM_LOW)
            end else begin
                fail_cnt++;
                `uvm_error("[SCBD]",
                    $sformatf("FAIL [MISO] DRR=0x%02h != MISO=0x%02h",
                               drr_tr.rdata[`SPI_DRR_DATA_R], spi_tr.miso))
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("[SCBD]", $sformatf(
            "\n================================================\n  PASS=%0d  FAIL=%0d\n================================================",
            pass_cnt, fail_cnt), UVM_NONE)
        if (fail_cnt > 0) 
            `uvm_error("[SCBD]", "TEST FAILED")
        else               
            `uvm_info("[SCBD]",  "TEST PASSED", UVM_NONE)
    endfunction
endclass

`endif