`ifdef SCS_OCP_IF

task bus_init;
   ocp_init;
endtask // bus_init

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

task bus_write;
   input [15:0] addr;
   input [15:0] data;
   
   ocp_write(addr, data);
   
endtask // bus_write
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

task bus_read;
   input [15:0] addr;
   input [1:0] be;
   
   ocp_read(addr,be);
   
endtask // ahb_read

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
task ocp_write;
   input [15:0] addr;
   input [15:0] data;
   reg [7:0] i;
   begin
      ocp_scsu_s_mcmd <= #1 3'b001;
      ocp_scsu_s_maddr <= #1 addr;
      ocp_scsu_s_mdata <= #1 data;
      ocp_scsu_s_mbyten <= #1 2'b11;
      @(posedge clk);
      
      
      while(scsu_s_ocp_scmdaccept != 1)
	@(posedge clk);
      
      // @(posedge clk);
      ocp_scsu_s_mcmd <= #1 3'b000;
      
      
   end
endtask // ocp_write

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
task ocp_init;
  begin 
     ocp_scsu_s_mcmd                 = 0;
     ocp_scsu_s_mbyten               = 0;
     ocp_scsu_s_maddr                = 0;
     ocp_scsu_s_mdata                = 0;
  end
endtask // ocp_init
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
task ocp_read;
   input [15:0] addr;
   input [1:0] be;
   reg [7:0] i;
   begin
      ocp_scsu_s_mcmd <= #1 3'b010;
      ocp_scsu_s_maddr <= #1 addr;
      ocp_scsu_s_mbyten <= #1 be;
      @(posedge clk);
      
      
      while(scsu_s_ocp_scmdaccept != 1)
	@(posedge clk);
      
      // @(posedge clk);
      ocp_scsu_s_mcmd <= #1 3'b000;
   end
endtask // ocp_read

`endif //  `ifdef SCS_OCP_IF
