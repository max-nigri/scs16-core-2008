sub parse_cmd_storeia{


    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w);
    my %Affected_Mcode_fields ;
    my $die_msg;
    my $ext_bus;

    my($add,$r_side,$success, $bin,$byte_sel,$offset,$r6_r7,$offset_bin);
    my($r6_r7_w,$offset_w,$source_reg,$source_reg_w);
    my ($ok, $address_mode, $r6r7, $inc_add, $imd_bin, $address);
   
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;
    $cmd =~ s/\s//g;

   

    $r6_r7=0;
    $offset=-1;
   

    print "\tProbably STOREIA command : $cmd\n";
##############################################################################
#####                   COMMAND PARSING                                 ######
##############################################################################
    
#RAM[100+R7]=device  or RAM[100]=R3_h 
     # if ($cmd =~ s/(RAM|EXT_BUS)\[\s*(\d\S*)\s*\]\s*=\s*(\w+)//){
    if ($cmd =~ s/(RAM|EXT_BUS)\[(\S+?\]?)\]=(\w+)//) { ## kkkk
	
	$ext_bus=$1;
	$add    =$2;
	$address=$2;
	$r_side =$3;
    }
    else{
	&die_fail_parse('STOREIA',$line_num,$cmd_org,"can not match the command",1,0);
    }
 
    #####################################################################
    ################ ext_bus parsing ####################################
    #####################################################################
    if (defined $G_STOREIA_Command_Format{'ext_bus'}->{'val_hash'}->{$ext_bus}){
	$w = $G_STOREIA_Command_Format{'ext_bus'}->{'wd'};
	$v = $G_STOREIA_Command_Format{'ext_bus'}->{'val_hash'}->{$ext_bus};
	($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	if ($success==0) {
	    $die_msg="Fail to parse ext_bus field\n";
	    &die_fail_parse('STOREIA',$line_num,$cmd_org,$die_msg,1,0);
	}
	$Affected_Mcode_fields{'ext_bus'}=$bin;
    }
    else  {
	$die_msg="Fail to parse ext_bus field\n";
	&die_fail_parse('STOREIA',$line_num,$cmd_org,$die_msg,1,0);
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
	&die_fail_parse('STOREIA',$line_num,$cmd_org,$die_msg,1,0);
    }
    else {
	if ($address_mode eq 'long') {
	    $Affected_Mcode_fields{'long'}= '1';
	}
	elsif ($address_mode eq 'imd_offset') {
	    $Affected_Mcode_fields{'offset'}= '1';
	}
	if (($address_mode eq 'long') ||($address_mode eq 'imd_offset'))  {
	    $Affected_Mcode_fields{'r6r7'}= $G_STOREIA_Command_Format{'r6r7'}->{val_hash}->{$r6r7};
	}
	$Affected_Mcode_fields{'imd1'} = substr($imd_bin,4,8);
	$Affected_Mcode_fields{'imd2'} = substr($imd_bin,0,4);
    }





    ### write_en ###	 
    if ($r_side =~ s/_(l|h)//) {
	$byte_sel = "Rx_$1";
	$v = $G_STOREIA_Command_Format{'write_en'}->{'val_hash'}->{$byte_sel};
	$w = $G_STOREIA_Command_Format{'write_en'}->{'wd'};
	($success, $bin) = &parse_const_new1($v,$w,'non tc');
	if ($success==0) {
	    &die_fail_parse('STOREIA',$line_num,$cmd_org,"Fail to parse write_en field\n",1,0);
	}
	$Affected_Mcode_fields{'write_en'} = $bin;
    }
    ### source_reg ###	 
    if (defined $G_STOREIA_Command_Format{'source_reg'}->{'val_hash'}->{$r_side}){
	$source_reg=$G_STOREIA_Command_Format{'source_reg'}->{'val_hash'}->{$r_side};
	$source_reg_w=$G_STOREIA_Command_Format{'source_reg'}->{'wd'};
	($success, $bin) = &parse_const_new1($source_reg,$source_reg_w,'non tc'); 
	if ($success==0) {
	    &die_fail_parse('STOREIA',$line_num,$cmd_org,"Fail to parse source_reg field\n",1,0);
	}
	$Affected_Mcode_fields{'source_reg'} =$bin;
    }
    else { # dest reg is not in the list
	$die_msg="Invalid Data to Ram data, source reg\n";
	&die_fail_parse('STOREIA',$line_num,$cmd_org,$die_msg,1,'source_reg');
    }


 
    # loadia force add_data to 0
    $Affected_Mcode_fields{'add_data'} = '0';

    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('STOREIA',$cmd_org,$cmd);
    }
    
    return (1, \%Affected_Mcode_fields);
    
}

##################################################################
##################################################################
##################################################################


@G_STOREIA_Command_Format = (
    {
	fname => 'regexp',
	#code => '(RAM\[\s*\d\S*\s*\S*\s*\S*\]=\s*\w+)',
	code => $G_regexp{ 'commands' }->{ 'STOREIA' },
	example  => "RAM[imd] = Rx<_l|_h>     or RAM[imd+R6|7] = Rx<_l|_h>",  
	example1 => "EXT_BUS[imd] = Rx<_l|_h> or EXT_BUS[imd+R6|7] = Rx<_l|_h>",  
	example2 => "RAM[100]=R2_l            or RAM[10+R6]=R4 ",  
	example3 => "EXT_BUS[100,R6[11:0]] = Rx<_l|_h>",  
	example4 => "EXT_BUS[100,R7[11:0]] = Rx<_l|_h>",  
	example5 => "RAM[100,R7[11:0]] = Rx<_l|_h> // may catch depends on RAM size",  

    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 15,
	default => 15,
	comment => "store Rx to imd address",
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
	fname => 'add_data',
	wd => 1,
	comment => "indicate whether imd is an address or data",
	default => 0,
    },
    {
	fname => 'offset',
	wd => 1,
	comment => "indicate That its not only an imd address but also R6 | R7",
	default => 0,
    },
    {
	fname => 'imd2',
	wd => 4,
	comment => "msb of imd address",
    },
    $Source_reg_hash,
    
    {
	fname => 'write_en',
	wd => 2,
	default => 3,
	comment => "indicate the part of address that will get the data",
	val_hash => { 
	    Rx => 3,
	    Rx_l => 1,
	    Rx_h => 2,
	},
    },
    {
	fname => 'r6r7',
	wd => 1,
	default => 0,
	comment => "Chooses wheather reading from an address of R7 or R6",
	val_hash => { 
	    R6 => 1,
	    R7 => 0,
	},
    },
    {
	fname => 'imd1',
	wd => 8,
	comment => "lsb part of imd address",
    },
    );


for $i ( 0..$#G_STOREIA_Command_Format ){
    $G_STOREIA_Command_Format{ $G_STOREIA_Command_Format[$i]{fname} } = $G_STOREIA_Command_Format[$i];

if ($i != 0) {
    $G_STOREIA_Command_Format[$i]{ 'cur_val' } = 'z' x $G_STOREIA_Command_Format[$i]{ 'wd' };
}
$r = ref $G_STOREIA_Command_Format[$i];

}

1;
