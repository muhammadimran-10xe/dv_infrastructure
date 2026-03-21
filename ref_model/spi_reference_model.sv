

class spi_reference_model extends uvm_component;
    `uvm_component_utils(spi_reference_model)

    function new(string name = "spi_reference_model", uvm_component parent);
        super.new(name, parent);
    endfunction

    byte mosi_q[$];
    int unsigned spi_regs[32];

    function void predict_axi_write(axi_transaction tr);
        dpi_axi_write(tr.addr, tr.wdata);
        // If write to DTR (0x68), add to MOSI queue
        if (tr.addr == `SPI_DTR) begin
            mosi_q.push_back(tr.wdata[7:0]);
        end
    endfunction

    function byte get_expected_mosi();
        if (mosi_q.size() > 0) return mosi_q.pop_front();
        else `uvm_error("REF_MODEL", "MOSI Queue Empty!")
    endfunction

endclass