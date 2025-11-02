
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
`ifdef SCS_AHB_IF

task bus_write;
   input [15:0] addr;
   input [15:0] data;
   
   ahb_write(addr, data);
   
endtask // bus_write

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

task bus_read;
   input [15:0] addr;
   input [1:0] be;
   
   ahb_read(addr,be);
   
endtask // ahb_read

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

task bus_init;
   ahb_init;
endtask // bus_init


//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
task ahb_write;
   input [15:0] addr;
   input [15:0] data;
   reg [7:0] i;
   begin
      wait (scsu_s_ahb_shready);
      
      ahb_scsu_s_mhtrans <= #1 2'b10; // nonseq
      ahb_scsu_s_mhwrite <= #1 1'b1;
      ahb_scsu_s_mhaddr  <= #1 addr;
      ahb_scsu_s_mhsize  <= #1 2'b01; // 2 bytes
      // 00 - byte
      @(posedge clk);
      
      ahb_scsu_s_mhwdata <= #1 data;
      
      while(scsu_s_ahb_shready != 1)
	@(posedge clk);
      
      ahb_scsu_s_mhtrans <= #1 2'b00; // idle
      #2;
      
   end
endtask // ahb_write

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

task ahb_init;
   begin
      ahb_scsu_s_mhtrans <= 0;
      ahb_scsu_s_mhwrite <= 0;
      ahb_scsu_s_mhaddr  <= 0;
      ahb_scsu_s_mhsize  <= 0; 
      ahb_scsu_s_mhwdata <= 0;
   end
endtask // ahb_init


//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
task ahb_read;
   input [15:0] addr;
   input [1:0] be;
   reg [7:0] i;
   begin
      wait (scsu_s_ahb_shready);
      ahb_scsu_s_mhtrans <= #1 2'b10; // nonseq
      ahb_scsu_s_mhwrite <= #1 1'b0;
      ahb_scsu_s_mhaddr  <= #1 addr;
      if (be == 2'b11)
	ahb_scsu_s_mhsize  <= #1 2'b01; // 01 - halfword
      else
	ahb_scsu_s_mhsize  <= #1 2'b00; // 00 - byte
      
      @(posedge clk);
      
      while(scsu_s_ahb_shready != 1)
	@(posedge clk);
      
      ahb_scsu_s_mhtrans <= #1 2'b00; // idle
      #2;
      
   end
endtask // ahb_write

`endif

