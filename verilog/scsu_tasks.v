//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
task gen_pulse;
   input [3:0] index;
   
   begin
      @(posedge clk);
      ext_condition[index] <= #1 1;	 
      @(posedge clk);
      ext_condition[index] <= #1 0;	 
      
   end
endtask

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
task gen_step;      
   begin
      @(posedge clk);
      scsu_0.x_scs16_wrapper.step <= #1 1;	 
      @(posedge clk);
      scsu_0.x_scs16_wrapper.step  <= #1 0;	 	 
   end
endtask
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
task gen_continue;      
   begin
      @(posedge clk);
      scsu_0.x_scs16_wrapper.continue <= #1 1;	 
      @(posedge clk);
      scsu_0.x_scs16_wrapper.continue  <= #1 0;	 	 
   end
endtask
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
task gen_bkpt;      
   begin
      @(posedge clk);
      scsu_0.x_scs16_wrapper.bkpt <= #1 1;	 
      @(posedge clk);
      scsu_0.x_scs16_wrapper.bkpt  <= #1 0;	 	 
   end
endtask

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

`ifdef SCSU
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////  
// data gen for wait_store
// create_and_send_packet(10,100,0)
task create_and_send_packet;
   input [7:0] len;
   input [7:0] halt_at;
   input [15:0] start_data;
   
   reg [7:0] len;
   reg [15:0] start_data;
   reg [7:0]  i;
   begin
      i = 1;	
      s0 <= #1 start_data;	 
      while (i < len)
	begin
	   @(posedge clk);
	   if (pulse[1]) // if core issue break then break
	     i = len;
	   
	   condition[1] <= #1 0;
	   if (i == halt_at)
	     condition[0] <= #1 0;
	   else 
	     condition[0] <= #1 1;
	   if (condition[0] && pulse[0])
	     s0 <= #1 s0 + 1;
	   if (pulse[0])
	     i = i+1;
	end // while (i < len)
      @(posedge clk);
      // ending the chunk
      condition[0] <= #1 0; 
      condition[1] <= #1 1;
      
      @(posedge clk);
      condition[1] <= #1 0;
   end
endtask // create_and_send_packet
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////  
// data acceptor for wait_load
// rcv_packet(10,100)
task rcv_packet;
   input [7:0] len;
   input [7:0] halt_at;
   
   reg [7:0] len;
   reg [15:0] recieved_data;
   reg [7:0]  i;
   begin
      i = 1;	
      while (i < len)
	begin
	   @(posedge clk);
	   if (pulse[1]) // if core issue break then break
	     i = len;
	   
	   condition[1] <= #1 0;
	   if (i == halt_at)
	     condition[0] <= #1 0;
	   else 
	     condition[0] <= #1 1;
	   if (condition[0] && pulse[0])
	     recieved_data <= #1 scs16_0.R0;
	   if (pulse[0])
	     i = i+1;
	end // while (i < len)
      @(posedge clk);
      // ending the chunk
      condition[0] <= #1 0; 
      condition[1] <= #1 1;
      
      @(posedge clk);
      condition[1] <= #1 0;
   end
endtask // rcv_packet
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
// data gen for wait_store
// create_and_send_packet1(10,1,0,100);
task create_and_send_packet1;
   input [7:0] len;
   input [7:0] cycles_per_data;
   input [7:0] valid_position; // < cycles_per_data     
   input [15:0] start_data;
   
   reg [7:0] len, cycles_per_data, valid_position;
   reg [15:0] start_data;
   reg [7:0]  i;
   integer    cycles;
   
   begin
      i = 0;
      cycles <= #1 0;
      
      s0 <= #1 start_data-1;	 
      while (i < len)
	begin
	   @(posedge clk);
	   if (pulse[14])
	     begin
		cycles <= #1 cycles+1;
		if (cycles % cycles_per_data == 0)
		  begin
		     s0 <= #1 s0 + 1;
		  end
		
		if ((cycles % cycles_per_data)  == valid_position)
		  condition[0] <= #1 1;
		else
		  condition[0] <= #1 0;
		
		if (cycles % cycles_per_data == (cycles_per_data-1))
	      	  i = i+1;
	     end
	   
	   //  	      if (pulse[1]) // if core issue break then break
	   //  		i = len;
	   
	   //  	      condition[1] <= #1 0;
	   //  	      if (i == halt_at)
	   //  		condition[0] <= #1 0;
	   //  	      else 
	   //  		condition[0] <= #1 1;
	   //  	      if (condition[0] && pulse[0])
	   //  		s0 <= #1 s0 + 1;
	   //  	      if (pulse[0])
	   //		i = i+1;
	end // while (i < len)
      @(posedge clk);
      // ending the chunk
      condition[0] <= #1 0; 
      //  	 condition[1] <= #1 1;
      
      //  	 @(posedge clk);
      //  	 condition[1] <= #1 0;
   end
endtask // create_and_send_packet1

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
task gen_pulse;
   input [3:0] index;
   
   begin
      @(posedge clk);
      condition[index] <= #1 1;	 
      @(posedge clk);
      condition[index] <= #1 0;	 
      
   end
endtask


`endif //  `ifdef SCSU
