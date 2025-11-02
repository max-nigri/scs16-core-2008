sub parse_cmd_ocp_storeia{


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
    my($r6_r7_w,$offset_w,$source_reg,$source_reg_w);

    $r6_r7=0;
    $offset=-1;
   

    print "\tProbably OCP_STOREIA command : $cmd\n";
    
    #OCP[100+R7]=device  or OCP[100]=R3_h 

    if ($cmd =~ s/OCP\[\s*(\d\S*)\s*\]\s*=\s*(\w+)//){
	$add=$1;
	$r_side=$2;
	
	if ($add =~ /(\S+)\s*\+\s*(\S+)/){  #to check is its simple or [100+R7]
	    $offset_bin=$1;
	    $r6_r7=$2;
	    $offset=1;
	}
	else{
	    
	    $offset_bin=$add;
	    $offset=0;
	    $r6_r7=0;
	}
    }
#OCP[R7+100]=device
    elsif($cmd =~ s/OCP\[\s*(R[6-7]\+\d+)\s*\]\s*=\s*(\w+)//){
	$add=$1;
	$r_side=$2;
	
	if ($add =~ /(\S+)\+(\S+)/){   #to check is its simple or [R7+100]
	    $offset_bin=$2;
	    $r6_r7=$1;
	    $offset=1;
	}
	else{
	    $offset_bin=$add;
	    $offset=0;
	    $r6_r7=0;
	}
    }
    else{
	&die_fail_parse('OCP_STOREIA',$line_num,$cmd_org,"can not mach the command",1,0);
    }
   
##############################################################################
#####                  INPUT CHECKS                                     ######
##############################################################################
    #this check is for the case that we have a register for the address but we make sure its only R6 or R7
    #and also to avoid [100+R6_h] mod 8/12/03
    if($r6_r7 ne "0"){  
	if ($r6_r7 !~ /\bR[6-7]\b/){    
	    $die_msg="only R6 & R7 can be used to store to the memory\n";
	    &die_fail_parse('OCP_STOREIA',$line_num,$cmd_org,$die_msg,1,0);
	}
    }
##############################################################################
#####                   OPCODE   GENRATOR                               ######
##############################################################################
### imd 1+2 ###
    ($success, $offset_bin) = &parse_const_new1($offset_bin,12,'non tc');
    if ($success==0) {
	&die_fail_parse('OCP_STOREIA',$line_num,$cmd_org,"Fail to parse immediate address\n",1,0);
    }
    $Affected_Mcode_fields{'imd1'} = substr($offset_bin, 4,8);
    $Affected_Mcode_fields{'imd2'} = substr($offset_bin, 0,4);    
    
### R6/7 ###
    if($r6_r7 ne "0"){
	$r6_r7=$G_OCP_STOREIA_Command_Format{'r6_r7'}->{'val_hash'}->{$r6_r7};
	$r6_r7_w = $G_OCP_STOREIA_Command_Format{'r6_r7'}->{'wd'};
	($success, $bin) = &parse_const_new1($r6_r7,$r6_r7_w,'non tc');
	if ($success==0) {
	    &die_fail_parse('OCP_STOREIA',$line_num,$cmd_org,"Fail to parse r6 r7 field\n",1,0);
	    
	}
	else{
	    $Affected_Mcode_fields{'r6_r7'} = $bin;
	}
    }
    else{
	$Affected_Mcode_fields{'r6_r7'} = 0;
    }
### source_reg & write_en ###
#the next part is for the source register and high low checks and opcode.	 
    if ($r_side =~ s/_(l|h)//) {
	$byte_sel = "Rx_$1";
	$v = $G_OCP_STOREIA_Command_Format{'write_en'}->{'val_hash'}->{$byte_sel};
	$w = $G_OCP_STOREIA_Command_Format{'write_en'}->{'wd'};
	($success, $bin) = &parse_const_new1($v,$w,'non tc');
	if ($success==0) {
	    &die_fail_parse('OCP_STOREIA',$line_num,$cmd_org,"Fail to parse write_en field\n",1,0);
	}
	$Affected_Mcode_fields{'write_en'} = $bin;
    }
    if (defined $G_OCP_STOREIA_Command_Format{'source_reg'}->{'val_hash'}->{$r_side}){
	$source_reg=$G_OCP_STOREIA_Command_Format{'source_reg'}->{'val_hash'}->{$r_side};
	$source_reg_w=$G_OCP_STOREIA_Command_Format{'source_reg'}->{'wd'};
	($success, $bin) = &parse_const_new1($source_reg,$source_reg_w,'non tc'); 
	if ($success==0) {
	    &die_fail_parse('OCP_STOREIA',$line_num,$cmd_org,"Fail to parse source_reg field\n",1,0);
	}
	$Affected_Mcode_fields{'source_reg'} =$bin;
    }
    else { # dest reg is not in the list
	$die_msg="Invalid Data to Ram data, source reg\n";
	&die_fail_parse('OCP_STOREIA',$line_num,$cmd_org,$die_msg,1,'source_reg');
    }
### offset ###   
    $offset_w=$G_OCP_STOREIA_Command_Format{'offset'}->{'wd'};
    ($success, $bin) =&parse_const_new1($offset,$offset_w,'non tc');
    if ($success==0) {
	&die_fail_parse('OCP_STOREIA',$line_num,$cmd_org,"Fail to parse offset field\n",1,0);
    }
    $Affected_Mcode_fields{'offset'} =$bin;

###  ###
    $Affected_Mcode_fields{'add_data'} = '0';
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('OCP_STOREIA',$cmd_org,$cmd);
    }
    
    return (1, \%Affected_Mcode_fields);
    
}

##################################################################
##################################################################
##################################################################


@G_OCP_STOREIA_Command_Format = (
    {
	fname => 'regexp',
	#code => '(OCP\[\s*\d\S*\s*\S*\s*\S*\]=\s*\w+)',
	code => $G_regexp{ 'commands' }->{ 'OCP_STOREIA' },
	example => "OCP[imd] = Rx<_l|_h> or OCP[imd+R6|7] = Rx<_l|_h> \n\tExample:OCP[100]=R2_l\n\t\tOCP[10+R6]=R4 ",  
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 26,
	default => 26,
	comment => "store Rx to imd address",
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
	default => 0,
    },
    {
	fname => 'offset',
	wd => 1,
	comment => "indicate That its not only an imd address but also R6 | R7",
	default => 0,
    },
#  {
#      fname => 'reserved',
#      wd => 1,
#      default => 0,
    
#  },
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
	fname => 'r6_r7',
	wd => 1,
	default => 0,
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


for $i ( 0..$#G_OCP_STOREIA_Command_Format ){
    $G_OCP_STOREIA_Command_Format{ $G_OCP_STOREIA_Command_Format[$i]{fname} } = $G_OCP_STOREIA_Command_Format[$i];

if ($i != 0) {
    $G_OCP_STOREIA_Command_Format[$i]{ 'cur_val' } = 'z' x $G_OCP_STOREIA_Command_Format[$i]{ 'wd' };
}
$r = ref $G_OCP_STOREIA_Command_Format[$i];

}

1;
