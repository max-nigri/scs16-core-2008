module cgate( en, te, clkin, clkout);

   input en;
   input te;
   input clkin;
   output clkout;

   reg 	  en1;


   always @(en or te or clkin)
      if (!clkin)
       en1 <= te || en;

   assign clkout = en1 && clkin;
   

endmodule // cgate
