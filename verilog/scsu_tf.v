
module scsu_tf;
   // Scs16 signals
   reg clk;	
   reg rst;
   
   reg [(8*50)-1:0]  script_base_name;
   reg [(8*30)-1:0]  test_name;
   reg [(8*100)-1:0] full_file_name;
    
   integer 	     cycles;
   
`ifdef SCS_OCP_IF		    
   // ocp slave inputs 
   reg [2:0]   ocp_scsu_s_mcmd;
   reg [1:0]   ocp_scsu_s_mbyten;
   reg [15:0]  ocp_scsu_s_maddr;
   reg [15:0]  ocp_scsu_s_mdata;
   wire        scsu_s_ocp_scmdaccept;
   wire [15:0] scsu_s_ocp_sdata;
   wire [1:0]  scsu_s_ocp_sresp;

   // connectivity from/to scsu/master ocp_slave stab
   wire [2:0]  scsu_m_ocp_mcmd;   // 
   wire [1:0]  scsu_m_ocp_mbyten; // 
   wire [13:1] scsu_m_ocp_maddr;  // 
   wire [15:0] scsu_m_ocp_mdata;  //
   //  
   wire [15:0]  ocp_scsu_m_sdata; //
   wire [1:0]   ocp_scsu_m_sresp; // 
   wire 	ocp_scsu_m_scmdaccept; //
`endif //  `ifdef SCS_OCP_IF
 
