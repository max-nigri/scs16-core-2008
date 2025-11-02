// scs compiler creates an "out" directory at the invokation  
// directory, and proceeds with the compilation from that directory  
// so if one wants to use relative path for the include files  
// one must use the ../ notation   
//   
// `include ../simple_script_defines.v  
//   
00000000  // (    0) NOP          nop                                 // 
68000004  // (    1) JUMP         goto 4                              // goto boot sequence
6800000c  // (    2) JUMP         goto 12                             // goto ISR
6800000d  // (    3) JUMP         goto 13                             // prepare 
//   
//   
38100fff  // (    4) LOADID       R0=16'h0fff                         // L_boot, begining of some boot sequence
780386f0  // (    5) STOREIA      RAM[`APP_OUT0_ADDR]=R0              // init app out regs
// do something  
//   
38130014  // (    6) LOADID       R6=20                               // 
2418670f  // (    7) STORE        EXT_BUS[R6] = R6                    // external bus write
00000000  // (    8) NOP          nop                                 // 
1c1a810f  // (    9) LOAD         R5 = EXT_BUS[R6]                    // external bus read 
6810000e  // (   10) JUMP         gosub 14                            // 
801cf00b  // (   11) BRANCH       branch !c14 11                      // c14 tied to "0" 
//   
//   
// //////////////////////////////////////////////  
// routines  
// //////////////////////////////////////////////  
// //////////////////////////////////////////////  
//   
70100000  // (   12) RETURN       rti                                 // 
//   
68000004  // (   13) JUMP         goto 4                              // 
//   
//   
// //////////////////////////////////////////////  
// ///////// L_delay ////////////////////////////  
// //////////////////////////////////////////////  
//   
48148400  // (   14) LOOP         loop 1 1 R5                         // 
00000000  // (   15) NOP          nop                                 // 
70000000  // (   16) RETURN       return                              // 
//   
//   
//   
