ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (    0) 00000000 NOP          nop                                 // 
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
ocp_write(`SCS_GPR0, 16'h0010); // 00111000000100110000000000010000// (    1) 38130010 LOADID       R6=16                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38130010
ocp_write(`SCS_GPR0, 16'h0709); // 01111000000101000000011100001001// (    2) 78140709 STOREID      RAM[R6++]=9                         // RAM[16] is the rd pointer
ocp_write(`SCS_GPR0, 16'h7814); // 78140709
ocp_write(`SCS_GPR0, 16'h0709); // 01111000000101000000011100001001// (    3) 78140709 STOREID      RAM[R6++]=9                         // RAM[17] is the wr pointer
ocp_write(`SCS_GPR0, 16'h7814); // 78140709
ocp_write(`SCS_GPR0, 16'h3f80); // 01111000000101100011111110000000// (    4) 78163f80 STOREID      RAM[R6++]=16'b0100011110000000      // full=0 empty=1 size=16  len=0
ocp_write(`SCS_GPR0, 16'h7816); // 78163f80
ocp_write(`SCS_GPR0, 16'h8014); // 00111000000100101000000000010100// (    5) 38128014 LOADID       R5=20                               // 
ocp_write(`SCS_GPR0, 16'h3812); // 38128014
ocp_write(`SCS_GPR0, 16'h2800); // 01001000000101100010100000000000// (    6) 48162800 LOOP         loop 4 10 R5                        // fifo fill loop invokation
ocp_write(`SCS_GPR0, 16'h4816); // 48162800
ocp_write(`SCS_GPR0, 16'h0011); // 00111000000100110000000000010001// (    7) 38130011 LOADID       R6=17                               // 
ocp_write(`SCS_GPR0, 16'h3813); // 38130011
ocp_write(`SCS_GPR0, 16'h810f); // 00011000000111001000000100001111// (    8) 181c810f LOAD         R1=RAM[R6++]                        // loading the wr pointer to R1
ocp_write(`SCS_GPR0, 16'h181c); // 181c810f
ocp_write(`SCS_GPR0, 16'h010f); // 00011000000111000000000100001111// (    9) 181c010f LOAD         R0=RAM[R6++]                        // loading the control to R0
ocp_write(`SCS_GPR0, 16'h181c); // 181c010f
ocp_write(`SCS_GPR0, 16'hf80d); // 10000000000000111111100000001101// (   10) 8003f80d BRANCH       branch (!R0[15]) 13                 // checking the full
ocp_write(`SCS_GPR0, 16'h8003); // 8003f80d
ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (   11) 00000000 NOP          nop                                 // full!!, do something			
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
ocp_write(`SCS_GPR0, 16'h0011); // 01101000000000000000000000010001// (   12) 68000011 JUMP         goto 17                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 68000011
ocp_write(`SCS_GPR0, 16'h9800); // 10001000000000111001100000000000// (   13) 88039800 ALUI         R7=R1+`BFA                          // calc abs wr ptr
ocp_write(`SCS_GPR0, 16'h8803); // 88039800
ocp_write(`SCS_GPR0, 16'h460f); // 00100000000110000100011000001111// (   14) 2018460f STORE        RAM[R7]=R4                          // wr the data
ocp_write(`SCS_GPR0, 16'h2018); // 2018460f
ocp_write(`SCS_GPR0, 16'h4801); // 10001000000000100100100000000001// (   15) 88024801 ALUI         R4=R4+1                             // inc the data
ocp_write(`SCS_GPR0, 16'h8802); // 88024801
ocp_write(`SCS_GPR0, 16'h0000); // 10101000000100000000000000000000// (   16) a8100000 FIFO         (R0,R1)=fifo_wr(R0,R1)              // update control	
ocp_write(`SCS_GPR0, 16'ha810); // a8100000
ocp_write(`SCS_GPR0, 16'h1611); // 01111000000000000001011000010001// (   17) 78001611 STOREIA      RAM[17]=R1                          // saving back the wr pointer to RAM[17]
ocp_write(`SCS_GPR0, 16'h7800); // 78001611
ocp_write(`SCS_GPR0, 16'h0612); // 01111000000000000000011000010010// (   18) 78000612 STOREIA      RAM[18]=R0                          // saving back the control record to RAM[18]
ocp_write(`SCS_GPR0, 16'h7800); // 78000612
ocp_write(`SCS_GPR0, 16'hb010); // 00111000000000001011000000010000// (   19) 3800b010 LOADIA       R1=RAM[16]                          // loading the rd pointer to R1 
ocp_write(`SCS_GPR0, 16'h3800); // 3800b010
ocp_write(`SCS_GPR0, 16'h9800); // 01001000000101001001100000000000// (   20) 48149800 LOOP         loop 1 6 R5                         // 
ocp_write(`SCS_GPR0, 16'h4814); // 48149800
ocp_write(`SCS_GPR0, 16'hf018); // 10000000000000111111000000011000// (   21) 8003f018 BRANCH       branch (!R0[14]) 24                 // checking the empty
ocp_write(`SCS_GPR0, 16'h8003); // 8003f018
ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (   22) 00000000 NOP          nop                                 // empty!!, do something
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
ocp_write(`SCS_GPR0, 16'h001b); // 01101000000000000000000000011011// (   23) 6800001b JUMP         goto 27                             // 
ocp_write(`SCS_GPR0, 16'h6800); // 6800001b
ocp_write(`SCS_GPR0, 16'h9800); // 10001000000000111001100000000000// (   24) 88039800 ALUI         R7=R1+`BFA                          // calc the abs rd ptr
ocp_write(`SCS_GPR0, 16'h8803); // 88039800
ocp_write(`SCS_GPR0, 16'h000f); // 00011000000110100000000000001111// (   25) 181a000f LOAD         R4=RAM[R7]                          // rd the data		
ocp_write(`SCS_GPR0, 16'h181a); // 181a000f
ocp_write(`SCS_GPR0, 16'h0000); // 10101000000000000000000000000000// (   26) a8000000 FIFO         (R0,R1)=fifo_rd(R0,R1)              // update control
ocp_write(`SCS_GPR0, 16'ha800); // a8000000
ocp_write(`SCS_GPR0, 16'h1610); // 01111000000000000001011000010000// (   27) 78001610 STOREIA      RAM[16]=R1                          // saving back the rd pointer to RAM[16]
ocp_write(`SCS_GPR0, 16'h7800); // 78001610
ocp_write(`SCS_GPR0, 16'h0612); // 01111000000000000000011000010010// (   28) 78000612 STOREIA      RAM[18]=R0                          // saving back the control record to RAM[18]
ocp_write(`SCS_GPR0, 16'h7800); // 78000612
ocp_write(`SCS_GPR0, 16'hf01d); // 10000000000111001111000000011101// (   29) 801cf01d BRANCH       branch !c14 29                      // stop
ocp_write(`SCS_GPR0, 16'h801c); // 801cf01d
ocp_write(`SCS_GPR0, 16'h0000); // 00000000000000000000000000000000// (   30) 00000000 NOP          nop                                 // 
ocp_write(`SCS_GPR0, 16'h0000); // 00000000
