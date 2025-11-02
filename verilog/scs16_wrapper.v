// to do
// 1. sample write data from slave to imem and dmem to eliminate delay from the bus
// 2. does the slave or interconnect hold the rd_data toward the master .... 
//    so the master does not need to sample it immediatly
// 3. bit[15] of GPR0 can trash the imem address in long imem design
// 4. conect the debug signals, step continue, ...
// 5. 
module scs16_wrapper (

    input  wire        rst,
    input  wire        clk,
		    
		    
    output wire        mems_clk,             // imem/dmem clock
    output wire        scs16_clk,            // scs16 clock
    output wire        scs16_rst, // 
    output reg 	       hard_break, // 
    output wire        interupt, // 
		    
`ifdef SCS_OCP_IF		    
    output reg  [2:0]  scsu_m_ocp_mcmd,      // ocp master if'
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
    output reg [15:0]  scsu_s_ocp_sdata,     // ocp slave if'  
    output wire [1:0]  scsu_s_ocp_sresp,     // ocp slave if'  
    output wire        scsu_s_ocp_scmdaccept,// ocp slave if'  
`endif //  `ifdef SCS_OCP_IF
		      

`ifdef SCS_AHB_IF		    
    output wire [1:0]  scsu_m_ahb_mhtrans,   // ahb master if'
    output wire [1:0]  scsu_m_ahb_mhsize,    // ahb master if' 
    output wire        scsu_m_ahb_mhwrite,   // ahb master if' 
    output wire [23:0] scsu_m_ahb_mhaddr,    // ahb master if' 
    output reg  [15:0] scsu_m_ahb_mhwdata,   // ahb master if' 
    input  wire [15:0] ahb_scsu_m_shrdata,   // ahb master if' 
    input  wire        ahb_scsu_m_shready,   // ahb master if' 
    input  wire [1:0]  ahb_scsu_m_shresp,    // ahb master if' 

    input  wire [1:0]  ahb_scsu_s_mhtrans,   // ahb slave if'
    input  wire [1:0]  ahb_scsu_s_mhsize,    // ahb slave if' 
    input  wire        ahb_scsu_s_mhwrite,   // ahb slave if' 
    input  wire [15:0] ahb_scsu_s_mhaddr,    // ahb slave if' 
    input  wire [15:0] ahb_scsu_s_mhwdata,   // ahb slave if' 
    output reg  [15:0] scsu_s_ahb_shrdata,   // ahb slave if' 
    output wire        scsu_s_ahb_shready,   // ahb slave if' 
    output reg  [1:0]  scsu_s_ahb_shresp,    // ahb slave if' 
`endif //  `ifdef SCS_AHB_IF
		      


		      
    output reg 	       scsu_debug_intr,      // to outside interupt
    output wire        scsu_intr1,           // 
    output wire        scsu_intr2,           // 
		    
    output reg  [15:0] scsu_tstout,          // 
    input  wire [7:0]  tstmux_sel, // 
    input  wire        test_mode, // 
		    
		    
    output wire [15:0] condition, // 
    output wire [15:0] S0, // 
    output wire [15:0] S1, // 
		    
    input wire  [15:0] ext_source0, // 
    input wire  [15:0] ext_source1, //
    input wire  [15:0] ext_condition,
    input wire 	       ext_interupt, // 
		    
    input  wire [15:0] dram_rd_data,       // from dmem
    output reg  [15:0] dram_wr_data,       // to dmem
    output reg  [10:0] dram_addr,          // to dmem
    output reg  [1:0]  dram_we,            // to dmem
    output wire        dram_cs,            // to dmem
		    
    input  wire [31:0] iram_rd_data,       // from imem
    output reg  [31:0] iram_wr_data,       // to imem
    output reg  [13:0] iram_addr,          // to imem
    output reg  [1:0]  iram_we,            // to imem
    output wire        iram_cs,            // to imem

    input wire  [15:0] scs16_dram_wr_data, // from scs16
    input wire  [23:0] scs16_dram_addr,    // from scs16
    input wire  [1:0]  scs16_dram_we,      // from scs16
    input wire 	       scs16_dram_cs,      // from scs16
    input wire 	       scs16_ext_bus_cs,   // from scs16
    output wire        scs16_ext_bus_done, // to scs16
    output wire [15:0] scs16_rd_data,      // to scs16
		    
		    
    input wire  [13:0] scs16_iram_addr,    // from scs16
    input wire 	       scs16_iram_cs,      // from scs16    
		    
    input wire  [15:0] scs16_debug_bus,    // from scs16 for debug
		    
    output reg  [15:0] APP_OUT0, APP_OUT1, APP_OUT2, APP_OUT3, APP_OUT4, APP_OUT5, APP_OUT6, APP_OUT7,
		    
    input wire  [15:0] device,  // from scs16 
    input wire  [14:0] pulse,   // from scs16 
    input wire  [15:0] r0,      // from scs16 
    input wire  [15:0] r1,      // from scs16 
    input wire  [15:0] r2,      // from scs16 
    input wire  [15:0] r3,      // from scs16 
    input wire  [15:0] r4,      // from scs16 
    input wire  [15:0] r5,      // from scs16 
    input wire  [15:0] r6,      // from scs16 
    input wire  [15:0] r7,      // from scs16 
		    
    output reg 	       step,     // to scs16  
    output reg 	       continue, // to scs16	       		    
    output reg 	       bkpt      // to scs16	       
   );

   wire [15:0] 	       s_addr;
   wire [1:0] 	       s_be;
   wire [15:0] 	       s_wr_data;
   
   
   reg 		       s_some_cs;
   reg 		       s_rnw;
   reg 		       s_ack;
   wire 	       s_imem_cs, s_dmem_cs, s_rfile_cs;
 
   wire 	       s_error; 
   wire 	       mcode_wr_en, SCSU_GPR0_wr; //
   reg 		       iram_wr;
   reg 		       mcode_wr_en_start;
   
   reg [15:0] 	       SCSU_CTL, SCSU_GPR0, SCSU_GPR1, SCSU_TST, SCSU_MSI; //
   
   wire 	       scs16_app_out_cs;
   wire [4:0] 	       app_out_addr;
   wire [1:0] 	       app_out_be;
   wire [15:0] 	       app_out_wr_data;
   
   wire [7:0] 	       SCSU_SPARE; // 
   reg [15:0] 	       s_rd_data_pre; // 
   
   reg 		       ext_bus_en; // 
   
   wire 	       scs16_gate_en_bit; // 
   reg 		       scs16_gating_en; // 
   reg [3:0] 	       scs16_off_delay; // 
   
   wire 	       glue_gate_en_bit; // 
   reg 		       glue_gating_en; // 
   reg [3:0] 	       glue_off_delay; // 
   
   wire 	       mems_gate_en_bit; // 
   wire 	       mems_gating_en; // 
   
   reg 		       hard_break_pre; // 
   wire 	       glue_clk; //
   wire 	       clk_inv;
   
