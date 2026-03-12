import uvm_pkg::*;
`include "uvm_macros.svh"   
// import axi_package::*;
// `include "test.sv"

module testbench_top;

logic clk;
logic rst;
initial clk = 0;
always #5 clk = ~clk;

spi_axi_intf intf(.clk_i(clk), .rst_i(rst));

spi_lite dut(
.clk_i(clk), .rst_i(rst),
.cfg_awvalid_i(intf.awvalid_i), .cfg_awaddr_i(intf.awaddr_i),
.cfg_wvalid_i(intf.wvalid_i),   .cfg_wdata_i(intf.wdata_i),
.cfg_wstrb_i(intf.wstrb_i),     .cfg_bready_i(intf.bready_i),
.cfg_arvalid_i(intf.arvalid_i), .cfg_araddr_i(intf.araddr_i),
.cfg_rready_i(intf.rready_i),   .spi_miso_i(intf.miso_i),
.cfg_awready_o(intf.awready_o), .cfg_wready_o(intf.wready_o),
.cfg_bvalid_o(intf.bvalid_o),   .cfg_bresp_o(intf.bresp_o),
.cfg_arready_o(intf.arready_o), .cfg_rvalid_o(intf.rvalid_o),
.cfg_rdata_o(intf.rdata_o),     .cfg_rresp_o(intf.rresp_o),
.spi_clk_o(intf.clk_o),      .spi_mosi_o(intf.mosi_o),
.spi_cs_o(intf.cs_o), .intr_o()
);

initial begin
    rst = 1; 
    repeat (10) @(posedge clk);
    rst = 0;
end

initial begin
$dumpfile("wave.vcd");
$dumpvars(0, testbench_top);         
end

initial begin
    uvm_config_db #(virtual spi_axi_intf)::set(null, "*", "vif", intf);
    run_test("axi_base_test");   
end
initial begin
    #2_000_000;
    `uvm_fatal("TB_TOP", "SIMULATION TIMEOUT – check for hung sequence")
end
endmodule: testbench_top