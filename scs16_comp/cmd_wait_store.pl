sub parse_cmd_wait_store{
# 
# 

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w);
    my %Affected_Mcode_fields ;
    my $negate;
    my $die_msg,$success,$bin;

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # print "$cmd\n";

    print "\tProbably WAIT+STORE command : $cmd\n";
    ($cmd, $negate, $Affected_Mcode_fields{'condition_bit'}) = &parse_condition($cmd);
### polarity  ###
    if (defined $negate ) {
	$v = $negate;
	$w = $G_WAIT_STORE_Command_Format{'polarity'}->{'wd'};
	($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	if ($success==0){
	    $die_msg="Fail to parse polarity\n";
	    &die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,0);
	}
	$Affected_Mcode_fields{'polarity'} = $bin;
    }
    else{
	$die_msg="Fail to parse polarity not defined \n";
	&die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,0);
    }
### Dest_reg  ###
    # catching  RAM[6|7++]=Rx=s0|1", anywhere in $cmd
    if ($cmd =~ s/RAM\[(R6|R7)\+\+\]\s*=\s*(R[0-5])\s*=\s*(s0|s1)\s*//) {
 	$r6r7=$1;
	$tmp =$3;
	if (defined $G_WAIT_STORE_Command_Format{'Dest_reg'}->{'val_hash'}->{$2}){
	    $w = $G_WAIT_STORE_Command_Format{'Dest_reg'}->{'wd'};
	    $v = $G_WAIT_STORE_Command_Format{'Dest_reg'}->{'val_hash'}->{$2};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0){
		$die_msg="Fail to parse Dest_reg\n";
		&die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'Dest_reg'} = $bin;
	}
	else {
	    $die_msg="Fail to parse Dest_reg field should be one of \n";
	    &die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,'Dest_reg');
	}
### ext_source  ###
	if (defined $G_WAIT_STORE_Command_Format{'ext_source'}->{'val_hash'}->{$tmp}){
	    $w = $G_WAIT_STORE_Command_Format{'ext_source'}->{'wd'};
	    $v = $G_WAIT_STORE_Command_Format{'ext_source'}->{'val_hash'}->{$tmp};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0){
		$die_msg="Fail to parse ext_source\n";
		&die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'ext_source'} = $bin;
	}
	else {
	    $die_msg="Fail to parse ext_source field should be one of \n";
	    &die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,'ext_source');
	}
### r6r7  ###	
	if (defined $G_WAIT_STORE_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7}){
	    $w = $G_WAIT_STORE_Command_Format{'r6r7'}->{'wd'};
	    $v = $G_WAIT_STORE_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0){
		$die_msg="Fail to parse val_hash\n";
		&die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'r6r7'}=$bin;
	}
	else{
	    $die_msg="Fail to parse r6r7 value not defined\n";
	    &die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,0);
	}
    }
    else {
	$die_msg="Fail to parse command\n";
	&die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,0);
    }
    
    ($cmd, $Affected_Mcode_fields{'pulse_bus'})  = &parse_pulse1($cmd);
### int_mask  ###	    
    if ($cmd =~ s/\b(enable_int|disable_int)\b//) { # 
	$w = $G_WAIT_STORE_Command_Format{'int_mask'}->{'wd'};
	$v = $G_WAIT_STORE_Command_Format{'int_mask'}->{'val_hash'}->{$1};
	($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	if ($success==0){
	    $die_msg="Fail to parse int_mask\n";
	    &die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,0);
	}
	$Affected_Mcode_fields{'int_mask'} = $bin;
    }
### condition_bit2  ###	
    print "in WAIT+STORE looking for the second condition\n";
    ($cmd, $negate, $Affected_Mcode_fields{'condition_bit2'}) = &parse_condition2($cmd);
    if (defined $negate ) {
	$v = $negate;
	$w = $G_WAIT_STORE_Command_Format{'polarity2'}->{'wd'};
	($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	if ($success==0){
	    $die_msg="Fail to parse polarity2\n";
	    &die_fail_parse('WAIT_STORE',$line_num,$cmd_org,$die_msg,1,0);
	}
	$Affected_Mcode_fields{'polarity2'} = $bin;
    }
    
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('WAIT_STORE',$cmd_org,$cmd);
    }
    return (1, \%Affected_Mcode_fields);
    
}

##################################################################
##################################################################
##################################################################

@G_WAIT_STORE_Command_Format = (
    {
	fname => 'regexp',
	#  code => '\bwait_store\s+(!\s*)?\w+\s+RAM\[(R6|R7)\+\+\]\s*=\s*R[0-5]s*=\s*(s0|s1)\s*(breakif\s*(!\s*)?\w+\s+)?(\s*pulse\s*->\s*\w+)?',
	code => $G_regexp{ 'commands' }->{ 'WAIT_STORE' },
	example => "wait_store cx RAM[R7|R6|++]=Rx=sx <breakif !cx> <pulse -> px >\n\tExample:wait_store c4 RAM[R7++]=R4=s0 breakif !c3 pulse -> p2 ",  
    },
    {
	fname => 'opcode',
#    wd => 5,
	wd => $OPCODE_WIDTH,
	code => 8,
	default => 8,
	comment => "wait condition and load R0-7 by some external source + generate pulse",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => 'Dest_reg',
	wd => 3,
	comment => "indicate the register that will get the intermediate data ",
	default => 7,
	val_hash => { 
	    R0 => 0,
	    R1 => 1,
	    R2 => 2,
	    R3 => 3,
	    R4 => 4,
	    R5 => 5,
	},
    },
    {
	fname => 'ext_source',
	wd => 2,
	comment => "indicate the port to be sampled by Dest_reg",
	default => 3,  # no load
	val_hash => { 
	    s0 => 0,
	    s1 => 1,
	},
    },
    {
	fname => 'polarity',
	wd => 1,
	default => 0,
	comment => "zero means normal polarity",
    },
    $condition_bit_hash,
    {
	fname => 'int_mask',
	wd => 1,
	default => 0,
	val_hash =>{
	    enable_int => 0,
	    disable_int => 1,
	},
    },
# Polarity2 and condition bus hash 2 are used to put the break statement on the bus.
    {
	fname => 'polarity2',
	wd => 1,
	default => 0,
	comment => "zero means normal polarity",
    },
    {
	fname => 'r6r7',
	wd => 1,
	default => 0,
	comment => "Chooses wheather writing to address of R7 or R6",
	val_hash => { 
	    R7 => 0,
	    R6 => 1,
	},
    },
    $condition_bit_hash2,
    $pulse_bus_hash,
    );


for $i ( 0..$#G_WAIT_STORE_Command_Format ){
    # print "$i $G_WAIT_STORE_Command_Format[$i]{fname}\n";
    $G_WAIT_STORE_Command_Format{ $G_WAIT_STORE_Command_Format[$i]{fname} } = $G_WAIT_STORE_Command_Format[$i];

if ($i != 0) {
    $G_WAIT_STORE_Command_Format[$i]{ 'cur_val' } = 'z' x $G_WAIT_STORE_Command_Format[$i]{ 'wd' };
}
$r = ref $G_WAIT_STORE_Command_Format[$i];
# print " ref is $r\n";
}

1;
