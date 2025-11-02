module ocp_slave(
    input  wire        rst,
    input  wire        clk,
		 
    input  wire [2:0]  scsu_m_ocp_mcmd,      // ocp master if'
    input  wire [1:0]  scsu_m_ocp_mbyten,    // ocp master if' 
    input  wire [13:1] scsu_m_ocp_maddr,     // ocp master if' 
    input  wire [15:0] scsu_m_ocp_mdata,     // ocp master if' 
    output  reg [15:0] ocp_scsu_m_sdata,     // ocp master if' 
    output  reg [1:0]  ocp_scsu_m_sresp,     // ocp master if' 
    output  reg        ocp_scsu_m_scmdaccept // ocp master if' 
		 );
   integer 	       i,s;
   reg [15:0] 	       slave_ram [0:4095];
   
   //////////////////////////////////////////////////////////////
  
   //////////////////////////////////////////////////////////////
  // ocp slave with some ram behind
   
   always @(posedge clk)
     if (rst)
       begin
	  ocp_scsu_m_sdata <= #1 0;
	  ocp_scsu_m_sresp <= #1 0;
	  ocp_scsu_m_scmdaccept <= #1 0;
       end
     else
       if (scsu_m_ocp_mcmd == 3'b010 && ocp_scsu_m_scmdaccept == 0)
	 begin
	    // read
	    if ($dist_uniform(s,0,3)> 1)
	      begin
		 ocp_scsu_m_scmdaccept <= #1 1;
		 //$display("read");
		 
		 ocp_scsu_m_sresp <= #1 2'b01;
		 if (scsu_m_ocp_mbyten == 2'b11)
		   ocp_scsu_m_sdata[15:0] <= #1 slave_ram[scsu_m_ocp_maddr[12:1]];
		 else if (scsu_m_ocp_mbyten == 2'b01)
		   begin
		      ocp_scsu_m_sdata[7:0]  <= #1 slave_ram[scsu_m_ocp_maddr[12:1]];
		      ocp_scsu_m_sdata[15:8] <= #1 slave_ram[scsu_m_ocp_maddr[12:1]];
		   end
		 else if (scsu_m_ocp_mbyten == 2'b10)
		   begin
		      ocp_scsu_m_sdata[7:0]  <= #1 slave_ram[scsu_m_ocp_maddr[12:1]] >> 8;
		      ocp_scsu_m_sdata[15:8] <= #1 slave_ram[scsu_m_ocp_maddr[12:1]] >> 8;
		   end
	      end // if ($dist_uniform(s,0,3)> 1)
	 end // if (scsu_m_ocp_mcmd == 3'b010 && ocp_scsu_m_scmdaccept == 0)
   
       else if (scsu_m_ocp_mcmd == 3'b001 && ocp_scsu_m_scmdaccept == 0)
	 begin
	    // write
	    if ($dist_uniform(s,0,3)> 1)
	      begin
		 //$display("write");
		 ocp_scsu_m_scmdaccept <= #1 1;
		 if (scsu_m_ocp_mbyten == 2'b11)
		   slave_ram[scsu_m_ocp_maddr[12:1]] <= #1 scsu_m_ocp_mdata;
		 else if (scsu_m_ocp_mbyten == 2'b01)
		   slave_ram[scsu_m_ocp_maddr[12:1]] <= #1 {slave_ram[scsu_m_ocp_maddr[12:1]], scsu_m_ocp_mdata[7:0]};
		 else if (scsu_m_ocp_mbyten == 2'b10)
		   slave_ram[scsu_m_ocp_maddr[12:1]] <= #1 {slave_ram[scsu_m_ocp_maddr[12:1]]>>8} | {scsu_m_ocp_mdata[15:8],8'h0};
	      end // if ($dist_uniform(s,0,3)> 1)
	 end // if (scsu_m_ocp_mcmd == 3'b001 && ocp_scsu_m_scmdaccept == 0)
       else if (ocp_scsu_m_scmdaccept == 1)
	 begin
	    ocp_scsu_m_scmdaccept <= #1 0;
	    ocp_scsu_m_sresp <= #1 2'b00;
	 end
   
endmodule // ocp_slave
