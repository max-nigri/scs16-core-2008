///////////////////////////////////////////////////////////////////////
// File:  		scs16.v
// Created by:		Max Nigri                             
// Date Creation:  	01.01
// Version:		1.0
// Modified:		01.04.01
//
// Project: 		SCS16
//           
///////////////////////////////////////////////////////////////////////
// to do:
// 1. make level saveble like in_main_level for contex switch 
// 2. review all contex switch facility



  //`resetall
  //`timescale 1ns/10ps
  module scs16( 

    input wire	       clk,
    input wire 	       rst,
    input wire 	       interupt,
    input wire 	       hard_break,
		
    input wire [15:0]  condition,
    input wire [15:0]  S0,
    input wire [15:0]  S1,
    input wire [31:0]  next_inst,
    input wire [15:0]  ram_rd_data,
		
    output wire        scs16_iram_cs,		
    output reg [15:0]  ram_wr_data,
    output reg [23:0]  ram_addr,
    output wire [1:0]  ram_we,
    output wire        ram_cs,
    output wire        scs16_ext_bus_cs,
    input  wire        scs16_ext_bus_done,
    output reg [15:0]  device,
    output reg [13:0]  next_pc,
    output reg [14:0]  pulse,
		
    output reg [15:0]  R0,
    output reg [15:0]  R1, 
    output reg [15:0]  R2, 
    output reg [15:0]  R3, 
    output reg [15:0]  R4, 
    output reg [15:0]  R5, 
    output reg [15:0]  R6, 
    output reg [15:0]  R7,
		
    output wire [15:0] debug_bus,
    // GK continue is reserved word in sv
    // input  wire        step, continue, bkpt,
    input  wire        step, cont, bkpt,
    output reg [1:0]   debug_state
		);
   

   parameter SCS16_VERBOSE = 0;
   
   
   // Opcodes and their value
