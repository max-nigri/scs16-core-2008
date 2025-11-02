
scs16 compiler

to get access to the compiler scs16_asm.pl scs16_line.pl :

windows - dos commad shell

         set path =       ...P:\Designs\Concepts\<top_scs_instal_dir>\scs16_comp 
	 set SCS_BASE_DIR=P:\Designs\Concepts\<top_scs_instal_dir>

linux - from the terminal

	 setenv OS           linux
	 setenv SCS_BASE_DIR /Designs/Concepts/<top_scs_instal_dir>

to compile a line
   	   scs16_line.pl "R1=R3"

to compile a script
   	   scs16_asm.pl <your_script_file_name>
  
