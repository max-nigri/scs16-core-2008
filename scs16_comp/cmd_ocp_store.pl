sub parse_cmd_ocp_store{

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my ($v, $w);
    my %Affected_Mcode_fields ;
    my ($s,$d);
    my $inc_add,$die_msg;
    my ($success, $bin);

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # print "$cmd\n";
    # OCP[R7|R6|++] = Rx|Rx_h|Rx_l
    print "\tProbably OCP_STORE command : $cmd\n";

    if ($cmd =~ s/OCP\[\s*(R7|R6)(\+?\+?)\s*\]\s*=(\w+)//){
	$s=$3;
	$r6r7=$1;
	$inc_add = Rx.$2;

	if (defined $G_OCP_STORE_Command_Format{'source_reg'}->{'val_hash'}->{$s}){
	    $v=$G_OCP_STORE_Command_Format{'source_reg'}->{'val_hash'}->{$s};
	    $w=$G_OCP_STORE_Command_Format{'source_reg'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse source_reg field\n";
		&die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'source_reg'} = $bin;
	}
        elsif (($s =~ s/(R\d)/Rx/) &&  (defined $G_OCP_STORE_Command_Format{'write_en'}->{'val_hash'}->{$s})){
	    $v = $G_OCP_STORE_Command_Format{'write_en'}->{'val_hash'}->{$s};
	    $w = $G_OCP_STORE_Command_Format{'write_en'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse write_en field\n";
		&die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'write_en'} = $bin;

	    $v=$G_OCP_STORE_Command_Format{'source_reg'}->{'val_hash'}->{$1};
	    $w=$G_OCP_STORE_Command_Format{'source_reg'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse source_reg field\n";
		&die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'source_reg'} = $bin;
	} 
	else { # dest reg is not in the list
	    $die_msg="Data to OCP can come from one of :\n";
	    &die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,'source_reg');
	}
	if (defined $G_OCP_STORE_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7}){
	    $w = $G_OCP_STORE_Command_Format{'r6r7'}->{'wd'};
	    $v = $G_OCP_STORE_Command_Format{'r6r7'}->{'val_hash'}->{$r6r7};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse r6r7 field\n";
		&die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'r6r7'}=$bin;
	    
	    if (defined $G_OCP_STORE_Command_Format{'inc_add'}->{'val_hash'}->{$inc_add }){
		$w = $G_OCP_STORE_Command_Format{'inc_add'}->{'wd'};
		$v = $G_OCP_STORE_Command_Format{'inc_add'}->{'val_hash'}->{$inc_add };
		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
		if ($success==0) {
		    $die_msg="Fail to parse inc_add field\n";
		    &die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,0);
		}
		$Affected_Mcode_fields{'inc_add'}=$bin;
	    }
	    else{
		$die_msg="An invalid calue of increament:\n";
		&die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,'inc_add');
		
	    }
	}
	else{
	    &die_fail_parse('OCP_STORE',$line_num,$cmd_org,"in the compiler a place that no logic to get to in cmd_ocp_store\n",0,0);
	}
    }
    if ($cmd =~ s/(R\d+)\s*=\s*(\w+)//){
	if (defined $G_OCP_STORE_Command_Format{'Dest_reg'}->{'val_hash'}->{$1}){
	    $v=$G_OCP_STORE_Command_Format{'Dest_reg'}->{'val_hash'}->{$1};
	    $w=$G_OCP_STORE_Command_Format{'Dest_reg'}->{'wd'};
	   
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse Dest_reg field\n";
		&die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'Dest_reg'} = $bin;
	}
	else { # dest reg is not in the list
	    $die_msg="Dest register can can be one of :\n";
	    &die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,'Dest_reg');
	}
	if (defined $G_OCP_STORE_Command_Format{'ext_source'}->{'val_hash'}->{$2}){
	    $v=$G_OCP_STORE_Command_Format{'ext_source'}->{'val_hash'}->{$2};
	    $w=$G_OCP_STORE_Command_Format{'ext_source'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse ext_source field\n";
		&die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'ext_source'} = $bin;
	}
	else { # dest reg is not in the list
	    $die_msg="Data to registers can come only from external source .. ";
	    &die_fail_parse('OCP_STORE',$line_num,$cmd_org,$die_msg,1,'ext_source');
	}
    }
    
    ($cmd, $Affected_Mcode_fields{'pulse_bus'})  = &parse_pulse1($cmd);
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('OCP_STORE',$cmd_org,$cmd);
    }
    return (1, \%Affected_Mcode_fields);
    
}
##################################################################
##################################################################
##################################################################

@G_OCP_STORE_Command_Format = (
    {
	fname => 'regexp',
	#code => '(RAM\S\s*\S+\s*\S+\s*=\s*\w+)?(\s+R\d+\s*=\s*\S+)?(\s+pulse\s*->\s*\w+)?',
	code => $G_regexp{ 'commands' }->{ 'OCP_STORE' },
	example => "OCP[R7|R6|++] = Rx|Rx_h|Rx_l|registers  <Rx=sx> <pulse -> px>\n\tExample:OCP[R6] = R2\n\t\tOCP[R7++] = R3_l\n\t\tOCP[R6++] = R5 R1=s0",  
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 25,
	default => 25,
	comment => "write to OCP destination one of the registers, optionally increament 
address and load one of the registers with s0|s1 ",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => 'ext_source',
	wd => 2,
	comment => "the external source to be loaded to the registers",
	default => 3,
	val_hash => { 
	    s0 => 0,
	    s1 => 1,
	},
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
	fname => 'Dest_reg',
	wd => 3,
	comment => "indicate the register that will be loaded by external source",
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
	    R7 => 0,
	    R6 => 1,
	},
    },
    {
	fname => 'resereved',
	wd => 4,
	default => 0,
    },
    $pulse_bus_hash,
    );


for $i ( 0..$#G_OCP_STORE_Command_Format ){
    # print "$i $G_OCP_STORE_Command_Format[$i]{fname}\n";
    $G_OCP_STORE_Command_Format{ $G_OCP_STORE_Command_Format[$i]{fname} } = $G_OCP_STORE_Command_Format[$i];

if ($i != 0) {
    $G_OCP_STORE_Command_Format[$i]{ 'cur_val' } = 'z' x $G_OCP_STORE_Command_Format[$i]{ 'wd' };
}
$r = ref $G_OCP_STORE_Command_Format[$i];
# print " ref is $r\n";
}

1;
