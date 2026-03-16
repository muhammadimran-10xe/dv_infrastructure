/*************************************************************************
   > File Name: spi_axi_intf.sv
   > Description: < Encapsulate the signals >
   > Author: Muhammad Imran
   > Modified: Muhammad Imran
   > Mail: muhammad.imran@10xengineers.ai
   ---------------------------------------------------------------
   Copyright   (c)2026 10xEngineers
   ---------------------------------------------------------------
************************************************************************/

`ifndef SPI_AXI_INTF
`define SPI_AXI_INTF

interface spi_axi_intf #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH/8
)(input logic clk_i, rst_i);
    // write address channel
    logic awvalid_i; 
    logic [ADDR_WIDTH-1:0] awaddr_i; 
    logic awready_o; 
    // write data channel
    logic wvalid_i; 
    logic [DATA_WIDTH-1:0]wdata_i; 
    logic [STRB_WIDTH-1:0]wstrb_i; 
    logic wready_o;
    // write response channel
    logic bready_i; 
    logic bvalid_o; 
    logic [1:0]bresp_o; 
    // read address channel
    logic arvalid_i; 
    logic [ADDR_WIDTH-1:0]araddr_i; 
    logic rready_i;
    // read data channel
    logic arready_o; 
    logic rvalid_o; 
    logic [DATA_WIDTH-1:0]rdata_o; 
    logic [1:0]rresp_o;  
    // spi engine 
    logic miso_i; 
    logic clk_o; 
    logic cs_o; 
    logic intr_o; 
    logic mosi_o;

endinterface: spi_axi_intf

`endif