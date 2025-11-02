// scs compiler creates an "out" directory at the invokation  
// directory, and proceeds with the compilation from that directory  
// so if one wants to use relative path for the include files  
// one must use the ../ notation   
//   
// `include ../simple_script_defines.v  
//   
00000000  // (    0) NOP          nop                                 // mandatory, start with nop.
68000004  // (    1) JUMP         goto 4                              // goto boot sequence, jump over the interrupt vector
68000059  // (    2) JUMP         goto 89                             // goto ISR, pc=2 interrupt destination
6800005a  // (    3) JUMP         goto 90                             // goto Hardbreak, pc=3 hardbreak destination
//   
//   
38100fff  // (    4) LOADID       R0=16'h0fff                         // L_boot, begining of some boot sequence
// do something  
// internal load  
38130040  // (    5) LOADID       R6=64                               // loadid
38138041  // (    6) LOADID       R7=65                               // loadid
//   
1818810f  // (    7) LOAD         R1=RAM[R6]                          // load
1818800f  // (    8) LOAD         R1=RAM[R7]                          // load
181d010f  // (    9) LOAD         R2=RAM[R6++]                        // load
181d000f  // (   10) LOAD         R2=RAM[R7++]                        // load
//   
18198106  // (   11) LOAD         R3=RAM[R6]    pulse->p6             // load
18198007  // (   12) LOAD         R3=RAM[R7]    pulse->p7             // load
181e0106  // (   13) LOAD         R4=RAM[R6++]  pulse->p6             // load 
181e0007  // (   14) LOAD         R4=RAM[R7++]  pulse->p7             // load
//   
38130042  // (   15) LOADID       R6=66                               // loadid
38138043  // (   16) LOADID       R7=67                               // loadid
//   
3800b064  // (   17) LOADIA       R1=RAM[100]                         // loadia
3808b11e  // (   18) LOADIA       R1=RAM[30+R6]                       // loadia  with offset
3809301e  // (   19) LOADIA       R2=RAM[30+R7]                       // loadia  with offset
//   
//   
// external bus load  
38130046  // (   20) LOADID       R6=70                               // loadid
3813804a  // (   21) LOADID       R7=74                               // loadid
//   
1c1d010f  // (   22) LOAD         R2=EXT_BUS[R6++]                    // load
1c1d000f  // (   23) LOAD         R2=EXT_BUS[R7++]                    // load
1c18810f  // (   24) LOAD         R1=EXT_BUS[R6]                      // load
1c18800f  // (   25) LOAD         R1=EXT_BUS[R7]                      // load
//   
1c1e0106  // (   26) LOAD         R4=EXT_BUS[R6++]  pulse->p6         // load 
1c1e0007  // (   27) LOAD         R4=EXT_BUS[R7++]  pulse->p7         // load
1c198106  // (   28) LOAD         R3=EXT_BUS[R6]    pulse->p6         // load
1c198007  // (   29) LOAD         R3=EXT_BUS[R7]    pulse->p7         // load
//   
38130042  // (   30) LOADID       R6=66                               // loadid
38138043  // (   31) LOADID       R7=67                               // loadid
//   
3c00b064  // (   32) LOADIA       R1=EXT_BUS[100]                     // loadia
3c08b11e  // (   33) LOADIA       R1=EXT_BUS[30+R6]                   // loadia  with offset
3c09301e  // (   34) LOADIA       R2=EXT_BUS[30+R7]                   // loadia  with offset
//   
38130044  // (   35) LOADID       R6=68                               // loadid
38138045  // (   36) LOADID       R7=69                               // loadid
3c20b11e  // (   37) LOADIA       R1=EXT_BUS[30,R6[11:0]]             // loadia  with long add
3c21301e  // (   38) LOADIA       R2=EXT_BUS[30,R7[11:0]]             // loadia  with long add
//   
//   
//   
// internal store	  
3811005a  // (   39) LOADID       R2=90                               // 
38130014  // (   40) LOADID       R6=20                               // 
38138018  // (   41) LOADID       R7=24                               // 
78100f90  // (   42) STOREID      RAM[R6]   = 400                     // storeid
78100e90  // (   43) STOREID      RAM[R7]   = 400                     // storeid
2018270f  // (   44) STORE        RAM[R6]   = R2                      // store
2018260f  // (   45) STORE        RAM[R7]   = R2                      // store
201c270f  // (   46) STORE        RAM[R6++] = R2                      // store
201c260f  // (   47) STORE        RAM[R7++] = R2                      // store
//   
3813001e  // (   48) LOADID       R6=30                               // 
38138022  // (   49) LOADID       R7=34                               // 
20182706  // (   50) STORE        RAM[R6]   = R2 pulse->p6            // store + pulse
20182607  // (   51) STORE        RAM[R7]   = R2 pulse->p7            // store + pulse
201c2706  // (   52) STORE        RAM[R6++] = R2 pulse->p6            // store + pulse
201c2607  // (   53) STORE        RAM[R7++] = R2 pulse->p7            // store + pulse
//   
7800261e  // (   54) STOREIA      RAM[30]   = R2                      // storeia 
7808271e  // (   55) STOREIA      RAM[30+R6]= R2                      // storeia with offset
7808261e  // (   56) STOREIA      RAM[30+R7]= R2                      // storeia with offset
//   
//   
// external store	  
3811005a  // (   57) LOADID       R2=90                               // 
38130014  // (   58) LOADID       R6=20                               // 
38138018  // (   59) LOADID       R7=24                               // 
7c100f90  // (   60) STOREID      EXT_BUS[R6]   = 400                 // storeid
7c100e90  // (   61) STOREID      EXT_BUS[R7]   = 400                 // storeid
2418270f  // (   62) STORE        EXT_BUS[R6]   = R2                  // store
2418260f  // (   63) STORE        EXT_BUS[R7]   = R2                  // store
241c270f  // (   64) STORE        EXT_BUS[R6++] = R2                  // store
241c260f  // (   65) STORE        EXT_BUS[R7++] = R2                  // store
//   
3813001e  // (   66) LOADID       R6=30                               // 
38138022  // (   67) LOADID       R7=34                               // 
24182706  // (   68) STORE        EXT_BUS[R6]   = R2 pulse->p6        // store + pulse
24182607  // (   69) STORE        EXT_BUS[R7]   = R2 pulse->p7        // store + pulse
241c2706  // (   70) STORE        EXT_BUS[R6++] = R2 pulse->p6        // store + pulse
241c2607  // (   71) STORE        EXT_BUS[R7++] = R2 pulse->p7        // store + pulse
//   
7c00261e  // (   72) STOREIA      EXT_BUS[30]   = R2                  // storeia 
7c08271e  // (   73) STOREIA      EXT_BUS[30+R6]= R2                  // storeia with offset
7c08261e  // (   74) STOREIA      EXT_BUS[30+R7]= R2                  // storeia with offset
//   
38130030  // (   75) LOADID       R6=48                               // 
38138034  // (   76) LOADID       R7=52                               // 
7c20271e  // (   77) STOREIA      EXT_BUS[30,R6[11:0]]= R2            // storeia with long add
7c20261e  // (   78) STOREIA      EXT_BUS[30,R7[11:0]]= R2            // storeia with long add
//   
//   
// R2=EXT_BUS[{12'habc,R7[11:0]}]  // loadia  with offset  
38198033  // (   79) LOADID       R3=16'h8033                         // 
3810807f  // (   80) LOADID       R1=16'h007f                         // 
500f9600  // (   81) ALU          gr_flag = R3 > R1                   // 
801de055  // (   82) BRANCH       branch (!gr_flag) 85                // 
58000002  // (   83) PULSE        pulse->p2                           // 
68000056  // (   84) JUMP         goto 86                             // 
//   
58000003  // (   85) PULSE        pulse->p3                           // 
//   
//   
//   
//   
//   
// do something  
3812800a  // (   86) LOADID       R5 = 10                             // 
6810005b  // (   87) JUMP         gosub 91                            // 
801cf058  // (   88) BRANCH       branch !c14 88                      // c14 tied to "0" 
//   
//   
// //////////////////////////////////////////////  
// routines  
// //////////////////////////////////////////////  
// //////////////////////////////////////////////  
//   
70100000  // (   89) RETURN       rti                                 // 
//   
68000004  // (   90) JUMP         goto 4                              // 
//   
// //////////////////////////////////////////////  
// ///////// L_delay ////////////////////////////  
// //////////////////////////////////////////////  
//   
48148400  // (   91) LOOP         loop 1 1 R5                         // 
00000000  // (   92) NOP          nop                                 // 
70000000  // (   93) RETURN       return                              // 
//   
//   
//   
