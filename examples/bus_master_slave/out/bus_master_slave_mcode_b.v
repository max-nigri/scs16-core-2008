// scs compiler creates an "out" directory at the invokation  
// directory, and proceeds with the compilation from that directory  
// so if one wants to use relative path for the include files  
// one must use the ../ notation   
//   
// `include ../simple_script_defines.v  
//   
00000000000000000000000000000000// (    0) 00000000 NOP          nop                                 // 
01101000000000000000000000000100// (    1) 68000004 JUMP         goto 4                              // goto boot sequence
01101000000000000000000000001100// (    2) 6800000c JUMP         goto 12                             // goto ISR
01101000000000000000000000001101// (    3) 6800000d JUMP         goto 13                             // prepare 
//   
//   
00111000000100000000111111111111// (    4) 38100fff LOADID       R0=16'h0fff                         // L_boot, begining of some boot sequence
01111000000000111000011011110000// (    5) 780386f0 STOREIA      RAM[`APP_OUT0_ADDR]=R0              // init app out regs
// do something  
//   
00111000000100110000000000010100// (    6) 38130014 LOADID       R6=20                               // 
00100100000110000110011100001111// (    7) 2418670f STORE        EXT_BUS[R6] = R6                    // external bus write
00000000000000000000000000000000// (    8) 00000000 NOP          nop                                 // 
00011100000110101000000100001111// (    9) 1c1a810f LOAD         R5 = EXT_BUS[R6]                    // external bus read 
01101000000100000000000000001110// (   10) 6810000e JUMP         gosub 14                            // 
10000000000111001111000000001011// (   11) 801cf00b BRANCH       branch !c14 11                      // c14 tied to "0" 
//   
//   
// //////////////////////////////////////////////  
// routines  
// //////////////////////////////////////////////  
// //////////////////////////////////////////////  
//   
01110000000100000000000000000000// (   12) 70100000 RETURN       rti                                 // 
//   
01101000000000000000000000000100// (   13) 68000004 JUMP         goto 4                              // 
//   
//   
// //////////////////////////////////////////////  
// ///////// L_delay ////////////////////////////  
// //////////////////////////////////////////////  
//   
01001000000101001000010000000000// (   14) 48148400 LOOP         loop 1 1 R5                         // 
00000000000000000000000000000000// (   15) 00000000 NOP          nop                                 // 
01110000000000000000000000000000// (   16) 70000000 RETURN       return                              // 
//   
//   
//   
