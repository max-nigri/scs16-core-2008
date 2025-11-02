sub parse_cmd_wait_load{
# 
# 

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w);
    my %Affected_Mcode_fields ;
    my $q ='"';
    my $regexp;
    my $negate;

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # print "$cmd\n";

    print "\tProbably WAIT+LOAD command : $cmd\n";
    ($cmd, $negate, $Affected_Mcode_fields{'condition_bit'}) = &parse_condition($cmd);
    if (defined $negate ) {
	$v = $negate;
	$w = $G_WAIT_LOAD_Command_Format{'polarity'}->{'wd'};
	$Affected_Mcode_fields{'polarity'} = &dec2bintc($v,$w);
    }
    else{
	die;
    }
    # catching  Rx = RAM[R6|7++]|s0|1", anywhere in $cmd
    if ($cmd =~ s/(R[0-5])\s*=\s*(RAM\[(R6|R7)\+\+\]|s0|s1)\s*//) { 
	if (defined $G_WAIT_LOAD_Command_Format{'Dest_reg'}->{'val_hash'}->{$1}){
	    $w = $G_WAIT_LOAD_Command_Format{'Dest_reg'}->{'wd'};
	    $v = $G_WAIT_LOAD_Command_Format{'Dest_reg'}->{'val_hash'}->{$1};
	    $Affected_Mcode_fields{'Dest_reg'} = &dec2bintc($v,$w);
	}
	else {
	    die;
	}
	$r6r7=$3;
	$tmp =$2;
	if ($r6r7 ne '') {
	    print "\n$r6r7, $tmp\n";
	    if (defined $G_WAIT_LOAD_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7}){
		$w = $G_WAIT_LOAD_Command_Format{'r6r7'}->{'wd'};
		$v = $G_WAIT_LOAD_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7};
		$Affected_Mcode_fields{'r6r7'}=&dec2bintc($v,$w);
	    }
	    else {
		die;  	
	    }
	    $tmp = 'RAM';
	}
	if (defined $G_WAIT_LOAD_Command_Format{'ext_source'}->{'val_hash'}->{$tmp}){
	    $w = $G_WAIT_LOAD_Command_Format{'ext_source'}->{'wd'};
	    $v = $G_WAIT_LOAD_Command_Format{'ext_source'}->{'val_hash'}->{$tmp};
	    $Affected_Mcode_fields{'ext_source'} = &dec2bintc($v,$w);
	}
	else {
	    die;
	}
	
    }
    else {
	die;  	
    }
	
	
    
    ($cmd, $Affected_Mcode_fields{'pulse_bus'})  = &parse_pulse1($cmd);

    if ($cmd =~ s/\b(enable_int|disable_int)\b//) { # 
	$w = $G_WAIT_LOAD_Command_Format{'int_mask'}->{'wd'};
	$v = $G_WAIT_LOAD_Command_Format{'int_mask'}->{'val_hash'}->{$1};
	$Affected_Mcode_fields{'int_mask'} = &dec2bintc($v,$w);
    }
    print "in WAIT+LOAD looking for the second condition \n";
    ($cmd, $negate, $Affected_Mcode_fields{'condition_bit2'}) = &parse_condition2($cmd);
    if (defined $negate ) {
	$v = $negate;
	$w = $G_WAIT_LOAD_Command_Format{'polarity2'}->{'wd'};
	$Affected_Mcode_fields{'polarity2'} = &dec2bintc($v,$w);
    }
    
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('WAIT_LOAD',$cmd_org,$cmd);
	print "in WAIT+LOAD cmd << $cmd_org >>, syntax error!! << $cmd >> was left after parsing\n";
	&elaborate_field(0,\%G_WAIT_LOAD_Command_Format);
	die "Exiting!!!\n";
    }
    return (1, \%Affected_Mcode_fields);
    

}

##################################################################
##################################################################
##################################################################

@G_WAIT_LOAD_Command_Format = (
    {
	fname => 'regexp',
	#  code => '\bwait_load\s+(!\s*)?\w+\s+R[0-5]\s*=\s*(RAM\[(R6|R7)\+\+\]|s0|s1)\s+(breakif\s*(!\s*)?\w+\s+)?(\s*pulse\s*->\s*\w+)?',
	code => $G_regexp{ 'commands' }->{ 'WAIT_LOAD' },
	example => "wait_load c4   R4=RAM[R7++]|s0|s1 <breakif !c3> <pulse -> p2 >   <enable_int or disable_int>",  
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 1,
	default => 1,
	comment => "wait condition and load R0-7 from RAM or from some external source + generate pulse",
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
	    RAM => 2,
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


for $i ( 0..$#G_WAIT_LOAD_Command_Format ){
    # print "$i $G_WAIT_LOAD_Command_Format[$i]{fname}\n";
    $G_WAIT_LOAD_Command_Format{ $G_WAIT_LOAD_Command_Format[$i]{fname} } = $G_WAIT_LOAD_Command_Format[$i];

if ($i != 0) {
    $G_WAIT_LOAD_Command_Format[$i]{ 'cur_val' } = 'z' x $G_WAIT_LOAD_Command_Format[$i]{ 'wd' };
}
$r = ref $G_WAIT_LOAD_Command_Format[$i];
# print " ref is $r\n";
}

1;
