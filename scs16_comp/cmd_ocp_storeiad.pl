sub parse_cmd_ocp_storeiad{


    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w);
    my %Affected_Mcode_fields ;
    my $die_msg;
   
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;
    $cmd =~ s/\s//g;

   
    my($add,$r_side,$success, $bin,$byte_sel,$offset,$r6_r7,$offset_bin);
    my($address,$data);
    my($r6_r7_w,$offset_w,$source_reg,$source_reg_w);

    $r6_r7=0;
    $offset=-1;
   

    print "\tProbably OCP_STOREIAD command : $cmd\n";
    
    #OCP[100]=30  

    if ($cmd =~ s/OCP\[\s*(\d\S*)\s*\]\s*=\s*(\d\S*)//){
	$address=$1;
	$data   =$2;
	$w = $G_OCP_STOREIAD_Command_Format{'address'}->{'wd'};
	($success, $bin) = &parse_const_new1($address,$w,'non tc');
	if ($success==0) {
	    &die_fail_parse('OCP_STOREIAD',$line_num,$cmd_org,"Fail to parse immediate address\n",1,0);
	}

	$Affected_Mcode_fields{'address'} = $bin;

	$w = $G_OCP_STOREIAD_Command_Format{'data'}->{'wd'};
	($success, $bin) = &parse_const_new1($data,$w,'non tc');
	if ($success==0) {
	    &die_fail_parse('OCP_STOREIAD',$line_num,$cmd_org,"Fail to parse immediate data\n",1,0);
	}

	$Affected_Mcode_fields{'data'} = $bin;
    }
    else{
	&die_fail_parse('OCP_STOREIAD',$line_num,$cmd_org,"can not mach the command",1,0);
    }
   
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('OCP_STOREIAD',$cmd_org,$cmd);
    }
    
    return (1, \%Affected_Mcode_fields);
    
}

##################################################################
##################################################################
##################################################################


@G_OCP_STOREIAD_Command_Format = (
    {
	fname => 'regexp',
	#code => '(OCP\[\s*\d\S*\s*\S*\s*\S*\]=\s*\w+)',
	code => $G_regexp{ 'commands' }->{ 'OCP_STOREIAD' },
	example => "OCP[imd] = IMD",
    },
    {
	fname => 'opcode',
	wd => $OPCODE_WIDTH,
	code => 1,
	default => 1,
	comment => "store imediate data to imd address",
    },
    {
	fname => 'address',
	wd => 11,
	comment => "the address field",
	default => 0,
    },
    {
	fname => 'data',
	wd => 16,
	comment => "the data field",
    },
    );


for $i ( 0..$#G_OCP_STOREIAD_Command_Format ){
    $G_OCP_STOREIAD_Command_Format{ $G_OCP_STOREIAD_Command_Format[$i]{fname} } = $G_OCP_STOREIAD_Command_Format[$i];

if ($i != 0) {
    $G_OCP_STOREIAD_Command_Format[$i]{ 'cur_val' } = 'z' x $G_OCP_STOREIAD_Command_Format[$i]{ 'wd' };
}
$r = ref $G_OCP_STOREIAD_Command_Format[$i];

}

1;
