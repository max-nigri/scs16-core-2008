sub parse_cmd_storeid{

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my ($v, $w);
    my %Affected_Mcode_fields ;
    my($add,$data,$success, $bin,$byte_sel,$r6r7,$inc_add);
    my $die_msg;
    my $ext_bus;
      
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;
   
    print "\tProbably STOREID command : $cmd\n";
   
    if ($cmd =~ s/(RAM|EXT_BUS)\[\s*(R\S*)\s*\]\s*=\s*(\S+)//){
	$ext_bus=$1;
	$add=$2;
	$data=$3;

	$Affected_Mcode_fields{'add_data'} = '1';

    #####################################################################
    ################ ext_bus parsing ####################################
    #####################################################################
    if (defined $G_STOREID_Command_Format{'ext_bus'}->{'val_hash'}->{$ext_bus}){
	$w = $G_STOREID_Command_Format{'ext_bus'}->{'wd'};
	$v = $G_STOREID_Command_Format{'ext_bus'}->{'val_hash'}->{$ext_bus};
	($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	if ($success==0) {
	    $die_msg="Fail to parse ext_bus field\n";
	    &die_fail_parse('STOREID',$line_num,$cmd_org,$die_msg,1,0);
	}
	$Affected_Mcode_fields{'ext_bus'}=$bin;
    }
    else  {
	$die_msg="Fail to parse ext_bus field\n";
	&die_fail_parse('STOREID',$line_num,$cmd_org,$die_msg,1,0);
    }
    #####################################################################
    ################ end of external bus parsing ########################
    #####################################################################







### immediate data ###
	($success, $bin) = &parse_const_new1($data,16,'tc');
	if ($success==0) {
	    &die_fail_parse('STOREID',$line_num,$cmd_org,"Fail to parse immediate data field\n",1,0); 
	}
	$Affected_Mcode_fields{'imd1'} = substr($bin, 8,8);
	$Affected_Mcode_fields{'imd2'} = substr($bin, 1,7);
	$Affected_Mcode_fields{'imd3'} = substr($bin, 0,1);
	#$Affected_Mcode_fields{'imd3'}= 11;
### R6|R7 + $inc_add ###
	if ($add =~ s/(R6|R7)(\+\+)?//) {
	    $r6r7=$1;
	    $inc_add = ($2 eq '') ? 'Rx' : 'Rx++';
	    $w = $G_STORE_Command_Format{'r6r7'}->{'wd'};
	    $v = $G_STORE_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7};
	    ($success, $bin) =&parse_const_new1($v,$w,'non tc');
	    if ($success==0) {
		&die_fail_parse('STOREID',$line_num,$cmd_org,"Fail to parse R6 R7 field\n",1,0);
	    }
	    $Affected_Mcode_fields{'r6r7'}=$bin;
	 
	    $w = $G_STORE_Command_Format{'inc_add'}->{'wd'};
	    $v = $G_STORE_Command_Format{'inc_add'}->{'val_hash'}->{$inc_add };
	    ($success, $bin) =&parse_const_new1($v,$w,'non tc');
	    if ($success==0) {
		&die_fail_parse('STOREID',$line_num,$cmd_org,"Fail to parse inc_add field\n",1,0);
	    }
	    	 
	    $Affected_Mcode_fields{'inc_add'}=$bin;
	}
	else{
	    &die_fail_parse('STOREID',$line_num,$cmd_org,"Fail to parse address, should be R6/R7/++\n",1,0);
	}
    }
###   ###
    if ($add =~ /[^\s]+/) { # catching leftovers in the address <R6+ >
	&die_leftovers('STOREID',$cmd_org,$add);
    }
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('STOREID',$cmd_org,$cmd);
    }
    return (1, \%Affected_Mcode_fields);
        
}


##################################################################
##################################################################
##################################################################
@G_STOREID_Command_Format = (
    {
	fname => 'regexp',
	#  code => '(RAM\[\s*R\S*\s*\S+\s*=\s*-?\d\S*)', last
	code => $G_regexp{ 'commands' }->{ 'STOREID' },
	
	example => "RAM[R7|R6|++] = imd \n\tExample:RAM[R7]=125\n\t\tRAM[R6++]=-10",  
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 15,
	default => 15,
	comment => "store imd data and optionally increament address",
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
	fname => 'add_data',
	wd => 1,
	comment => "indicate whether imd is an address or data",
	default => 1,
    },
    {
	fname => 'imd3',
	wd => 1,
	comment => "msb of imd data",
    },
    {
	fname => 'inc_add',
	wd => 1,
	default => 0,
	comment => "can either increament address or not each write",
	val_hash => { 
	    Rx => 0,
	    'Rx++' => 1,
	},
    },
    {
	fname => 'imd2',
	wd => 7,
	comment => "middle part of imd data",
    },
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
	comment => "Chooses wheather writing will be to an address from R7 or R6",
	val_hash => { 
	    R7 => 0,
	    R6 => 1,
	},
    },
    {
	fname => 'imd1',
	wd => 8,
	comment => "lsb part of imd data",
    },
    );


for $i ( 0..$#G_STOREID_Command_Format ){
    # print "$i $G_STORE_Command_Format[$i]{fname}\n";
    $G_STOREID_Command_Format{ $G_STOREID_Command_Format[$i]{fname} } = $G_STOREID_Command_Format[$i];

if ($i != 0) {
    $G_STOREID_Command_Format[$i]{ 'cur_val' } = 'z' x $G_STOREID_Command_Format[$i]{ 'wd' };
}
$r = ref $G_STOREID_Command_Format[$i];
# print " ref is $r\n";
}

1;
