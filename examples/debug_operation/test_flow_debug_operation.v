
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
      delay(30);
      bus_write(`SCS_CTL, 16'h0000); // releasing machine to run

      // put your sequence here
      
      // you can use the following tokens
      
      // bus_read, 16 bits address and 2 bits byte enable
      // bus_read( `SCS_CTL, 2'b01);      // read byte 
      // bus_read( `SCS_CTL, 2'b11);      // read 2 bytes
      
      // bus_write, 16 bits address and 16 bits data
      // bus_write(`SCS_CTL, 16'h0003);   // setting mcode_wr_en, scs16_rst

      // you can also play with the following input signal of scs16
      // with the @(posedge clk) to sync signal change ...
      // @(posedge clk)
      // ext_interupt                    <= #1 0;
      // ext_source0                     <= #1 0;
      // ext_source1                     <= #1 0;
      // ext_condition[3]                <= #1 1;
      
      // you can play with the debug port
      delay(1);
      gen_bkpt;
      delay(10);
      gen_step;
      gen_step;
      delay(10);
      gen_step;
      delay(10);
      gen_continue;
      delay(10);
      gen_bkpt;
      delay(10);
      gen_continue;


      // you can use the delay(n) task 
      // delay(5);
 
      delay(30);
      // finally you may use the $stop system task to stop simulation

      $stop;
      

   end
