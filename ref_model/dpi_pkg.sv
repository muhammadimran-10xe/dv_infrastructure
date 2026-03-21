package dpi_pkg;
  import "DPI-C" function void dpi_model_init();
  import "DPI-C" function void dpi_axi_write(int addr, int data);
  import "DPI-C" function int  dpi_axi_read(int addr);
endpackage