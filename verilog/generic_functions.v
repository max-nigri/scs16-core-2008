//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
function [799:0] strip_null;
   
   input [799:0] in_string;
   
   integer 	    m, mm;
   begin
      mm = 799; 
      strip_null = 800'h0;
      for (m=799; m>0; m=m-8) 
	if (full_file_name[m-:8]>0)
	  begin
	     strip_null[mm-:8] = in_string[m-:8];
	     mm = mm -8;
	  end
   end
endfunction // strip_null
