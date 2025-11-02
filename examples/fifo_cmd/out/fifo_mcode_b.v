// /////////////////////////////////////////////////////////////////////  
// File:  		fifo.scs  
// Location:		  
// Created by:		Nadav Feldman                           
// Date Creation:  	28.11.03  
// Version:		1.0                                                   
// Modified:		  
//   
// Project: 		SCS16  
//   
// Purpose:		This progrem is made to check a fifo of 16 cells.  
// useing 2 loop one to fill the fifo and one to empty it.  
//   
// Description:           
//   
// How to use it:	                                                   
//   
// ToDo:                                                             
//   
// /////////////////////////////////////////////////////////////////////  
//   
00000000000000000000000000000000// (    0) 00000000 NOP          nop                                 // 
//   
//   
// `define BFA 0  
// `define FWP 8  
// `define FRP 9  
// `define FMN 10  
//   
// in this example we define a fifo of 16 lines located in RAM  
// in the region `BFA (Base Fifo Address) to `BFA+15  
// its control struct is located above the fifo region, however  
// its location is totally controlled by the programmer.  
// the control struct consist of 3 lines  
// RAM[16] is the rd pointer   
// RAM[17] is the wr pointer  
// RAM[18] {full=0 empty=1 size[6:0]=16  len[6:0]=0}  
//   
//   
// fifo control structure initiation  
// in this specific example, I'm setting the rd,wr ptr to point to 9  
// which is near the middle of the fifo. this will demonstrate the  
// wrap around mechanism  
00111000000100110000000000010000// (    1) 38130010 LOADID       R6=16                               // 
01111000000101000000011100001001// (    2) 78140709 STOREID      RAM[R6++]=9                         // RAM[16] is the rd pointer
01111000000101000000011100001001// (    3) 78140709 STOREID      RAM[R6++]=9                         // RAM[17] is the wr pointer
01111000000101100011111110000000// (    4) 78163f80 STOREID      RAM[R6++]=16'b0100011110000000      // full=0 empty=1 size=16  len=0
//   
00111000000100101000000000010100// (    5) 38128014 LOADID       R5=20                               // 
//   
// writing R5 times to an empty fifo  
//   
01001000000101100010100000000000// (    6) 48162800 LOOP         loop 4 10 R5                        // fifo fill loop invokation
// loop pre-conditioning  
00111000000100110000000000010001// (    7) 38130011 LOADID       R6=17                               // 
00011000000111001000000100001111// (    8) 181c810f LOAD         R1=RAM[R6++]                        // loading the wr pointer to R1
00011000000111000000000100001111// (    9) 181c010f LOAD         R0=RAM[R6++]                        // loading the control to R0
//   
10000000000000111111100000001101// (   10) 8003f80d BRANCH       branch (!R0[15]) 13                 // checking the full
00000000000000000000000000000000// (   11) 00000000 NOP          nop                                 // full!!, do something			
01101000000000000000000000010001// (   12) 68000011 JUMP         goto 17                             // 
//   
10001000000000111001100000000000// (   13) 88039800 ALUI         R7=R1+`BFA                          // calc abs wr ptr
00100000000110000100011000001111// (   14) 2018460f STORE        RAM[R7]=R4                          // wr the data
10001000000000100100100000000001// (   15) 88024801 ALUI         R4=R4+1                             // inc the data
10101000000100000000000000000000// (   16) a8100000 FIFO         (R0,R1)=fifo_wr(R0,R1)              // update control	
//   
//   
01111000000000000001011000010001// (   17) 78001611 STOREIA      RAM[17]=R1                          // saving back the wr pointer to RAM[17]
01111000000000000000011000010010// (   18) 78000612 STOREIA      RAM[18]=R0                          // saving back the control record to RAM[18]
//   
//   
00111000000000001011000000010000// (   19) 3800b010 LOADIA       R1=RAM[16]                          // loading the rd pointer to R1 
//   
// reading R5 times from a full fifo  
//   
01001000000101001001100000000000// (   20) 48149800 LOOP         loop 1 6 R5                         // 
10000000000000111111000000011000// (   21) 8003f018 BRANCH       branch (!R0[14]) 24                 // checking the empty
00000000000000000000000000000000// (   22) 00000000 NOP          nop                                 // empty!!, do something
01101000000000000000000000011011// (   23) 6800001b JUMP         goto 27                             // 
//   
10001000000000111001100000000000// (   24) 88039800 ALUI         R7=R1+`BFA                          // calc the abs rd ptr
00011000000110100000000000001111// (   25) 181a000f LOAD         R4=RAM[R7]                          // rd the data		
10101000000000000000000000000000// (   26) a8000000 FIFO         (R0,R1)=fifo_rd(R0,R1)              // update control
//   
//   
01111000000000000001011000010000// (   27) 78001610 STOREIA      RAM[16]=R1                          // saving back the rd pointer to RAM[16]
01111000000000000000011000010010// (   28) 78000612 STOREIA      RAM[18]=R0                          // saving back the control record to RAM[18]
//   
10000000000111001111000000011101// (   29) 801cf01d BRANCH       branch !c14 29                      // stop
00000000000000000000000000000000// (   30) 00000000 NOP          nop                                 // 
//   
//   
//   
// /////////////////////  
