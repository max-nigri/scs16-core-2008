sub parse_cmd_ocp_loadia{
#  Rx|Rother = imd | OCP[imd<+R6|7>] 

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

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;
    $cmd =~ s/\s//g;   # cleaning all spaces
   
    # Rx=OCP[imd] or Rx=OCP[imd+R6] R3=OCP[345] R3=OCP[100+R6] 

    # print "$cmd\n";
    # if you are here so you either die or success, you cant try enother command
    print "\tProbably OCP_LOADIA command : $cmd\n";

    # expecting (\w+)=(\w+) 
    # R3=OCP[100]
    # R3=OCP[100+R6]
    if ($cmd =~ s/\b(\w+)=(\S+)//) { 
	$r_side = $2;
	$l_side = $1;
	# parsing the l_side
	if ($l_side =~ s/((R\d)(_l|_h))//){
	    # of the form Rx_l|h
	    $Rx=$2;
	    $part_sel= "Rx$3";
	    if (defined $G_OCP_LOADIA_Command_Format{'read_en'}->{'val_hash'}->{$part_sel}) {
		$v = $G_OCP_LOADIA_Command_Format{'read_en'}->{'val_hash'}->{$part_sel};
		$w = $G_OCP_LOADIA_Command_Format{'read_en'}->{'wd'};
		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
		if ($success==0) {
		    $die_msg="Fail to parse source_reg field\n";
		    &die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
		}
		$Affected_Mcode_fields{'read_en'} =$bin; 
	    }
	    else {
		$die_msg="Fail to parse ocp_loadia command\n";
		&die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    if (defined $G_OCP_LOADIA_Command_Format{'Dest_reg'}->{'val_hash'}->{$Rx}) {
		$v=$G_OCP_LOADIA_Command_Format{'Dest_reg'}->{'val_hash'}->{$Rx};
		$w=$G_OCP_LOADIA_Command_Format{'Dest_reg'}->{'wd'};
		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
		if ($success==0) {
		    $die_msg="Fail to parse Dest_reg field\n";
		    &die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
		}
		$Affected_Mcode_fields{'Dest_reg'} = $bin;
	    }
	    else {
		$die_msg="Dest_reg field should be in the following form:\n";
		&die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,'Dest_reg');
	    }
	} 
	elsif (defined $G_OCP_LOADIA_Command_Format{'Dest_reg'}->{'val_hash'}->{$l_side}){
	    $v = $G_OCP_LOADIA_Command_Format{'Dest_reg'}->{'val_hash'}->{$l_side};
	    $w = $G_OCP_LOADIA_Command_Format{'Dest_reg'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse Dest_reg field\n";
		&die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'Dest_reg'} = $bin;
	}
	else{
	    $die_msg="Dest_reg field should be in the following form:\n";
	    &die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,'Dest_reg');
	}
	# parsing the r_side
	if ($r_side =~ s/OCP\[(\S+?)\]//) {
	    # load from imd address
	    $address=$1;
	    if ($address =~ s/(\S+)\+(\S+)//){
		# expression, so should be imd+R6|R7 address
		$Affected_Mcode_fields{'offset'}= '1';
		$a = $1; $b = $2;
		if (defined $G_OCP_LOADIA_Command_Format{'r6r7'}->{val_hash}->{$a}){
		    $Affected_Mcode_fields{'r6r7'}= $G_OCP_LOADIA_Command_Format{'r6r7'}->{val_hash}->{$a};
		    ($success, $bin) = &parse_const_new1($b,12,'non tc');
		    if ($success==0) {
			$die_msg="Fail to parse address offset\n";
			&die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
		    }
		}
		elsif (defined $G_OCP_LOADIA_Command_Format{'r6r7'}->{val_hash}->{$b}){
		    $Affected_Mcode_fields{'r6r7'}= $G_OCP_LOADIA_Command_Format{'r6r7'}->{val_hash}->{$b};
		    ($success, $bin) = &parse_const_new1($a,12,'non tc');
		    if ($success==0) {
			$die_msg="Fail to parse r6r7\n";
			&die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
			
		    }
		}
		else{
		    $die_msg="Fail to parse address\n";
		    &die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
		}
		$tmp = $bin;
	    }
	    else {
		# no an expression, so should be imd address
		$Affected_Mcode_fields{'offset'}= '0';
		($success,   $bin) = &parse_const_new1($address,16,'non tc');
		($success1, $bin1) = &parse_const_new1($address,12,'non tc');
		if ($success==0 && $success1==0 ) {
		    $die_msg="Fail to parse immediate address\n";
		    &die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
		}
		elsif ($success==1){
		    $tmp = substr($bin,4,12);
		    if (substr($bin,0,4) =~ /1/){
			$die_msg="truncating significant digits from $address\n";
			&die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
		    }
		}
		elsif ($success1==1){
		    $tmp = $bin1;
		}
		else {
		    $die_msg="fail in the ocp_loadia command(should not be here)\n";
		    &die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
		}
	    }	
	    $Affected_Mcode_fields{'imd1'} = substr($tmp,4,8);
	    $Affected_Mcode_fields{'imd2'} = substr($tmp,1,3);
	    $Affected_Mcode_fields{'imd3'} = substr($tmp,0,1);
	}
	else {
	    $die_msg="Fail to parse right side.\n";
	    &die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
	}
	if ($r_side =~ /\S+/) {
	    $die_msg="Fail :right side leftovers.\n";
	    &die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
	} 
    }
    else{
	$die_msg="Fail to parse command.\n";
	&die_fail_parse('OCP_LOADIA',$line_num,$cmd_org,$die_msg,1,0);
    }

    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('OCP_LOADIA',$cmd_org,$cmd);
    }
   
    return ( 1 , \%Affected_Mcode_fields);
}



##################################################################
##################################################################
##################################################################

@G_OCP_LOADIA_Command_Format = (
    {
	fname => 'regexp',
	code => $G_regexp{ 'commands' }->{ 'OCP_LOADIA' },
	#code => '(\w+\s*=\s*OCP\S\s*\S+\s*\S+)', # this is from load command
	example => "Rx=OCP[imd] or Rx=OCP[imd+R6]\n\tExample:R3=OCP[345]\n\t\t R3=OCP[100+R6]", 
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 30,
	default => 30,
	comment => "load to lower/upper part of destenation register from imd add or imd + R6|R7",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
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
	default => 0,
	comment => "not in use yet",
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
	comment => "an unsigned 11bits number - for address",
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
	comment => "an unsigned 11bits number - for address",
    },
    );


for $i ( 0..$#G_OCP_LOADIA_Command_Format ){
    # print "$i $G_LOADW_Command_Format[$i]{fname}\n";
    $G_OCP_LOADIA_Command_Format{ $G_OCP_LOADIA_Command_Format[$i]{fname} } = $G_OCP_LOADIA_Command_Format[$i];
if ($i != 0) {
    $G_OCP_LOADIA_Command_Format[$i]{ 'cur_val' } = 'z' x $G_OCP_LOADIA_Command_Format[$i]{ 'wd' };
}
    $r = ref $G_OCP_LOADIA_Command_Format[$i];
}



1;
