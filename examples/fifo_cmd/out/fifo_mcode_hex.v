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
00000000  // (    0) NOP          nop                                 // 
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
38130010  // (    1) LOADID       R6=16                               // 
78140709  // (    2) STOREID      RAM[R6++]=9                         // RAM[16] is the rd pointer
78140709  // (    3) STOREID      RAM[R6++]=9                         // RAM[17] is the wr pointer
78163f80  // (    4) STOREID      RAM[R6++]=16'b0100011110000000      // full=0 empty=1 size=16  len=0
//   
38128014  // (    5) LOADID       R5=20                               // 
//   
// writing R5 times to an empty fifo  
//   
48162800  // (    6) LOOP         loop 4 10 R5                        // fifo fill loop invokation
// loop pre-conditioning  
38130011  // (    7) LOADID       R6=17                               // 
181c810f  // (    8) LOAD         R1=RAM[R6++]                        // loading the wr pointer to R1
181c010f  // (    9) LOAD         R0=RAM[R6++]                        // loading the control to R0
//   
8003f80d  // (   10) BRANCH       branch (!R0[15]) 13                 // checking the full
00000000  // (   11) NOP          nop                                 // full!!, do something			
68000011  // (   12) JUMP         goto 17                             // 
//   
88039800  // (   13) ALUI         R7=R1+`BFA                          // calc abs wr ptr
2018460f  // (   14) STORE        RAM[R7]=R4                          // wr the data
88024801  // (   15) ALUI         R4=R4+1                             // inc the data
a8100000  // (   16) FIFO         (R0,R1)=fifo_wr(R0,R1)              // update control	
//   
//   
78001611  // (   17) STOREIA      RAM[17]=R1                          // saving back the wr pointer to RAM[17]
78000612  // (   18) STOREIA      RAM[18]=R0                          // saving back the control record to RAM[18]
//   
//   
3800b010  // (   19) LOADIA       R1=RAM[16]                          // loading the rd pointer to R1 
//   
// reading R5 times from a full fifo  
//   
48149800  // (   20) LOOP         loop 1 6 R5                         // 
8003f018  // (   21) BRANCH       branch (!R0[14]) 24                 // checking the empty
00000000  // (   22) NOP          nop                                 // empty!!, do something
6800001b  // (   23) JUMP         goto 27                             // 
//   
88039800  // (   24) ALUI         R7=R1+`BFA                          // calc the abs rd ptr
181a000f  // (   25) LOAD         R4=RAM[R7]                          // rd the data		
a8000000  // (   26) FIFO         (R0,R1)=fifo_rd(R0,R1)              // update control
//   
//   
78001610  // (   27) STOREIA      RAM[16]=R1                          // saving back the rd pointer to RAM[16]
78000612  // (   28) STOREIA      RAM[18]=R0                          // saving back the control record to RAM[18]
//   
801cf01d  // (   29) BRANCH       branch !c14 29                      // stop
00000000  // (   30) NOP          nop                                 // 
//   
//   
//   
// /////////////////////  
