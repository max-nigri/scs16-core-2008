sub parse_cmd_loadid{
#  Rx|Rother = imd | RAM[imd<+R6|7>] 

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w, $r_side,$l_side);
    my ($success, $bin);
    my ($success1, $bin1);
    my %Affected_Mcode_fields;
    my $die_msg;
    my ($i, $key);
    
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;
   
    $cmd =~ s/(\W)\s+(\W)/"$1$2"/ge;   # cleaning all spaces


    print "\tProbably LOADID command : $cmd\n";

   
    if ($cmd =~ s/\b(\w+)=(\S+)//) { 
	$Affected_Mcode_fields{'address_data'} = 1;
	$r_side = $2;
	$l_side = $1;
	if (defined $G_LOADID_Command_Format{'Dest_reg'}->{'val_hash'}->{$l_side}){
	    $v = $G_LOADID_Command_Format{'Dest_reg'}->{'val_hash'}->{$l_side};
	    $w = $G_LOADID_Command_Format{'Dest_reg'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0){
		$die_msg="Fail to parse Dest_reg\n";
		&die_fail_parse('LOADID',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'Dest_reg'} = $bin;
	}
	else{
	    $die_msg="Dest field should be one of :\n";
	    &die_fail_parse('LOADID',$line_num,$cmd_org,$die_msg,1,'Dest_reg');
	}
	$v = $r_side;
	($success,   $bin) = &parse_const_new1($v,16,'tc');
	($success1, $bin1) = &parse_const_new1($v,11,'tc');
		
	if ($success==0 && $success1==0 ) {
	    $die_msg="Fail to parse immediate data\n";
	    &die_fail_parse('LOADID',$line_num,$cmd_org,$die_msg,1,0);
	}
	elsif ($success==1){
	    $tmp = $bin;
	}
	elsif ($success1==1){
	    $tmp = '00000'.$bin1;
	}

	$Affected_Mcode_fields{'imd2'} = substr($tmp,0,2);
	$Affected_Mcode_fields{'imd1'} = substr($tmp,2,14);
    }
    else{
	$die_msg="Fail to parse equality $cmd\n";
	&die_fail_parse('LOADID',$line_num,$cmd_org,$die_msg,1,0);
    }
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('LOADID',$cmd_org,$cmd);
    }
    return ( 1 , \%Affected_Mcode_fields);

}



##################################################################
##################################################################
##################################################################

@G_LOADID_Command_Format = (
    {
	fname => 'regexp',				
	#code => '\w+\s*=\s*(\d|-)[^<+\-&|>=^]*$', # this is from load command
	code => $G_regexp{ 'commands' }->{ 'LOADID' },
	example => "Rx = dig\n\tExample:R3=345\n\t\tR3=16'h02df", 
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 7,
	default => 7,
	comment => "load to lower/upper part of destenation register from imd data",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    
    {
	fname => 'address_data',
	wd => 1,
	default => 1,
	comment => "0 - address, 1 - data",
    },
    {
	fname => 'imd2',
	wd => 2,
	comment => "a signed 16 bits number - for data",
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
	fname => 'imd1',
	wd => 14,
	comment => "a signed 16 bits number - for data",
    },
    );


for $i ( 0..$#G_LOADID_Command_Format ){
    # print "$i $G_LOADW_Command_Format[$i]{fname}\n";
    $G_LOADID_Command_Format{ $G_LOADID_Command_Format[$i]{fname} } = $G_LOADID_Command_Format[$i];
if ($i != 0) {
    $G_LOADID_Command_Format[$i]{ 'cur_val' } = 'z' x $G_LOADID_Command_Format[$i]{ 'wd' };
}
$r = ref $G_LOADID_Command_Format[$i];
}



1;