`ifdef SCS_OCP_IF		    

   // this code segment imlement the adaptation layer from the ocp protocol
   // to wraaper internal signaling
   // the outputs of this segment toward the wrapper
   // 1. s_addr       - slave address
   // 2. s_be         - byte enable
   // 3. s_wr_data    - write data
   // 4. s_some_cs    - chip select indicating this slave is accessed
   // 5. s_rnw        - read not write
   // 6. glue_gating_en - clock gating signal if this feature is active
   // the input of this segment from the wrapper
   // 1. s_ack        - ack indicating transaction is complete
   // 2. s_rd_data_pre- read data 
   //  
   assign s_addr    = ocp_scsu_s_maddr;
   assign s_be      = ocp_scsu_s_mbyten;
   assign s_wr_data = ocp_scsu_s_mdata;
   /////////////////////////////////////////////////////////////////////////  
   
   always @(posedge clk or posedge rst)
     if (rst)
       begin
	  s_some_cs          <= 0;
	  s_rnw              <= 0;
	  glue_off_delay     <= 0;
	  glue_gating_en     <= 1;
       end
     else if (s_ack)
       begin
          s_some_cs        <= 0;
          s_rnw            <= 0;
       end
     else
       begin
          s_some_cs        <= ocp_scsu_s_mcmd != 3'b000;
          s_rnw            <= ocp_scsu_s_mcmd != 3'b001;
	  
          if ((ocp_scsu_s_mcmd != 3'b000) && glue_gate_en_bit)
	    begin
               glue_off_delay <= 4'b0001;
               glue_gating_en <= 1;
	    end
          else if ((glue_off_delay == 4'b1000) && glue_gate_en_bit) 
            glue_gating_en <= 0;
          else
            glue_off_delay <= {glue_off_delay[2:0], 1'b0};
       end // else: !if(s_ack)
   
   assign s_error               = 0;          //for the moment

   assign scsu_s_ocp_scmdaccept = s_ack;
   assign scsu_s_ocp_sresp      = ((s_ack && s_rnw) && (!s_error))?  2'b01 :  2'b00;
   
   always @(s_rd_data_pre or  s_be)
     case (s_be)
       2'b01 : scsu_s_ocp_sdata   = {s_rd_data_pre[7:0],  s_rd_data_pre[7:0]};
       2'b10 : scsu_s_ocp_sdata   = {s_rd_data_pre[15:8], s_rd_data_pre[15:8]};
       2'b11 : scsu_s_ocp_sdata   = s_rd_data_pre;
       default : scsu_s_ocp_sdata = s_rd_data_pre;
     endcase // case(s_be)
   
`endif
  
