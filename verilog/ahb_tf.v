
module ahb_tf;
   
   reg clk;	
   reg rst;
   
   integer 	     cycles;

 
   
   reg [1:0]   ahb_scsu_s_mhtrans;   // ahb slave if'
   reg [1:0]   ahb_scsu_s_mhsize;    // ahb slave if' 
   reg 	       ahb_scsu_s_mhwrite;   // ahb slave if' 
   reg [13:1]  ahb_scsu_s_mhaddr;    // ahb slave if' 
   reg [15:0]  ahb_scsu_s_mhwdata;   // ahb slave if' 
   wire [15:0] scsu_s_ahb_shrdata;   // ahb slave if' 
   wire        scsu_s_ahb_shready;   // ahb slave if' 
   wire [1:0]  scsu_s_ahb_shresp;    // ahb slave if' 
   

   ahb_slave ahb_slave(	
			.clk(clk),
			.rst(rst),
			// scsu as AHB master interface
			.scsu_m_ahb_mhtrans(ahb_scsu_s_mhtrans),   // ahb master if'
			.scsu_m_ahb_mhsize(ahb_scsu_s_mhsize),     // ahb master if' 
			.scsu_m_ahb_mhwrite(ahb_scsu_s_mhwrite),   // ahb master if' 
			.scsu_m_ahb_mhaddr(ahb_scsu_s_mhaddr),     // ahb master if' 
			.scsu_m_ahb_mhwdata(ahb_scsu_s_mhwdata),   // ahb master if' 
			.ahb_scsu_m_shrdata(scsu_s_ahb_shrdata),   // ahb master if' 
			.ahb_scsu_m_shready(scsu_s_ahb_shready),   // ahb master if' 
			.ahb_scsu_m_shresp(scsu_s_ahb_shresp)      // ahb master if' 
			);
   
  
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   
   initial
     begin
	rst = 1;
	clk = 0;

	bus_init;                        // initiating the master stab signals
	
	delay(30);
	
	rst = 0;
	
	/////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////
        // put your task calls here
	#100;
	delay(30);
	
	bus_write(16'h0000, 16'h1234); // 
	delay(1);
	bus_write(16'h0002, 16'ha0a0); // 
	delay(1);
	bus_write(16'h0004, 16'h0a0a); //
	
	bus_read(16'h0000, 2'b11);     // 
	bus_read(16'h0002, 2'b11);     // 
	bus_read(16'h0004, 2'b11);     // 
	bus_read(16'h0006, 2'b11);     // 
	
	delay(20);
	
	bus_read(16'h200c, 2'b11);     // 

	bus_write(16'h3010, 16'habcd); // 
	bus_write(16'h3012, 16'ha00a); //    

	delay(10);
	
     end
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   // clock generation
   always #50 clk <= !clk; 
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   // generic cycle counter
   always @(posedge clk)
     if (rst)
       cycles <= #1 0;
     else
       cycles <= #1 cycles +1;
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   
   // `include "scsu_tasks.v"
   `include "generic_tasks.v"
   `include "ahb_tasks.v"
   
   
endmodule     	 	
