sub parse_cmd_ocp_storeid{

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my ($v, $w);
    my %Affected_Mcode_fields ;
    my($add,$data,$success, $bin,$byte_sel,$r6r7,$inc_add);
      
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;
   
    # OCP[R7|R6|++] = imd  OCP[R7]=125  OCP[R6++]=-10
  
    print "\tProbably OCP_STOREID command : $cmd\n";
   
    if ($cmd =~ s/OCP\[\s*(R\S*)\s*\]\s*=\s*(\S+)//){
	$add=$1;
	$data=$2;

	$Affected_Mcode_fields{'add_data'} = '1';

### immediate data ###
	($success, $bin) = &parse_const_new1($data,16,'tc');
	if ($success==0) {
	    &die_fail_parse('OCP_STOREID',$line_num,$cmd_org,"Fail to parse immediate data field\n",1,0); 
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
		&die_fail_parse('OCP_STOREID',$line_num,$cmd_org,"Fail to parse R6 R7 field\n",1,0);
	    }
	    $Affected_Mcode_fields{'r6r7'}=$bin;
	 
	    $w = $G_STORE_Command_Format{'inc_add'}->{'wd'};
	    $v = $G_STORE_Command_Format{'inc_add'}->{'val_hash'}->{$inc_add };
	    ($success, $bin) =&parse_const_new1($v,$w,'non tc');
	    if ($success==0) {
		&die_fail_parse('OCP_STOREID',$line_num,$cmd_org,"Fail to parse inc_add field\n",1,0);
	    }
	    	 
	    $Affected_Mcode_fields{'inc_add'}=$bin;
	}
	else{
	    &die_fail_parse('OCP_STOREID',$line_num,$cmd_org,"Fail to parse address, should be R6/R7/++\n",1,0);
	}
    }
###   ###
    if ($add =~ /[^\s]+/) { # catching leftovers in the address <R6+ >
	&die_leftovers('OCP_STOREID',$cmd_org,$add);
    }
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('OCP_STOREID',$cmd_org,$cmd);
    }
    return (1, \%Affected_Mcode_fields);
        
}


##################################################################
##################################################################
##################################################################
@G_OCP_STOREID_Command_Format = (
    {
	fname => 'regexp',
	#  code => '(OCP\[\s*R\S*\s*\S+\s*=\s*-?\d\S*)', last
	code => $G_regexp{ 'commands' }->{ 'OCP_STOREID' },
	
	example => "OCP[R7|R6|++] = imd \n\tExample:OCP[R7]=125\n\t\tOCP[R6++]=-10",  
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 26,
	default => 26,
	comment => "store imd data and optionally increament address",
    },
    {
	fname => 'res32',
	wd => 6,
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


for $i ( 0..$#G_OCP_STOREID_Command_Format ){
    # print "$i $G_STORE_Command_Format[$i]{fname}\n";
    $G_OCP_STOREID_Command_Format{ $G_OCP_STOREID_Command_Format[$i]{fname} } = $G_OCP_STOREID_Command_Format[$i];

if ($i != 0) {
    $G_OCP_STOREID_Command_Format[$i]{ 'cur_val' } = 'z' x $G_OCP_STOREID_Command_Format[$i]{ 'wd' };
}
$r = ref $G_OCP_STOREID_Command_Format[$i];
# print " ref is $r\n";
}

1;
