
reg [31:0] imem_line;
integer i;

initial
   begin
      rst = 1;
      clk = 0;
      // initializing the debug logic
      scsu_0.x_scs16_wrapper.bkpt     = 0;
      scsu_0.x_scs16_wrapper.continue = 0;	 
      scsu_0.x_scs16_wrapper.step     = 0;

      bus_init;                        // initiating the master stab signals
      
      tstmux_sel                      = 0;

      ext_interupt                    = 0;
      ext_source0                     = 0;
      ext_source1                     = 0;
      ext_condition                   = 0;
      
      script_base_name = "out/";
      
      // Reading the iram
      
      test_name = "simple_script";
      
      full_file_name = {script_base_name,test_name,"_mcode_b.v"};
      $display("loading micro code from   :%s",strip_null(full_file_name));
      $readmemb (full_file_name, scsu_0.imem.ram);
      
      full_file_name = {script_base_name,test_name,"_mcode_xdisplay_hex.v"};
      $display("loading sniffer code from :%s",strip_null(full_file_name));
      $readmemh (full_file_name, scsu_0.x_scs16.display_ram);

      delay(30);
      
      rst = 0;
      
      /////////////////////////////////////////////////////////
      /////////////////////////////////////////////////////////
      // put your task calls here
      delay(30);
      bus_read( `SCS_CTL, 2'b01);      // read byte 
      bus_read( `SCS_CTL, 2'b11);      // read 2 bytes
      
      // demonstrating micro code load
      bus_write(`SCS_CTL, 16'h0003);   // setting mcode_wr_en, scs16_rst

      for (i=0; i<20; i=i+1)
	begin
	   // copy the intruction from imem to tmp register and writting it
	   // to the imem via the bus slave interface
	   imem_line = scsu_0.imem.ram[i];
	   bus_write((i*4),   imem_line[15:0]);
	   bus_write((i*4+2), imem_line[31:16]);
	end
	   

      delay(5);
      bus_write(`SCS_CTL, 16'h0000); // releasing machine to run
      bus_read( `SCS_CTL, 2'b01);    // read 
 
      delay(30);

   end