`ifdef SCS_AHB_IF		    
   wire [1:0]  scsu_m_ahb_mhtrans;   // ahb master if'
   wire [1:0]  scsu_m_ahb_mhsize;    // ahb master if' 
   wire        scsu_m_ahb_mhwrite;   // ahb master if' 
   wire [23:0] scsu_m_ahb_mhaddr;    // ahb master if' 
   wire [15:0] scsu_m_ahb_mhwdata;   // ahb master if' 
   wire [15:0] ahb_scsu_m_shrdata;   // ahb master if' 
   wire	       ahb_scsu_m_shready;   // ahb master if' 
   wire [1:0]  ahb_scsu_m_shresp;    // ahb master if' 
   
   reg [1:0]   ahb_scsu_s_mhtrans;   // ahb slave if'
   reg [1:0]   ahb_scsu_s_mhsize;    // ahb slave if' 
   reg 	       ahb_scsu_s_mhwrite;   // ahb slave if' 
   reg [15:0]  ahb_scsu_s_mhaddr;    // ahb slave if' 
   reg [15:0]  ahb_scsu_s_mhwdata;   // ahb slave if' 
   wire [15:0] scsu_s_ahb_shrdata;   // ahb slave if' 
   wire        scsu_s_ahb_shready;   // ahb slave if' 
   wire [1:0]  scsu_s_ahb_shresp;    // ahb slave if' 
`endif //  `ifdef SCS_AHB_IF
   

   wire [15:0] 	 APP_OUT0, APP_OUT1, APP_OUT2, APP_OUT3, APP_OUT4, APP_OUT5, APP_OUT6, APP_OUT7;

   reg [15:0]  ext_source0; // 
   reg [15:0]  ext_source1; //
   reg [15:0]  ext_condition;
   reg 	       ext_interupt;
   
   wire [14:0] pulse;
   wire [15:0] device;

   wire [15:0] scsu_tstout;
   reg [7:0]   tstmux_sel;

   

   `define SCS_CTL  16'h3000
   `define SCS_GPR0 16'h3002
   `define SCS_GPR1 16'h3004
   `define SCS_TST  16'h3006
   `define SCS_MSI  16'h3008
 
   // instantiation
   scsu #(1) scsu_0( 
		     .clk(clk),
		     .rst(rst),

   `ifdef SCS_OCP_IF		    
		     // scsu as OCP slave interface
		     .ocp_scsu_s_mcmd(ocp_scsu_s_mcmd),             // in
		     .ocp_scsu_s_mbyten(ocp_scsu_s_mbyten),         // in
		     .ocp_scsu_s_maddr(ocp_scsu_s_maddr),           // in
		     .ocp_scsu_s_mdata(ocp_scsu_s_mdata),           // in
		     .scsu_s_ocp_scmdaccept(scsu_s_ocp_scmdaccept), // out
		     .scsu_s_ocp_sdata(scsu_s_ocp_sdata),           // out
		     .scsu_s_ocp_sresp(scsu_s_ocp_sresp),           // out
		     
		     // scsu as OCP master interface
		     .scsu_m_ocp_mcmd(scsu_m_ocp_mcmd),             //  
		     .scsu_m_ocp_mbyten(scsu_m_ocp_mbyten),         // 
		     .scsu_m_ocp_maddr(scsu_m_ocp_maddr),           // 
		     .scsu_m_ocp_mdata(scsu_m_ocp_mdata),           // 
		     .ocp_scsu_m_sdata(ocp_scsu_m_sdata),           // 
		     .ocp_scsu_m_sresp(ocp_scsu_m_sresp),           // 
		     .ocp_scsu_m_scmdaccept(ocp_scsu_m_scmdaccept), // 
   `endif

   `ifdef SCS_AHB_IF		    
		     .scsu_m_ahb_mhtrans(scsu_m_ahb_mhtrans),   // ahb master if'
		     .scsu_m_ahb_mhsize(scsu_m_ahb_mhsize),     // ahb master if' 
		     .scsu_m_ahb_mhwrite(scsu_m_ahb_mhwrite),   // ahb master if' 
		     .scsu_m_ahb_mhaddr(scsu_m_ahb_mhaddr),     // ahb master if' 
		     .scsu_m_ahb_mhwdata(scsu_m_ahb_mhwdata),   // ahb master if' 
		     .ahb_scsu_m_shrdata(ahb_scsu_m_shrdata),   // ahb master if' 
		     .ahb_scsu_m_shready(ahb_scsu_m_shready),   // ahb master if' 
		     .ahb_scsu_m_shresp(ahb_scsu_m_shresp),     // ahb master if' 
		     
		     .ahb_scsu_s_mhtrans(ahb_scsu_s_mhtrans),   // ahb slave if'
		     .ahb_scsu_s_mhsize(ahb_scsu_s_mhsize),     // ahb slave if' 
		     .ahb_scsu_s_mhwrite(ahb_scsu_s_mhwrite),   // ahb slave if' 
		     .ahb_scsu_s_mhaddr(ahb_scsu_s_mhaddr),     // ahb slave if' 
		     .ahb_scsu_s_mhwdata(ahb_scsu_s_mhwdata),   // ahb slave if' 
		     .scsu_s_ahb_shrdata(scsu_s_ahb_shrdata),   // ahb slave if' 
		     .scsu_s_ahb_shready(scsu_s_ahb_shready),   // ahb slave if' 
		     .scsu_s_ahb_shresp(scsu_s_ahb_shresp),     // ahb slave if' 
   `endif //  `ifdef SCS_AHB_IF
     
		     
		     .APP_OUT0(APP_OUT0),
		     .APP_OUT1(APP_OUT1),
		     .APP_OUT2(APP_OUT2),
		     .APP_OUT3(APP_OUT3),
		     .APP_OUT4(APP_OUT4),
		     .APP_OUT5(APP_OUT5),
		     .APP_OUT6(APP_OUT6),
		     .APP_OUT7(APP_OUT7),
		     
		     .ext_source0(ext_source0),
		     .ext_source1(ext_source1),
		     .ext_condition(ext_condition),
		     .ext_interupt(ext_interupt),
		     
		     .pulse(pulse),
		     .device(device),

		     .scsu_intr(),
		     .scsu_intr1(),
		     .scsu_intr2(),
		     
		     .scan_mode(1'b0),
		     .scsu_tstout(scsu_tstout),  // out 
		     .tstmux_sel(tstmux_sel)     // in
		     );
   

   `ifdef SCS_OCP_IF		       
   ocp_slave ocp_slave(	
			.clk(clk),
			.rst(rst),
			// scsu as OCP master interface
			.scsu_m_ocp_mcmd(scsu_m_ocp_mcmd),             //  
			.scsu_m_ocp_mbyten(scsu_m_ocp_mbyten),         // 
			.scsu_m_ocp_maddr(scsu_m_ocp_maddr),           // 
			.scsu_m_ocp_mdata(scsu_m_ocp_mdata),           // 
			.ocp_scsu_m_sdata(ocp_scsu_m_sdata),           // 
			.ocp_scsu_m_sresp(ocp_scsu_m_sresp),           // 
			.ocp_scsu_m_scmdaccept(ocp_scsu_m_scmdaccept)  // 
			);
   `endif //  `ifdef SCS_OCP_IF
   
   `ifdef SCS_AHB_IF		    
   ahb_slave ahb_slave(	
			.clk(clk),
			.rst(rst),
			// scsu as AHB master interface
			.scsu_m_ahb_mhtrans(scsu_m_ahb_mhtrans),   // ahb master if'
			.scsu_m_ahb_mhsize(scsu_m_ahb_mhsize),     // ahb master if' 
			.scsu_m_ahb_mhwrite(scsu_m_ahb_mhwrite),   // ahb master if' 
			.scsu_m_ahb_mhaddr(scsu_m_ahb_mhaddr[15:0]),     // ahb master if' 
			.scsu_m_ahb_mhwdata(scsu_m_ahb_mhwdata),   // ahb master if' 
			.ahb_scsu_m_shrdata(ahb_scsu_m_shrdata),   // ahb master if' 
			.ahb_scsu_m_shready(ahb_scsu_m_shready),   // ahb master if' 
			.ahb_scsu_m_shresp(ahb_scsu_m_shresp)      // ahb master if' 
			);
   `endif //  `ifdef SCS_AHB_IF
   
  
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////

   `include "test_flow.v"

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
   
   `include "scsu_tasks.v"
   `include "generic_tasks.v"
   `include "generic_functions.v"

`ifdef SCS_AHB_IF
   `include "ahb_tasks.v"
`endif

`ifdef SCS_OCP_IF
 `include "ocp_tasks.v"
`endif
   
  
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////

   
   
endmodule     	 	
