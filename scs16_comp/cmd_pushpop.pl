sub parse_cmd_pushpop{

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w);
    my %Affected_Mcode_fields;
    
    my ($i, $key);
    my $success,$die_msg;
    my $ok =1;
   

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # print "$cmd\n";
    print "\tProbably PUSHPOP command : $cmd\n";
    
    if ($cmd =~ s/(push|pop)\s+//){
	if (defined $G_PUSHPOP_Command_Format{'cmd_sel'}->{'val_hash'}->{$1}){
	    $v =$G_PUSHPOP_Command_Format{'cmd_sel'}->{'val_hash'}->{$1};
	    $w =$G_PUSHPOP_Command_Format{'cmd_sel'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v ,$w ,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse source_reg\n";
		&die_fail_parse('PUSHPOP',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'cmd_sel'} = $bin; 
	}
	else{
	    $die_msg="fail to parse the command";
	    &die_fail_parse('PUSHPOP',$line_num,$cmd_org,$die_msg,1,'cmd_sel');
	}
	$v = 0;
	while ($cmd =~ s/(\w+)//){
	    if (defined $G_PUSHPOP_Command_Format{'reg'}->{'val_hash'}->{$1}){
		$v +=$G_PUSHPOP_Command_Format{'reg'}->{'val_hash'}->{$1};
	    }
	    else{
		$die_msg="Registers to  push/pop should be of :\n";
		&die_fail_parse('PUSHPOP',$line_num,$cmd_org,$die_msg,1,'reg');
	    }
	}
	$w =$G_PUSHPOP_Command_Format{'reg'}->{'wd'};
	($success, $bin) = &parse_const_new1($v ,$w ,'non_tc');
	if ($success==0) {
	    $die_msg="Fail to parse reg\n";
	    &die_fail_parse('PUSHPOP',$line_num,$cmd_org,$die_msg,1,0);
	}
	else{
	    $Affected_Mcode_fields{'reg'} = $bin;
	}
	
	if (($cmd =~ /[^\s]+/)) { # catching leftovers
	    &die_leftovers('PUSHPOP',$cmd_org,$cmd);
	}
	return ( 1 , \%Affected_Mcode_fields);
    }
}
    
##################################################################
##################################################################
##################################################################
@G_PUSHPOP_Command_Format = (
    {
	fname => 'regexp',
	code => '\b(push|pop)\b\s+.+',        #'  
	example =>"push|pop Rx or loop_state or sub_return or device or flags\n\n\tExample:pop sub_return flags\n\t\tpush R0 R1 R2",
	code => $G_regexp{ 'commands' }->{ 'PUSHPOP' },
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 18,
	default => 18,
	comment => "push or pop several registers ",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => 'cmd_sel',
	wd => 1,
	default => 0,
	val_hash => {
	    push => 0,
	    pop => 1,
	}
    },
    {
	fname => 'reserved',
	wd => 6,
	default => 0,
    },
    {
	fname => 'reg',
	wd => 14,
	comment => "selects the register to be pushed poped",
	default => 0,
	val_hash => { 
	    R0 => 1<<0, #ir[0]
	    R1 => 1<<1, #ir[1]
	    R2 => 1<<2, #ir[2]
	    R3 => 1<<3, #ir[3]
	    R4 => 1<<4, #ir[4]
	    R5 => 1<<5, #ir[5]
	    R6 => 1<<6, #ir[6]
	    R7 => 1<<7, #ir[7]
	    loop_state  => 1<<8,  #ir[8]
	    sub_return  => 1<<11, #ir[11]
	    device      => 1<<12, #ir[12]
	    flags       => 1<<13, #ir[13]
	},
    },
    );


for $i ( 0..$#G_PUSHPOP_Command_Format ){
    # print "$i $G_PUSHPOP_Command_Format[$i]{fname}\n";
    $G_PUSHPOP_Command_Format{ $G_PUSHPOP_Command_Format[$i]{fname} } = $G_PUSHPOP_Command_Format[$i];
    
    if ($i != 0) {
	$G_PUSHPOP_Command_Format[$i]{ 'cur_val' } = 'z' x $G_PUSHPOP_Command_Format[$i]{ 'wd' };
    }
    $r = ref $G_PUSHPOP_Command_Format[$i];
# print " ref is $r\n";
}

1;
