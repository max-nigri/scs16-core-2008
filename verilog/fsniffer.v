   //////////////////////////////////////////////////////////////
   //////////////////////////////////////////////////////////////
   // some debug utilities
   reg [15:0] ref_ram [63:0];
      always @(negedge clk)
	begin
	   if (scs16_0.R0 != ref_ram[0])
	     begin
	     $display("%s R0                  = %h",space_x,scs16_0.R0);
	     $fdisplay(fh,"%s R0                  = %h",space_x,scs16_0.R0);
	     end
	   if (scs16_0.R1 != ref_ram[1])				      
	     begin
	     $display("%s R1                  = %h",space_x,scs16_0.R1);
	     $fdisplay(fh,"%s R1                  = %h",space_x,scs16_0.R1);
	     end
	   if (scs16_0.R2 != ref_ram[2])				      
	     begin
	     $display("%s R2                  = %h",space_x,scs16_0.R2);
	     $fdisplay(fh,"%s R2                  = %h",space_x,scs16_0.R2);
	     end
	   if (scs16_0.R3 != ref_ram[3])				      
	     begin
	     $display("%s R3                  = %h",space_x,scs16_0.R3);
	     $fdisplay(fh,"%s R3                  = %h",space_x,scs16_0.R3);
	     end
	   if (scs16_0.R4 != ref_ram[4])				      
	     begin
	     $display("%s R4                  = %h",space_x,scs16_0.R4);
	     $fdisplay(fh,"%s R4                  = %h",space_x,scs16_0.R4);
	     end
	   if (scs16_0.R5 != ref_ram[5])				      
	     begin
	     $display("%s R5                  = %h",space_x,scs16_0.R5);
	     $fdisplay(fh,"%s R5                  = %h",space_x,scs16_0.R5);
	     end
	   if (scs16_0.R6 != ref_ram[6])				      
	     begin
	     $display("%s R6                  = %h",space_x,scs16_0.R6);
	     $fdisplay(fh,"%s R6                  = %h",space_x,scs16_0.R6);
	     end
	   if (scs16_0.R7 != ref_ram[7])				      
	     begin
	     $display("%s R7                  = %h",space_x,scs16_0.R7);
	     $fdisplay(fh,"%s R7                  = %h",space_x,scs16_0.R7);
	     end
								      
								      
	   if (scs16_0.R0_b != ref_ram[0+8])			      
	     begin
	     $display("%s R0_b                = %h",space_x,scs16_0.R0_b);
	     $fdisplay(fh,"%s R0_b                = %h",space_x,scs16_0.R0_b);
	     end
	   if (scs16_0.R1_b != ref_ram[1+8])			      
	     begin
	     $display("%s R1_b                = %h",space_x,scs16_0.R1_b);
	     $fdisplay(fh,"%s R1_b                = %h",space_x,scs16_0.R1_b);
	     end
	   if (scs16_0.R2_b != ref_ram[2+8])			      
	     begin
	     $display("%s R2_b                = %h",space_x,scs16_0.R2_b);
	     $fdisplay(fh,"%s R2_b                = %h",space_x,scs16_0.R2_b);
	     end
	   if (scs16_0.R3_b != ref_ram[3+8])			      
	     begin
	     $display("%s R3_b                = %h",space_x,scs16_0.R3_b);
	     $fdisplay(fh,"%s R3_b                = %h",space_x,scs16_0.R3_b);
	     end
	   if (scs16_0.R4_b != ref_ram[4+8])			      
	     begin
	     $display("%s R4_b                = %h",space_x,scs16_0.R4_b);
	     $fdisplay(fh,"%s R4_b                = %h",space_x,scs16_0.R4_b);
	     end
	   if (scs16_0.R5_b != ref_ram[5+8])			      
	     begin
	     $display("%s R5_b                = %h",space_x,scs16_0.R5_b);
	     $fdisplay(fh,"%s R5_b                = %h",space_x,scs16_0.R5_b);
	     end
	   if (scs16_0.R6_b != ref_ram[6+8])			      
	     begin
	     $display("%s R6_b                = %h",space_x,scs16_0.R6_b);
	     $fdisplay(fh,"%s R6_b                = %h",space_x,scs16_0.R6_b);
	     end
	   if (scs16_0.R7_b != ref_ram[7+8])			      
	     begin
	     $display("%s R7_b                = %h",space_x,scs16_0.R7_b);
	     $fdisplay(fh,"%s R7_b                = %h",space_x,scs16_0.R7_b);
	     end
								      
	   ref_ram[0] = scs16_0.R0;				      
	   ref_ram[1] = scs16_0.R1;				      
	   ref_ram[2] = scs16_0.R2;				      
	   ref_ram[3] = scs16_0.R3;				      
	   ref_ram[4] = scs16_0.R4;				      
	   ref_ram[5] = scs16_0.R5;				      
	   ref_ram[6] = scs16_0.R6;				      
	   ref_ram[7] = scs16_0.R7;				      
	   							      
	   ref_ram[0+8] = scs16_0.R0_b;				      
	   ref_ram[1+8] = scs16_0.R1_b;				      
	   ref_ram[2+8] = scs16_0.R2_b;				      
	   ref_ram[3+8] = scs16_0.R3_b;				      
	   ref_ram[4+8] = scs16_0.R4_b;				      
	   ref_ram[5+8] = scs16_0.R5_b;				      
	   ref_ram[6+8] = scs16_0.R6_b;				      
	   ref_ram[7+8] = scs16_0.R7_b;				      
								      
	   if (scs16_0.loop_start_pc != ref_ram[16])		      
	     begin
	     $display("%s loop_start          = %h",space_x,scs16_0.loop_start_pc);
	     $fdisplay(fh,"%s loop_start          = %h",space_x,scs16_0.loop_start_pc);
	     end
	   if (scs16_0.loop_end_pc != ref_ram[17])		      
	     begin
	     $display("%s loop_end            = %h",space_x,scs16_0.loop_end_pc);
	     $fdisplay(fh,"%s loop_end            = %h",space_x,scs16_0.loop_end_pc);
	     end
	   if (scs16_0.loop_cnt != ref_ram[18])			      
	     begin
	     $display("%s loop_cnt            = %h",space_x,scs16_0.loop_cnt);
	     $fdisplay(fh,"%s loop_cnt            = %h",space_x,scs16_0.loop_cnt);
	     end
								      
	   if (scs16_0.device != ref_ram[19])			      
	     begin
	     $display("%s device              = %h",space_x,scs16_0.device);
	     $fdisplay(fh,"%s device              = %h",space_x,scs16_0.device);
	     end
	   if (scs16_0.sub_return_add != ref_ram[20])		      
	     begin
	     $display("%s sub_return_add      = %h",space_x,scs16_0.sub_return_add);
	     $fdisplay(fh,"%s sub_return_add      = %h",space_x,scs16_0.sub_return_add);
	     end
								      
	   if (scs16_0.loop_start_pc_b != ref_ram[16+8])		      
	     begin
	     $display("%s loop_start_b        = %h",space_x,scs16_0.loop_start_pc_b);
	     $fdisplay(fh,"%s loop_start_b        = %h",space_x,scs16_0.loop_start_pc_b);
	     end
	   if (scs16_0.loop_end_pc_b != ref_ram[17+8])		      
	     begin
	     $display("%s loop_end_b          = %h",space_x,scs16_0.loop_end_pc_b);
	     $fdisplay(fh,"%s loop_end_b          = %h",space_x,scs16_0.loop_end_pc_b);
	     end
	   if (scs16_0.loop_cnt_b != ref_ram[18+8])		      
	     begin
	     $display("%s loop_cnt_b          = %h",space_x,scs16_0.loop_cnt_b);
	     $fdisplay(fh,"%s loop_cnt_b          = %h",space_x,scs16_0.loop_cnt_b);
	     end
								      
	   if (scs16_0.device_b != ref_ram[19+8])		      
	     begin
	     $display("%s device_b            = %h",space_x,scs16_0.device_b);
	     $fdisplay(fh,"%s device_b            = %h",space_x,scs16_0.device_b);
	     end
	   if (scs16_0.sub_return_add_b != ref_ram[20+8])	      
	     begin
	     $display("%s sub_return_add_b    = %h",space_x,scs16_0.sub_return_add_b);
	     $fdisplay(fh,"%s sub_return_add_b    = %h",space_x,scs16_0.sub_return_add_b);
	     end
	   



	   ref_ram[16] = scs16_0.loop_start_pc;
	   ref_ram[17] = scs16_0.loop_end_pc;
	   ref_ram[18] = scs16_0.loop_cnt;
	   ref_ram[19] = scs16_0.device;
	   ref_ram[20] = scs16_0.sub_return_add;
	   
	   ref_ram[16+8] = scs16_0.loop_start_pc_b;
	   ref_ram[17+8] = scs16_0.loop_end_pc_b;
	   ref_ram[18+8] = scs16_0.loop_cnt_b;
	   ref_ram[19+8] = scs16_0.device_b;
	   ref_ram[20+8] = scs16_0.sub_return_add_b;

	   if ({10'h0,{scs16_0.eq,scs16_0.gr,scs16_0.ls,scs16_0.ovf,scs16_0.zero,scs16_0.neg}} != ref_ram[30])	
	     begin
	     $display("%s status              = %b",space_x,
		      {scs16_0.eq,scs16_0.gr,scs16_0.ls,scs16_0.ovf,scs16_0.zero,scs16_0.neg});
	     $fdisplay(fh,"%s status              = %b",space_x,
		      {scs16_0.eq,scs16_0.gr,scs16_0.ls,scs16_0.ovf,scs16_0.zero,scs16_0.neg});
	     end
	   
	   if ({10'h0,{scs16_0.eq_b,scs16_0.gr_b,scs16_0.ls_b,scs16_0.ovf_b,scs16_0.zero_b,scs16_0.neg_b}} != ref_ram[31]) 
	     begin
	     $display("%s status_b            = %b",space_x,
		      {scs16_0.eq_b,scs16_0.gr_b,scs16_0.ls_b,scs16_0.ovf_b,scs16_0.zero_b,scs16_0.neg_b});
	     $fdisplay(fh,"%s status_b            = %b",space_x,
		      {scs16_0.eq_b,scs16_0.gr_b,scs16_0.ls_b,scs16_0.ovf_b,scs16_0.zero_b,scs16_0.neg_b});
	     end
	   
	   ref_ram[30] = {10'h0,{scs16_0.eq,scs16_0.gr,scs16_0.ls,scs16_0.ovf,scs16_0.zero,scs16_0.neg}};	   
	   ref_ram[31] = {10'h0,{scs16_0.eq_b,scs16_0.gr_b,scs16_0.ls_b,scs16_0.ovf_b,scs16_0.zero_b,scs16_0.neg_b}};

	   // pulse and conditions
	   if (scs16_0.pulse != ref_ram[40])	      
	     begin
	     $display("%s pulse               = %b",space_x,scs16_0.pulse);
	     $fdisplay(fh,"%s pulse               = %b",space_x,scs16_0.pulse);
	     end
	   
	   if (scs16_0.condition != ref_ram[41])	      
	     begin
	     $display("%s condition           = %b",space_x,scs16_0.condition);
	     $fdisplay(fh,"%s condition           = %b",space_x,scs16_0.condition);
	     end
	   ref_ram[40] = scs16_0.pulse;
	   ref_ram[41] = scs16_0.condition;
   
	   if (scs16_0.interupt && !ref_ram[42])	      
	     begin
	     $display("##################### INTERUPT PENDING ####################");
	     $fdisplay(fh,"##################### INTERUPT PENDING ####################");
	     end
	   ref_ram[42] = scs16_0.interupt;

	   if (scs16_0.in_main_level && scs16_0.sampled_interupt)
	     begin
	     $display("##################### INTERUPT TAKEN ######################");
	     $fdisplay(fh,"##################### INTERUPT TAKEN ######################");
	     end
	     
	   	
	end
 
