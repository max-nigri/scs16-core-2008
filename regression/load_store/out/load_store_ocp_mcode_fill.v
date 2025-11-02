ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (    0) 00000000 NOP          nop                                 // mandatory, start with nop.
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
ocp_write(`SCS_GPR0, 16'h0004); // 01101000000000000000000000000100// (    1) 68000004 JUMP         goto 4                              // goto boot sequence, jump over the interrupt vector
ocp_write(`SCS_GPR0, 16'h6800); // 68000004
ocp_write(`SCS_GPR0, 16'h0059); // 01101000000000000000000001011001// (    2) 68000059 JUMP         goto 89                             // goto ISR, pc=2 interrupt destination
ocp_write(`SCS_GPR0, 16'h6800); // 68000059
ocp_write(`SCS_GPR0, 16'h005a); // 01101000000000000000000001011010// (    3) 6800005a JUMP         goto 90                             // goto Hardbreak, pc=3 hardbreak destination
ocp_write(`SCS_GPR0, 16'h6800); // 6800005a
ocp_write(`SCS_GPR0, 16'h0fff); // 00111000000100000000111111111111// (    4) 38100fff LOADID       R0=16'h0fff                         // L_boot, begining of some boot sequence
ocp_write(`SCS_GPR0, 16'h3810); // 38100fff
ocp_write(`SCS_GPR0, 16'h0040); // 00111000000100110000000001000000// (    5) 38130040 LOADID       R6=64                               // loadid
ocp_write(`SCS_GPR0, 16'h3813); // 38130040
ocp_write(`SCS_GPR0, 16'h8041); // 00111000000100111000000001000001// (    6) 38138041 LOADID       R7=65                               // loadid
ocp_write(`SCS_GPR0, 16'h3813); // 38138041
ocp_write(`SCS_GPR0, 16'h810f); // 00011000000110001000000100001111// (    7) 1818810f LOAD         R1=RAM[R6]                          // load
ocp_write(`SCS_GPR0, 16'h1818); // 1818810f
ocp_write(`SCS_GPR0, 16'h800f); // 00011000000110001000000000001111// (    8) 1818800f LOAD         R1=RAM[R7]                          // load
ocp_write(`SCS_GPR0, 16'h1818); // 1818800f
ocp_write(`SCS_GPR0, 16'h010f); // 00011000000111010000000100001111// (    9) 181d010f LOAD         R2=RAM[R6++]                        // load
ocp_write(`SCS_GPR0, 16'h181d); // 181d010f
ocp_write(`SCS_GPR0, 16'h000f); // 00011000000111010000000000001111// (   10) 181d000f LOAD         R2=RAM[R7++]                        // load
ocp_write(`SCS_GPR0, 16'h181d); // 181d000f
ocp_write(`SCS_GPR0, 16'h8106); // 00011000000110011000000100000110// (   11) 18198106 LOAD         R3=RAM[R6]    pulse->p6             // load
ocp_write(`SCS_GPR0, 16'h1819); // 18198106
ocp_write(`SCS_GPR0, 16'h8007); // 00011000000110011000000000000111// (   12) 18198007 LOAD         R3=RAM[R7]    pulse->p7             // load
ocp_write(`SCS_GPR0, 16'h1819); // 18198007
ocp_write(`SCS_GPR0, 16'h0106); // 00011000000111100000000100000110// (   13) 181e0106 LOAD         R4=RAM[R6++]  pulse->p6             // load 
ocp_write(`SCS_GPR0, 16'h181e); // 181e0106
ocp_write(`SCS_GPR0, 16'h0007); // 00011000000111100000000000000111// (   14) 181e0007 LOAD         R4=RAM[R7++]  pulse->p7             // load
ocp_write(`SCS_GPR0, 16'h181e); // 181e0007
ocp_write(`SCS_GPR0, 16'h0042); // 00111000000100110000000001000010// (   15) 38130042 LOADID       R6=66                               // loadid
ocp_write(`SCS_GPR0, 16'h3813); // 38130042
ocp_write(`SCS_GPR0, 16'h8043); // 00111000000100111000000001000011// (   16) 38138043 LOADID       R7=67                               // loadid
ocp_write(`SCS_GPR0, 16'h3813); // 38138043
ocp_write(`SCS_GPR0, 16'hb064); // 00111000000000001011000001100100// (   17) 3800b064 LOADIA       R1=RAM[100]                         // loadia
ocp_write(`SCS_GPR0, 16'h3800); // 3800b064
ocp_write(`SCS_GPR0, 16'hb11e); // 00111000000010001011000100011110// (   18) 3808b11e LOADIA       R1=RAM[30+R6]                       // loadia  with offset
ocp_write(`SCS_GPR0, 16'h3808); // 3808b11e
ocp_write(`SCS_GPR0, 16'h301e); // 00111000000010010011000000011110// (   19) 3809301e LOADIA       R2=RAM[30+R7]                       // loadia  with offset
ocp_write(`SCS_GPR0, 16'h3809); // 3809301e
ocp_write(`SCS_GPR0, 16'h0046); // 00111000000100110000000001000110// (   20) 38130046 LOADID       R6=70                               // loadid
ocp_write(`SCS_GPR0, 16'h3813); // 38130046
ocp_write(`SCS_GPR0, 16'h804a); // 00111000000100111000000001001010// (   21) 3813804a LOADID       R7=74                               // loadid
ocp_write(`SCS_GPR0, 16'h3813); // 3813804a
ocp_write(`SCS_GPR0, 16'h010f); // 00011100000111010000000100001111// (   22) 1c1d010f LOAD         R2=EXT_BUS[R6++]                    // load
ocp_write(`SCS_GPR0, 16'h1c1d); // 1c1d010f
ocp_write(`SCS_GPR0, 16'h000f); // 00011100000111010000000000001111// (   23) 1c1d000f LOAD         R2=EXT_BUS[R7++]                    // load
ocp_write(`SCS_GPR0, 16'h1c1d); // 1c1d000f
ocp_write(`SCS_GPR0, 16'h810f); // 00011100000110001000000100001111// (   24) 1c18810f LOAD         R1=EXT_BUS[R6]                      // load
ocp_write(`SCS_GPR0, 16'h1c18); // 1c18810f
ocp_write(`SCS_GPR0, 16'h800f); // 00011100000110001000000000001111// (   25) 1c18800f LOAD         R1=EXT_BUS[R7]                      // load
ocp_write(`SCS_GPR0, 16'h1c18); // 1c18800f
ocp_write(`SCS_GPR0, 16'h0106); // 00011100000111100000000100000110// (   26) 1c1e0106 LOAD         R4=EXT_BUS[R6++]  pulse->p6         // load 
ocp_write(`SCS_GPR0, 16'h1c1e); // 1c1e0106
ocp_write(`SCS_GPR0, 16'h0007); // 00011100000111100000000000000111// (   27) 1c1e0007 LOAD         R4=EXT_BUS[R7++]  pulse->p7         // load
ocp_write(`SCS_GPR0, 16'h1c1e); // 1c1e0007
ocp_write(`SCS_GPR0, 16'h8106); // 00011100000110011000000100000110// (   28) 1c198106 LOAD         R3=EXT_BUS[R6]    pulse->p6         // load
ocp_write(`SCS_GPR0, 16'h1c19); // 1c198106
ocp_write(`SCS_GPR0, 16'h8007); // 00011100000110011000000000000111// (   29) 1c198007 LOAD         R3=EXT_BUS[R7]    pulse->p7         // load
ocp_write(`SCS_GPR0, 16'h1c19); // 1c198007
ocp_write(`SCS_GPR0, 16'h0042); // 00111000000100110000000001000010// (   30) 38130042 LOADID       R6=66                               // loadid
ocp_write(`SCS_GPR0, 16'h3813); // 38130042
ocp_write(`SCS_GPR0, 16'h8043); // 00111000000100111000000001000011// (   31) 38138043 LOADID       R7=67                               // loadid
ocp_write(`SCS_GPR0, 16'h3813); // 38138043
ocp_write(`SCS_GPR0, 16'hb064); // 00111100000000001011000001100100// (   32) 3c00b064 LOADIA       R1=EXT_BUS[100]                     // loadia
ocp_write(`SCS_GPR0, 16'h3c00); // 3c00b064
ocp_write(`SCS_GPR0, 16'hb11e); // 00111100000010001011000100011110// (   33) 3c08b11e LOADIA       R1=EXT_BUS[30+R6]                   // loadia  with offset
ocp_write(`SCS_GPR0, 16'h3c08); // 3c08b11e
ocp_write(`SCS_GPR0, 16'h301e); // 00111100000010010011000000011110// (   34) 3c09301e LOADIA       R2=EXT_BUS[30+R7]                   // loadia  with offset
ocp_write(`SCS_GPR0, 16'h3c09); // 3c09301e
ocp_write(`SCS_GPR0, 16'h0044); // 00111000000100110000000001000100// (   35) 38130044 LOADID       R6=68                               // loadid
ocp_write(`SCS_GPR0, 16'h3813); // 38130044
ocp_write(`SCS_GPR0, 16'h8045); // 00111000000100111000000001000101// (   36) 38138045 LOADID       R7=69                               // loadid
ocp_write(`SCS_GPR0, 16'h3813); // 38138045
ocp_write(`SCS_GPR0, 16'hb11e); // 00111100001000001011000100011110// (   37) 3c20b11e LOADIA       R1=EXT_BUS[30,R6[11:0]]             // loadia  with long add
ocp_write(`SCS_GPR0, 16'h3c20); // 3c20b11e
ocp_write(`SCS_GPR0, 16'h301e); // 00111100001000010011000000011110// (   38) 3c21301e LOADIA       R2=EXT_BUS[30,R7[11:0]]             // loadia  with long add
ocp_write(`SCS_GPR0, 16'h3c21); // 3c21301e
ocp_write(`SCS_GPR0, 16'h005a); // 00111000000100010000000001011010// (   39) 3811005a LOADID       R2=90                               // 
ocp_write(`SCS_GPR0, 16'h3811); // 3811005a
ocp_write(`SCS_GPR0, 16'h0014); // 00111000000100110000000000010100// (   40) 38130014 LOADID       R6=20                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38130014
ocp_write(`SCS_GPR0, 16'h8018); // 00111000000100111000000000011000// (   41) 38138018 LOADID       R7=24                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38138018
ocp_write(`SCS_GPR0, 16'h0f90); // 01111000000100000000111110010000// (   42) 78100f90 STOREID      RAM[R6]   = 400                     // storeid
ocp_write(`SCS_GPR0, 16'h7810); // 78100f90
ocp_write(`SCS_GPR0, 16'h0e90); // 01111000000100000000111010010000// (   43) 78100e90 STOREID      RAM[R7]   = 400                     // storeid
ocp_write(`SCS_GPR0, 16'h7810); // 78100e90
ocp_write(`SCS_GPR0, 16'h270f); // 00100000000110000010011100001111// (   44) 2018270f STORE        RAM[R6]   = R2                      // store
ocp_write(`SCS_GPR0, 16'h2018); // 2018270f
ocp_write(`SCS_GPR0, 16'h260f); // 00100000000110000010011000001111// (   45) 2018260f STORE        RAM[R7]   = R2                      // store
ocp_write(`SCS_GPR0, 16'h2018); // 2018260f
ocp_write(`SCS_GPR0, 16'h270f); // 00100000000111000010011100001111// (   46) 201c270f STORE        RAM[R6++] = R2                      // store
ocp_write(`SCS_GPR0, 16'h201c); // 201c270f
ocp_write(`SCS_GPR0, 16'h260f); // 00100000000111000010011000001111// (   47) 201c260f STORE        RAM[R7++] = R2                      // store
ocp_write(`SCS_GPR0, 16'h201c); // 201c260f
ocp_write(`SCS_GPR0, 16'h001e); // 00111000000100110000000000011110// (   48) 3813001e LOADID       R6=30                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 3813001e
ocp_write(`SCS_GPR0, 16'h8022); // 00111000000100111000000000100010// (   49) 38138022 LOADID       R7=34                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38138022
ocp_write(`SCS_GPR0, 16'h2706); // 00100000000110000010011100000110// (   50) 20182706 STORE        RAM[R6]   = R2 pulse->p6            // store + pulse
ocp_write(`SCS_GPR0, 16'h2018); // 20182706
ocp_write(`SCS_GPR0, 16'h2607); // 00100000000110000010011000000111// (   51) 20182607 STORE        RAM[R7]   = R2 pulse->p7            // store + pulse
ocp_write(`SCS_GPR0, 16'h2018); // 20182607
ocp_write(`SCS_GPR0, 16'h2706); // 00100000000111000010011100000110// (   52) 201c2706 STORE        RAM[R6++] = R2 pulse->p6            // store + pulse
ocp_write(`SCS_GPR0, 16'h201c); // 201c2706
ocp_write(`SCS_GPR0, 16'h2607); // 00100000000111000010011000000111// (   53) 201c2607 STORE        RAM[R7++] = R2 pulse->p7            // store + pulse
ocp_write(`SCS_GPR0, 16'h201c); // 201c2607
ocp_write(`SCS_GPR0, 16'h261e); // 01111000000000000010011000011110// (   54) 7800261e STOREIA      RAM[30]   = R2                      // storeia 
ocp_write(`SCS_GPR0, 16'h7800); // 7800261e
ocp_write(`SCS_GPR0, 16'h271e); // 01111000000010000010011100011110// (   55) 7808271e STOREIA      RAM[30+R6]= R2                      // storeia with offset
ocp_write(`SCS_GPR0, 16'h7808); // 7808271e
ocp_write(`SCS_GPR0, 16'h261e); // 01111000000010000010011000011110// (   56) 7808261e STOREIA      RAM[30+R7]= R2                      // storeia with offset
ocp_write(`SCS_GPR0, 16'h7808); // 7808261e
ocp_write(`SCS_GPR0, 16'h005a); // 00111000000100010000000001011010// (   57) 3811005a LOADID       R2=90                               // 
ocp_write(`SCS_GPR0, 16'h3811); // 3811005a
ocp_write(`SCS_GPR0, 16'h0014); // 00111000000100110000000000010100// (   58) 38130014 LOADID       R6=20                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38130014
ocp_write(`SCS_GPR0, 16'h8018); // 00111000000100111000000000011000// (   59) 38138018 LOADID       R7=24                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38138018
ocp_write(`SCS_GPR0, 16'h0f90); // 01111100000100000000111110010000// (   60) 7c100f90 STOREID      EXT_BUS[R6]   = 400                 // storeid
ocp_write(`SCS_GPR0, 16'h7c10); // 7c100f90
ocp_write(`SCS_GPR0, 16'h0e90); // 01111100000100000000111010010000// (   61) 7c100e90 STOREID      EXT_BUS[R7]   = 400                 // storeid
ocp_write(`SCS_GPR0, 16'h7c10); // 7c100e90
ocp_write(`SCS_GPR0, 16'h270f); // 00100100000110000010011100001111// (   62) 2418270f STORE        EXT_BUS[R6]   = R2                  // store
ocp_write(`SCS_GPR0, 16'h2418); // 2418270f
ocp_write(`SCS_GPR0, 16'h260f); // 00100100000110000010011000001111// (   63) 2418260f STORE        EXT_BUS[R7]   = R2                  // store
ocp_write(`SCS_GPR0, 16'h2418); // 2418260f
ocp_write(`SCS_GPR0, 16'h270f); // 00100100000111000010011100001111// (   64) 241c270f STORE        EXT_BUS[R6++] = R2                  // store
ocp_write(`SCS_GPR0, 16'h241c); // 241c270f
ocp_write(`SCS_GPR0, 16'h260f); // 00100100000111000010011000001111// (   65) 241c260f STORE        EXT_BUS[R7++] = R2                  // store
ocp_write(`SCS_GPR0, 16'h241c); // 241c260f
ocp_write(`SCS_GPR0, 16'h001e); // 00111000000100110000000000011110// (   66) 3813001e LOADID       R6=30                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 3813001e
ocp_write(`SCS_GPR0, 16'h8022); // 00111000000100111000000000100010// (   67) 38138022 LOADID       R7=34                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38138022
ocp_write(`SCS_GPR0, 16'h2706); // 00100100000110000010011100000110// (   68) 24182706 STORE        EXT_BUS[R6]   = R2 pulse->p6        // store + pulse
ocp_write(`SCS_GPR0, 16'h2418); // 24182706
ocp_write(`SCS_GPR0, 16'h2607); // 00100100000110000010011000000111// (   69) 24182607 STORE        EXT_BUS[R7]   = R2 pulse->p7        // store + pulse
ocp_write(`SCS_GPR0, 16'h2418); // 24182607
ocp_write(`SCS_GPR0, 16'h2706); // 00100100000111000010011100000110// (   70) 241c2706 STORE        EXT_BUS[R6++] = R2 pulse->p6        // store + pulse
ocp_write(`SCS_GPR0, 16'h241c); // 241c2706
ocp_write(`SCS_GPR0, 16'h2607); // 00100100000111000010011000000111// (   71) 241c2607 STORE        EXT_BUS[R7++] = R2 pulse->p7        // store + pulse
ocp_write(`SCS_GPR0, 16'h241c); // 241c2607
ocp_write(`SCS_GPR0, 16'h261e); // 01111100000000000010011000011110// (   72) 7c00261e STOREIA      EXT_BUS[30]   = R2                  // storeia 
ocp_write(`SCS_GPR0, 16'h7c00); // 7c00261e
ocp_write(`SCS_GPR0, 16'h271e); // 01111100000010000010011100011110// (   73) 7c08271e STOREIA      EXT_BUS[30+R6]= R2                  // storeia with offset
ocp_write(`SCS_GPR0, 16'h7c08); // 7c08271e
ocp_write(`SCS_GPR0, 16'h261e); // 01111100000010000010011000011110// (   74) 7c08261e STOREIA      EXT_BUS[30+R7]= R2                  // storeia with offset
ocp_write(`SCS_GPR0, 16'h7c08); // 7c08261e
ocp_write(`SCS_GPR0, 16'h0030); // 00111000000100110000000000110000// (   75) 38130030 LOADID       R6=48                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38130030
ocp_write(`SCS_GPR0, 16'h8034); // 00111000000100111000000000110100// (   76) 38138034 LOADID       R7=52                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38138034
ocp_write(`SCS_GPR0, 16'h271e); // 01111100001000000010011100011110// (   77) 7c20271e STOREIA      EXT_BUS[30,R6[11:0]]= R2            // storeia with long add
ocp_write(`SCS_GPR0, 16'h7c20); // 7c20271e
ocp_write(`SCS_GPR0, 16'h261e); // 01111100001000000010011000011110// (   78) 7c20261e STOREIA      EXT_BUS[30,R7[11:0]]= R2            // storeia with long add
ocp_write(`SCS_GPR0, 16'h7c20); // 7c20261e
ocp_write(`SCS_GPR0, 16'h8033); // 00111000000110011000000000110011// (   79) 38198033 LOADID       R3=16'h8033                         // 
ocp_write(`SCS_GPR0, 16'h3819); // 38198033
ocp_write(`SCS_GPR0, 16'h807f); // 00111000000100001000000001111111// (   80) 3810807f LOADID       R1=16'h007f                         // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810807f
ocp_write(`SCS_GPR0, 16'h9600); // 01010000000011111001011000000000// (   81) 500f9600 ALU          gr_flag = R3 > R1                   // 
ocp_write(`SCS_GPR0, 16'h500f); // 500f9600
ocp_write(`SCS_GPR0, 16'he055); // 10000000000111011110000001010101// (   82) 801de055 BRANCH       branch (!gr_flag) 85                // 
ocp_write(`SCS_GPR0, 16'h801d); // 801de055
ocp_write(`SCS_GPR0, 16'h0002); // 01011000000000000000000000000010// (   83) 58000002 PULSE        pulse->p2                           // 
ocp_write(`SCS_GPR0, 16'h5800); // 58000002
ocp_write(`SCS_GPR0, 16'h0056); // 01101000000000000000000001010110// (   84) 68000056 JUMP         goto 86                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000056
ocp_write(`SCS_GPR0, 16'h0003); // 01011000000000000000000000000011// (   85) 58000003 PULSE        pulse->p3                           // 
ocp_write(`SCS_GPR0, 16'h5800); // 58000003
ocp_write(`SCS_GPR0, 16'h800a); // 00111000000100101000000000001010// (   86) 3812800a LOADID       R5 = 10                             // 
ocp_write(`SCS_GPR0, 16'h3812); // 3812800a
ocp_write(`SCS_GPR0, 16'h005b); // 01101000000100000000000001011011// (   87) 6810005b JUMP         gosub 91                            // 
ocp_write(`SCS_GPR0, 16'h6810); // 6810005b
ocp_write(`SCS_GPR0, 16'hf058); // 10000000000111001111000001011000// (   88) 801cf058 BRANCH       branch !c14 88                      // c14 tied to "0" 
ocp_write(`SCS_GPR0, 16'h801c); // 801cf058
ocp_write(`SCS_GPR0, 16'h0000); // 01110000000100000000000000000000// (   89) 70100000 RETURN       rti                                 // 
ocp_write(`SCS_GPR0, 16'h7010); // 70100000
ocp_write(`SCS_GPR0, 16'h0004); // 01101000000000000000000000000100// (   90) 68000004 JUMP         goto 4                              // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000004
ocp_write(`SCS_GPR0, 16'h8400); // 01001000000101001000010000000000// (   91) 48148400 LOOP         loop 1 1 R5                         // 
ocp_write(`SCS_GPR0, 16'h4814); // 48148400
ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (   92) 00000000 NOP          nop                                 // 
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
ocp_write(`SCS_GPR0, 16'h0000); // 01110000000000000000000000000000// (   93) 70000000 RETURN       return                              // 
ocp_write(`SCS_GPR0, 16'h7000); // 70000000
