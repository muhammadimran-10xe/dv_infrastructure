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

    axi_transaction axi_trans;
    bit [WIDTH-1:0] dtr_q[DEPTH];
    bit [WIDTH-1:0] drr_q[DEPTH];
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
    endfunction

    typedef struct {
        logic loop;             
        logic spe;              
        logic master;           
        logic cpol;             
        logic cpha;             
        logic manual_ss;        
        logic trans_inhibit;    
        logic lsb_first;        
        logic gie;              
        logic ipier_tx_empty;   
        logic ssr_value;    
        int unsigned tx_fifo_count;
        int unsigned rx_fifo_count;    
    } reg_model_t;

    reg_model_t rm;

    function void reset_model();
        rm.loop = `SPI_CR_LOOP_DEFAULT;
        rm.spe = `SPI_CR_SPE_DEFAULT;
        rm.master = `SPI_CR_MASTER_DEFAULT;
        rm.cpol = `SPI_CR_CPOL_DEFAULT;
        rm.cpha = `SPI_CR_CPHA_DEFAULT;
        rm.manual_ss = `SPI_CR_MANUAL_SS_DEFAULT;
        rm.trans_inhibit = `SPI_CR_TRANS_INHIBIT_DEFAULT;
        rm.lsb_first = `SPI_CR_LSB_FIRST_DEFAULT;
        rm.gie = `SPI_DGIER_GIE_DEFAULT;
        rm.ipier_tx_empty= `SPI_IPIER_TX_EMPTY_DEFAULT;
        rm.ssr_value     = `SPI_SSR_VALUE_DEFAULT;
        rm.tx_fifo_count = 0;
        rm.rx_fifo_count = 0;
    endfunction

    function void update_model(axi_transaction tr);
        case(tr.addr[7:0])
            `SPI_DGIER:
                rm.gie = tr.wdata[`SPI_DGIER_GIE_R];
            `SPI_IPISR: ;// try to write will clear this
            `SPI_IPIER:
                rm.ipier_tx_empty = tr.wdata[`SPI_IPIER_TX_EMPTY_R];
            `SPI_SSR: begin
                if(tr.wdata == 32'hA)
                    reset_model();
                else
                    `uvm_error("[SCB]", "Can not write to SSR other than 0xA");
            end
            `SPI_CR: begin
                rm.loop = tr.wdata[`SPI_CR_LOOP_R];
                rm.spe = tr.wdata[`SPI_CR_SPE_R];
                rm.master = tr.wdata[`SPI_CR_MASTER_R];
                rm.cpol = tr.wdata[`SPI_CR_CPOL_R];
                rm.cpha = tr.wdata[`SPI_CR_CPHA_R];
                rm.manual_ss = tr.wdata[`SPI_CR_MANUAL_SS_R];
                rm.trans_inhibit = tr.wdata[`SPI_CR_TRANS_INHIBIT_R];
                rm.lsb_first = tr.wdata[`SPI_CR_LSB_FIRST_R];
                if(tr.wdata[`SPI_CR_TXFIFO_RST_R])
                    rm.tx_fifo_count = 0;
                if(tr.wdata[`SPI_CR_RXFIFO_RST_R])
                    rm.rx_fifo_count = 0;
            end
            `SPI_DTR: begin
                if(rm.tx_fifo_count < DEPTH) begin
                    rm.tx_fifo_count++;
                    // dtr_q.push_back(tr.wdata); 
                end
            end
            `SPI_SSR:
                rm.ssr_value = tr.wdata[`SPI_SSR_VALUE_R];
        endcase
    endfunction

    function logic [31:0] rdata_out(logic [31:0] addr);

    endfunction

    function void write_spi(spi_slave_transaction tr);

    endfunction

    function void write_drv(axi_transaction tr);

    endfunction

    function void write_mon(axi_transaction tr);

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