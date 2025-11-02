sub parse_cmd_lin_search{
# R1 == R2 = RAM[R7+=R5/1]

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my ($die_msg);
    my ($success, $bin);
    my %Affected_Mcode_fields;
    my ($i, $key);
    my ($vreg, $step_reg, $rb_sel, $range, $search_op, $r_offset,$l_offset,$r6r7,$r5);
    my ($vreg_w, $step_reg_w, $rb_sel_w, $range_w, $search_op_w, $r_offset_w,$l_offset_w,$r6r7,$r5_w);

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # return (0, \%Affected_Mcode_fields);
    print "\tProbably LIN_SEARCH command : $cmd\n";
   
    if ($cmd =~ s/\bbreakif\s+(R\d)(\[(\d+):(\d+)\])?\s*(==|>|<)\s*(R\d)\s*=\s*RAM\[(R\S+)\s*\]//){
	$search_val = $1;
	$range = $2;
	$l_offset = $3;
	$r_offset = $4;
	$search_op = $5;
	$rb_sel = $6;
	$step_reg = $7;
	
	
### range ###		
	if($range ne "") {
	    # CB 31->15
	    if(($l_offset > 15 )||( $r_offset < 0 )||( $r_offset > $l_offset )){
		$die_msg="The input range of bit < $range > is not valid for a search.\n";
		&die_fail_parse('LIN_SEARCH',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    else{
### left_offset ###
		$l_offset = 15-$l_offset;
		$l_offset_w = $G_LIN_SEARCH_Command_Format{'left_offset'}->{'wd'};
		($success, $bin) = &parse_const_new1($l_offset,$l_offset_w,'non_tc');
		if ($success==0) {
		    print "In LIN_SEARCH command! << $cmd_org >> Fail to parse left_offset\n";
		    die "Exiting !!!\n";
		}
		$Affected_Mcode_fields{'left_offset'}=$bin;
### right_offset ###		
		$r_offset_w = $G_LIN_SEARCH_Command_Format{'right_offset'}->{'wd'};
		($success, $bin) = &parse_const_new1($r_offset,$r_offset_w,'non_tc');
		if ($success==0) {
		    print "In LIN_SEARCH command! << $cmd_org >> Fail to parse right_offset\n";
		    die "Exiting !!!\n";
		}
		$Affected_Mcode_fields{'right_offset'}= $bin
		}
	}   # if ($range ne "")
### search_val ###
	if (defined ($G_LIN_SEARCH_Command_Format{'search_val'}->{'val_hash'}->{$search_val})){
	    $search_val = $G_LIN_SEARCH_Command_Format{'search_val'}->{'val_hash'}->{$search_val};
	    $search_val_w = $G_LIN_SEARCH_Command_Format{'search_val'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($search_val ,$search_val_w,'non_tc');
	    if ($success==0) {
		print "In LIN_SEARCH command! << $cmd_org >> Fail to parse search_val\n";
		die "Exiting !!!\n";
	    }
	    $Affected_Mcode_fields{'search_val'}= $bin;
	}
	else{
	    $die_msg="The search value should be in one of the registers:\n";
	    &die_fail_parse('LIN_SEARCH',$line_num,$cmd_org,$die_msg,1,'search_val');
	}
### rb_sel ###
	if (defined ($G_LIN_SEARCH_Command_Format{'rb_sel'}->{'val_hash'}->{$rb_sel})){
	    $rb_sel = $G_LIN_SEARCH_Command_Format{'rb_sel'}->{'val_hash'}->{$rb_sel};
	    $rb_sel_w = $G_LIN_SEARCH_Command_Format{'rb_sel'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($rb_sel ,$rb_sel_w,'non_tc');
	    if ($success==0) {
		print "In LIN_SEARCH command! << $cmd_org >> Fail to parse rb_sel\n";
		die "Exiting !!!\n";
	    }
	    $Affected_Mcode_fields{'rb_sel'}= $bin;
	}
	else{
	    $die_msg="Rb_sel field  should be in one of the registers:\n";
	    &die_fail_parse('LIN_SEARCH',$line_num,$cmd_org,$die_msg,1,'rb_sel');
	}
### op  ###
	if(defined ($G_LIN_SEARCH_Command_Format{'op'}->{'val_hash'}->{$search_op})){
	    $search_op = $G_LIN_SEARCH_Command_Format{'op'}->{'val_hash'}->{$search_op};
	    $search_op_w = $G_LIN_SEARCH_Command_Format{'op'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($search_op ,$search_op_w,'non_tc');
	    if ($success==0) {
		print "In LIN_SEARCH command! << $cmd_org >> Fail to parse rb_sel\n";
		die "Exiting !!!\n";
	    }
	    $Affected_Mcode_fields{'op'}= $bin;
	}    
	else{
	    $die_msg="the operatoresin this command should be one of:\n";
	    &die_fail_parse('LIN_SEARCH',$line_num,$cmd_org,$die_msg,1,'op');
	}
### r6_r7 ###
	if($step_reg =~ /\b(R7|R6)\s*\+(\+|=\s*(R\d))/) {
	    $r6r7=$1;	
	    if (defined $G_LIN_SEARCH_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7}){
		$r6r7_w = $G_LIN_SEARCH_Command_Format{'r6r7'}->{'wd'};
		$r6r7 = $G_LIN_SEARCH_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7};
		($success, $bin) = &parse_const_new1($r6r7,$r6r7_w,'non_tc');
		if ($success==0) {
		    print "In LIN_SEARCH command! << $cmd_org >> Fail to parse r6r7\n";
		    die "Exiting !!!\n";
		}
		$Affected_Mcode_fields{'r6r7'}=$bin;
	    }
	    else{
		$die_msg="To move the search in the memory you can only use the next registers:\n";
		&die_fail_parse('LIN_SEARCH',$line_num,$cmd_org,$die_msg,1,'r6r7');
	    }
### R5 ###
	    if($2 ne "+") {
		if (defined $G_LIN_SEARCH_Command_Format{'step_reg'}->{'val_hash'}->{$3}){
		    $r5 = $G_LIN_SEARCH_Command_Format{'step_reg'}->{'val_hash'}->{$3};
		    $r5_w = $G_LIN_SEARCH_Command_Format{'step_reg'}->{'wd'};
		    ($success, $bin) = &parse_const_new1($r5,$r5_w,'non_tc');
		    if ($success==0) {
			print "In LIN_SEARCH command! << $cmd_org >> Fail to parse step register R5\n";
			die "Exiting !!!\n";
		    }
		    $Affected_Mcode_fields{'step_reg'}= $bin;
		}
		else{
		    $die_msg="only R5 can be used to indicate the steps size in the search. \n";
		    &die_fail_parse('LIN_SEARCH',$line_num,$cmd_org,$die_msg,1,0);
		}
	    }
	}   
    } 
    
    elsif ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('LIN_SEARCH',$cmd_org,$cmd);
    }
    
    return ( 1 , \%Affected_Mcode_fields);
    
}

##################################################################
##################################################################
##################################################################


@G_LIN_SEARCH_Command_Format = (
    {
	fname => 'regexp',
	
	# code => '\bbreakif\s*\S+?\s*(==|>|<)\s*\S+',
	code => $G_regexp{ 'commands' }->{ 'LIN_SEARCH' },
	example => "breakif Rx<[x:y]> ==|>|< Ry = RAM[R7+=R5] or RAM[R7++]\n\n\tExample:breakif R2==R4=RAM[R7++]\n\t\tbreakif R2>R1=RAM[R7++]\n\t\tbreakif R2[4:0]==R1=RAM[R7++]\n\t\tbreakif R2>R1=RAM[R7+=R5]",  
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 31,
	default => 31,
	comment => "linear search command",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => 'search_val',
	wd => 3,
	comment => "indicate the register that it's value will be search",
	default => 0,
	val_hash => { 
	    R0 => 0,
	    R1 => 1,
	    R2 => 2,
	    R3 => 3,
	    R4 => 4,
	    R5 => 5,
	    R6 => 6,
	    R7 => 7,
	},
    },
    {
	fname => 'resereved',
	wd => 2,
	default => 0,
    },
    {
	fname => 'step_reg',
	wd => 1,
	comment => "indicate the register for address inceament",
	default => 0,
	val_hash => { 
	    #   R0 => 0,
	    #   R1 => 1,
	    #   R2 => 2,
	    #   R3 => 3,
	    #   R4 => 4,
	    R5 => 1,
	    #   R6 => 6,
	},
    },
    {
	fname => 'rb_sel',
	wd => 3,
	comment => "indicate the register that will get data from Dmem",
	default => 0,
	val_hash => { 
	    R0 => 0,
	    R1 => 1,
	    R2 => 2,
	    R3 => 3,
	    R4 => 4,
	    R5 => 5,
	    R6 => 6,
	    R7 => 7,
	},
    },
    {
	fname => 'op',
	wd => 3,
	comment => "indicate the operator ",
	val_hash => { 
	    # '&'  => 0, 
	    # '|'  => 1, 
	    # '^'  => 2, 
	    '==' => 1,
	    '>'  => 2,
	    '<'  => 3, 
	    # '+'  => 4, 
	    # '-'  => 5, 
	    # '>>' => 6, 
	    # '<<' => 7, 
	    
	},
    },
#  				    {
#  					fname => 'op',
#  					wd => 2,
#  					default => 0,
#  					op_hash => {
#  					    '==' => 0,
#  					    '<'  => 1,
#  					    '>'  => 2,
#  					},
#  				    },
#  				    {
#  					fname => 'resereved',
#      					wd => 1,
#      					default => 0,
#  				    },
    {
	fname => 'r6r7',
	wd => 1,
	default => 0,
	comment => "Chooses wheather reading from an address of R7 or R6",
	val_hash => { 
	    R7 => 0,
	    R6 => 1,
	},
    },
    
    {
	fname => 'left_offset',
	wd => 4,
	default => 0,
	comment => "offset from left (for mask)",
	regexp_hash => { 
	    hexadecimal => "16'h([0-9a-f]{4})",
	    binary      => "16'b([01]{16})",
	    decimal     => '\b(-?\d+)$',      #'
	},
    },
    {
	fname => 'right_offset',
	wd => 4,
	default => 0,
	comment => "offset from right (for mask)",
	regexp_hash => { 
	    hexadecimal => "16'h([0-9a-f]{4})",
	    binary      => "16'b([01]{16})",
	    decimal     => '\b(-?\d+)$',      #'
	},
    },
    );


for $i ( 0..$#G_LIN_SEARCH_Command_Format ){
    # print "$i $G_WAIT_LOAD_Command_Format[$i]{fname}\n";
    $G_LIN_SEARCH_Command_Format{ $G_LIN_SEARCH_Command_Format[$i]{fname} } = $G_LIN_SEARCH_Command_Format[$i];
    if ($i != 0) {
	$G_LIN_SEARCH_Command_Format[$i]{ 'cur_val' } = 'z' x $G_LIN_SEARCH_Command_Format[$i]{ 'wd' };
    }
    $r = ref $G_LIN_SEARCH_Command_Format[$i];
    # print " ref is $r\n";
}


1;
