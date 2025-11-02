# scs16-core-2008
scs16 is a micro controller core, with 16b data path and single cycle instructions, development started at 2003, I'm making the 2008 version public. this core is very efficient replacing FSM hence making flows programmable instead of hardcoded

in early 2000, communication standarts were popular and evolving, and many chip companies designed chips to cover functionalities needed in the networks stack.
back then, the typical ASIC clock speed was few hundreds of Mhz and at network speed of 100Mbps, one may have less that 1000 clocks cycles to examine one packet of data, traditionally this examination is done with an FSM, that are naturaly "fixed", and can not support changes in the flow after peoduction, this is exactly where the SCS16 technology shines, one use this type of core in place of the FSM and use simple languuge' C-like' to express the flow, hence the flow remain flexible and can be changed after production. 
