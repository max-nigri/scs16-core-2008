sub parse_cmd_loadia{
#  Rx|Rother = imd | RAM[imd<+R6|7>] 

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w, $r_side,$l_side);
    my ($success, $bin);
    my ($success1, $bin1);
    my %Affected_Mcode_fields;
    my($address,$a,$b);
    my $die_msg;
    my ($i, $key);
    my($Rx,$part_sel);
    my ($ext_bus);
    my ($ok, $address_mode, $r6r7, $inc_add, $imd_bin);

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;
    $cmd =~ s/\s//g;   # cleaning all spaces
   

    # print "$cmd\n";
    # if you are here so you either die or success, you cant try enother command
    print "\tProbably LOADIA command : $cmd\n";

    # &die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,0);

    # expecting (\w+)=(\w+) 
    # R3=RAM[100]
    # R3=RAM[100+R6]
    if ($cmd =~ s/\b(\w+)=(\S+)//) { 
	$r_side = $2;
	$l_side = $1;
	# parsing the l_side
	if ($l_side =~ s/((R\d)(_l|_h))//){
	    # of the form Rx_l|h
	    $Rx=$2;
	    $part_sel= "Rx$3";
	    if (defined $G_LOADIA_Command_Format{'read_en'}->{'val_hash'}->{$part_sel}) {
		$v = $G_LOADIA_Command_Format{'read_en'}->{'val_hash'}->{$part_sel};
		$w = $G_LOADIA_Command_Format{'read_en'}->{'wd'};
		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
		if ($success==0) {
		    $die_msg="Fail to parse source_reg field\n";
		    &die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,0);
		}
		$Affected_Mcode_fields{'read_en'} =$bin; 
	    }
	    else {
		$die_msg="Fail to parse loadia command\n";
		&die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    if (defined $G_LOADIA_Command_Format{'Dest_reg'}->{'val_hash'}->{$Rx}) {
		$v=$G_LOADIA_Command_Format{'Dest_reg'}->{'val_hash'}->{$Rx};
		$w=$G_LOADIA_Command_Format{'Dest_reg'}->{'wd'};
		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
		if ($success==0) {
		    $die_msg="Fail to parse Dest_reg field\n";
		    &die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,0);
		}
		$Affected_Mcode_fields{'Dest_reg'} = $bin;
	    }
	    else {
		$die_msg="Dest_reg field should be in the following form:\n";
		&die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,'Dest_reg');
	    }
	} 
	elsif (defined $G_LOADIA_Command_Format{'Dest_reg'}->{'val_hash'}->{$l_side}){
	    $v = $G_LOADIA_Command_Format{'Dest_reg'}->{'val_hash'}->{$l_side};
	    $w = $G_LOADIA_Command_Format{'Dest_reg'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse Dest_reg field\n";
		&die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'Dest_reg'} = $bin;
	}
	else{
	    $die_msg="Dest_reg field should be in the following form:\n";
	    &die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,'Dest_reg');
	}
	# parsing the r_side
	if ($r_side =~ s/(RAM|EXT_BUS)\[(\S+?\]?)\]//) { ## kkkk
	    $ext_bus=$1;
	    # load from imd address
	    $address=$2;

	    #####################################################################
	    ################ ext_bus parsing ####################################
	    #####################################################################
	    if (defined $G_LOADIA_Command_Format{'ext_bus'}->{'val_hash'}->{$ext_bus}){
		$w = $G_LOADIA_Command_Format{'ext_bus'}->{'wd'};
		$v = $G_LOADIA_Command_Format{'ext_bus'}->{'val_hash'}->{$ext_bus};
		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
		if ($success==0) {
		    $die_msg="Fail to parse ext_bus field\n";
		    &die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,0);
		}
		$Affected_Mcode_fields{'ext_bus'}=$bin;
	    }
	    else  {
		$die_msg="Fail to parse ext_bus field\n";
		&die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    #####################################################################
	    ################ end of external bus parsing ########################
	    #####################################################################


	    # return ($ok, $address_mode, $r6r7, $inc_add, $imd_bin);
	    ($ok, $address_mode, $r6r7, $inc_add, $imd_bin)= &parse_address_mode($address, 12, 12);
	    
	    # available address_mode are: long, imd_offset, r6r7, inc, imd  
	    if ($ok ==0){
		if ($address_mode eq 'null') {
		    $die_msg="Fail to parse address mode\n";
		}
		elsif ( ($address_mode eq 'inc') ||
			($address_mode eq 'r6r7')
		    ){
		    $die_msg="Fail to parse address mode, address mode $address_mode not available in this commad\n";
		}
		else {
		    $die_msg="Fail to parse address operands of address mode $address_mode\n";
		}
		&die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    else {
		if ($address_mode eq 'long') {
		   $Affected_Mcode_fields{'long'}= '1';
		}
		elsif ($address_mode eq 'imd_offset') {
		   $Affected_Mcode_fields{'offset'}= '1';
		}
		if (($address_mode eq 'long') ||($address_mode eq 'imd_offset'))  {
		    $Affected_Mcode_fields{'r6r7'}= $G_LOADIA_Command_Format{'r6r7'}->{val_hash}->{$r6r7};
		}
		$Affected_Mcode_fields{'imd1'} = substr($imd_bin,4,8);
		$Affected_Mcode_fields{'imd2'} = substr($imd_bin,1,3);
		$Affected_Mcode_fields{'imd3'} = substr($imd_bin,0,1);
	    }
		    
	}
	else {
	    $die_msg="Fail to parse right side $r_side\n";
	    &die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,0);
	}
    }
    else{
	$die_msg="Fail to parse command.\n";
	&die_fail_parse('LOADIA',$line_num,$cmd_org,$die_msg,1,0);
    }

    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('LOADIA',$cmd_org,$cmd);
    }
   
    return ( 1 , \%Affected_Mcode_fields);
}