`define NOP		0
`define WAIT_LOAD	1
`define LCRLR		2  
`define LOAD	 	3
`define STORE 		4 
`define MOVE		6
`define LOADI	 	7
`define WAIT_STORE	8
`define LOOP		9
`define ALU		10
`define DEST		11
`define TIMER		12  
`define JUMP		13
`define RETURN		14
`define STOREI 		15 
`define BRANCH		16
`define ALUI		17
`define PUSHPOP		18
`define EXTINS		19
`define CRC		20  // not implemented
`define FIFO		21
  
`define MATH            24
`define OCP_STORE       25
`define OCP_STOREI      26
`define OCP_STOREIAD    28  // this is the wide command


`define OCP_LOAD        29
`define OCP_LOADI       30
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
// replacement procedure
// assign ir_ext_bus = ir[26];
// inst_id[`OCP_STORE]   -> (inst_id[`STORE]  && ir_ext_bus)
// inst_id[`OCP_STOREI]  -> (inst_id[`STOREI] && ir_ext_bus)
// inst_id[`OCP_LOAD]    -> (inst_id[`LOAD]   && ir_ext_bus)
// inst_id[`OCP_LOADI]   -> (inst_id[`LOADI]  && ir_ext_bus)
// inst_id[`OCP_STOREIAD]-> ext_storeiad 
// ALL_OCP_CMD           -> ALL_EXT_BUS_CMD  
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
   
   
`define ORD_STORE       ((inst_id[`STORE]  && ir_ext_bus)  || inst_id[`STORE])  // replacing inst_id[`STORE] with `ORD_STORE
`define ORD_STOREI      ((inst_id[`STOREI]  && ir_ext_bus) || inst_id[`STOREI])
`define ORD_LOAD        ((inst_id[`LOAD]   && ir_ext_bus)   || inst_id[`LOAD])
`define ORD_LOADI       ((inst_id[`LOADI]   && ir_ext_bus)  || inst_id[`LOADI])
   
`define ALL_OCP_CMD     ((inst_id[`STORE]  && ir_ext_bus)  || (inst_id[`STOREI]  && ir_ext_bus)  || ext_storeiad  || (inst_id[`LOAD]   && ir_ext_bus)  || (inst_id[`LOADI]   && ir_ext_bus))
`define ALL_EXT_BUS_CMD ((inst_id[`STORE] || inst_id[`STOREI] || ext_storeiad  || inst_id[`LOAD] || inst_id[`LOADI] ) && ir_ext_bus)


   
`define LIN_SEARCH	31

// Other defines
`define INTERRUPT_ADDR  14'd2
`define HARD_BREAK_ADDR 14'd3
   
`define ASYNC_RST       or posedge rst

   wire 	       ir_ext_bus;
   wire 	       ext_storeiad;  // place holder
	 
   reg  [15:0] 	       R0_b, R1_b, R2_b, R3_b, R4_b, R5_b, R6_b, R7_b;
   reg  [15:0] 	       device_b;
   reg  [16:0] 	       alu_out;
   
   wire [4:0] 	       next_op_code;
   
   reg  [31:0] 	       ir;
   reg  [31:0] 	       inst_id;
   
   // Internal Signals
   wire [1:0] 	       ram_addr_sel;
   wire [1:0] 	       ram_wr_data_sel;
   wire [15:0] 	       imd_add_data;
   wire [15:0] 	       ld_en1_Rx;
   wire [2:0] 	       ld_en1_Rx_index; 
   wire [1:0] 	       ld_en1_Rx_lh; // controls low high or both or none depends on command
   wire [2:0] 	       RB_sel,RA_sel;
   reg  [15:0] 	       RA,RB,Rother;
   reg  [15:0] 	       next_ram_addr;
   wire [1:0] 	       next_ram_addr_ld_en;


   reg  [13:0] 	       pc;
   reg  [13:0] 	       sub_return_add,sub_return_add_b;
   wire [13:0] 	       pc_inc;  
   
   reg  [13:0] 	       next_pc_no_interupt;
   wire [13:0] 	       early_pc;
   reg  [13:0] 	       loop_start_pc, loop_start_pc_b;
   reg  [13:0] 	       loop_end_pc, loop_end_pc_b;

   reg  [1:0] 	       interupt_state;
   reg  [13:0] 	       interupt_return;
   wire 	       interupt_sel;
   reg 		       in_main_level;
   reg 		       interupt_to_core;
   reg 		       sampled_interupt;
   reg 		       sampled_hard_break;
   wire 	       hard_break_sel;

   
   wire 	       late_non_pc_inc_dsc;
   wire 	       Rx_bit_y;
   wire 	       cond_bit;
   wire 	       end_cond;
   

   wire 	       ext_cond_branch;
   reg 		       flag_bit;
   wire 	       cond;

   wire 	       ext_cond;
   wire 	       end_cond_pre;
   reg 		       neg,zero,eq,gr,ls,ovf,cnt_0_zero,cnt_1_zero;
   reg 		       neg_b,zero_b,eq_b,gr_b,ls_b,ovf_b,cnt_0_zero_b,cnt_1_zero_b;
   reg 		       search_stop, search_stop_b;
   reg  [2:0] 	       level;
   
   reg 		       loop_invoked, loop_invoked_b;
   reg  [9:0] 	       loop_cnt, loop_cnt_b;
   wire 	       pc_eq_loop_end, loop_cnt_gr_zero, loop_goto_start_pc, loop_goto_post_end_pc;
   wire 	       loop_cnt_dec;   
   
   wire [1:0] 	       ld_en1_Rother_lh;
   wire [2:0] 	       ld_en1_Rother_index;
   wire [15:0] 	       ld_en1_Rother;
   
   reg  [15:0] 	       early_regs_load;
   wire [15:0] 	       early_late_regs_load;
   wire [15:0] 	       late_regs_load;
   wire [15:0] 	       alu_y;
   reg  [15:0] 	       counter0, counter1;
   
   wire 	       ram_rd;
   wire [15:0] 	       r6r7;  
   wire 	       add_from_regs;
   wire 	       add_from_imd;
   wire 	       add_from_both;
   wire                add_from_long;
   

   wire [13:0] 	       push_en, pop_en;
   wire [15:0] 	       insert_load_en;
   
   wire 	       fifo_e,fifo_f,fifo_wr,wrap_arround,next_fifo_f,next_fifo_e;
   wire [6:0] 	       fifo_m,fifo_l,fifo_wa,fifo_ra,next_fifo_rel_add,next_fifo_l;
   wire [15:0] 	       next_R0,next_R1;
   
   // timer vars
   wire [15:0] 	       timer_load_data;
   reg  [15:0] 	       timer0, timer1;
   reg 		       t0_pl, t0_der, t0_es, t0_done;
   reg  [3:0] 	       t0_cb;
   wire 	       t0_ls, t0_count_source2,t0_count_source1, t0_count_source1_der;
   wire 	       t0_count;   
   reg 		       t0_count_source1_prev;
   
   reg 		       t1_pl, t1_der, t1_es, t1_done;
   reg  [3:0] 	       t1_cb;
   wire 	       t1_ls, t1_count_source2,t1_count_source1, t1_count_source1_der;
   wire 	       t1_count;   
   reg 		       t1_count_source1_prev;
   
   // optional math command place holder
   wire [23:0] 	       M_out;
   wire [31:0] 	       A_out;
   wire [23:0] 	       MA_out;
   wire [36:0] 	       Div_out;
   wire [31:0] 	       Div_out_result;
   wire 	       div_start, div_complete, div_capture, divide_by_0;
   
   
   reg 		       t0_done_before_wait, t1_done_before_wait;
   reg 		       t0_done_before_wait_state, t1_done_before_wait_state;
   wire 	       wait_via_branch;
   
   wire 	       no_update;
   wire 	       no_update_pcir;
   wire 	       cmd_boundery;

   assign ir_ext_bus = ir[26];
   assign ext_storeiad = 1'b0;
 
   //////////////////////////////////
   // Instruction Environment
   //////////////////////////////////
   
   assign next_op_code = next_inst[31:27]; // [31:21]
       
   always @(posedge clk `ASYNC_RST)
     begin
	if (rst)
	  begin 
	     ir <=#1 32'b0;
	     inst_id <=#1 32'h00000001;
	  end 
	else if (no_update_pcir)       ;  
	else
	  begin  	
	     ir <= #1 next_inst; 
	     // Setting the hot one bit
	     if ((next_inst[28] == 1) && 0 ) // kkk handle coding of wide storiad 
	       inst_id <= #1 (32'h00000001 << 28);
	     else
	       inst_id <= #1 (32'h00000001<<next_op_code);  
    	  end
     end
 
   /////////////////////////////////////////////////////////////////////////////////////////////
   // interupt staff

  
   always @(posedge clk `ASYNC_RST)
     if (rst)
       sampled_interupt <= #1 0;
     else if (no_update)       ;  
     else if ( !sampled_interupt && interupt)
       sampled_interupt <= #1 1;
     else if (!interupt)       // for level interupt
     // else if (interupt_sel) // for pulsed interupt
       sampled_interupt <= #1 0;
   
   assign     interupt_sel = in_main_level && sampled_interupt;



   
   always @(posedge clk `ASYNC_RST)
      if (rst)
	sampled_hard_break <= #1 0;
     else if (no_update)       ;  
      else if ( !sampled_hard_break && hard_break)
	sampled_hard_break <= #1 1;
      else if (hard_break_sel)
	sampled_hard_break <= #1 0;

   assign     hard_break_sel = sampled_hard_break && ( (`ALL_EXT_BUS_CMD && scs16_ext_bus_done) || !`ALL_EXT_BUS_CMD );
   
      
   always @(posedge clk `ASYNC_RST)
     if (rst)
       begin
	  in_main_level <= #1 1;
	  level <= #1 0;
       end
     else if (no_update)       ;  
     else if (hard_break_sel)
       begin
	  in_main_level <= #1 1;
	  level <= #1 0;
       end
//     else if (ld_en1_Rother[13:12] == 2'b11)  // must ensure no interupt while loading 
//       in_main_level <= #1     late_regs_load[2];  
     else if ((inst_id[`JUMP] && ir[20]) || interupt_sel ) // gosub .... or interupt
       begin
	  in_main_level <= #1 0;
	  if ((inst_id[`JUMP] && ir[20]) && interupt_sel )
	    level <= #1 level + 2;
	  else
	    level <= #1 level + 1;
       end
     else if (inst_id[`RETURN] && (ir[19] == 1'b0)) // return from sub ... or interupt
       begin
	  if (level == 3'b001) 
	    in_main_level <= #1 1;
	  level <= #1 level - 1;
       end

      
   always @(posedge clk `ASYNC_RST)
     if (rst)
       interupt_return <= #1 0;
     // else if (sampled_interupt)
     else if (no_update)       ;  
     else if (ld_en1_Rother[9:8] == 2'b11)  // in load and loadi
       interupt_return <= #1 late_regs_load;  // must ensure no interupt while loading
     else if (interupt_sel)
       interupt_return <= #1 next_pc_no_interupt;
   
   always @(interupt_sel or next_pc_no_interupt or hard_break or hard_break_sel)
     if (hard_break_sel) // assumed to be pulse
       next_pc = `HARD_BREAK_ADDR;
     else if (interupt_sel)
       next_pc = `INTERRUPT_ADDR;
     else
       next_pc = next_pc_no_interupt;


  /////////////////////////////////////////////////////////////////////////////////////////////
   // pc staff

   always @(posedge clk `ASYNC_RST)
     if (rst)
       pc <= #1 0;
     else if (no_update_pcir)       ;  
     else if (ld_en1_Rother[15:14] == 2'b11)
       pc <= #1 late_regs_load; // context switch from ram
     else
       pc <= #1 next_pc;

   always @(inst_id or pc or late_non_pc_inc_dsc or early_pc or pc_inc)
     if (late_non_pc_inc_dsc)
       next_pc_no_interupt  = early_pc;
     else
       next_pc_no_interupt = pc + pc_inc ;

   /////////////////////////////////////////////////////////////////////////////////////////////
   // sub return staff
   always @(posedge clk `ASYNC_RST)
     if (rst)
       begin
	  sub_return_add   <= #1 0;
	  sub_return_add_b <= #1 0;
       end
     else if (no_update)       ;  
     else if (inst_id[`JUMP] && ir[20]) // gosub
       sub_return_add <= #1 pc +1;      // consider sharing
     else if (ld_en1_Rother[7:6] == 2'b11)  // in load and loadi 
       sub_return_add <= #1 late_regs_load;
     else if (push_en[11])
       sub_return_add_b <= #1 sub_return_add;
     else if (pop_en[11])
       sub_return_add <= #1 sub_return_add_b;
   
   /////////////////////////////////////////////////////////////////////////////////////////////
   // loop staff

   always @(posedge clk `ASYNC_RST)
     if (rst)
       begin
	  loop_start_pc <= #1 0;
	  loop_end_pc   <= #1 0;
	  loop_invoked  <= #1 0;
	  loop_cnt      <= #1 0;
	  loop_start_pc_b <= #1 0;
	  loop_end_pc_b   <= #1 0;
	  loop_invoked_b  <= #1 0;
	  loop_cnt_b      <= #1 0;
       end
     else if (no_update)       ;  
     else if (inst_id[`LOOP])
       begin
	  loop_start_pc <= #1 pc + {11'h0, ir[17:15]};
	  loop_end_pc   <= #1 pc + { 9'h0, ir[14:10]};
	  loop_invoked  <= #1 1;
	  if (ir[20:18] == 3'h7)
	    loop_cnt      <= #1 ir[9:0];
	  else
	    loop_cnt      <= #1 RA;
       end
     else 
       begin
	  if (loop_cnt_dec)
	    loop_cnt <= #1 loop_cnt -1;
	  else if (ld_en1_Rother[5:4] == 2'b11)  // in load and loadi, should be carefull
	    loop_cnt <= #1 late_regs_load;
	  else if (pop_en[8])                    // avoid pushpop at loop boundry!!!!
	    loop_cnt <= #1 loop_cnt_b;
	  
	  if (ld_en1_Rother[13:12] == 2'b11)  // must ensure not in loop boundry while loading 
	    loop_invoked <= #1     late_regs_load[1];  
	  else if (loop_goto_post_end_pc) 
	    loop_invoked  <= #1 0;
	  else if (pop_en[8])                    // avoid pushpop at loop boundry!!!!
	    loop_invoked  <= #1 loop_invoked_b;
	  
	  if (ld_en1_Rother[3:2] == 2'b11)  // in load and loadi, should be carefull
	    loop_end_pc <= #1 late_regs_load;
	  else if (pop_en[8])                    // avoid pushpop at loop boundry!!!!
	    loop_end_pc <= #1 loop_end_pc_b;
	  
	  if (ld_en1_Rother[1:0] == 2'b11)  // in load and loadi, should be carefull
	    loop_start_pc <= #1 late_regs_load;
	  else if (pop_en[8])                    // avoid pushpop at loop boundry!!!!
	    loop_start_pc <= #1 loop_start_pc_b;
	  
	  if (push_en[8])  // avoid pushpop at loop boundry!!!!
            begin
	       loop_start_pc_b <= #1 loop_start_pc;
	       loop_end_pc_b   <= #1 loop_end_pc;
	       loop_invoked_b  <= #1 loop_invoked;
	       loop_cnt_b      <= #1 loop_cnt;
	    end
       end
   
  
   assign pc_eq_loop_end   = (pc == loop_end_pc);
   assign loop_cnt_gr_zero = (loop_cnt > 1);
   
   // used to select loop_start in early pc mux and ...
   assign loop_goto_start_pc    = (
				   ( pc_eq_loop_end && loop_cnt_gr_zero && loop_invoked ) && 
				   !(search_stop && inst_id[`LIN_SEARCH])  &&  
				   !(inst_id[`WAIT_STORE] && end_cond) && 
				   !(inst_id[`WAIT_LOAD] && end_cond) &&
				   !(wait_via_branch && cond_bit) &&
				   !(`ALL_EXT_BUS_CMD  && !scs16_ext_bus_done )
				   );

   // used to advance the loop cnt
   assign loop_cnt_dec = ( pc_eq_loop_end &&  loop_cnt_gr_zero && loop_invoked ) &&
	  ( 
	    (inst_id[`WAIT_STORE] || inst_id[`WAIT_LOAD])  ? ext_cond : 
	    wait_via_branch ? !cond_bit :
	    `ALL_EXT_BUS_CMD ? scs16_ext_bus_done :
	    1'b1
	    );
   
   // used to clear the loop_invoked
   assign loop_goto_post_end_pc = (pc_eq_loop_end && !loop_cnt_gr_zero && loop_invoked) &&
	  (
	   inst_id[`LIN_SEARCH] ? search_stop : 
	   (inst_id[`WAIT_STORE] || inst_id[`WAIT_LOAD]) ? end_cond :
	   wait_via_branch ? !cond_bit :
	   `ALL_EXT_BUS_CMD ? scs16_ext_bus_done :
	   1'b1
	   );
     
   assign early_pc = (
		      ( {14{ inst_id[`BRANCH] && !loop_goto_start_pc }} & {ir[23:21],ir[10:0]}   ) |  // kkk
		      ( {14{ inst_id[`JUMP]   && !ir[16] }}             & {ir[23:21],ir[10:0]}   ) |              // kkk 
		      ( {14{ inst_id[`RETURN] &&  (ir[20:19]==2'b00) }} & sub_return_add    ) | // return from sub
		      ( {14{ inst_id[`RETURN] &&  (ir[20:19]==2'b10) }} & interupt_return   ) | // return from interupt
		      ( {14{ loop_goto_start_pc}} &  loop_start_pc ) |  // this and the next are complementary
		      ( {14{((inst_id[`WAIT_STORE] || inst_id[`WAIT_LOAD]) && !ext_cond)}} & pc) | 
		      ( {14{  `ALL_EXT_BUS_CMD && !loop_goto_start_pc }} & pc) | 
		      (  14'h0 ) |
		      (  14'h0 ) |
		      (  14'h0 )
		      );
 
   assign late_non_pc_inc_dsc = ( // one selects early_pc
				 (inst_id[`BRANCH]  && cond_bit) || // && !ir[16]
				 (inst_id[`JUMP] &&  !ir[16])  ||
				 inst_id[`RETURN] ||	
				 loop_goto_start_pc ||
				 ((inst_id[`WAIT_STORE] || inst_id[`WAIT_LOAD]) && !ext_cond) || // this is new
				 (`ALL_EXT_BUS_CMD && !scs16_ext_bus_done) || 
				 (1'b0)
				 );

   assign pc_inc = ( inst_id[`JUMP] && ir[16] ) ? R5 : 1;
   
   assign Rx_bit_y = RA >> ir[14:11];
   assign ext_cond_branch = condition >> ir[14:11];
   
   
   always @(ir or neg or zero or eq or gr or ls or ovf or t0_done or t1_done or 
	    in_main_level or loop_invoked or search_stop)
     case(ir[14:11])
       15 : flag_bit =  neg;
       14 : flag_bit =  zero;
       13 : flag_bit =  eq;
       12 : flag_bit =  gr;
       11 : flag_bit =  ls;
       10 : flag_bit =  ovf;
       9 :  flag_bit =  eq || gr;
       8 :  flag_bit =  eq || ls;
       7 :  flag_bit =  0;
       6 :  flag_bit =  0;
       5 :  flag_bit =  0;
       4 :  flag_bit =  t0_done; // cnt_0_zero;
       3 :  flag_bit =  t1_done; // cnt_1_zero;
       2 :  flag_bit =  in_main_level;
       1 :  flag_bit =  loop_invoked;
       0 :  flag_bit =  search_stop;
     endcase // case(ir[14:11])

   // assign ext_cond     = condition >> ir[14:11];
   assign ext_cond     = ir[15] ? !ext_cond_branch : ext_cond_branch;


   assign end_cond_pre = {1'b0,condition[14:0]} >> ir[7:4];  // no breakif on c15 !!!
   assign end_cond = ir[9] ? !end_cond_pre : end_cond_pre;
   
   // assign cond_bit = ir[15] ? (ir[17] ? !Rx_bit_y : Rx_bit_y) : (ir[17] ? !ext_cond : ext_cond);
   assign cond = ir[16] ? ( ir[17] ? Rx_bit_y : flag_bit  ) : ext_cond_branch;   
   assign cond_bit = ir[15] ? !cond : cond;

   /////////////////////////////////////////////////////////////////////////////////////////////
   // the following decoder handles the load enable in byte level for the 8 GPR.
   // those enables can still be overridden by pop.
   // separate load and loadi!!!!
   assign ld_en1_Rx_lh = 	( {2{((`ORD_LOAD  ) && !ir[14]) }} & ir[20:19])  | 
				  {  2{((`ORD_STORE)  && !ir[20]) }} |
	  {2{ (inst_id[`MOVE] && !ir[18] )}} |
	  {2{ (inst_id[`LCRLR] && !(ir[20:19]==2'b11)) }} |
	  ({2{ (`ORD_LOADI&& !ir[14] & !ir[20])}} & ir[13:12]) | // new part select in loadia
	  ({2{ (`ORD_LOADI&& !ir[14] &  ir[20])}} & 2'b11    ) | // no part select in loadid
	  {2{ (inst_id[`ALU] && (ir[11:9]!= 3'b011)) }} |	  
	  {2{ (inst_id[`ALUI] && (ir[11:9]!= 3'b011)) }} |
	  {2{ (inst_id[`WAIT_STORE] && !(ir[17:16]==2'b11) && ext_cond ) }} |  // this can be late
	  {2{ (inst_id[`WAIT_LOAD]  &&               (1'b1 && ext_cond) ) }} | // enable load all command time this is new
	  {2{ (inst_id[`EXTINS] && 1'b1)}} |      // extract in extract insert command
 	  {2{ (inst_id[`LIN_SEARCH] && 1'b1) }}   // support load at linear search
	  ;
   
   // first load enable signal - can be overriden 
   assign ld_en1_Rx_index =  (
			      {3{ ( `ORD_LOAD || `ORD_LOADI || `ORD_STORE ||
				    inst_id[`ALU]  || inst_id[`ALUI]  ||
				    inst_id[`MOVE] || inst_id[`LCRLR]) }} & 
			      ir[17:15] ) |
			       ( {3{ inst_id[`WAIT_STORE] }} & ir[20:18]) | 
			       ( {3{ inst_id[`WAIT_LOAD] }} & ir[20:18]) | 
			       ( {3{ (inst_id[`EXTINS] || inst_id[`LIN_SEARCH]) }} & ir[14:12] )
			       ;

   assign      ld_en1_Rx =  {16'h0000,ld_en1_Rx_lh} << {ld_en1_Rx_index,1'b0};
 
   /////////////////////////////////////////////////////////////////////////////////////////////
	       // load enable construction for Rother
   
   assign      ld_en1_Rother_lh = 	{2{( `ORD_LOAD  && ir[14] ) }}  | 
	                                {2{( `ORD_LOADI && ir[14] ) }}  |
	                                {2{( inst_id[`MOVE]  && ir[18] ) }}
	       ;
   // first load enable signal - can be overriden 
   assign      ld_en1_Rother_index =  (`ORD_LOAD || `ORD_LOADI || inst_id[`MOVE]) ?  ir[17:15] : 3'b000;

   assign      ld_en1_Rother =  {16'h0000,ld_en1_Rother_lh} << {ld_en1_Rother_index,1'b0};

   /////////////////////////////////////////////////////////////////////////////////////////////
	       // ram read write signals
   assign      ram_we = (  {2{ (`ORD_STORE || (`ORD_STOREI && !ir[20]) ) }} & ir[10:9]) | 
			  {2{ (`ORD_STOREI && ir[20]) }} |
	       {2{ inst_id[`WAIT_STORE]}} |  // we might write the same data several times
	       {2{ ext_storeiad}}	       
	       ;

   
   assign      ram_rd = (`ORD_LOADI && !ir[20]) || `ORD_LOAD || inst_id[`LIN_SEARCH] ||
	       (inst_id[`WAIT_LOAD]&& (ir[17:16]==2'b10) ) || (inst_id[`LCRLR] && (ir[20:19]==2'b10));
   

   assign      ram_cs = ( |ram_we || ram_rd) && !scs16_ext_bus_cs;
   
   // new code for ram_addr and imd_add_data
   
   assign      r6r7 = ir[8] ? R6 : R7;
   assign      add_from_regs = (`ORD_LOAD  || `ORD_STORE ||
				inst_id[`LCRLR] || inst_id[`LIN_SEARCH] ||
				inst_id[`WAIT_STORE] || inst_id[`WAIT_LOAD] ||
				(`ORD_STOREI && ir[20]));  // storeid
   assign      add_from_imd = ( `ORD_LOADI || `ORD_STOREI )  && !ir[21] && !ir[20] && !ir[19];
   
   assign      add_from_both = ( `ORD_LOADI || `ORD_STOREI ) && !ir[21] && !ir[20] && ir[19];
   
   assign      add_from_long = ( `ORD_LOADI || `ORD_STOREI ) &&  ir[21] && !ir[20] && !ir[19];
   
   always @(add_from_regs or add_from_imd or add_from_both or r6r7 or imd_add_data or R7 or inst_id or ir or add_from_long or ext_storeiad)
     if (ext_storeiad == 0) 
       case({add_from_regs,add_from_imd,add_from_both,add_from_long}) // synopsys full_case
	 4'b0001 : ram_addr = {imd_add_data[11:0],r6r7[11:0]};
	 4'b0010 : ram_addr = {8'h0,(imd_add_data + r6r7)};
	 4'b0100 : ram_addr = {8'h0,imd_add_data};
	 4'b1000 : ram_addr = {8'h0,r6r7};
	 4'b0000 : ram_addr = {8'h0,R7}; // default - to save power
       endcase // case({add_from_regs,add_from_imd,add_from_both})
     else
       ram_addr = {8'h0,4'h0,ir[27:16]}; // in ext_storeiad
   
       
   assign imd_add_data = ( 
			   {16{(`ORD_LOADI && ir[20] )}}  & {ir[19:18],ir[13:0]} | // loadid
			   {16{(`ORD_LOADI && !ir[20])}}  & {4'b0000,ir[18],ir[11:9],ir[7:0]} | // loadia
			   
			   {16{ (`ORD_STOREI && !ir[20]) }} & {4'b0000,ir[18:15],ir[7:0]} | // stoeia
			   {16{ (`ORD_STOREI &&  ir[20]) }} & {  ir[19],ir[17:11],ir[7:0]}	  // storid   
			   );
   
   // end of new code 


   // coding will be R0-7=0, other=1
   assign ram_wr_data_sel = ( {2{( `ORD_STORE || (`ORD_STOREI && !ir[20]) ) }} & {1'b0,ir[11]}) |
 			    ({2{( `ORD_STOREI && ir[20]) }}  & {2'b11}) |
			     {2{ inst_id[`WAIT_STORE]}} & {2'b10} // in wait_store, code 2, writing RA
			    ;

   
   always @(ram_wr_data_sel or RB or RA or Rother or imd_add_data or inst_id or ir or ext_storeiad )
     if (ext_storeiad == 0) 
       case(ram_wr_data_sel) // synopsys full_case
	 0 : ram_wr_data = RB;
	 1 : ram_wr_data = Rother;
	 2 : ram_wr_data = RA;  // in wait store     
	 3 : ram_wr_data = imd_add_data;
       endcase // case(ram_wr_data_sel)
     else
       ram_wr_data = ir[15:0];

       
 
   
   assign     RB_sel = ir[14:12];
   always @(RB_sel or R0 or R1 or R2 or R3 or R4 or R5 or R6 or R7)
     case(RB_sel)
       0 : RB = R0;
       1 : RB = R1;
       2 : RB = R2;
       3 : RB = R3;
       4 : RB = R4;
       5 : RB = R5;
       6 : RB = R6;
       7 : RB = R7;
     endcase // case(RB_sel)
   
   assign     RA_sel = ir[20:18];
   always @(RA_sel or R0 or R1 or R2 or R3 or R4 or R5 or R6 or R7)
     case(RA_sel)
       0 : RA = R0;
       1 : RA = R1;
       2 : RA = R2;
       3 : RA = R3;
       4 : RA = R4;
       5 : RA = R5;
       6 : RA = R6;
       7 : RA = R7;
     endcase // case(RA_sel)
   
   // need to be revised
   always @(RB_sel or loop_start_pc or loop_end_pc or loop_cnt or pc or device or eq or gr or 
	    ls or ovf or zero or neg or in_main_level or loop_invoked or search_stop or 
	    sub_return_add or counter0 or counter1)
     // part source_reg for store, storeia, mode
     case(RB_sel) // effective when ir[11]==1
       0 : Rother = {2'h0,loop_start_pc};
       1 : Rother = {2'h0,loop_end_pc};
       2 : Rother = {6'h0,loop_cnt};
       3 : Rother = {2'h0,sub_return_add};
       4 : Rother = 16'h0; // should be counter or crc
       5 : Rother = device;
       // 6 : Rother = {9'h0,eq,gr,ls,ovf,zero,neg, search_stop};
       //            15  14   13 12 11 10         2             1             0
       6 : Rother = {neg,zero,eq,gr,ls,ovf, 7'h0, in_main_level,loop_invoked, search_stop};
       7 : Rother = {2'h0,pc};
     endcase
   
   ///////////////////////////////////////////////////////////////////////////
   //  north mux    

   always @(inst_id or ir or S0 or S1 or imd_add_data or RB or RA or Rother )
     case({inst_id[`EXTINS],inst_id[`LCRLR],`ORD_LOADI,inst_id[`MOVE],
	   `ORD_STORE,(inst_id[`WAIT_STORE] || inst_id[`WAIT_LOAD]) })
       6'b100000 : early_regs_load = RA; // sould be removed soon
       6'b010000 : case (ir[19]) // synopsys full_case
		    // LCRLR
		 0 :  early_regs_load = S0;
		 1 :  early_regs_load = S1; 
		 endcase // case(ir[19])             
       6'b001000 : early_regs_load =  {ir[19:18],ir[13:0]};
       // LOADI
       6'b000100 : case (ir[20:19]) // synopsys full_case
		    // MOVE
		 0 :  early_regs_load = S0;
		 1 :  early_regs_load = S1;
		 3 :  begin
		    if (ir[10])
		      early_regs_load = 0; // crc;
		    else if (ir[11])
		      early_regs_load = Rother;
		    else
		      early_regs_load = RB;
		 end
	       endcase // case(ir[20:19])
       6'b000010 : case (ir[20:19]) // synopsys full_case
		    // STORE
		 0 :  early_regs_load = S0;
		 1 :  early_regs_load = S1;
		 3 :  early_regs_load = RB;
	       endcase // case(ir[20:19])
       6'b000001 : case (ir[17:16]) // synopsys full_case
		    // WAIT STORE
		 0 :  early_regs_load = S0;
		 1 :  early_regs_load = S1;
		  endcase       
       default : early_regs_load = S0;
     endcase // case({inst_id[`LCRLR],`ORD_LOADI,inst_id[`MOVE],`ORD_STORE,inst_id[`WAIT_STORE]})
   
      
   assign early_late_regs_load = (inst_id[`ALU] || inst_id[`ALUI] || (inst_id[`EXTINS] && ir[8])) ? 
				 alu_out : (inst_id[`EXTINS] && !ir[8]) ? 
				 ((insert_load_en & alu_out) | (~insert_load_en & RB)) : early_regs_load;
   

   //assign late_regs_load = ((`ORD_LOADI && ir[20]) || `ORD_LOAD) ? early_late_regs_load : ram_rd_data;
   assign late_regs_load = ram_rd ? ram_rd_data : early_late_regs_load;

   /////////////////////////////////////////////////////////////////////////////////////////////
   // alu staff
   //
   reg  [16:0] alu_addsub;
   wire [15:0] RAA, RBB, RAAA, RBBB, RA_;
   wire [15:0] left_mask;
   wire [15:0] right_mask;
   wire [15:0] word_mask;
   wire [15:0] insert_imd;   

   assign      RA_ = inst_id[`ALUI] ? RB : RA;
   
   assign      insert_imd =  {11'h0,ir[20:16]};
   
   assign      RAAA = (inst_id[`ALUI] &&  ir[8]) ? { {8{ir[18]}}, ir[7:0] } : 
	       ( (inst_id[`EXTINS] && !ir[8] && ir[15]) ? insert_imd : RA_);
   assign      RBBB = (inst_id[`ALUI] && !ir[8]) ? { {8{ir[18]}}, ir[7:0] } : RB;
   
   assign      RAA = (inst_id[`EXTINS] && !ir[8]) ? RAAA : (RAAA & word_mask);
   assign      RBB = RBBB & word_mask;
   
   always @(RAA or RBB or ir or alu_addsub or inst_id) // need to consider power saving
     case(ir[11:9])
       0 : alu_out = {1'b0, (RAA & RBB)};
       1 : alu_out = {1'b0, (RAA | RBB)};
       2 : alu_out = {1'b0, (RAA ^ RBB)};
       4 : alu_out = alu_addsub;                  // {RAA[15],RAA} + {RBB[15],RBB};
       5 : alu_out = alu_addsub;                  // {RAA[15],RAA} - {RBB[15],RBB};
       6 : alu_out = {17'h0,RAA} >> ((inst_id[`EXTINS] &&  ir[8]) ? ir[3:0] : RBB[3:0]);     // shift is geometric
       7 : alu_out = {17'h0,RAA} << ((inst_id[`EXTINS] && !ir[8]) ? ir[3:0] : RBB[3:0]);     // shift is geometric
       3 : alu_out = {1'b0, (RAA | RBB)};         // some default
     endcase // case(ir[11:9])

   
   // need to consider resource sharing   
   always @(posedge clk `ASYNC_RST)
     if (rst)
       begin
	  search_stop   <= #1 0;
	  search_stop_b <= #1 0;
	  {eq,gr,ls,ovf,zero,neg}             <= #1 6'b000000;
	  {eq_b,gr_b,ls_b,ovf_b,zero_b,neg_b} <= #1 6'b000000;
       end
     else if (no_update)       ;  
     else if (ld_en1_Rother[13:12] == 2'b11)  // in load and loadi
       //            15  14   13 12 11 10         2             1             0
       //  Rother = {neg,zero,eq,gr,ls,ovf, 7'h0, in_main_level,loop_invoked, search_stop};       
       {eq,gr,ls,ovf,zero,neg, search_stop} <= #1 {late_regs_load[15:10],late_regs_load[0]};  
     else if (inst_id[`ALU] | inst_id[`ALUI] )
       begin
	  if (ir[11:9] == 3'b011)  // compare command
	    begin 
	       eq <= #1 !(|alu_addsub);                      // RAA == RBB;
	       gr <= #1 (|alu_addsub) && (!alu_addsub[16]);  // RAA >  RBB;
	       ls <= #1 (|alu_addsub) &&   alu_addsub[16];   // RAA <  RBB;
	    end
	  else if ((ir[11:9] == 3'b100) || (ir[11:9] == 3'b101)) // add or substruct
	    begin
	       ovf <= #1 alu_addsub[16] ^ alu_addsub[15];
	       neg <= #1 alu_addsub[16];
	       zero<= #1 !(|alu_addsub);
	    end
       end // if (inst_id[`ALU] | inst_id[`ALUI] )
     else if ( inst_id[`LIN_SEARCH] )
       case(ir[11:9])
	 1 : begin
	    if (!search_stop)
	      search_stop <= #1 !(|alu_addsub);  // ==
	    eq          <= #1 !(|alu_addsub);  // ==	    
	 end
	 2 : begin
	    if (!search_stop)
	      search_stop <= #1 (|alu_addsub) && (!alu_addsub[16]);  // >
	    gr          <= #1 (|alu_addsub) && (!alu_addsub[16]);  // >
	 end
	 3 : begin
	    if (!search_stop)
	      search_stop <= #1 (|alu_addsub) && ( alu_addsub[16]);  // <
	    ls          <= #1 (|alu_addsub) && ( alu_addsub[16]);  // <
	 end
       endcase // case(ir[11:9])
     else if (pop_en[13])
       begin
	  {eq,gr,ls,ovf,zero,neg, search_stop} <= #1 {eq_b,gr_b,ls_b,ovf_b,zero_b,neg_b, search_stop_b};
       end
     else if (push_en[13])
       begin
	  {eq_b,gr_b,ls_b,ovf_b,zero_b,neg_b, search_stop_b} <= #1 {eq,gr,ls,ovf,zero,neg, search_stop};
       end

      
   always @(RAA or RBB or ir or inst_id) // need to consider power saving
     case(ir[11:9])
       4 : alu_addsub        = {RAA[15],RAA} + {RBB[15],RBB}; // add
       5 : alu_addsub        = {RAA[15],RAA} - {RBB[15],RBB}; // substruct
       default :  alu_addsub = (inst_id[`ALU] && ir[8]) ? // suporting also lin search
			       ({RAA[15],RAA} + {RBB[15],RBB}) : ({RAA[15],RAA} - {RBB[15],RBB}); // to calculate cmp flags
     endcase // case(ir[11:9])
      
   /////////////////////////////////////////////////////////////////////////////////////////////
       // Linear Search logic

   assign      left_mask  = 32'h0000ffff >> ((inst_id[`LIN_SEARCH] || (inst_id[`EXTINS] ))  ? ir[7:4] : 4'h0);
   assign      right_mask = 32'h0000ffff << ((inst_id[`LIN_SEARCH] || (inst_id[`EXTINS] ))  ? ir[3:0] : 4'h0);

   assign      word_mask = left_mask & right_mask;
     
   /////////////////////////////////////////////////////////////////////////////////////////////
       // pushpop logic
   
   assign      push_en = {14{(inst_id[`PUSHPOP] && !ir[20])}} & ir[13:0];
   assign      pop_en  = {14{(inst_id[`PUSHPOP] &&  ir[20])}} & ir[13:0];
   
   /////////////////////////////////////////////////////////////////////////////////////////////
      // register file
   always @(posedge clk `ASYNC_RST)	
     if (rst)
       begin
	  R0 <= #1 0;
	  R1 <= #1 0;
	  R2 <= #1 0;
	  R3 <= #1 0;
	  R4 <= #1 0;
	  R5 <= #1 0;
	  R6 <= #1 0;
	  R7 <= #1 0;
	  R0_b <= #1 0;
	  R1_b <= #1 0;
	  R2_b <= #1 0;
	  R3_b <= #1 0;
	  R4_b <= #1 0;
	  R5_b <= #1 0;
	  R6_b <= #1 0;
	  R7_b <= #1 0;
       end // if (rst)
     else if (no_update)       ;  
     else
       begin
	  // R0
	  if (inst_id[`FIFO])
	    R0[7:0] <= #1 next_R0[7:0];
	  else if (ld_en1_Rx[0])
	    R0[7:0] <= #1 late_regs_load[7:0];
	  else if (pop_en[0])
	    R0[7:0] <= #1 R0_b[7:0];
	    
	  if (inst_id[`FIFO])
	    R0[15:8] <= #1 next_R0[15:8];
	  else if (ld_en1_Rx[1])
	    R0[15:8] <= #1 late_regs_load[15:8];
	  else if (pop_en[0])
	    R0[15:8] <= #1 R0_b[15:8];

	  if (push_en[0])
	    R0_b <= #1 R0;
	  

	  // R1
	  if (inst_id[`FIFO])
	    R1[7:0] <= #1 next_R1[7:0];
	  else if (ld_en1_Rx[2])
	    R1[7:0] <= #1 late_regs_load[7:0];
	  else if (pop_en[1])
	    R1[7:0] <= #1 R1_b[7:0];

	  if (inst_id[`FIFO])
	    R1[15:8] <= #1 next_R1[15:8];
	  else if (ld_en1_Rx[3])
	    R1[15:8] <= #1 late_regs_load[15:8];
	  else if (pop_en[1])
	    R1[15:8] <= #1 R1_b[15:8];
	  
	  if (push_en[1])
	    R1_b <= #1 R1;
	  
	  // R2
	  if (ld_en1_Rx[4])
	    R2[7:0] <= #1 late_regs_load[7:0];
	  else if (pop_en[2])
	    R2[7:0] <= #1 R2_b[7:0];

	  if (ld_en1_Rx[5])
	    R2[15:8] <= #1 late_regs_load[15:8];
	  else if (pop_en[2])
	    R2[15:8] <= #1  R2_b[15:8];
	
	  if (push_en[2])
	    R2_b <= #1 R2;
  
	  // R3
	  
	  if (inst_id[`MATH])  // optional
	    begin
	       if (div_capture)
		 R3  <= #1 Div_out_result[15:0];
	       else if (ir[19])  // multiply command 	
		 R3  <= #1 M_out[15:0];
	       else if (ir[16])  // add command 	
		 R3  <= #1 A_out[15:0];
	    end
	  else 
	    begin
	       if (ld_en1_Rx[6])
		 R3[7:0] <= #1 late_regs_load[7:0];
	       else if (pop_en[3])
		 R3[7:0] <= #1 R3_b[7:0];
	       
	       if (ld_en1_Rx[7])
		 R3[15:8] <= #1 late_regs_load[15:8];
	       else if (pop_en[3])
		 R3[15:8] <= #1 R3_b[15:8];
	       
 	       if (push_en[3])
		 R3_b <= #1 R3;
	    end
 
	  // R4
	  if (inst_id[`MATH])   // optional
	    begin
	       if (div_capture)
		 R4  <= #1 Div_out_result[31:16]; 
	       else if (ir[19])  // multiply command 	
		 R4  <= #1 M_out[23:16];
	       else if (ir[16])  // add command 	
		 R4  <= #1 A_out[31:16];
	    end
	  else
	    begin
	       if (ld_en1_Rx[8])
		 R4[7:0] <= #1 late_regs_load[7:0];
	       else if (pop_en[4])
		 R4[7:0] <= #1 R4_b[7:0];
	       
	       if (ld_en1_Rx[9])
		 R4[15:8] <= #1 late_regs_load[15:8];
	       else if (pop_en[4])
		 R4[15:8] <= #1  R4_b[15:8];
	       
	       if (push_en[4])
		 R4_b <= #1 R4;
	    end

	  // R5
	  if (ld_en1_Rx[10])
	    R5[7:0] <= #1 late_regs_load[7:0];
	  else if (pop_en[5])
	    R5[7:0] <= #1 R5_b[7:0];
    
	  if (ld_en1_Rx[11])
	    R5[15:8] <= #1 late_regs_load[15:8];
	  else if (pop_en[5])
	    R5[15:8] <= #1 R5_b[15:8];

	  if (push_en[5])
	    R5_b <= #1 R5;
	  
	  // R6
	  if (next_ram_addr_ld_en[0])
	    R6[7:0] <= #1 next_ram_addr[7:0];	  
	  else if (ld_en1_Rx[12])
	    R6[7:0] <= #1 late_regs_load[7:0];
	  else if (pop_en[6])
	    R6[7:0] <= #1 R6_b[7:0];
	    	  
	  if (next_ram_addr_ld_en[0])
	    R6[15:8] <= #1 next_ram_addr[15:8];
	  else if (ld_en1_Rx[13])
	    R6[15:8] <= #1 late_regs_load[15:8];
	  else if (pop_en[6])
	    R6[15:8] <= #1 R6_b[15:8];

 	  if (push_en[6])
	    R6_b <= #1 R6;
 
	  // R7
	  if (next_ram_addr_ld_en[1])
	    R7[7:0] <= #1 next_ram_addr[7:0];	  
	  else if (ld_en1_Rx[14])
	    R7[7:0] <= #1 late_regs_load[7:0];
	  else if (pop_en[7])
	    R7[7:0] <= #1   R7_b[7:0];
	  
	  if (next_ram_addr_ld_en[1])
	    R7[15:8] <= #1 next_ram_addr[15:8];
	  else if (ld_en1_Rx[15])
	    R7[15:8] <= #1 late_regs_load[15:8];
	  else if (pop_en[7])
	    R7[15:8] <= #1 R7_b[15:8];
	  
	  if (push_en[7])
	    R7_b <= #1 R7;
  
       end	  
	  
   /////////////////////////////////////////////////////////////////////////////////////////////
   // address increamentor logic
   // also need to consider the wait load and wait store
   wire trivial_inc_add_commands;   
   assign trivial_inc_add_commands = ( inst_id[`LCRLR] || `ORD_LOAD || 
				  `ORD_STORE || `ORD_STOREI) ;
   
   always @(inst_id or ir or ram_addr or R5 or trivial_inc_add_commands or search_stop)
     casex({inst_id[`WAIT_LOAD],inst_id[`WAIT_STORE],trivial_inc_add_commands, inst_id[`LIN_SEARCH], ir[18]}) // synopsys full_case
       5'b1000x : next_ram_addr = ram_addr+1;
       5'b0100x : next_ram_addr = ram_addr+1;
       5'b00101 : next_ram_addr = ram_addr+1;
       5'b0001x : // linear search
	 if (search_stop)  // be carefull here
 	   // next_ram_addr = ram_addr - ( ((ir[17:15] == 3'h7) ? 1 : R5) << 1) ;
 	   next_ram_addr = ram_addr - (( ir[15] ? R5 : 1) << 1) ;
	 else
	   // only R5 or 1 for linear search step
	   // next_ram_addr = ram_addr + ((ir[17:15] == 3'h7) ? 1 : R5); 
	   next_ram_addr = ram_addr + (ir[15] ? R5 : 1) ;
       5'b00000 : next_ram_addr = ram_addr;
     endcase // casex({trivial_inc_add_commands, inst_id[`LIN_SEARCH], ir[18]})
   
   
   // two bits supporting load enable to R6 and R7
   assign     next_ram_addr_ld_en = ( 
				      {2{
					 (((
					    (((inst_id[`LOAD]   && ir_ext_bus) && scs16_ext_bus_done)  || inst_id[`LOAD])  || 
					    (((inst_id[`STORE]  && ir_ext_bus) && scs16_ext_bus_done) || inst_id[`STORE]) || 
					    inst_id[`LCRLR] || 
					    ((((inst_id[`STOREI]  && ir_ext_bus) && scs16_ext_bus_done) || inst_id[`STOREI]) && ir[20])
					    )  && ir[18] ) ||   // the inc address bit
					  inst_id[`LIN_SEARCH] ||
					  (inst_id[`WAIT_LOAD]  &&  ext_cond ) || // to inc add when valid
					  (inst_id[`WAIT_STORE] &&  ext_cond ) // to inc add when valid
					  )
					 }} & {2'b10 >> ir[8]}  
				      );
   
   // Pulse
   /////////////////////////////////////////////////////////////////////////////////////////////
   wire pulse_en; // should incorporate all command enabler including the burst commands
   assign 		pulse_en=(`ORD_STORE || `ORD_LOAD || 
				  (inst_id[`WAIT_STORE]) || //  &&  ext_cond ) ||  // to ack a valid stroke 
				  (inst_id[`WAIT_LOAD]) ||  // to valid the data
				  inst_id[`LCRLR] || inst_id[`DEST] || inst_id[`MOVE]);  	
   // The pulse register
   always @(posedge clk `ASYNC_RST)			
     if (rst)
       pulse <= #1 15'h0000;
     else if (no_update)       ;  
     else
   	begin
   	if (pulse_en)
   		pulse <= #1 15'h0001<<ir[3:0];
   	else
   		pulse <= #1 15'h0000;
	end
 

   ///////////////////////////////////////////////////////////////////////////////////////////// 
   // device
   wire [15:0] device_ld_en;
   wire [15:0] device_next_data;
   
   assign      device_ld_en = ( {16{inst_id[`LCRLR]}} & ((ir[14:11] | ir[7:4]) << ({ir[10:9],2'b00})) ) |
				( {8{ld_en1_Rother[11:10]}} ) |
				  ( 16'h0 );
   assign      device_next_data = inst_id[`LCRLR] ? {4{ir[14:11]}} : late_regs_load;
 
   always @(posedge clk `ASYNC_RST)
     if (rst)
       begin
	  device <= #1 0;
	  device_b <= #1 0;
       end
     else if (no_update)       ;  
     else
       begin
	  if ( pop_en[12] )
	    device <= #1    device_b;
	  else
	    device <= #1    (device_ld_en & device_next_data) | (~device_ld_en & device);
	  if ( push_en[12] )	
	    device_b <= #1 device;
       end		     
   
   ///////////////////////////////////////////////////////////////////////////////////////////// 
   // extract insert - insert section

   assign      insert_load_en = word_mask;
   
   ///////////////////////////////////////////////////////////////////////////////////////////// 
   // fifo command
   // assumptions :
   // R0 [empty[15],full[14],max_size-m[13:7],current_size-l[6:0]]
   // R1 [relative read/write address]
   // fifo_wr ir[20] = 1, fifo_rd ir[20] = 0   
   assign      fifo_e = R0[14];
   assign      fifo_f = R0[15];
   assign      fifo_m = R0[13:7];
   assign      fifo_l = R0[6:0];
   assign      fifo_wr = ir[20];
   assign      fifo_wa = R1[6:0];
   assign      fifo_ra = R1[6:0];

   // the following should work with true fifo size - 1
   assign      wrap_arround = (fifo_wa == (fifo_m));
   assign      next_fifo_rel_add = wrap_arround ? 0 : (fifo_wa + 1);
   assign      next_fifo_l =  fifo_wr ?  (fifo_l + 1) : (fifo_l - 1) ;
   assign      next_fifo_f =  fifo_wr ?  (fifo_l == (fifo_m)) : 0;
   assign      next_fifo_e =  fifo_wr ?  0 : (fifo_l == 1);

   assign      next_R0 = {next_fifo_f,next_fifo_e,fifo_m,next_fifo_l};
   assign      next_R1 = {9'h0,next_fifo_rel_add};

   ///////////////////////////////////////////////////////////////////////////////////////////// 
   // timers section

   assign 	timer_load_data = t0_ls ? { 7'h0, ir[8:0]} : RA;
  
   assign 	t0_ls =  ir[17]; 
   assign 	t0_count_source2 = (t0_es ? pulse : condition) >> t0_cb;
   assign 	t0_count_source1 =  t0_pl ? !t0_count_source2 : t0_count_source2;
   assign 	t0_count_source1_der =  t0_count_source1 && !t0_count_source1_prev;
   assign 	t0_count             = t0_der ? t0_count_source1_der : t0_count_source1;

   assign 	t1_ls =  ir[17]; 
   assign 	t1_count_source2 = (t1_es ? pulse : condition) >> t1_cb;
   assign 	t1_count_source1 =  t1_pl ? !t1_count_source2 : t1_count_source2;
   assign 	t1_count_source1_der =  t1_count_source1 && !t1_count_source1_prev;
   assign 	t1_count             = t1_der ? t1_count_source1_der : t1_count_source1;
   
   
   
   always @(posedge clk `ASYNC_RST)
     if (rst)
       begin
	  t0_pl <= #1 0;
	  t0_der<= #1 0;
	  t0_es <= #1 0;
	  t0_cb <= #1 0;
	  timer0 <= #1 0;	
	  t0_count_source1_prev <= #1 0;	  
	  t0_done <= #1 0;
       end
     else if (no_update)       ;  
     else
       begin
	  t0_count_source1_prev <= #1 t0_count_source1;   
	  if (inst_id[`TIMER] && !ir[9])
	    begin	    
	       t0_pl <= #1 ir[15];
	       t0_der<= #1 ir[16];
	       t0_es <= #1 ir[10];
	       t0_cb <= #1 ir[14:11];
	       timer0 <= #1 timer_load_data;
	       t0_done <= #1 0;
	    end
	  else
	    if (t0_count)
	      begin
		 if (timer0 >= 1)
		   timer0 <= #1 timer0 -1;
		 if (timer0 <= 1)
		   t0_done <= #1 1;
	      end
       end
    
   always @(posedge clk `ASYNC_RST)
     if (rst)
       begin
	  t1_pl <= #1 0;
	  t1_der<= #1 0;
	  t1_es <= #1 0;
	  t1_cb <= #1 0;
	  timer1 <= #1 0;	
	  t1_count_source1_prev <= #1 0;
	  t1_done <= #1 0;	  
       end
     else if (no_update)       ;  
     else
       begin
	  t1_count_source1_prev <= #1 t1_count_source1;   
	  if (inst_id[`TIMER] && ir[9])
	    begin	    
	       t1_pl <= #1 ir[15];
	       t1_der<= #1 ir[16];
	       t1_es <= #1 ir[10];
	       t1_cb <= #1 ir[14:11];
	       timer1 <= #1 timer_load_data;
	       t1_done <= #1 0;
	    end
	  else
	    if (t1_count)
	      begin
		 if (timer1 >= 1)
		   timer1 <= #1 timer1 -1;
		 if (timer1 <= 1)
		   t1_done <= #1 1;
	      end
       end
    

   ///////////////////////////////////////////////////////////////////////////////////////////// 
   // optional math specific command

   
   assign      div_start   =  inst_id[`MATH] && ir[20] && !ir[18];
   assign      div_capture =  inst_id[`MATH] && ir[20] &&  ir[18];
   assign      Div_out_result = 0;
   assign      A_out = 0;
   assign      M_out = 0;
   
   
   /////////////////////////////////////////////////////////////////////////////////////////////
   //  ocp master cs
   wire        ocp_rd;
   wire [1:0]  ocp_we;
   
   assign      ocp_we = (  {2{ ((inst_id[`STORE]  && ir_ext_bus) || ((inst_id[`STOREI]  && ir_ext_bus) && !ir[20]) ) }} & ir[10:9]) | 
			  {2{ ((inst_id[`STOREI]  && ir_ext_bus) && ir[20]) }} |
	       {2{ ext_storeiad}} 
	       ;

   
   assign      ocp_rd = ((inst_id[`LOADI]   && ir_ext_bus) && !ir[20]) || (inst_id[`LOAD]   && ir_ext_bus);

   assign      scs16_ext_bus_cs = ( |ocp_we || ocp_rd) ;

   /////////////////////////////////////////////////////////////////////////////////////////////
   //  debug bus

   assign      debug_bus = {12'h0, t1_done_before_wait, t0_done_before_wait, t1_done, t0_done};
   
   /////////////////////////////////////////////////////////////////////////////////////////////
   //  interupt on timer expiration before branch (wait t0_done)
   
   always @(posedge clk `ASYNC_RST)
     if (rst)
       begin
          t0_done_before_wait <= #1 0;
          t1_done_before_wait <= #1 0;
          t0_done_before_wait_state <= #1 0;
          t1_done_before_wait_state <= #1 0;
       end
     else if (no_update)
       ;  
     else
       begin
          if (inst_id[`TIMER] && !ir[9])
            begin
               t0_done_before_wait_state <= #1 0;
               t0_done_before_wait <= #1 0;
            end   
          else if  (inst_id[`BRANCH] && (ir[10:0] == pc) && ! ir[17] && ir[16] && ir[15] && (ir[14:11] == 4))
            if (!t0_done_before_wait_state)
              begin
		 t0_done_before_wait_state <= #1 1;
		 if (t0_done)
                   t0_done_before_wait <= #1 1;
              end

          if (inst_id[`TIMER] && ir[9])
            begin
               t1_done_before_wait_state <= #1 0;
               t1_done_before_wait <= #1 0;
            end   
          else if  (inst_id[`BRANCH] && (ir[10:0] == pc) && ! ir[17] && ir[16] && ir[15] && (ir[14:11] == 3))
            if (!t1_done_before_wait_state)
              begin
		 t1_done_before_wait_state <= #1 1;
		 if (t1_done)
                   t1_done_before_wait <= #1 1;
              end
	  
       end // else: !if(rst)
   
   
   assign wait_via_branch = inst_id[`BRANCH] && (ir[10:0] == pc);
   
   // based on the inputs : 		 step, continue, bkpt
   // and internal signal cmd_boundery 
   // we are going to formulate the no_update signal with the aid of some state variable


   assign cmd_boundery  = // part of the equation of loop_cnt_dec
	  (inst_id[`WAIT_STORE] || inst_id[`WAIT_LOAD])  ? ext_cond : 
	   wait_via_branch ? (!cond_bit || interupt_sel):
	  `ALL_EXT_BUS_CMD ? scs16_ext_bus_done :
	  1'b1;

   reg 	  first_in_halt;
   
   assign no_update = ((debug_state == 2) && !step); // !cmd_boundery; //  && (debug_state == 2);
   assign no_update_pcir = ((debug_state != 2) && !cmd_boundery) || ((debug_state == 2) && !step);
   
   assign scs16_iram_cs = !no_update_pcir;
   
   always @(posedge clk `ASYNC_RST)
     if (rst)
       begin
	  debug_state <= #1 0;
	  first_in_halt <= #1 0;
       end
     else 
       case (debug_state)
	 0 : // IDLE
	   if (bkpt && cmd_boundery) 
	     begin
		debug_state <= #1 2;
		first_in_halt <= #1 1;
	     end
	   else if (bkpt)
	     debug_state <= #1 1;
	 1 : // WAIT for command boundery
	   if (cmd_boundery)  
             begin
		debug_state <= #1 2;
		first_in_halt <= #1 1;
	     end
	 2 : // HALT
	   if (step && cmd_boundery)
	     begin
       		debug_state <= #1 2;  // stay here
		first_in_halt <= #1 1;
	     end
	   else if (step)
	     debug_state <= #1 1;
	   else if (cont)
	     debug_state <= #1 0;
	   else
	     first_in_halt <= #1 0;
	     
       endcase // case(debug_state)
   
   
   // synopsys translate_off
   
`include "fsniffer_flat.v"
   
   // synopsys translate_on
   
endmodule
