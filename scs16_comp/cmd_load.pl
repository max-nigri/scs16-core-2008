sub parse_cmd_load{
# this routine check if its an load command

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my ($v, $w);
    my %Affected_Mcode_fields ;
    my ($d ,$inc_add,$die_msg );
    my ($success, $bin);
    my ($ext_bus);

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

##############################################################################
#####                   COMMAND PARSING                                 ######
##############################################################################
    # print "$cmd\n";
    print "\tProbably LOAD command : $cmd\n";
    if ($cmd =~ s/(\w+)\s*=\s*(RAM|EXT_BUS)\[\s*(R7|R6)(\+?\+?)\s*\]//){
	$d = $1;
	$ext_bus=$2;

	$inc_add = Rx.$4;
	$r6r7=$3;

    #####################################################################
    ################ ext_bus parsing ####################################
    #####################################################################
    if (defined $G_LOAD_Command_Format{'ext_bus'}->{'val_hash'}->{$ext_bus}){
	$w = $G_LOAD_Command_Format{'ext_bus'}->{'wd'};
	$v = $G_LOAD_Command_Format{'ext_bus'}->{'val_hash'}->{$ext_bus};
	($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	if ($success==0) {
	    $die_msg="Fail to parse ext_bus field\n";
	    &die_fail_parse('LOAD',$line_num,$cmd_org,$die_msg,1,0);
	}
	$Affected_Mcode_fields{'ext_bus'}=$bin;
    }
    else  {
	$die_msg="Fail to parse ext_bus field\n";
	&die_fail_parse('LOAD',$line_num,$cmd_org,$die_msg,1,0);
    }
    #####################################################################
    ################ end of external bus parsing ########################
    #####################################################################



##############################################################################
#####                  INPUT CHECKS                                     ######
##############################################################################	
	if ($d eq $r6r7){
	    $die_msg="Not valid \"No meaning\" at the same time the register $r6r7 is loaded and inc. in this case the register will not get data from the memory.\n";
	    &die_fail_parse('LOAD',$line_num,$cmd_org,$die_msg,1,0);
	}

	if ($inc_add eq "Rx+"){    #mod 8.12.03 check Ram[R6+]
	    $die_msg="To increament the address only ++ is valid!\n";
	    &die_fail_parse('LOAD',$line_num,$cmd_org,$die_msg,1,0);
	}
##############################################################################
#####                   OPCODE   GENRATOR                               ######
##############################################################################
### Dest_reg ###
	if (defined $G_LOAD_Command_Format{'Dest_reg'}->{'val_hash'}->{$d}){
	    $v=$G_LOAD_Command_Format{'Dest_reg'}->{'val_hash'}->{$d};
	    $w=$G_LOAD_Command_Format{'Dest_reg'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse Dest_reg field\n";
		&die_fail_parse('STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'Dest_reg'} = $bin;
	}

        elsif (($d =~ s/(R\d)/Rx/) &&  (defined $G_LOAD_Command_Format{'read_en'}->{'val_hash'}->{$d})){
	    $v = $G_LOAD_Command_Format{'read_en'}->{'val_hash'}->{$d};
	    $w = $G_LOAD_Command_Format{'read_en'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse read_en field\n";
		&die_fail_parse('STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'read_en'} = $bin;
	    $v=$G_LOAD_Command_Format{'Dest_reg'}->{'val_hash'}->{$1};
	    $w=$G_LOAD_Command_Format{'Dest_reg'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse Dest_reg field\n";
		&die_fail_parse('STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'Dest_reg'} = $bin;
	} 
	else { # dest reg is not in the list
	    $die_msg="Ram data can be loaded to one of :\n";
	    &die_fail_parse('LOAD',$line_num,$cmd_org,$die_msg,1,'Dest_reg');
	}
### r6r7 ###
	if (defined $G_LOAD_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7}){
	    $w = $G_LOAD_Command_Format{'r6r7'}->{'wd'};
	    $v = $G_LOAD_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse r6r7 field\n";
		&die_fail_parse('STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'r6r7'}=$bin;
	    
	    if (defined $G_LOAD_Command_Format{'inc_add'}->{'val_hash'}->{$inc_add }){
		$w = $G_LOAD_Command_Format{'inc_add'}->{'wd'};
	    	$v = $G_LOAD_Command_Format{'inc_add'}->{'val_hash'}->{$inc_add };
		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
		if ($success==0) {
		    $die_msg="Fail to parse r6r7 field\n";
		    &die_fail_parse('STORE',$line_num,$cmd_org,$die_msg,1,0);
		}
	    	$Affected_Mcode_fields{'inc_add'}=$bin;
	    }
	    
	}
	else{
	    $die_msg="Only R6 and R7 valid in the RAM\n";
	    &die_fail_parse('STORE',$line_num,$cmd_org,$die_msg,1,0);
	   
	}

    }

    ($cmd, $Affected_Mcode_fields{'pulse_bus'})  = &parse_pulse1($cmd);
    
    
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('LOAD',$cmd_org,$cmd);
    }
    return (1, \%Affected_Mcode_fields);
        
}
##################################################################
##################################################################
##################################################################

@G_LOAD_Command_Format = (
    {
	fname => 'regexp',
	
	#code => '(\w+\s*=\s*RAM\S\s*R\S+\s*\S+)?(\s+pulse\s*->\s*\w+)?',
	code => $G_regexp{ 'commands' }->{ 'LOAD' },
	example => "Rx|Rx_l|Rx_h = RAM[R7|R6|++] <pulse -> px>\n\tExample:R3_l = RAM[R7++]\n\t\tR3 = RAM[R6]\n\t\tR1 = RAM[R6] pulse -> p3",  
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 3,
	default => 3,
	num_of_lines => 1,
	comment => "load from memory to registers, optionally increament address ",
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
	wd => 5,
	default => 0,
	
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
	fname => 'inc_add',
	wd => 1,
	default => 0,
	comment => "can either increament address or not each load",
	val_hash => { 
	    Rx => 0,
	    'Rx++' => 1,
	},
    },
    {
	fname => 'Dest_reg',
	wd => 4,
	comment => "indicate the register that will get the data from ram",
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
	fname => 'reserved0',
	wd => 5,
	default => 0,
	comment => "not in use yet",
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
    fname => 'reserved1',
    wd => 4,
    default => 0,
    comment => "not in use yet",
},
    $pulse_bus_hash,
    );


for $i ( 0..$#G_LOAD_Command_Format ){
    # print "$i $G_LOAD_Command_Format[$i]{fname}\n";
    $G_LOAD_Command_Format{ $G_LOAD_Command_Format[$i]{fname} } = $G_LOAD_Command_Format[$i];

if ($i != 0) {
    $G_LOAD_Command_Format[$i]{ 'cur_val' } = 'z' x $G_LOAD_Command_Format[$i]{ 'wd' };
}
$r = ref $G_LOAD_Command_Format[$i];
# print " ref is $r\n";
}
##################################################################

1;
