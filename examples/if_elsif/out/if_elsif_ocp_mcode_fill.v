ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (    0) 00000000 NOP          nop                                 // mandatory, start with nop.
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
ocp_write(`SCS_GPR0, 16'h0004); // 01101000000000000000000000000100// (    1) 68000004 JUMP         goto 4                              // goto boot sequence, jump over the interrupt vector
ocp_write(`SCS_GPR0, 16'h6800); // 68000004
ocp_write(`SCS_GPR0, 16'h0047); // 01101000000000000000000001000111// (    2) 68000047 JUMP         goto 71                             // goto ISR, pc=2 interrupt destination
ocp_write(`SCS_GPR0, 16'h6800); // 68000047
ocp_write(`SCS_GPR0, 16'h0048); // 01101000000000000000000001001000// (    3) 68000048 JUMP         goto 72                             // goto Hardbreak, pc=3 hardbreak destination
ocp_write(`SCS_GPR0, 16'h6800); // 68000048
ocp_write(`SCS_GPR0, 16'h0fff); // 00111000000100000000111111111111// (    4) 38100fff LOADID       R0=16'h0fff                         // L_boot, begining of some boot sequence
ocp_write(`SCS_GPR0, 16'h3810); // 38100fff
ocp_write(`SCS_GPR0, 16'h86f0); // 01111000000000111000011011110000// (    5) 780386f0 STOREIA      RAM[`APP_OUT0_ADDR]=R0              // init app out regs
ocp_write(`SCS_GPR0, 16'h7803); // 780386f0
ocp_write(`SCS_GPR0, 16'h8005); // 00111000000100101000000000000101// (    6) 38128005 LOADID       R5=5                                // 
ocp_write(`SCS_GPR0, 16'h3812); // 38128005
ocp_write(`SCS_GPR0, 16'h9009); // 10000000000101111001000000001001// (    7) 80179009 BRANCH       branch (!R5[2]) 9                   // bit of reg branch
ocp_write(`SCS_GPR0, 16'h8017); // 80179009
ocp_write(`SCS_GPR0, 16'h8001); // 00111000000100001000000000000001// (    8) 38108001 LOADID       R1=1                                // branch not taken
ocp_write(`SCS_GPR0, 16'h3810); // 38108001
ocp_write(`SCS_GPR0, 16'h100b); // 10000000000101110001000000001011// (    9) 8017100b BRANCH       branch (R5[2]) 11                   // !bit of reg branch
ocp_write(`SCS_GPR0, 16'h8017); // 8017100b
ocp_write(`SCS_GPR0, 16'h8002); // 00111000000100001000000000000010// (   10) 38108002 LOADID       R1=2                                // branch not taken
ocp_write(`SCS_GPR0, 16'h3810); // 38108002
ocp_write(`SCS_GPR0, 16'h801e); // 00111000000100001000000000011110// (   11) 3810801e LOADID       R1=30                               // condition is set to 16'hff00
ocp_write(`SCS_GPR0, 16'h3810); // 3810801e
ocp_write(`SCS_GPR0, 16'h800e); // 10000000000111001000000000001110// (   12) 801c800e BRANCH       branch (!c0) 14                     // bit of condition branch
ocp_write(`SCS_GPR0, 16'h801c); // 801c800e
ocp_write(`SCS_GPR0, 16'h8001); // 00111000000100001000000000000001// (   13) 38108001 LOADID       R1=1                                // branch not taken
ocp_write(`SCS_GPR0, 16'h3810); // 38108001
ocp_write(`SCS_GPR0, 16'hc010); // 10000000000111001100000000010000// (   14) 801cc010 BRANCH       branch (!c8) 16                     // !bit of reg branch
ocp_write(`SCS_GPR0, 16'h801c); // 801cc010
ocp_write(`SCS_GPR0, 16'h8002); // 00111000000100001000000000000010// (   15) 38108002 LOADID       R1=2                                // branch not taken
ocp_write(`SCS_GPR0, 16'h3810); // 38108002
ocp_write(`SCS_GPR0, 16'h8028); // 00111000000100001000000000101000// (   16) 38108028 LOADID       R1=40                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 38108028
ocp_write(`SCS_GPR0, 16'h8014); // 10000000000111001000000000010100// (   17) 801c8014 BRANCH       branch (!c0) 20                     // bit of condition branch
ocp_write(`SCS_GPR0, 16'h801c); // 801c8014
ocp_write(`SCS_GPR0, 16'h8007); // 00111000000100001000000000000111// (   18) 38108007 LOADID       R1=7                                // branch not taken
ocp_write(`SCS_GPR0, 16'h3810); // 38108007
ocp_write(`SCS_GPR0, 16'h0015); // 01101000000000000000000000010101// (   19) 68000015 JUMP         goto 21                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000015
ocp_write(`SCS_GPR0, 16'h8008); // 00111000000100001000000000001000// (   20) 38108008 LOADID       R1=8                                // branch taken
ocp_write(`SCS_GPR0, 16'h3810); // 38108008
ocp_write(`SCS_GPR0, 16'hc018); // 10000000000111001100000000011000// (   21) 801cc018 BRANCH       branch (!c8) 24                     // bit of condition branch
ocp_write(`SCS_GPR0, 16'h801c); // 801cc018
ocp_write(`SCS_GPR0, 16'h8009); // 00111000000100001000000000001001// (   22) 38108009 LOADID       R1=9                                // branch not taken
ocp_write(`SCS_GPR0, 16'h3810); // 38108009
ocp_write(`SCS_GPR0, 16'h0019); // 01101000000000000000000000011001// (   23) 68000019 JUMP         goto 25                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000019
ocp_write(`SCS_GPR0, 16'h800a); // 00111000000100001000000000001010// (   24) 3810800a LOADID       R1=10                               // branch taken
ocp_write(`SCS_GPR0, 16'h3810); // 3810800a
ocp_write(`SCS_GPR0, 16'h8020); // 10000000000111001000000000100000// (   25) 801c8020 BRANCH       branch (!c0) 32                     // bit of condition branch
ocp_write(`SCS_GPR0, 16'h801c); // 801c8020
ocp_write(`SCS_GPR0, 16'h881e); // 10000000000111001000100000011110// (   26) 801c881e BRANCH       branch (!c1) 30                     // 
ocp_write(`SCS_GPR0, 16'h801c); // 801c881e
ocp_write(`SCS_GPR0, 16'h901d); // 10000000000111001001000000011101// (   27) 801c901d BRANCH       branch (!c2) 29                     // 
ocp_write(`SCS_GPR0, 16'h801c); // 801c901d
ocp_write(`SCS_GPR0, 16'h800b); // 00111000000100001000000000001011// (   28) 3810800b LOADID       R1=11                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810800b
ocp_write(`SCS_GPR0, 16'h800c); // 00111000000100001000000000001100// (   29) 3810800c LOADID       R1=12                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810800c
ocp_write(`SCS_GPR0, 16'h800d); // 00111000000100001000000000001101// (   30) 3810800d LOADID       R1=13                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810800d
ocp_write(`SCS_GPR0, 16'h0021); // 01101000000000000000000000100001// (   31) 68000021 JUMP         goto 33                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000021
ocp_write(`SCS_GPR0, 16'h800e); // 00111000000100001000000000001110// (   32) 3810800e LOADID       R1=14                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810800e
ocp_write(`SCS_GPR0, 16'hb024); // 10000000000111001011000000100100// (   33) 801cb024 BRANCH       branch (!c6) 36                     // if elsif start
ocp_write(`SCS_GPR0, 16'h801c); // 801cb024
ocp_write(`SCS_GPR0, 16'h8014); // 00111000000100001000000000010100// (   34) 38108014 LOADID       R1=20                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 38108014
ocp_write(`SCS_GPR0, 16'h002e); // 01101000000000000000000000101110// (   35) 6800002e JUMP         goto 46                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 6800002e
ocp_write(`SCS_GPR0, 16'hb827); // 10000000000111001011100000100111// (   36) 801cb827 BRANCH       branch (!c7) 39                     // 
ocp_write(`SCS_GPR0, 16'h801c); // 801cb827
ocp_write(`SCS_GPR0, 16'h8015); // 00111000000100001000000000010101// (   37) 38108015 LOADID       R1=21                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 38108015
ocp_write(`SCS_GPR0, 16'h002e); // 01101000000000000000000000101110// (   38) 6800002e JUMP         goto 46                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 6800002e
ocp_write(`SCS_GPR0, 16'hc02a); // 10000000000111001100000000101010// (   39) 801cc02a BRANCH       branch (!c8) 42                     // 
ocp_write(`SCS_GPR0, 16'h801c); // 801cc02a
ocp_write(`SCS_GPR0, 16'h8016); // 00111000000100001000000000010110// (   40) 38108016 LOADID       R1=22                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 38108016
ocp_write(`SCS_GPR0, 16'h002e); // 01101000000000000000000000101110// (   41) 6800002e JUMP         goto 46                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 6800002e
ocp_write(`SCS_GPR0, 16'hc82d); // 10000000000111001100100000101101// (   42) 801cc82d BRANCH       branch (!c9) 45                     // 
ocp_write(`SCS_GPR0, 16'h801c); // 801cc82d
ocp_write(`SCS_GPR0, 16'h8017); // 00111000000100001000000000010111// (   43) 38108017 LOADID       R1=23                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 38108017
ocp_write(`SCS_GPR0, 16'h002e); // 01101000000000000000000000101110// (   44) 6800002e JUMP         goto 46                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 6800002e
ocp_write(`SCS_GPR0, 16'h8018); // 00111000000100001000000000011000// (   45) 38108018 LOADID       R1=24                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 38108018
ocp_write(`SCS_GPR0, 16'h0028); // 00111000000100010000000000101000// (   46) 38110028 LOADID       R2=40                               // 
ocp_write(`SCS_GPR0, 16'h3811); // 38110028
ocp_write(`SCS_GPR0, 16'ha628); // 10001000000000111010011000101000// (   47) 8803a628 ALUI         gr_flag = R2>40                     // 
ocp_write(`SCS_GPR0, 16'h8803); // 8803a628
ocp_write(`SCS_GPR0, 16'he033); // 10000000000111011110000000110011// (   48) 801de033 BRANCH       branch (!gr_flag) 51                // alu assist branch
ocp_write(`SCS_GPR0, 16'h801d); // 801de033
ocp_write(`SCS_GPR0, 16'h801e); // 00111000000100001000000000011110// (   49) 3810801e LOADID       R1=30                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810801e
ocp_write(`SCS_GPR0, 16'h0034); // 01101000000000000000000000110100// (   50) 68000034 JUMP         goto 52                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000034
ocp_write(`SCS_GPR0, 16'h801f); // 00111000000100001000000000011111// (   51) 3810801f LOADID       R1=31                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810801f
ocp_write(`SCS_GPR0, 16'h0028); // 00111000000100010000000000101000// (   52) 38110028 LOADID       R2=40                               // 
ocp_write(`SCS_GPR0, 16'h3811); // 38110028
ocp_write(`SCS_GPR0, 16'ha628); // 10001000000000111010011000101000// (   53) 8803a628 ALUI         gr_flag = R2>40                     // 
ocp_write(`SCS_GPR0, 16'h8803); // 8803a628
ocp_write(`SCS_GPR0, 16'he038); // 10000000000111011110000000111000// (   54) 801de038 BRANCH       branch (!gr_flag) 56                // alu assist branch
ocp_write(`SCS_GPR0, 16'h801d); // 801de038
ocp_write(`SCS_GPR0, 16'h801e); // 00111000000100001000000000011110// (   55) 3810801e LOADID       R1=30                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810801e
ocp_write(`SCS_GPR0, 16'h0028); // 00111000000100010000000000101000// (   56) 38110028 LOADID       R2=40                               // 
ocp_write(`SCS_GPR0, 16'h3811); // 38110028
ocp_write(`SCS_GPR0, 16'ha628); // 10001000000000111010011000101000// (   57) 8803a628 ALUI         gr_flag = R2>40                     // explicit alu compare
ocp_write(`SCS_GPR0, 16'h8803); // 8803a628
ocp_write(`SCS_GPR0, 16'he83d); // 10000000000111011110100000111101// (   58) 801de83d BRANCH       branch (!eq_flag) 61                // start of alu if elsif emulation
ocp_write(`SCS_GPR0, 16'h801d); // 801de83d
ocp_write(`SCS_GPR0, 16'h801e); // 00111000000100001000000000011110// (   59) 3810801e LOADID       R1=30                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810801e
ocp_write(`SCS_GPR0, 16'h0042); // 01101000000000000000000001000010// (   60) 68000042 JUMP         goto 66                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000042
ocp_write(`SCS_GPR0, 16'hd840); // 10000000000111011101100001000000// (   61) 801dd840 BRANCH       branch (!ls_flag) 64                // 
ocp_write(`SCS_GPR0, 16'h801d); // 801dd840
ocp_write(`SCS_GPR0, 16'h801f); // 00111000000100001000000000011111// (   62) 3810801f LOADID       R1=31                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810801f
ocp_write(`SCS_GPR0, 16'h0042); // 01101000000000000000000001000010// (   63) 68000042 JUMP         goto 66                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000042
ocp_write(`SCS_GPR0, 16'he042); // 10000000000111011110000001000010// (   64) 801de042 BRANCH       branch (!gr_flag) 66                // 
ocp_write(`SCS_GPR0, 16'h801d); // 801de042
ocp_write(`SCS_GPR0, 16'h801f); // 00111000000100001000000000011111// (   65) 3810801f LOADID       R1=31                               // 
ocp_write(`SCS_GPR0, 16'h3810); // 3810801f
ocp_write(`SCS_GPR0, 16'h0032); // 00111000000100010000000000110010// (   66) 38110032 LOADID       R2=50                               // 
ocp_write(`SCS_GPR0, 16'h3811); // 38110032
ocp_write(`SCS_GPR0, 16'h0045); // 10000000000010110000000001000101// (   67) 800b0045 BRANCH       branch (R2[0]) 69                   // basic branch
ocp_write(`SCS_GPR0, 16'h800b); // 800b0045
ocp_write(`SCS_GPR0, 16'h003c); // 00111000000100010000000000111100// (   68) 3811003c LOADID       R2=60                               // 
ocp_write(`SCS_GPR0, 16'h3811); // 3811003c
ocp_write(`SCS_GPR0, 16'h0046); // 00111000000100010000000001000110// (   69) 38110046 LOADID       R2=70                               // L_simple_branch      
ocp_write(`SCS_GPR0, 16'h3811); // 38110046
ocp_write(`SCS_GPR0, 16'hf046); // 10000000000111001111000001000110// (   70) 801cf046 BRANCH       branch !c14 70                      // c14 tied to "0" 
ocp_write(`SCS_GPR0, 16'h801c); // 801cf046
ocp_write(`SCS_GPR0, 16'h0000); // 01110000000100000000000000000000// (   71) 70100000 RETURN       rti                                 // 
ocp_write(`SCS_GPR0, 16'h7010); // 70100000
ocp_write(`SCS_GPR0, 16'h0004); // 01101000000000000000000000000100// (   72) 68000004 JUMP         goto 4                              // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000004
ocp_write(`SCS_GPR0, 16'h8400); // 01001000000101001000010000000000// (   73) 48148400 LOOP         loop 1 1 R5                         // 
ocp_write(`SCS_GPR0, 16'h4814); // 48148400
ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (   74) 00000000 NOP          nop                                 // 
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
ocp_write(`SCS_GPR0, 16'h0000); // 01110000000000000000000000000000// (   75) 70000000 RETURN       return                              // 
ocp_write(`SCS_GPR0, 16'h7000); // 70000000
