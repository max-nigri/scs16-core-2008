sub parse_cmd_lcrlr{


    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w);
    my %Affected_Mcode_fields ;
    my($nibble_value,$bits2set ,$bits2reset, $i, $inc_add); 
    my ($success, $bin);
    my $die_msg,$dest;

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # print "$cmd\n";

    print "\tProbably LCRLR command : $cmd\n";

    ($cmd, $Affected_Mcode_fields{'CR_part'} ,$Affected_Mcode_fields{'bits2reset'},$Affected_Mcode_fields{'bits2set'}) = &parse_device($cmd);
    ($cmd, $Affected_Mcode_fields{'pulse_bus'})  = &parse_pulse1($cmd);

### 'Dest_reg' ###    
    # catching  <R0 = RAM[R7++] s0|1>", anywhare in $cmd
    if ($cmd =~ s/(R[0-7])\s*=\s*(RAM\[\s*(R7|R6)(\+?\+?)\s*\]|s0|s1)//) {
	$dest=$1;
	$r6r7=$3;
	$tmp =$2;
	$inc_add = Rx.$4;
	if (defined $G_LCRLR_Command_Format{'Dest_reg'}->{'val_hash'}->{$dest}){
	    $w = $G_LCRLR_Command_Format{'Dest_reg'}->{'wd'};
	    $v = $G_LCRLR_Command_Format{'Dest_reg'}->{'val_hash'}->{$dest};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse Dest_reg field\n";
		&die_fail_parse('LCRLR',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'Dest_reg'} =$bin;
	}
	else {
	    $die_msg="Fail to parse lcrlr command\n";
	    &die_fail_parse('LCRLR',$line_num,$cmd_org,$die_msg,1,0);
	}
### 'ext_source' ###
	$tmp =~ s/\[.+$//; # should left RAM 
	if (defined $G_LCRLR_Command_Format{'ext_source'}->{'val_hash'}->{$tmp}){
	    $w = $G_LCRLR_Command_Format{'ext_source'}->{'wd'};
	    $v = $G_LCRLR_Command_Format{'ext_source'}->{'val_hash'}->{$tmp};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse ext_source field\n";
		&die_fail_parse('LCRLR',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'ext_source'} = $bin;
	}
	else {
	    $die_msg="Fail to parse ext_source \n";
	    &die_fail_parse('LCRLR',$line_num,$cmd_org,$die_msg,1,'ext_source');
	}
### r6r7 inc_add ###
	if ($tmp eq RAM){
	    if (defined $G_LCRLR_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7}){
		$w = $G_LCRLR_Command_Format{'r6r7'}->{'wd'};
		$v = $G_LCRLR_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7};
		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
		if ($success==0) {
		    $die_msg="Fail to parse r6r7 field\n";
		    &die_fail_parse('LCRLR',$line_num,$cmd_org,$die_msg,1,0);
		}
		$Affected_Mcode_fields{'r6r7'}=$bin;
	    }
	    else{
		$die_msg="Fail to parse r6r7 field\n";
		&die_fail_parse('LCRLR',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    if (defined $G_LCRLR_Command_Format{'inc_add'}->{'val_hash'}->{$inc_add }){
		$w = $G_LCRLR_Command_Format{'inc_add'}->{'wd'};
		$v = $G_LCRLR_Command_Format{'inc_add'}->{'val_hash'}->{$inc_add };
		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
		if ($success==0) {
		    $die_msg="Fail to parse r6r7 field\n";
		    &die_fail_parse('LCRLR',$line_num,$cmd_org,$die_msg,1,0);
		}
		$Affected_Mcode_fields{'inc_add'}=$bin;
	    }
	}
    }
    
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('LCRLR',$cmd_org,$cmd);
    }
    return (1, \%Affected_Mcode_fields);
}


##################################################################
##################################################################
##################################################################

@G_LCRLR_Command_Format = (
    {
	fname => 'regexp',
	#  code => '\bdevice_\d+\s*->\s*\S+(\s+R[0-7]\s*=\s*\S+)?(\s+pulse\s*->\s*\w+)?',
	code => $G_regexp{ 'commands' }->{ 'LCRLR' },
	example => "device_x -> 4'bxxxx  <Rx = RAM[R7|R6|++]> <pulse -> px>\n\tExample:device_2 -> 4'bx0x1\n\t\tdevice_3 -> 4'b00x1 R3 = RAM[R7++]\n\t\tdevice_1 -> 4'b00x1 R3 = RAM[R7++] pulse -> p3\n\t\tdevice_2->4 R2=s0",   
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 2,
	default => 2,
	comment => "lcl lr command , sets part of CR, optionally loads R0-7 from ports s01, 
RAM, optionally pulse",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
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
	fname => 'inc_add',
	wd => 1,
	default => 0,
	comment => "can either increament address or not each read",
	val_hash => { 
	    Rx => 0,
	    'Rx++' => 1,
	},
    },
    {
	fname => 'Dest_reg',
	wd => 3,
	comment => "indicate the register that will get the data from source",
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
    $bits2set_hash,
    $CR_part_hash,
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
    $bits2reset_hash,
    $pulse_bus_hash,
    );


    for $i ( 0..$#G_LCRLR_Command_Format ){
	# print "$i $G_LCRLR_Command_Format[$i]{fname}\n";
	$G_LCRLR_Command_Format{ $G_LCRLR_Command_Format[$i]{fname} } = $G_LCRLR_Command_Format[$i];

	if ($i != 0) {
	    $G_LCRLR_Command_Format[$i]{ 'cur_val' } = 'z' x $G_LCRLR_Command_Format[$i]{ 'wd' };
	}
	$r = ref $G_LCRLR_Command_Format[$i];
	# print " ref is $r\n";
    }
##################################################################


1;