##################################################################
##################################################################
##################################################################

@G_LOADIA_Command_Format = (
    {
	fname => 'regexp',
	code => $G_regexp{ 'commands' }->{ 'LOADIA' },
	#code => '(\w+\s*=\s*RAM\S\s*\S+\s*\S+)', # this is from load command
	example  => "Rx=RAM[imd] or Rx=RAM[imd+R6]", 
	example1 => "R3=RAM[345] or R3=RAM[100+R6]", 
	example2 => "Rx=EXT_BUS[imd] or Rx=EXT_BUS[imd+R6]",
	example3 => "R3=EXT_BUS[345] or R3=EXT_BUS[100+R6]", 
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 7,
	default => 7,
	comment => "load to lower/upper part of destenation register from imd add or imd + R6|R7",
    },
    {
	fname => 'ext_bus',
	wd => 1,
	default => 0,	
	val_hash => { 
	    'EXT_BUS' => 1,
	    'RAM'     => 0,
	},
    },
     {
	fname => 'res32',
	wd => 4,
	default => 0,
	
    },
    {
	fname => 'long',
	wd => 1,
	default => 0,
	comment => "0 - non long address, 1 - long address",
    },
    {
	fname => 'address_data',
	wd => 1,
	default => 0,
	comment => "0 - address, 1 - data",
    },
    {
	fname => 'offset',
	wd => 1,
	default => 0,
	comment => "when 1, indicates that address is of the form imd + R6|R7, 0 - imd",
    },
    {
	fname => 'imd3',
	wd => 1,
        comment => "an unsigned 12 bits number - for address offset or prefix",
    },
    {
	fname => 'Dest_reg',
	wd => 4,
	comment => "indicate the register that will get the imd or data from imd address",
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
	    int_return => 9,
	    device => 11,
	    flags => 13,
	    pc => 15,		# need to put a nop after this instruction
	},
    },
    {
	fname => 'read_en',
	wd => 2,
	default => 3,
	comment => "indicate the part of reg that will get the data",
	val_hash => { 
	    Rx => 3,
	    Rx_l => 1,
	    Rx_h => 2,
	},
    },
{
    fname => 'imd2',
    wd => 3,
    comment => "an unsigned 12 bits number - for address offset or prefix",
},
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
    fname => 'imd1',
    wd => 8,
    comment => "an unsigned 12 bits number - for address offset or prefix",
},
    );


for $i ( 0..$#G_LOADIA_Command_Format ){
    # print "$i $G_LOADW_Command_Format[$i]{fname}\n";
    $G_LOADIA_Command_Format{ $G_LOADIA_Command_Format[$i]{fname} } = $G_LOADIA_Command_Format[$i];
if ($i != 0) {
    $G_LOADIA_Command_Format[$i]{ 'cur_val' } = 'z' x $G_LOADIA_Command_Format[$i]{ 'wd' };
}
    $r = ref $G_LOADIA_Command_Format[$i];
}



1;
