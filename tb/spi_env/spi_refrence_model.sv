`ifndef SPI_REFERENCE_MODEL_SV
`define SPI_REFERENCE_MODEL_SV

class spi_refrence_model #(parameter WIDTH=8, parameter DEPTH=4) extends uvm_component;

    `uvm_component_utils(spi_refrence_model)

    function new(string name="spi_refrence_model", uvm_component parent);
        super.new(name, parent);
        reset_model();
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
                end
            end
            `SPI_SSR:
                rm.ssr_value = tr.wdata[`SPI_SSR_VALUE_R];
        endcase
    endfunction

    function logic [31:0] rdata_out(logic [31:0] addr);
        logic [31:0] expected = 32'h0;
        case(addr[7:0])
            `SPI_DGIER:
                expected[`SPI_DGIER_GIE_R] = rm.gie;
            `SPI_IPISR:
                expected[`SPI_IPISR_TX_EMPTY_R] = (rm.tx_fifo_count == 0) ? 1'b1 : 1'b0;
            `SPI_IPIER:
                expected[`SPI_IPIER_TX_EMPTY_R] = rm.ipier_tx_empty;
            `SPI_SRR:
                expected = 32'h0;
            `SPI_CR: begin
                expected[`SPI_CR_LOOP_R]          = rm.loop;
                expected[`SPI_CR_SPE_R]           = rm.spe;
                expected[`SPI_CR_MASTER_R]        = rm.master;
                expected[`SPI_CR_CPOL_R]          = rm.cpol;
                expected[`SPI_CR_CPHA_R]          = rm.cpha;
                expected[`SPI_CR_MANUAL_SS_R]     = rm.manual_ss;
                expected[`SPI_CR_TRANS_INHIBIT_R] = rm.trans_inhibit;
                expected[`SPI_CR_LSB_FIRST_R]     = rm.lsb_first;
            end
            `SPI_SR: begin
                expected[`SPI_SR_RX_EMPTY_R] =
                    (rm.rx_fifo_count == 0)     ? 1'b1 : 1'b0;
                expected[`SPI_SR_RX_FULL_R]  =
                    (rm.rx_fifo_count == DEPTH) ? 1'b1 : 1'b0;
                expected[`SPI_SR_TX_EMPTY_R] =
                    (rm.tx_fifo_count == 0)     ? 1'b1 : 1'b0;
                expected[`SPI_SR_TX_FULL_R]  =
                    (rm.tx_fifo_count == DEPTH) ? 1'b1 : 1'b0;
            end
            `SPI_DTR:
                expected = 32'h0;
            `SPI_DRR:
                expected = 32'hX;
            `SPI_SSR:
                expected[`SPI_SSR_VALUE_R] = rm.ssr_value;
            default:
                expected = 32'h0;
        endcase
        return expected;

    endfunction

    function void spi_transfer();
        if (rm.tx_fifo_count > 0) rm.tx_fifo_count--;
        if (rm.rx_fifo_count < DEPTH) rm.rx_fifo_count++;
        `uvm_info("[REF_MODEL]",
            $sformatf("SPI transfer done — tx=%0d rx=%0d",
                       rm.tx_fifo_count, rm.rx_fifo_count),
            UVM_MEDIUM)
    endfunction

    function void drr_pop();
        if (rm.rx_fifo_count > 0) rm.rx_fifo_count--;
        `uvm_info("[REF_MODEL]",
            $sformatf("DRR read — rx_count=%0d", rm.rx_fifo_count),
            UVM_MEDIUM)
    endfunction

endclass

`endif