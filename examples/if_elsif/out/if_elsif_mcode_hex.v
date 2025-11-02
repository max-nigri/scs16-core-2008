// scs compiler creates an "out" directory at the invokation  
// directory, and proceeds with the compilation from that directory  
// so if one wants to use relative path for the include files  
// one must use the ../ notation   
//   
// `include ../simple_script_defines.v  
//   
00000000  // (    0) NOP          nop                                 // mandatory, start with nop.
68000004  // (    1) JUMP         goto 4                              // goto boot sequence, jump over the interrupt vector
68000047  // (    2) JUMP         goto 71                             // goto ISR, pc=2 interrupt destination
68000048  // (    3) JUMP         goto 72                             // goto Hardbreak, pc=3 hardbreak destination
//   
//   
38100fff  // (    4) LOADID       R0=16'h0fff                         // L_boot, begining of some boot sequence
// do something  
780386f0  // (    5) STOREIA      RAM[`APP_OUT0_ADDR]=R0              // init app out regs
// do something  
//   
38128005  // (    6) LOADID       R5=5                                // 
// simple register bit branch  
80179009  // (    7) BRANCH       branch (!R5[2]) 9                   // bit of reg branch
38108001  // (    8) LOADID       R1=1                                // branch not taken
//   
8017100b  // (    9) BRANCH       branch (R5[2]) 11                   // !bit of reg branch
38108002  // (   10) LOADID       R1=2                                // branch not taken
//   
3810801e  // (   11) LOADID       R1=30                               // condition is set to 16'hff00
// simple condition bit branch  
801c800e  // (   12) BRANCH       branch (!c0) 14                     // bit of condition branch
38108001  // (   13) LOADID       R1=1                                // branch not taken
//   
801cc010  // (   14) BRANCH       branch (!c8) 16                     // !bit of reg branch
38108002  // (   15) LOADID       R1=2                                // branch not taken
//   
//   
38108028  // (   16) LOADID       R1=40                               // 
// if else example  
801c8014  // (   17) BRANCH       branch (!c0) 20                     // bit of condition branch
38108007  // (   18) LOADID       R1=7                                // branch not taken
68000015  // (   19) JUMP         goto 21                             // 
//   
38108008  // (   20) LOADID       R1=8                                // branch taken
//   
// if else with branch taken  
801cc018  // (   21) BRANCH       branch (!c8) 24                     // bit of condition branch
38108009  // (   22) LOADID       R1=9                                // branch not taken
68000019  // (   23) JUMP         goto 25                             // 
//   
3810800a  // (   24) LOADID       R1=10                               // branch taken
//   
//   
// nested if  
801c8020  // (   25) BRANCH       branch (!c0) 32                     // bit of condition branch
801c881e  // (   26) BRANCH       branch (!c1) 30                     // 
801c901d  // (   27) BRANCH       branch (!c2) 29                     // 
3810800b  // (   28) LOADID       R1=11                               // 
//   
3810800c  // (   29) LOADID       R1=12                               // 
//   
3810800d  // (   30) LOADID       R1=13                               // 
68000021  // (   31) JUMP         goto 33                             // 
//   
3810800e  // (   32) LOADID       R1=14                               // 
//   
//   
// if else if example  
801cb024  // (   33) BRANCH       branch (!c6) 36                     // if elsif start
38108014  // (   34) LOADID       R1=20                               // 
6800002e  // (   35) JUMP         goto 46                             // 
801cb827  // (   36) BRANCH       branch (!c7) 39                     // 
38108015  // (   37) LOADID       R1=21                               // 
6800002e  // (   38) JUMP         goto 46                             // 
801cc02a  // (   39) BRANCH       branch (!c8) 42                     // 
38108016  // (   40) LOADID       R1=22                               // 
6800002e  // (   41) JUMP         goto 46                             // 
801cc82d  // (   42) BRANCH       branch (!c9) 45                     // 
38108017  // (   43) LOADID       R1=23                               // 
6800002e  // (   44) JUMP         goto 46                             // 
//   
38108018  // (   45) LOADID       R1=24                               // 
//   
//   
//   
38110028  // (   46) LOADID       R2=40                               // 
8803a628  // (   47) ALUI         gr_flag = R2>40                     // 
801de033  // (   48) BRANCH       branch (!gr_flag) 51                // alu assist branch
3810801e  // (   49) LOADID       R1=30                               // 
68000034  // (   50) JUMP         goto 52                             // 
//   
3810801f  // (   51) LOADID       R1=31                               // 
//   
//   
38110028  // (   52) LOADID       R2=40                               // 
8803a628  // (   53) ALUI         gr_flag = R2>40                     // 
801de038  // (   54) BRANCH       branch (!gr_flag) 56                // alu assist branch
3810801e  // (   55) LOADID       R1=30                               // 
//   
// the following elsif with compare is not supported  
// elsif (R2==40) {  
// R1=31  
// }  
//   
// instead, one can do the following  
38110028  // (   56) LOADID       R2=40                               // 
8803a628  // (   57) ALUI         gr_flag = R2>40                     // explicit alu compare
801de83d  // (   58) BRANCH       branch (!eq_flag) 61                // start of alu if elsif emulation
3810801e  // (   59) LOADID       R1=30                               // 
68000042  // (   60) JUMP         goto 66                             // 
801dd840  // (   61) BRANCH       branch (!ls_flag) 64                // 
3810801f  // (   62) LOADID       R1=31                               // 
68000042  // (   63) JUMP         goto 66                             // 
801de042  // (   64) BRANCH       branch (!gr_flag) 66                // 
3810801f  // (   65) LOADID       R1=31                               // 
//   
//   
// if ( some condition) L_label  
38110032  // (   66) LOADID       R2=50                               // 
800b0045  // (   67) BRANCH       branch (R2[0]) 69                   // basic branch
3811003c  // (   68) LOADID       R2=60                               // 
38110046  // (   69) LOADID       R2=70                               // L_simple_branch      
//   
801cf046  // (   70) BRANCH       branch !c14 70                      // c14 tied to "0" 
//   
//   
// //////////////////////////////////////////////  
// routines  
// //////////////////////////////////////////////  
// //////////////////////////////////////////////  
//   
70100000  // (   71) RETURN       rti                                 // 
//   
68000004  // (   72) JUMP         goto 4                              // 
//   
// //////////////////////////////////////////////  
// ///////// L_delay ////////////////////////////  
// //////////////////////////////////////////////  
//   
48148400  // (   73) LOOP         loop 1 1 R5                         // 
00000000  // (   74) NOP          nop                                 // 
70000000  // (   75) RETURN       return                              // 
//   
//   
//   
