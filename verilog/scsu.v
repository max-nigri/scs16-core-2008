
module scsu(
	    
    input wire     rst, // reset
    input wire     clk, // clk
	    
`ifdef SCS_OCP_IF		    
    output wire [2:0]  scsu_m_ocp_mcmd,      // ocp master if'
    output wire [1:0]  scsu_m_ocp_mbyten,    // ocp master if' 
    output wire [13:1] scsu_m_ocp_maddr,     // ocp master if' 
    output wire [15:0] scsu_m_ocp_mdata,     // ocp master if' 
    input  wire [15:0] ocp_scsu_m_sdata,     // ocp master if' 
    input  wire [1:0]  ocp_scsu_m_sresp,     // ocp master if' 
    input  wire        ocp_scsu_m_scmdaccept,// ocp master if' 
	    
    input  wire [2:0]  ocp_scsu_s_mcmd,      // ocp slave if'  
    input  wire [1:0]  ocp_scsu_s_mbyten,    // ocp slave if'  
    input  wire [15:0] ocp_scsu_s_maddr,     // ocp slave if'  
    input  wire [15:0] ocp_scsu_s_mdata,     // ocp slave if'  
    output wire [15:0] scsu_s_ocp_sdata,     // ocp slave if'  
    output wire [1:0]  scsu_s_ocp_sresp,     // ocp slave if'  
    output wire        scsu_s_ocp_scmdaccept,// ocp slave if'  
`endif //  `ifdef SCS_OCP_IF
		      

`ifdef SCS_AHB_IF		    
    output wire [1:0]  scsu_m_ahb_mhtrans,   // ahb master if'
    output wire [1:0]  scsu_m_ahb_mhsize,    // ahb master if' 
    output wire        scsu_m_ahb_mhwrite,   // ahb master if' 
    output wire [23:0] scsu_m_ahb_mhaddr,    // ahb master if' 
    output wire [15:0] scsu_m_ahb_mhwdata,   // ahb master if' 
    input  wire [15:0] ahb_scsu_m_shrdata,   // ahb master if' 
    input  wire        ahb_scsu_m_shready,   // ahb master if' 
    input  wire [1:0]  ahb_scsu_m_shresp,    // ahb master if' 

    input  wire [1:0]  ahb_scsu_s_mhtrans,   // ahb slave if'
    input  wire [1:0]  ahb_scsu_s_mhsize,    // ahb slave if' 
    input  wire        ahb_scsu_s_mhwrite,   // ahb slave if' 
    input  wire [15:0] ahb_scsu_s_mhaddr,    // ahb slave if' 
    input  wire [15:0] ahb_scsu_s_mhwdata,   // ahb slave if' 
    output wire [15:0] scsu_s_ahb_shrdata,   // ahb slave if' 
    output wire        scsu_s_ahb_shready,   // ahb slave if' 
    output wire [1:0]  scsu_s_ahb_shresp,    // ahb slave if' 
`endif //  `ifdef SCS_AHB_IF
		      
   
    output wire [15:0] APP_OUT0, APP_OUT1, APP_OUT2, APP_OUT3, APP_OUT4, APP_OUT5, APP_OUT6, APP_OUT7,
	    
    input wire [15:0]  ext_source0,  
    input wire [15:0]  ext_source1,
    input wire [15:0]  ext_condition,  
    input 	       ext_interupt,
	    
	    
    output wire [14:0] pulse,
    output wire [15:0] device,
	    
	    
    output wire        scsu_intr,  // 
    output wire        scsu_intr1, // 
    output wire        scsu_intr2, // 
	    
	    
    output wire [15:0] scsu_tstout, // 
    input wire [7:0]   tstmux_sel,  // 
    input wire 	       scan_mode    // 
	    );
 


   parameter SCS16_VERBOSE = 0;
  
   
   wire [31:0] 	 iram_rd_data; // from imem
   wire [31:0] 	 iram_wr_data; // to imem
   wire [13:0] 	 iram_addr;    // to imem
   wire [1:0] 	 iram_we;      // to imem
   wire 	 iram_cs;      // to imem
   wire 	 scs16_iram_cs;// internal
   
   wire [15:0] 	 dram_rd_data; // from dmem
   wire [15:0] 	 dram_wr_data; // to dmem
   wire [10:0] 	 dram_addr;    // to dmem
   wire [1:0] 	 dram_we;      // to dmem
   wire 	 dram_cs;      // to dmem
   
   wire [15:0] 	 r0;           // 
   wire [15:0] 	 r1;           // 
   wire [15:0] 	 r2;           // 
   wire [15:0] 	 r3;           // 
   wire [15:0] 	 r4;           // 
   wire [15:0] 	 r5;           // 
   wire [15:0] 	 r6;           // 
   wire [15:0] 	 r7;           // 
   
   wire [15:0] 	 scs16_ram_wr_data; // 
   wire [23:0] 	 scs16_ram_addr;    // 
   wire [1:0] 	 scs16_ram_we;      // 
   wire [13:0] 	 scs16_next_pc;     // 
   wire 	 scs16_ram_cs;      // 
   wire 	 scs16_ext_bus_cs;  // 
   wire 	 scs16_ext_bus_done;// 
   wire [15:0] 	 scs16_rd_data;     // 
   
   wire 	 scs16_rst;         // 
   wire 	 hard_break;        // 
   wire 	 interupt;          // 
   wire [15:0] 	 condition;         // 
   wire [15:0] 	 S0;                // 
   wire [15:0] 	 S1;                // 
   
   wire step, continue, bkpt;

   
   
   wire [15:0] 	 scs16_debug_bus;   // from scs16 for debug
   
   
   wire 	 scs16_clk;         // 
   wire 	 mems_clk;          // 
   
   
   dmem #(16,2048,11) dmem( 
			    .clk(mems_clk),
			    .wen(dram_we),
			    .cs(dram_cs),
			    .reset(1'b0),
			    .d(dram_wr_data),
			    .address(dram_addr),
			    .q(dram_rd_data)
			    );    
   
   imem #(32,2048,14) imem( 
			    .clk(mems_clk),
			    .reset(1'b0),			
			    .wen(iram_we),
			    .cs(iram_cs),
			    .address(iram_addr),
			    .q(iram_rd_data),
			    .d(iram_wr_data)
			    );    	
   
   scs16 #(SCS16_VERBOSE) x_scs16(
				  
				  .clk(scs16_clk),                 // from clock gating device
				  .rst(scs16_rst),                 // from wrapper
				  .hard_break(hard_break),         // from wrapper
				  .interupt(interupt),             // from wrapper
				  .condition(condition),           // from wrapper
				  .S0(S0),                         // from wrapper
				  .S1(S1),                         // from wrapper
				  .ram_rd_data(scs16_rd_data),     // from wrapper
				  
				  .ram_wr_data(scs16_ram_wr_data), // to wrapper
				  .ram_addr(scs16_ram_addr),       // to wrapper
				  .ram_we(scs16_ram_we),           // to wrapper
				  .ram_cs(scs16_ram_cs),           // to wrapper
				  .scs16_ext_bus_cs(scs16_ext_bus_cs),       // to wrapper
				  .scs16_ext_bus_done(scs16_ext_bus_done),   // from wrapper
				  
				  .next_pc(scs16_next_pc),         // to wrapper
				  .next_inst(iram_rd_data),        // from imem
				  .scs16_iram_cs(scs16_iram_cs),   // to wrapper
				  
				  .debug_state(),                  // to wrapper external world
				  .debug_bus(scs16_debug_bus),     // from scs16 for debug
				  
				  .device(device),                 // to wrapper
				  .pulse(pulse),                   // to wrapper
				  .R0(r0),                         // to wrapper
				  .R1(r1),                         // to wrapper
				  .R2(r2),                         // to wrapper
				  .R3(r3),                         // to wrapper
				  .R4(r4),                         // to wrapper
				  .R5(r5),                         // to wrapper
				  .R6(r6),                         // to wrapper
				  .R7(r7),                         // to wrapper
				  .step(step),                     // from wrapper
				  .cont(continue),             // from wrapper
				  .bkpt(bkpt)                      // from wrapper     

				  );
   
   
   scs16_wrapper x_scs16_wrapper (
				  
				  .rst(rst), // from port
				  .clk(clk), // from port          
				  
				  .scs16_clk(scs16_clk), // 
				  .mems_clk(mems_clk),   // 
				  
`ifdef SCS_OCP_IF		    
				  // scsu master interface
				  .scsu_m_ocp_mcmd(scsu_m_ocp_mcmd),             // to port
				  .scsu_m_ocp_mbyten(scsu_m_ocp_mbyten),         // to port
				  .scsu_m_ocp_maddr(scsu_m_ocp_maddr),           // to port
				  .scsu_m_ocp_mdata(scsu_m_ocp_mdata),           // to port 
				  .ocp_scsu_m_sdata(ocp_scsu_m_sdata),           // from port
				  .ocp_scsu_m_sresp(ocp_scsu_m_sresp),           // from port
				  .ocp_scsu_m_scmdaccept(ocp_scsu_m_scmdaccept), // from port
				  
				  // scsu slave interface
				  .ocp_scsu_s_mcmd(ocp_scsu_s_mcmd),             // from port
				  .ocp_scsu_s_mbyten(ocp_scsu_s_mbyten),         // from port
				  .ocp_scsu_s_maddr(ocp_scsu_s_maddr),           // from port
				  .ocp_scsu_s_mdata(ocp_scsu_s_mdata),           // from port
				  .scsu_s_ocp_sdata(scsu_s_ocp_sdata),           // to port
				  .scsu_s_ocp_sresp(scsu_s_ocp_sresp),           // to port
				  .scsu_s_ocp_scmdaccept(scsu_s_ocp_scmdaccept), // to port
`endif //  `ifdef SCS_OCP_IF
				  


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
				  

			      
			      
			      .scsu_debug_intr(scsu_intr), // 
			      .scsu_intr1(scsu_intr1),     // 
			      .scsu_intr2(scsu_intr2),     // 
			      
			      
			      .scsu_tstout(scsu_tstout),         // to port  
			      .tstmux_sel(tstmux_sel),           // from port
			      .test_mode(scan_mode),             // 
			      
			      .scs16_rst(scs16_rst),             // to scs16
			      .hard_break(hard_break),           // to scs16 
			      .interupt(interupt),               // to scs16
			      .condition(condition),             // to scs16
			      .S0(S0),                           // to scs16 
			      .S1(S1),                           // to scs16
			      
			      
			      .dram_rd_data(dram_rd_data),       // from dmem
			      .dram_wr_data(dram_wr_data),       // to dmem
			      .dram_addr(dram_addr),             // to dmem
			      .dram_we(dram_we),                 // to dmem
			      .dram_cs(dram_cs),                 // to dmem
			      
			      .scs16_dram_wr_data(scs16_ram_wr_data), // from scs16
			      .scs16_dram_addr(scs16_ram_addr),       // from scs16
			      .scs16_dram_we(scs16_ram_we),           // from scs16
			      .scs16_dram_cs(scs16_ram_cs),           // from scs16
			      .scs16_ext_bus_cs(scs16_ext_bus_cs),    // from scs16
			      .scs16_ext_bus_done(scs16_ext_bus_done),// to scs16
			      .scs16_rd_data(scs16_rd_data),          // to scs16
			      
			      .iram_rd_data(iram_rd_data),            // from imem
			      .iram_wr_data(iram_wr_data),            // to imem
			      .iram_addr(iram_addr),                  // to imem
			      .iram_we(iram_we),                      // to imem
			      .iram_cs(iram_cs),                      // to imem
			      .scs16_iram_cs(scs16_iram_cs),          // from scs16
			      
			      .scs16_iram_addr(scs16_next_pc),        // from scs16
			      
			      .scs16_debug_bus(scs16_debug_bus),      // from scs16 for debug
			      
			      .ext_source0(ext_source0),
			      .ext_source1(ext_source1),
			      .ext_condition(ext_condition),
			      .ext_interupt(ext_interupt),
			      
			      .APP_OUT0(APP_OUT0),
			      .APP_OUT1(APP_OUT1),
			      .APP_OUT2(APP_OUT2),
			      .APP_OUT3(APP_OUT3),
			      .APP_OUT4(APP_OUT4),
			      .APP_OUT5(APP_OUT5),
			      .APP_OUT6(APP_OUT6),
			      .APP_OUT7(APP_OUT7),
			      
			      .device(device),                       // from scs16  
			      .pulse(pulse),                         // from scs16  
			      .r0(r0),                               // from scs16      
			      .r1(r1),                               // from scs16      
			      .r2(r2),                               // from scs16      
			      .r3(r3),                               // from scs16      
			      .r4(r4),                               // from scs16      
			      .r5(r5),                               // from scs16      
			      .r6(r6),                               // from scs16      
			      .r7(r7),                               // from scs16 
			      .step(step),                           // to scs16
			      .continue(continue),                   // to scs16
			      .bkpt(bkpt)                            // to scs16     
			      );
   
   endmodule 


