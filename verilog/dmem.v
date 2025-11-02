
module dmem (clk,cs, wen,reset,d,address,q);

   parameter width=28;
   parameter rows=2048;
   parameter add_size=11;
   
   
   input     clk;
   input [1:0] wen;
   input       cs;   
   input       reset;
   input [width-1:0] d;
   input [add_size-1:0] address;
   output [width-1:0]   q;
   
   
   reg [width-1:0]      ram [0:rows-1];
   reg [width-1:0]      q;
   wire [width-1:0]     g;
   integer 	      I;
   
   assign 	      g = ram[address];
   
   always @(posedge clk)
     begin  
	if (reset)
	  for (I=0 ; I<rows; I=I+1)
	    ram[I] <= #1 0;
	else 
	  begin
	     if (cs && |wen)
	     case (wen) // synopsis full case 
	       2'b10: ram[address] <= #1 {d[15:8], g[7:0]};
	       2'b01: ram[address] <= #1 {g[15:8], d[7:0]};
	       2'b11: ram[address] <= #1  d[15:0] ;
	     endcase
	  end     
     end   
   
   always @(posedge clk)
     if (cs && !(|wen))
       q <= #1 ram[address];
   
endmodule