`ifdef SCS_AHB_IF		    
   reg 	       access_start;
   reg 	       internal_ready;
   reg         ram_rd_valid;
   
   reg [15:0]  ahb_scsu_s_mhaddr_latch;
   reg [1:0]   ahb_scsu_s_mhsize_latch; 
  
   assign s_addr = ahb_scsu_s_mhaddr_latch;
   assign s_be   = (ahb_scsu_s_mhsize_latch == 2'b00) ? (2'b01 << ahb_scsu_s_mhaddr_latch[0]) : 
		   (ahb_scsu_s_mhsize_latch == 2'b01) ? 2'b11 :
		   2'b00;
   

   assign s_wr_data          = ahb_scsu_s_mhwdata;

   always @(posedge clk or posedge rst)
     if (rst)
       scsu_s_ahb_shrdata <= #1 0;
   else 
     case (s_be)
       2'b01 : scsu_s_ahb_shrdata   <= #1 {s_rd_data_pre[7:0],  s_rd_data_pre[7:0]};
       2'b10 : scsu_s_ahb_shrdata   <= #1 {s_rd_data_pre[15:8], s_rd_data_pre[15:8]};
       2'b11 : scsu_s_ahb_shrdata   <= #1 s_rd_data_pre;
       default : scsu_s_ahb_shrdata <= #1 s_rd_data_pre;
     endcase // case(s_be)

   
   always @(posedge clk or posedge rst)
     if (rst)
       begin
	  scsu_s_ahb_shresp       <= #1 0;
	  
	  internal_ready          <= #1 1;
	  ahb_scsu_s_mhaddr_latch <= #1 0;
	  ahb_scsu_s_mhsize_latch <= #1 0;
	  s_rnw                   <= #1 1;
	  s_some_cs               <= #1 0;
	  ram_rd_valid            <= #1 0;
	  access_start            <= #1 0;
	  glue_gating_en          <= #1 1;
       end
     else
       begin
	  ram_rd_valid            <= #1 s_some_cs && s_rnw && s_ack;	  
 	  access_start            <= #1 0;

	  if ((internal_ready || s_ack) && ahb_scsu_s_mhtrans == 2'b10)
	    begin
	       // start of access
	       access_start            <= #1 1;
	       ahb_scsu_s_mhaddr_latch <= #1 ahb_scsu_s_mhaddr;
	       ahb_scsu_s_mhsize_latch <= #1 ahb_scsu_s_mhsize;

	       if (ahb_scsu_s_mhwrite) // write
		 begin
		    s_rnw       <= #1 0;
		    s_some_cs   <= #1 1; 
		 end
	       else  // read
		 begin 
		    s_rnw       <= #1 1;
		    s_some_cs   <= #1 1; 
		 end
	       internal_ready<= #1 0;

	    end // if ((internal_ready || s_ack) && ahb_scsu_s_mhtrans == 2'b10)
	  
	  else if (!internal_ready && s_ack)
	    begin
	       internal_ready <= #1 1;
	       s_rnw          <= #1 1;
	       s_some_cs      <= #1 0;
	    end

       end // else: !if(rst)
   
   assign scsu_s_ahb_shready =  internal_ready || ram_rd_valid || (!s_rnw && s_ack);

`endif
   
   // ADDRESS MAP
   // address space assumptions
   // imem -       2K words of 4 bytes each  total 8KB, address 0x0000->0x1ffe 
   // dmem -       2K words of 2 bytes each  total 4KB, address 0x2000->0x2ffe
   // scsu regfile 16 words of 2 bytes each  total 32B, address 0x3000->0x301e

   // regfile list
   // SCSU_CTL  16'h3000
   // SCSU_GPR0 16'h3002
   // SCSU_GPR1 16'h3004
   // SCSU_TST  16'h3006
   // SCSU_MSI  16'h3008
   
   // the following APP_OUT registers (if imlemented) are accessible from the slave
   // interface for rd/wr at the following addresses
   // scs16 can write access those register. in scs16 address space they are place 
   // near the top of the dmem space in a way that actually hides the upper words of
   // the dmem
   
   // APP_OUT0                 from scs16 address 07f0    slave address 16'h3010
   // APP_OUT1                 from scs16 address 07f1    slave address 16'h3012
   // APP_OUT2                 from scs16 address 07f2    slave address 16'h3014
   // APP_OUT3                 from scs16 address 07f3    slave address 16'h3016
   // APP_OUT4                 from scs16 address 07f4    slave address 16'h3018
   // APP_OUT5                 from scs16 address 07f5    slave address 16'h301a
   // APP_OUT6                 from scs16 address 07f6    slave address 16'h301c
   // APP_OUT7                 from scs16 address 07f7    slave address 16'h301e


   
   assign s_dmem_cs  = s_some_cs &&  (s_addr[15:12] == 4'h2);   // from 0x2000->0x2ffe       
   assign s_imem_cs  = s_some_cs &&  (s_addr[15:13] == 3'h0);   // from 0x0000->0x1ffe  
   assign s_rfile_cs = s_some_cs &&  (s_addr[15:5]  == 11'h180);// from 0x3000->0x301e
   
   always @(s_imem_cs or  s_dmem_cs or  s_rfile_cs or  mcode_wr_en or  scs16_dram_cs)
     if (s_rfile_cs)
       s_ack = 1;
     else if (s_imem_cs)
       s_ack = mcode_wr_en;
     else if (s_dmem_cs)
       s_ack = !scs16_dram_cs;
     else
       s_ack = 0;
   
   
   always @(posedge clk or posedge rst)
     if (rst)
       iram_wr <= 0;
     else
       iram_wr <= SCSU_GPR0_wr;                      // s_rfile_cs and not s_rnw;
   
   
   
   assign iram_cs       = mcode_wr_en ? (iram_wr || s_imem_cs) : scs16_iram_cs;
   assign dram_cs       = scs16_dram_cs || s_dmem_cs;

   // dram arbitration mux
   always @(*)
     if (scs16_dram_cs)            // scs16 wins
       begin
	  dram_we      = scs16_dram_we;
	  dram_addr    = scs16_dram_addr[10:0];
	  dram_wr_data = scs16_dram_wr_data;
       end
     else if (s_dmem_cs && !s_rnw) // if cycle is clear then give it to slave
       begin
	  dram_we      = s_be;
	  dram_addr    = {3'b000,s_addr[8:1]};
	  dram_wr_data = s_wr_data;
       end
     else
       begin
	  dram_we      = 0;
	  dram_addr    = {3'b000,s_addr[8:1]};
	  dram_wr_data = s_wr_data;
       end
   
   
  // iram arbitration mux
  always @(*)
     if (mcode_wr_en && iram_wr)      // write via SCSU_GPR0 port
       begin
	  iram_wr_data = {SCSU_GPR0[15:0],SCSU_GPR0[15:0]};
          iram_addr    = SCSU_GPR1[15:2];
	  if (!SCSU_GPR1[1])          // high low 16bit select
            iram_we = 2'b01;
	  else
            iram_we = 2'b10;
       end
     else if (mcode_wr_en && s_imem_cs && !s_rnw) // direct access to imem in mcode load mod
       begin
	  iram_wr_data = {s_wr_data[15:0], s_wr_data[15:0]};
	  iram_addr    = s_addr[15:2];
	  if (!s_addr[1])               // high low 16bit select
            iram_we = 2'b01;
	  else
            iram_we = 2'b10;
       end
     else // scs16 instruction fetch
       begin
	  iram_wr_data = {SCSU_GPR0[15:0],SCSU_GPR0[15:0]};
	  iram_addr    = scs16_iram_addr;
	  iram_we      = 2'b00;
       end

   // slave read mux
   always @(*)    
     if (s_rnw)
       if (s_rfile_cs)
         case (s_addr[4:0])
           5'h00 : s_rd_data_pre = SCSU_CTL;
           5'h02 : s_rd_data_pre = SCSU_GPR0;
           5'h04 : s_rd_data_pre = SCSU_GPR1;
           5'h06 : s_rd_data_pre = SCSU_TST;
           5'h08 : s_rd_data_pre = SCSU_MSI;
	   5'h10 : s_rd_data_pre = APP_OUT0;
	   5'h12 : s_rd_data_pre = APP_OUT1;
	   5'h14 : s_rd_data_pre = APP_OUT2;
	   5'h16 : s_rd_data_pre = APP_OUT3;
	   5'h18 : s_rd_data_pre = APP_OUT4;
	   5'h1a : s_rd_data_pre = APP_OUT5;
	   5'h1c : s_rd_data_pre = APP_OUT6;
	   5'h1e : s_rd_data_pre = APP_OUT7;
	   
           default : s_rd_data_pre = 16'h0;
         endcase // case(s_addr[4:2])
   
       else if (s_imem_cs)
         if (s_addr[1])
           s_rd_data_pre                                            = iram_rd_data[31:16];
         else
           s_rd_data_pre                                            = iram_rd_data[15:0];
       else if (s_dmem_cs) 
         s_rd_data_pre                                              = dram_rd_data;
       else
         s_rd_data_pre                                              = 16'h0;
     else
       s_rd_data_pre                                                = 16'h0;
   
 

   // SCSU_CTL reg
   // [0] mcode_wr_en bit   - writing to this bit place scsu in micro-code load mode
   //                         where in this mode, SCSU_GPR0 serve as a port to the imem
   //                         continues write to SCSU_GPR0 place the data in the imem in
   //                         a consequtive addresses.
   // [1] scs16_rst bit     - active high, writing zero release the rst of scs16 
   // [2] scs16_gate_en_bit - configuration bit to activate clock gating
   // [3] glue_gate_en_bit  - configuration bit to activate clock gating
   // [4] mems_gate_en_bit  - configuration bit to activate clock gating
   always @(posedge glue_clk or posedge rst)
     if (rst)
       begin
	  SCSU_CTL                      <= 16'h2;
	  mcode_wr_en_start             <= 0;
       end
     else if (s_rfile_cs && (!s_rnw) && (s_addr[4:0] == 5'h0))
       begin
	  if (s_be[0])
	    begin
               SCSU_CTL[7:0]       <= s_wr_data[7:0];
               if (s_wr_data[0])
		 mcode_wr_en_start      <= 1;
               
            end
	  if (s_be[1])
            SCSU_CTL[15:8]      <= s_wr_data[15:8];
       end
     else
       mcode_wr_en_start           <= 0;
   
   assign mcode_wr_en = SCSU_CTL[0];
   
   // SCSU_GPR0 reg
   // 16 bits data register with few functionalities
   // 1. in micro-code loading mode, it act as a port to the imem, every write place
   //    the 16 bits data in a consequtive address
   // 2. out of mode 1, writing to this reg assert the hard_break signal force the
   //    scs16 to jump to predefined pc.
   // 3. out of mode 1, based on the user script, it is possible to read the data of
   //    this reg to the scs16 via the S0 port
   always @(posedge glue_clk or posedge rst)
     if (rst)
       SCSU_GPR0                    <= 0;
     else if (s_rfile_cs && !s_rnw && (s_addr[4:0] == 5'h2))
       begin
          if (s_be[0])
            SCSU_GPR0[7:0]    <= s_wr_data[7:0];
	  
          if (s_be[1])
            SCSU_GPR0[15:8]   <= s_wr_data[15:8];
       end
   
   assign SCSU_GPR0_wr  = s_rfile_cs && (!s_rnw) && (s_addr[4:0] == 5'h2);
 
   // SCSU_GPR1
   // 16 bits data register with few functionalities
   // 1. in micro-code loading mode, it act as the address reg to the imem, every write 
   //    to SCSU_GPR0 increament its value by 2. SW can write to this register an init value
   //    other then zero and it will be used as the init address for the next micro-code write.
   //    this operation is stored in bit [15] 
   // 2. out of mode 1, based on the user script, it is possible to read the data of
   //    this reg to the scs16 via the S1 port
   // 3. out of mode 1, based on the user script, it is possible to see SCSU_GPR1[13:0] inside
   //    the scs16 script via the condition port

   always @(posedge glue_clk or posedge rst)
     if (rst)
       SCSU_GPR1                    <= 0;
     else if (s_rfile_cs && !s_rnw && (s_addr[4:0] == 5'h4))
       begin
          if (s_be[0])
	    SCSU_GPR1[7:0]    <= s_wr_data[7:0];
	  
          if (s_be[1])
            if (mcode_wr_en) // skip the state change
              SCSU_GPR1[14:8] <= s_wr_data[14:8];
            else
              SCSU_GPR1[15:8] <= s_wr_data[15:8];
       end
     else
       if (mcode_wr_en)
         if (mcode_wr_en_start)
           SCSU_GPR1              <= 0;
	 else if (!SCSU_GPR1[15] &&  SCSU_GPR0_wr) 
           SCSU_GPR1[15]          <= 1;
         else if (SCSU_GPR0_wr)
           SCSU_GPR1              <= SCSU_GPR1 + 2;
   

   // SCSU_TST reg
   // this reg holds the reference pc value in debug mode
   always @(posedge glue_clk or posedge rst)
     if (rst)
       SCSU_TST                  <= 0;
     else if (s_rfile_cs && !s_rnw && (s_addr[4:0] == 5'h6))
       begin
          if (s_be[0])
            SCSU_TST[7:0]  <= s_wr_data[7:0];
	  
          if (s_be[1])
            SCSU_TST[15:8] <= s_wr_data[15:8];
       end

   // SCSU_MSI
   // this reg holds the interuppt mask for the scsu_debug_intr.
   // this interrupt indicates that some event occur, so SW can take actions
   always @(posedge glue_clk or posedge rst)
     if (rst)
       SCSU_MSI                  <= 0;
     else if (s_rfile_cs && !s_rnw && (s_addr[4:0] == 5'h8))
       begin
          if (s_be[0])
            SCSU_MSI[7:0]  <= s_wr_data[7:0];
	  
          if (s_be[1])
            SCSU_MSI[15:8] <= s_wr_data[15:8];
       end
   

   // implementing the APP_OUTX reg with option to be written from micro code

   
   assign scs16_app_out_cs  = scs16_dram_cs && (|scs16_dram_we) && (scs16_dram_addr[15:4] == 16'h07f);
   assign app_out_addr[4:0] = scs16_app_out_cs ? {1'b1, scs16_dram_addr[2:0],1'b0} : s_addr[4:0];
   assign app_out_wr_data   = scs16_app_out_cs ? scs16_dram_wr_data : s_wr_data;
   assign app_out_be        = scs16_app_out_cs ? scs16_dram_we : s_be;
  
   always @(posedge glue_clk or posedge rst) // consider using different clock
     if (rst)
       begin
	  APP_OUT0 <= 0;
	  APP_OUT1 <= 0;
	  APP_OUT2 <= 0;
	  APP_OUT3 <= 0;
	  APP_OUT4 <= 0;
	  APP_OUT5 <= 0;
	  APP_OUT6 <= 0;
	  APP_OUT7 <= 0;
       end
     else if ((s_rfile_cs && !s_rnw ) || scs16_app_out_cs)
       begin
          if (app_out_be[0])
	    case (app_out_addr[4:0])
	      5'h10 : APP_OUT0[7:0]  <= app_out_wr_data[7:0];
	      5'h12 : APP_OUT1[7:0]  <= app_out_wr_data[7:0];
	      5'h14 : APP_OUT2[7:0]  <= app_out_wr_data[7:0];
	      5'h16 : APP_OUT3[7:0]  <= app_out_wr_data[7:0];
	      5'h18 : APP_OUT4[7:0]  <= app_out_wr_data[7:0];
	      5'h1a : APP_OUT5[7:0]  <= app_out_wr_data[7:0];
	      5'h1c : APP_OUT6[7:0]  <= app_out_wr_data[7:0];
	      5'h1e : APP_OUT7[7:0]  <= app_out_wr_data[7:0];
	    endcase // case(app_out_addr[5:0])
	  
	  
          if (app_out_be[1])
	    case (app_out_addr[4:0])
	      5'h10 : APP_OUT0[15:8]  <= app_out_wr_data[15:8];
	      5'h12 : APP_OUT1[15:8]  <= app_out_wr_data[15:8];
	      5'h14 : APP_OUT2[15:8]  <= app_out_wr_data[15:8];
	      5'h16 : APP_OUT3[15:8]  <= app_out_wr_data[15:8];
	      5'h18 : APP_OUT4[15:8]  <= app_out_wr_data[15:8];
	      5'h1a : APP_OUT5[15:8]  <= app_out_wr_data[15:8];
	      5'h1c : APP_OUT6[15:8]  <= app_out_wr_data[15:8];
	      5'h1e : APP_OUT7[15:8]  <= app_out_wr_data[15:8];
	    endcase // case(app_out_addr[5:0])
	  
	    
       end

   // hardbreak signal generation (one cycle pulse)
   always @(posedge clk or posedge rst)
     if (rst)
       begin
	  hard_break_pre <= 0;
	  hard_break     <= 0;
       end
     else
       begin
	  hard_break_pre <= SCSU_GPR0_wr && !mcode_wr_en; // one cycle pulse
	  hard_break     <= hard_break_pre;
       end


   assign scs16_rst        = (SCSU_CTL[1] && !test_mode) || rst;
   assign scs16_gate_en_bit = SCSU_CTL[2]; //      configue bit to activate clock gating
   assign glue_gate_en_bit  = SCSU_CTL[3]; //      configue bit to activate clock gating
   assign mems_gate_en_bit  = SCSU_CTL[4]; //      configue bit to activate clock gating

   // external signal routing to the core
   assign interupt         = device[14] ? 1'b0      : ext_interupt;
   assign S0               = device[12] ? SCSU_GPR0 : ext_source0;
   assign S1               = device[13] ? SCSU_GPR1 : ext_source1;
   assign condition        = device[15] ? {1'b1, 1'b0, SCSU_GPR1[13:0]} : {1'b1, 1'b0, ext_condition[13:0]};


`ifdef SCS_OCP_IF		    

   //     output wire [2:0]  scsu_m_ocp_mcmd,      // ocp master if'
   //     output wire [1:0]  scsu_m_ocp_mbyten,    // ocp master if' 
   //     output wire [13:1] scsu_m_ocp_maddr,     // ocp master if' 
   //     output wire [15:0] scsu_m_ocp_mdata,     // ocp master if' 
   //     input  wire [15:0] ocp_scsu_m_sdata,     // ocp master if' 
   //     input  wire [1:0]  ocp_scsu_m_sresp,     // ocp master if' 
   //     input  wire        ocp_scsu_m_scmdaccept,// ocp master if' 
   
   // the OCP master logic
   // the inputs to this process from the wrapper are
   // 1. scs16_ext_bus_cs- scs16 indication that it needs to access the external bus
   // 2. scs16_dram_we   - write access indication
   // 3. scs16_dram_cs   - kkkk not need to be here
   // 4. scs16_dram_addr - the address
   // 5. scs16_dram_wr_data - the write data
   // the outputs of this process are
   // 1. scs16_ext_bus_done  - completion indication to the core
   // 2. scs16_rd_data       - the read data
   
   always @(posedge scs16_clk or posedge rst) // scs16 GATED CLOCK
     if (rst) 
       ext_bus_en   <= 0;
     else if (scs16_ext_bus_cs) 
       if (ocp_scsu_m_scmdaccept)
         ext_bus_en <= 0;
       else
         ext_bus_en <= 1;
     else
       ext_bus_en   <= 1;

   always @(ext_bus_en or  scs16_ext_bus_cs or  scs16_dram_we)
     if (scs16_ext_bus_cs)
       if (scs16_dram_we !== 2'b00)
         scsu_m_ocp_mcmd <= 3'b001 & {3{ext_bus_en}};     // write
       else
         scsu_m_ocp_mcmd <= 3'b010 & {3{ext_bus_en}};     // read
     else
       scsu_m_ocp_mcmd   <= 3'b000 & {3{ext_bus_en}};     // idle

   assign scs16_ext_bus_done= !ext_bus_en;

   assign scsu_m_ocp_mbyten = (scs16_dram_cs && (scs16_dram_we[1] || scs16_dram_we[0])) ? scs16_dram_we : 2'b11; // kkk

   assign scsu_m_ocp_maddr  = scs16_dram_addr[12:0];
   
   assign scsu_m_ocp_mdata  = scs16_dram_wr_data[15:0];

   assign scs16_rd_data     = scs16_ext_bus_cs ? ocp_scsu_m_sdata : dram_rd_data;

`endif //  `ifdef SCS_OCP_IF
   
`ifdef SCS_AHB_IF		    

   //     output wire [1:0]  scsu_m_ahb_mhtrans,   // ahb master if'
   //     output wire [1:0]  scsu_m_ahb_mhsize,    // ahb master if' 
   //     output wire        scsu_m_ahb_mhwrite,   // ahb master if' 
   //     output wire [13:1] scsu_m_ahb_mhaddr,    // ahb master if' 
   //     output reg  [15:0] scsu_m_ahb_mhwdata,   // ahb master if' 
   //     input  wire [15:0] ahb_scsu_m_shrdata,   // ahb master if' 
   //     input  wire        ahb_scsu_m_shready,   // ahb master if' 
   //     input  wire [1:0]  ahb_scsu_m_shresp,    // ahb master if' 
   
   // the AHB master logic
   // the inputs to this process from the wrapper are
   // 1. scs16_ext_bus_cs- scs16 indication that it needs to access the external bus
   // 2. scs16_dram_we   - write access indication
   // 3. scs16_dram_cs   - kkkk not need to be here
   // 4. scs16_dram_addr - the address
   // 5. scs16_dram_wr_data - the write data
   // the outputs of this process are
   // 1. scs16_ext_bus_done  - completion indication to the core
   // 2. scs16_rd_data       - the read data

   reg master_access_start;
   reg [1:0] mh_state;
   
   assign scsu_m_ahb_mhaddr = scs16_dram_addr[23:0];
   assign scsu_m_ahb_mhwrite=  scs16_ext_bus_cs && |scs16_dram_we;
   assign scsu_m_ahb_mhsize = (scs16_ext_bus_cs && !(|scs16_dram_we)) ? 2'b01 :                  // read always two bytes
			      (scs16_ext_bus_cs &&  (scs16_dram_we == 2'b10) ) ? 2'b00 :         // write upper byte
			      (scs16_ext_bus_cs &&  (scs16_dram_we == 2'b01) ) ? 2'b00 :         // write lowr byte	      
			      (scs16_ext_bus_cs &&  (scs16_dram_we == 2'b11) ) ? 2'b01 : 2'b01;  // write two byte
			      
   always @(posedge scs16_clk or posedge rst) // scs16 GATED CLOCK
     if (rst)
       begin
	  scsu_m_ahb_mhwdata <= #1 0;
	  mh_state <= #1 0;
       end
     else if ((mh_state == 0) && scs16_ext_bus_cs)
       begin
	  scsu_m_ahb_mhwdata <= #1 scs16_dram_wr_data;
	  mh_state <= #1 1;
       end
     else if ((mh_state == 1) && ahb_scsu_m_shready)
       mh_state <= #1 2;
     else if (mh_state == 2)
       mh_state <= #1 0;
   
   assign scs16_ext_bus_done = mh_state == 2;
   assign scsu_m_ahb_mhtrans = (scs16_ext_bus_cs && ahb_scsu_m_shready && (mh_state == 0)) ? 
			       2'b10 : 2'b00;

   
       
//   // one should check that scs16_dram_we=11 comes always with scs16_dram_addr[0]=0  kkk
//    always @(posedge scs16_clk or posedge rst) // scs16 GATED CLOCK
//      if (rst)
//        begin
// 	  scsu_m_ahb_mhwdata <= #1 0;
// 	  master_access_start       <= #1 0;
//        end
//      else if (scs16_ext_bus_cs && ahb_scsu_m_shready)
//        begin
// 	  scsu_m_ahb_mhwdata <= scs16_dram_wr_data;
// 	  master_access_start       <= #1 1;
//        end
//      else if (master_access_start && ahb_scsu_m_shready)
//        master_access_start       <= #1 0;
   
//    assign scs16_ext_bus_done = master_access_start && ahb_scsu_m_shready && scs16_ext_bus_cs;
//    assign scsu_m_ahb_mhtrans = (scs16_ext_bus_cs && ahb_scsu_m_shready && !master_access_start) ? 
// 			       2'b10 : 2'b00;

   // do we need alignment here ? kkk
   assign scs16_rd_data      = scs16_ext_bus_cs ? ahb_scsu_m_shrdata : dram_rd_data;

   
  
`endif
   
   ////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////
   
   always @(r0 or  r1 or  r2 or  r3 or  r4 or  r5 or  r6 or  r7 or  device or  pulse or  scs16_iram_addr or  tstmux_sel)

     case (tstmux_sel) 
       0      : scsu_tstout = r0;
       1      : scsu_tstout = r1;
       2      : scsu_tstout = r2;
       3      : scsu_tstout = r3;
       4      : scsu_tstout = r4;
       5      : scsu_tstout = r5;
       6      : scsu_tstout = r6;
       7      : scsu_tstout = r7;
       8      : scsu_tstout = {1'b0,pulse};
       9      : scsu_tstout = device;
       10     : scsu_tstout = {2'b00, scs16_iram_addr};
       default : scsu_tstout = 0;
     endcase // case(tstmux_sel)



   always @(posedge clk or posedge rst)  // original clock UN-GATED
     if (rst)
       scsu_debug_intr <= 0;
     else 
       scsu_debug_intr <= ((SCSU_TST[13:0] == scs16_iram_addr) && SCSU_MSI[0]) ||
                          (scs16_debug_bus[0]                  && SCSU_MSI[1]) ||
                          (scs16_debug_bus[1]                  && SCSU_MSI[2]) ||
                          (scs16_debug_bus[2]                  && SCSU_MSI[3]) ||
                          (scs16_debug_bus[3]                  && SCSU_MSI[4]) ||
                          (pulse[2]                            && SCSU_MSI[5]) ||
                          (pulse[3]                            && SCSU_MSI[6]) ||
                          (scs16_gating_en                     && SCSU_MSI[7]);
   

   assign scsu_intr1 = pulse[2];
   assign scsu_intr2 = pulse[3];


   // implementing the SW initiated pulse[14] sleep mode. 
   always @(posedge clk or posedge rst)// original clock UN-GATED
     if (rst)
       begin
	  scs16_gating_en     <= 0;
	  scs16_off_delay   <= 0;
       end
     else
       if (!scs16_gate_en_bit)
	 begin
            scs16_gating_en   <= 1;
            scs16_off_delay <= 0;
	 end
       else if (SCSU_GPR0_wr && !SCSU_CTL[1] && scs16_gate_en_bit)
	 begin
            scs16_gating_en   <= 1;
            scs16_off_delay <= 0;
	 end
       else if (scs16_off_delay[3] && !SCSU_CTL[1] && scs16_gate_en_bit) 
	 begin
            scs16_gating_en   <= 0;
            scs16_off_delay <= 0;
	 end
       else
         scs16_off_delay <= {scs16_off_delay[2:0],pulse[14]};

   assign mems_gating_en = !mems_gate_en_bit || ( mcode_wr_en || scs16_gating_en || s_imem_cs || s_dmem_cs);


   
   cgate x_scs16_clock_gate(
			    .en(scs16_gating_en),
			    .te(test_mode), // 
			    .clkin(clk), // 
			    .clkout(scs16_clk)
			    );


   cgate x_mems_clock_gate(
			   .en(mems_gating_en),
			   .te(test_mode), // 
			   .clkin(clk_inv), // 
			   .clkout(mems_clk) // 
			   );
   
   cgate x_glue_clock_gate(
			   .en(glue_gating_en),
			   .te(test_mode), // 
			   .clkin(clk), // 
			   .clkout(glue_clk) // 
			   );




   assign clk_inv = !clk;
   

   
endmodule
