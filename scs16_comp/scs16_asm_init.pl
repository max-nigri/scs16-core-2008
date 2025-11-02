
#################################################################
#################################################################
#################################################################
sub define_all{

    # this is the width of the new opcode field, to support the ocp_storiad 
    $OPCODE_WIDTH = 5;
    $XDISPLAY_LINE_LEN = {
	code_len => 30,
	comment_len => 80,
	x_display_len => 90,
    };

    # print "x_display_len $XDISPLAY_LINE_LEN->{x_display_len}\n"; exit ;



    my (@array_names, $key, $key1, $key2, $key3, @fields_values, $i, $bin,$k, $r, $header_name);



%G_regexp = (
	     commands => {
		 ALU         => '(\S+)\s*=\s*([-]?[a-zA-Z]\w+)\s*(>|<|>>|<<|\||&|==|\+|-|>=|<=|\^)\s*([-]?[a-zA-Z]\S*)',
		 ALUI        => '((\w+)\s*=\s*([-]?R\d)\s*(>|<|>>|<<|\||&|==|\+|-|>=|<=|\^)\s*([-]?\d\S*)|(\w+)\s*=\s*[-]?\d\S*\s*(>|<|>>|<<|\||&|==|\+|-|>=|<=|\^)\s*([-]?R\d)\s*)',
		 STORE       => '(RAM|EXT_BUS)\[\s*R\w+[\+]{0,2}\s*\]\s*=\s*[a-zA-Z]\w+',
		 STOREIA     => '((RAM|EXT_BUS)\[\s*\d.*?=\s*\w+)',
		 STOREID     => '((RAM|EXT_BUS)\[.+?=\s*-?\d\S*)',
# 		 OCP_STORE   => 'OCP\[\s*R\w+[\+]{0,2}\s*\]\s*=\s*[a-zA-Z]\w+',
# 		 OCP_STOREIA => '(OCP\[\s*\d.*?=\s*[a-zA-Z]\w*)',
# 		 OCP_STOREIAD=> '(OCP\[\s*\d.*?=\s*[0-9]\S*)',
# 		 OCP_STOREID => '(OCP\[\s*[a-zA-Z].*?=\s*-?\d\S*)',
		 LOAD        => '(\w+\s*=\s*(RAM|EXT_BUS)\[\s*R\w+[\+]{0,2}s*])',
		 LOADIA      => '(\w+\s*=\s*(RAM|EXT_BUS)\[\s*\d)',
		 LOADID      => '(R\w+)\s*=\s*(\d|-)[^<+\-&|>=^]*$' ,  #'
# 		 OCP_LOAD    => '(\w+\s*=\s*OCP\[\s*R\w+[\+]{0,2}s*])',
# 		 OCP_LOADIA  => '(\w+\s*=\s*OCP\[\s*\d)',
		 BRANCH      => '\bbranch\b\s+\S+',
		 EXTRACT     => '\s*(R\d)\s*=\s*(R\d)\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])\s*',
		 INSERTR     => '\s*(R\d)\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])\s*=\s*(R\d)\s*',
		 INSERTI     => '\s*(R\d)\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])\s*=\s*(\d\S*)\s*',
		 FIFO        => '\s*\(\s*R\d\s*,\s*R\d\s*\)\s*=\s*fifo_\S+',
		 GOSUB       => '\bgosub\b\s+\S+',
		 LCRLR       => '\bdevice_\d+\s*->\s*\S+', 
		 LIN_SEARCH  => '\bbreakif\s*\S+?\s*(==|>|<).*',
		 LOOP        => '\bloop\b\s+\S+',
		 NOP         => '\b(nop)\b',
		 PULSE       => '^\bpulse\s*->\s*(\w+)',
		 PUSHPOP     => '\b(push|pop)\b\s+.+',
		 RETURN      => '\b(return|rti|return_debug)\b',
		 WAIT_STORE  => '\bwait_store\s+(!\s*)?\w+\s+RAM\[(R6|R7)\+\+\]\s*=\s*R[0-5]s*=\s*(s0|s1)',
		 WAIT_LOAD   => '\bwait_load\s+(!\s*)?\w+\s+R[0-5]\s*=\s*(RAM\[(R6|R7)\+\+\]|s0|s1)',
		 MOVE        => '\w+\s*=\s*[a-zA-Z]\w+',
		 JUMP        => '\b(gosub|goto)\b\s+\S+',
		 TIMER       => '(timer_\d)=(\w+)\s+dec\s+@\s*\(\s*(posedge)?\s*(!)?(\w+)\s*\)',
		 MATH        => ',\s*R\d\s*\)\s*=\s*math\s*.*?[*/+-]',
		 DATA        => 'DATA',

		 },
	     
	     );



# 'LOADI',
    $h2b{"0"} = "0000";
    $h2b{"1"} = "0001";
    $h2b{"2"} = "0010";
    $h2b{"3"} = "0011";
    $h2b{"4"} = "0100";
    $h2b{"5"} = "0101";
    $h2b{"6"} = "0110";
    $h2b{"7"} = "0111";
    $h2b{"8"} = "1000";
    $h2b{"9"} = "1001";
    $h2b{"a"} = "1010";
    $h2b{"b"} = "1011";
    $h2b{"c"} = "1100";
    $h2b{"d"} = "1101";
    $h2b{"e"} = "1110";
    $h2b{"f"} = "1111";
    
    $b2h{"0000"} = "0";
    $b2h{"0001"} = "1";
    $b2h{"0010"} = "2";
    $b2h{"0011"} = "3";
    $b2h{"0100"} = "4";
    $b2h{"0101"} = "5";
    $b2h{"0110"} = "6";
    $b2h{"0111"} = "7";
    $b2h{"1000"} = "8";
    $b2h{"1001"} = "9";
    $b2h{"1010"} = "a";
    $b2h{"1011"} = "b";
    $b2h{"1100"} = "c";
    $b2h{"1101"} = "d";
    $b2h{"1110"} = "e";
    $b2h{"1111"} = "f";



    $condition_bit_hash = {
	fname => 'condition_bit',
	wd => 4,
	comment => "signal that is used for wait",
	val_hash => {
	    c15 => 15,
	    c14 => 14,
	    c13 => 13,
	    c12 => 12,
	    c11 => 11,
	    c10 => 10,
	    c9  => 9,
	    c8  => 8,
	    c7  => 7,
	    c6  => 6,
	    c5  => 5,
	    c4  => 4,
	    c3  => 3,
	    c2  => 2,
	    c1  => 1,
	    c0  => 0,
	},
    };

    $condition_bit_hash2 = {
	fname => 'condition_bit2',
	wd => 4,
	comment => "signal that is used for wait",
	default => 15, # Not looking at this bit
	val_hash => { 
	    # true_bit => 15,
	    c14 => 14,
	    c13 => 13, 
	    c12 => 12, 
	    c11 => 11, 
	    c10 => 10, 
	    c9 => 9,
	    c8 => 8,
	    c7 => 7,
	    c6 => 6,
	    c5 => 5,
	    c4 => 4,
	    c3 => 3,
	    c2 => 2,
	    c1 => 1,
	    c0 => 0,
	},
    };
    
    $pulse_bus_hash= {
	fname => 'pulse_bus',
	wd => 4,
	default => 15,
	comment => "indicate the signal to be set for one clock",
	val_hash => { 
	    p14 => 14,
	    p13 => 13,
	    p12 => 12,
	    p11 => 11,
	    p10 => 10,
	    p9 => 9,
	    p8 => 8,
	    p7 => 7,
	    p6 => 6,
	    p5 => 5,
	    p4 => 4,
	    p3 => 3,
	    p2 => 2,
	    p1 => 1,
	    p0 => 0,
	},
    };

    $debug_source_reg_hash = {
	fname => 'debug_source_reg',
	wd => 4,
	comment => "indicate the register that will be copied",
	default => 0,
	val_hash => { 
	    R0 => 0,
	    R1 => 1,
	    R2 => 2,
	    R3 => 3,
	    R4 => 4,
	    R5 => 5 ,
	    R6 => 6 ,
	    R7 => 7 ,
	    loop => 8,
	    pc => 9,
	    cr => 10,
	    flags => 11,
	    int_return => 12,
	    sub_return => 13,
	    cnt1 => 14,
	    cnt2 => 15,
	},
    };

    $Source_reg_hash ={
	fname => 'source_reg',
	wd => 4,
	comment => "source reg for store, storeia, move commands",
	default => 0,
	val_hash => { 
	    R0 => 0,
	    R1 => 2,
	    R2 => 4,
	    R3 => 6,
	    R4 => 8,
	    R5 => 10,
	    R6 => 12,
	    R7 => 14,
	    loop_start => 1,
	    loop_stop => 3,
	    loop_cnt => 5,
	    sub_return => 7, 
	    counter0 => 9,
	    device => 11, 
	    flags => 13, 
	    pc => 15,
	},
    };

    $CR_part_hash = {
	fname => 'CR_part',   #  also called device
	wd => 2,
	default => 0,
	comment => "indicate the part (nibble) of the CR to be altered",
	val_hash => { 
	    device_0 => 0, 
	    device_1 => 1, 
	    device_2 => 2, 
	    device_3 => 3, 
	},
    };			     
    
    $bits2reset_hash = {
	fname => 'bits2reset',
	wd => 4,
	comment => "the bits in the nibble to be reset",
	default => 0,
	regexp_hash => { 
	    binary      => "4'b([01]{4})",
	    decimal     => '\b(\d+)$',    #'
	},
    };

    $bits2set_hash = {
	fname => 'bits2set',
	wd => 4,
	comment => "the bits in the nibble to be set",
	default => 0,
	regexp_hash => { 
	    binary      => "4'b([01]{4})",
	    decimal     => '\b(\d+)$',    #'
	},
    };

} # end of define all


1;


