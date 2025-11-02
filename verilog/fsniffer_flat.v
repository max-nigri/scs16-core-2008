   // debug facility !!!! not for synthesis
   
   // reg [25:0]  ir;
   reg [8*15:0] msg;
   reg [8*15:0] space;
   reg [8*60:0] space_x;
   reg [(8*100)-1:0] full_file_name;

   integer 	     script_select,fh;

   // reg [8*60:0] display_ram [0:2047];
   reg [8*90-1:0] display_ram [0:2047];
   reg [15:0] ref_ram [63:0];



   initial
     begin
	fh = $fopen("scs16_log");
	
	// full_file_name = "/link_to_mcode_xdisplay_hex.v";

	// $readmemh (full_file_name, display_ram);
     end // initial begin
   



   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   // a better way without compilation, for displaying command on the screen
   always @(negedge clk)
     begin
     if (SCS16_VERBOSE == 1) begin
	 #1 $display("pc = %d : %s",  pc, display_ram[ pc]);
	 #1 $fdisplay(fh,"pc = %d : %s",  pc, display_ram[ pc]);
      end
      end

   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////

   // Display command name - the message for the wave
   // always @(posedge clk)
   //   ir <= #1 next_inst;
   always @(ir)
     if ((ir[28] == 1) && 0)
       msg="OCP_STOREIAD"; 
     else	
        case (ir[31:27])
	  0: msg="NOP";		
	  1: msg="WAIT_LOAD";
	  2: msg="LCRLR";	
	  3: msg= ir_ext_bus ? "EXT_LOAD"  : "LOAD"; 		
	  4: msg= ir_ext_bus ? "EXT_STORE" : "STORE"; 		
	  5: msg="WAIT_MOVE";	
	  6: msg="MOVE";		
	  7: msg = ir_ext_bus ? (ir[20] ?  "EXT_LOADID" : "EXT_LOADIA") : (ir[20] ?  "LOADID" : "LOADIA");	  
	  8: msg="WAIT_STORE";
	  9: msg= (ir[20:18]==7) ? "LOOP IMD" : "LOOP Rx";		
	  10: msg="ALU";		
	  11: msg="PULSE";
 	  12: msg="TIMER";	
 	  13: msg= ir[20] ? "GOSUB" : ir[16]? "GOTO R5" : "GOTO IMD";	
	  14: msg= (ir[20:19] == 2'b00) ? "RETURN" : "RTI";	  
	  15: msg= ir_ext_bus ? (ir[20] ?  "EXT_STOREID" : "EXT_STOREIA") : (ir[20] ?  "STOREID" : "STOREIA"); 		
	  16: msg= !ir[16] ?  "BRANCH Cx" : ir[17] ?  "BRANCH Rxy" : "BRANCH Flg" ;
	  17: msg="ALUI";
	  18: msg= ir[20] ? "POP" : "PUSH";		
	  19: msg= ir[8] ? "EXTRACT" : ir[15] ? "INSERTI" : "INSERTR";
	  20: msg="CRC";
	  21: msg= ir[20] ? "FIFO_WR" : "FIFO_RD";
	  
	  24: msg= ir[20] ? "DIV" : "MULTADD";
	  25: msg="OCP_STORE"; 		
	  26: msg= ir[20] ?  "OCP_STOREID" : "OCP_STOREIA"; 
	  28: msg="OCP_STOREIAD"; 		
	  29: msg="OCP_LOAD"; 				
	  30: msg = ir[20] ?  "OCP_LOADID" : "OCP_LOADIA";
	  
	  31: msg="LIN_SEARCH";	
	  default: msg="UNKNOWN";	
        endcase	
   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   // some debug utilities
   
      always @(negedge clk)
	begin
   if (SCS16_VERBOSE == 1) begin
	   if ( R0 != ref_ram[0])
	     begin
		$display("%s R0                  = %h",space_x, R0);
		$fdisplay(fh,"%s R0                  = %h",space_x, R0);
	     end
	   if ( R1 != ref_ram[1])				      
	     begin
		$display("%s R1                  = %h",space_x, R1);
		$fdisplay(fh,"%s R1                  = %h",space_x, R1);
	     end
	   if ( R2 != ref_ram[2])				      
	     begin
		$display("%s R2                  = %h",space_x, R2);
		$fdisplay(fh,"%s R2                  = %h",space_x, R2);
	     end
	   if ( R3 != ref_ram[3])				      
	     begin
		$display("%s R3                  = %h",space_x, R3);
		$fdisplay(fh,"%s R3                  = %h",space_x, R3);
	     end
	   if ( R4 != ref_ram[4])				      
	     begin
		$display("%s R4                  = %h",space_x, R4);
		$fdisplay(fh,"%s R4                  = %h",space_x, R4);
	     end
	   if ( R5 != ref_ram[5])				      
	     begin
		$display("%s R5                  = %h",space_x, R5);
		$fdisplay(fh,"%s R5                  = %h",space_x, R5);
	     end
	   if ( R6 != ref_ram[6])				      
	     begin
		$display("%s R6                  = %h",space_x, R6);
		$fdisplay(fh,"%s R6                  = %h",space_x, R6);
	     end
	   if ( R7 != ref_ram[7])				      
	     begin
		$display("%s R7                  = %h",space_x, R7);
		$fdisplay(fh,"%s R7                  = %h",space_x, R7);
	     end
	   
	   
	   if ( R0_b != ref_ram[0+8])			      
	     begin
		$display("%s R0_b                = %h",space_x, R0_b);
		$fdisplay(fh,"%s R0_b                = %h",space_x, R0_b);
	     end
	   if ( R1_b != ref_ram[1+8])			      
	     begin
		$display("%s R1_b                = %h",space_x, R1_b);
		$fdisplay(fh,"%s R1_b                = %h",space_x, R1_b);
	     end
	   if ( R2_b != ref_ram[2+8])			      
	     begin
		$display("%s R2_b                = %h",space_x, R2_b);
		$fdisplay(fh,"%s R2_b                = %h",space_x, R2_b);
	     end
	   if ( R3_b != ref_ram[3+8])			      
	     begin
		$display("%s R3_b                = %h",space_x, R3_b);
		$fdisplay(fh,"%s R3_b                = %h",space_x, R3_b);
	     end
	   if ( R4_b != ref_ram[4+8])			      
	     begin
		$display("%s R4_b                = %h",space_x, R4_b);
		$fdisplay(fh,"%s R4_b                = %h",space_x, R4_b);
	     end
	   if ( R5_b != ref_ram[5+8])			      
	     begin
		$display("%s R5_b                = %h",space_x, R5_b);
		$fdisplay(fh,"%s R5_b                = %h",space_x, R5_b);
	     end
	   if ( R6_b != ref_ram[6+8])			      
	     begin
		$display("%s R6_b                = %h",space_x, R6_b);
		$fdisplay(fh,"%s R6_b                = %h",space_x, R6_b);
	     end
	   if ( R7_b != ref_ram[7+8])			      
	     begin
		$display("%s R7_b                = %h",space_x, R7_b);
		$fdisplay(fh,"%s R7_b                = %h",space_x, R7_b);
	     end
	   
	   ref_ram[0] =  R0;				      
	   ref_ram[1] =  R1;				      
	   ref_ram[2] =  R2;				      
	   ref_ram[3] =  R3;				      
	   ref_ram[4] =  R4;				      
	   ref_ram[5] =  R5;				      
	   ref_ram[6] =  R6;				      
	   ref_ram[7] =  R7;				      
	   							      
	   ref_ram[0+8] =  R0_b;				      
	   ref_ram[1+8] =  R1_b;				      
	   ref_ram[2+8] =  R2_b;				      
	   ref_ram[3+8] =  R3_b;				      
	   ref_ram[4+8] =  R4_b;				      
	   ref_ram[5+8] =  R5_b;				      
	   ref_ram[6+8] =  R6_b;				      
	   ref_ram[7+8] =  R7_b;				      
								      
	   if ( loop_start_pc != ref_ram[16])		      
	     begin
		$display("%s loop_start          = %h",space_x, loop_start_pc);
		$fdisplay(fh,"%s loop_start          = %h",space_x, loop_start_pc);
	     end
	   if ( loop_end_pc != ref_ram[17])		      
	     begin
		$display("%s loop_end            = %h",space_x, loop_end_pc);
		$fdisplay(fh,"%s loop_end            = %h",space_x, loop_end_pc);
	     end
	   if ( loop_cnt != ref_ram[18])			      
	     begin
		$display("%s loop_cnt            = %h",space_x, loop_cnt);
		$fdisplay(fh,"%s loop_cnt            = %h",space_x, loop_cnt);
	     end
	   
	   if ( device != ref_ram[19])			      
	     begin
		$display("%s device              = %h",space_x, device);
		$fdisplay(fh,"%s device              = %h",space_x, device);
	     end
	   if ( sub_return_add != ref_ram[20])		      
	     begin
		$display("%s sub_return_add      = %h",space_x, sub_return_add);
		$fdisplay(fh,"%s sub_return_add      = %h",space_x, sub_return_add);
	     end
	   
	   if ( loop_start_pc_b != ref_ram[16+8])		      
	     begin
		$display("%s loop_start_b        = %h",space_x, loop_start_pc_b);
		$fdisplay(fh,"%s loop_start_b        = %h",space_x, loop_start_pc_b);
	     end
	   if ( loop_end_pc_b != ref_ram[17+8])		      
	     begin
		$display("%s loop_end_b          = %h",space_x, loop_end_pc_b);
		$fdisplay(fh,"%s loop_end_b          = %h",space_x, loop_end_pc_b);
	     end
	   if ( loop_cnt_b != ref_ram[18+8])		      
	     begin
		$display("%s loop_cnt_b          = %h",space_x, loop_cnt_b);
		$fdisplay(fh,"%s loop_cnt_b          = %h",space_x, loop_cnt_b);
	     end
	   
	   if ( device_b != ref_ram[19+8])		      
	     begin
		$display("%s device_b            = %h",space_x, device_b);
		$fdisplay(fh,"%s device_b            = %h",space_x, device_b);
	     end
	   if ( sub_return_add_b != ref_ram[20+8])	      
	     begin
		$display("%s sub_return_add_b    = %h",space_x, sub_return_add_b);
		$fdisplay(fh,"%s sub_return_add_b    = %h",space_x, sub_return_add_b);
	     end
	   



	   ref_ram[16] =  loop_start_pc;
	   ref_ram[17] =  loop_end_pc;
	   ref_ram[18] =  loop_cnt;
	   ref_ram[19] =  device;
	   ref_ram[20] =  sub_return_add;
	   
	   ref_ram[16+8] =  loop_start_pc_b;
	   ref_ram[17+8] =  loop_end_pc_b;
	   ref_ram[18+8] =  loop_cnt_b;
	   ref_ram[19+8] =  device_b;
	   ref_ram[20+8] =  sub_return_add_b;

	   if ({10'h0,{ eq, gr, ls, ovf, zero, neg}} != ref_ram[30])	
	     begin
		$display("%s status              = %b",space_x,
			 { eq, gr, ls, ovf, zero, neg});
		$fdisplay(fh,"%s status              = %b",space_x,
			  { eq, gr, ls, ovf, zero, neg});
	     end
	   
	   if ({10'h0,{ eq_b, gr_b, ls_b, ovf_b, zero_b, neg_b}} != ref_ram[31]) 
	     begin
		$display("%s status_b            = %b",space_x,
			 { eq_b, gr_b, ls_b, ovf_b, zero_b, neg_b});
		$fdisplay(fh,"%s status_b            = %b",space_x,
			  { eq_b, gr_b, ls_b, ovf_b, zero_b, neg_b});
	     end
	   
	   ref_ram[30] = {10'h0,{ eq, gr, ls, ovf, zero, neg}};	   
	   ref_ram[31] = {10'h0,{ eq_b, gr_b, ls_b, ovf_b, zero_b, neg_b}};
	   
	   // pulse and conditions
	   if ( pulse != ref_ram[40])	      
	     begin
		$display("%s pulse               = %b",space_x, pulse);
		$fdisplay(fh,"%s pulse               = %b",space_x, pulse);
	     end
	   
	   if ( condition != ref_ram[41])	      
	     begin
		$display("%s condition           = %b",space_x, condition);
		$fdisplay(fh,"%s condition           = %b",space_x, condition);
	     end
	   ref_ram[40] =  pulse;
	   ref_ram[41] =  condition;
	   
	   if ( interupt && !ref_ram[42])	      
	     begin
		$display("##################### INTERUPT PENDING ####################");
		$fdisplay(fh,"##################### INTERUPT PENDING ####################");
	     end
	   ref_ram[42] =  interupt;
	   
	   if ( in_main_level &&  sampled_interupt)
	     begin
		$display("##################### INTERUPT TAKEN ######################");
		$fdisplay(fh,"##################### INTERUPT TAKEN ######################");
	     end
	   
	end //verbose
	end
 




