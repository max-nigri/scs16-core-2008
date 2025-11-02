module ahb_slave( 
    input  wire        rst,
    input  wire        clk,
		 
    input  wire [1:0]  scsu_m_ahb_mhtrans,   // ahb master if'
    input  wire [1:0]  scsu_m_ahb_mhsize,    // ahb master if' 
    input  wire        scsu_m_ahb_mhwrite,   // ahb master if' 
    input  wire [15:0] scsu_m_ahb_mhaddr,    // ahb master if' 
    input  wire [15:0] scsu_m_ahb_mhwdata,   // ahb master if' 
    output wire [15:0] ahb_scsu_m_shrdata,   // ahb master if' 
    output wire        ahb_scsu_m_shready,   // ahb master if' 
    output reg [1:0]   ahb_scsu_m_shresp     // ahb master if' 
		 
		 
		 );
   integer 	       i,s;
   reg [15:0] 	       slave_ram [0:4095];
   
  //////////////////////////////////////////////////////////////
  // ahb slave with some ram behind
   wire [15:0] s_addr;
   wire        s_wr;
   wire [1:0]  s_size;
   wire        s_cs;
   reg 	       ram_wr;
   reg 	       ram_rd_valid;
   reg 	       ram_cs;
   wire        ram_ack;
   
   reg [15:0]  s_rd_data;
   wire [15:0] s_wr_data;
   reg [3:0]   wait_cnt;

   reg 	       access_start;
   reg 	       internal_ready;
   
  
   reg [15:0]  scsu_m_ahb_mhaddr_latch;
   reg [1:0]   scsu_m_ahb_mhsize_latch; 
   reg         scsu_m_ahb_mhwrite_latch;

   assign s_cs   = (scsu_m_ahb_mhtrans == 2'b10);

   assign s_addr = scsu_m_ahb_mhaddr_latch;
   assign s_wr   = scsu_m_ahb_mhwrite_latch;
   assign s_size = scsu_m_ahb_mhsize_latch;

   assign s_wr_data = scsu_m_ahb_mhwdata;
   assign ahb_scsu_m_shrdata = s_rd_data;
   
   
   always @(posedge clk)
     if (rst)
       begin
	  ahb_scsu_m_shresp       <= #1 0;
	  
	  internal_ready          <= #1 1;
	  scsu_m_ahb_mhaddr_latch <= #1 0;
	  scsu_m_ahb_mhwrite_latch<= #1 0;
	  scsu_m_ahb_mhsize_latch <= #1 0;
	  ram_wr                  <= #1 0;
	  ram_cs                  <= #1 0;
	  ram_rd_valid            <= #1 0;
	  access_start            <= #1 0;
       end
     else
       begin
	  ram_rd_valid            <= #1 ram_cs && !ram_wr && ram_ack;	  
 	  access_start            <= #1 0;

	  if ((internal_ready || ram_ack) && scsu_m_ahb_mhtrans == 2'b10)
	    begin
	       // start of access
	       access_start            <= #1 1;
	       scsu_m_ahb_mhaddr_latch <= #1 scsu_m_ahb_mhaddr;
	       scsu_m_ahb_mhwrite_latch<= #1 scsu_m_ahb_mhwrite;
	       scsu_m_ahb_mhsize_latch <= #1 scsu_m_ahb_mhsize;

	       if (scsu_m_ahb_mhwrite) // write
		 begin
		    ram_wr   <= #1 1;
		    ram_cs   <= #1 1; 
		 end
	       else  // read
		 begin 
		    ram_wr   <= #1 0;
		    ram_cs   <= #1 1; 
		 end
	       internal_ready<= #1 0;

	    end // if ((internal_ready || ram_ack) && scsu_m_ahb_mhtrans == 2'b10)
	  
	  else if (!internal_ready && ram_ack)
	    begin
	       internal_ready <= #1 1;
	       ram_wr         <= #1 0;
	       ram_cs         <= #1 0;
	    end

       end // else: !if(rst)
   
   assign ahb_scsu_m_shready =  internal_ready || ram_rd_valid || (ram_wr && ram_ack);

   always @(posedge clk)
     if (rst)
       wait_cnt <= #1 0;
     else if (access_start)
       // wait_cnt <= #1 $dist_uniform(s,0,3);
       wait_cnt <= #1 0;
     else if (wait_cnt >= 1)
       wait_cnt <= #1 wait_cnt-1;
      
   assign ram_ack = ram_cs && (wait_cnt == 0);
 	  
   // slave ram read write process
   always @(posedge clk)
     if (rst)
       	  s_rd_data <= #1 16'h0000;
     else if (ram_cs && ram_wr && (ram_ack || 0)) // ram write
       if (s_size == 2'b01)
	 slave_ram[s_addr] <= #1 s_wr_data;
       else if  ((s_size == 2'b00) && !s_addr[0])
	 // lower byte
	 slave_ram[s_addr] <= #1 {slave_ram[s_addr][15:8], s_wr_data[7:0]};
       else if  ((s_size == 2'b00) && s_addr[0])
	 // higher byte
	 slave_ram[s_addr] <= #1 {s_wr_data[7:0], slave_ram[s_addr][7:0]};
       else
	 begin
	    slave_ram[s_addr] <= #1 16'hxxxx;
	    $display("Bus Error - Illigale write access");
	    #3;
	    $stop;
	 end
     else if (ram_cs && !ram_wr && (ram_ack || 0)) // ram read
       begin
	  s_rd_data <= #1 16'hxxxx;
	  
	  if (s_size == 2'b01)
	    s_rd_data <= #10 slave_ram[s_addr];
	  else if  ((s_size == 2'b00) && !s_addr[0])
	    // lower byte
	    s_rd_data <= #10 {slave_ram[s_addr][15:8], slave_ram[s_addr][7:0]};
	  else if  ((s_size == 2'b00) && s_addr[0])
	    // higher byte
	    s_rd_data <=  #10 {slave_ram[s_addr][15:8], slave_ram[s_addr][15:8]};
	  else
	    begin
	       s_rd_data <=  #10  16'hxxxx;
	       $display("Bus Error - Illigale read access");
	       #3;
	       $stop;
	    end
       end // if (ram_cs && !ram_wr)
   


   
endmodule // ahb_slave


