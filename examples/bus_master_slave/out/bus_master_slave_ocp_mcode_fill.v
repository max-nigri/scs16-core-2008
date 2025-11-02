ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (    0) 00000000 NOP          nop                                 // 
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
ocp_write(`SCS_GPR0, 16'h0004); // 01101000000000000000000000000100// (    1) 68000004 JUMP         goto 4                              // goto boot sequence
ocp_write(`SCS_GPR0, 16'h6800); // 68000004
ocp_write(`SCS_GPR0, 16'h000c); // 01101000000000000000000000001100// (    2) 6800000c JUMP         goto 12                             // goto ISR
ocp_write(`SCS_GPR0, 16'h6800); // 6800000c
ocp_write(`SCS_GPR0, 16'h000d); // 01101000000000000000000000001101// (    3) 6800000d JUMP         goto 13                             // prepare 
ocp_write(`SCS_GPR0, 16'h6800); // 6800000d
ocp_write(`SCS_GPR0, 16'h0fff); // 00111000000100000000111111111111// (    4) 38100fff LOADID       R0=16'h0fff                         // L_boot, begining of some boot sequence
ocp_write(`SCS_GPR0, 16'h3810); // 38100fff
ocp_write(`SCS_GPR0, 16'h86f0); // 01111000000000111000011011110000// (    5) 780386f0 STOREIA      RAM[`APP_OUT0_ADDR]=R0              // init app out regs
ocp_write(`SCS_GPR0, 16'h7803); // 780386f0
ocp_write(`SCS_GPR0, 16'h0014); // 00111000000100110000000000010100// (    6) 38130014 LOADID       R6=20                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38130014
ocp_write(`SCS_GPR0, 16'h670f); // 00100100000110000110011100001111// (    7) 2418670f STORE        EXT_BUS[R6] = R6                    // external bus write
ocp_write(`SCS_GPR0, 16'h2418); // 2418670f
ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (    8) 00000000 NOP          nop                                 // 
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
ocp_write(`SCS_GPR0, 16'h810f); // 00011100000110101000000100001111// (    9) 1c1a810f LOAD         R5 = EXT_BUS[R6]                    // external bus read 
ocp_write(`SCS_GPR0, 16'h1c1a); // 1c1a810f
ocp_write(`SCS_GPR0, 16'h000e); // 01101000000100000000000000001110// (   10) 6810000e JUMP         gosub 14                            // 
ocp_write(`SCS_GPR0, 16'h6810); // 6810000e
ocp_write(`SCS_GPR0, 16'hf00b); // 10000000000111001111000000001011// (   11) 801cf00b BRANCH       branch !c14 11                      // c14 tied to "0" 
ocp_write(`SCS_GPR0, 16'h801c); // 801cf00b
ocp_write(`SCS_GPR0, 16'h0000); // 01110000000100000000000000000000// (   12) 70100000 RETURN       rti                                 // 
ocp_write(`SCS_GPR0, 16'h7010); // 70100000
ocp_write(`SCS_GPR0, 16'h0004); // 01101000000000000000000000000100// (   13) 68000004 JUMP         goto 4                              // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000004
ocp_write(`SCS_GPR0, 16'h8400); // 01001000000101001000010000000000// (   14) 48148400 LOOP         loop 1 1 R5                         // 
ocp_write(`SCS_GPR0, 16'h4814); // 48148400
ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (   15) 00000000 NOP          nop                                 // 
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
ocp_write(`SCS_GPR0, 16'h0000); // 01110000000000000000000000000000// (   16) 70000000 RETURN       return                              // 
ocp_write(`SCS_GPR0, 16'h7000); // 70000000
