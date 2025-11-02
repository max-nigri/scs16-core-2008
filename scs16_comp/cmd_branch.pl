sub parse_cmd_branch{
# this routine check if its a simple branch command
# branch <signal>

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my $die_msg;
    my (@tmp,$tmp,$address,$negate,$reg,$bit,$flag);
    my ($tmp_w,$address_w,$negate_w,$reg_w,$bit_w,$flag_w);
    my %Affected_Mcode_fields ;
    my $success, $bin;
    my $con_num;
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # print "$cmd\n";

    print "\tProbably BRANCH command : $cmd\n";

    if ($cmd =~ s/\bbranch\b\s+\(?\s*(!)?\s*([^\)]+)\s*\)?\s+(\S+)//) { # catching "branch string" anywhare in $cmd
	$address = $3;
	$tmp = $2;
	$negate = $1;
### address ###
	$address_w=$G_BRANCH_Command_Format{'Imd'}->{'wd'}+$G_BRANCH_Command_Format{'Imd1'}->{'wd'};
	if ($address =~ /^\d+/){
	    ($success, $bin) = &parse_const_new1($address ,$address_w,'non_tc');
	    if ($success==0) {
		print "In Branch command! << $cmd_org >> Fail to parse address \n";
		die "Exiting !!!\n";
	    }
	    else {
		# $Affected_Mcode_fields{'Imd'} = $bin;
		$Affected_Mcode_fields{'Imd'} = substr($bin,$G_BRANCH_Command_Format{'Imd1'}->{'wd'},
						   $G_BRANCH_Command_Format{'Imd'}->{'wd'});
		$Affected_Mcode_fields{'Imd1'} = substr($bin,0,$G_BRANCH_Command_Format{'Imd1'}->{'wd'});

	    }
	}
	else{
	    $die_msg="address is not clear .... :\n\n";
	    &die_fail_parse('BRANCH',$line_num,$cmd_org,$die_msg,1,0);
	}

### polarity ###	
	if ($negate eq '!'){
	    $Affected_Mcode_fields{'polarity'} = '1';
	}
	else{
	    $Affected_Mcode_fields{'polarity'} = '0';
	}
	$tmp_w=$G_BRANCH_Command_Format{'flag_bit'}->{'wd'};


	if ($tmp =~ /c(\d+)/){
	    $con_num=$1;
	    ($success, $bin) = &parse_const_new1($con_num ,$tmp_w,'non_tc');
	    if ($success==0) {
		print "In Branch command! << $cmd_org >> Fail to parse condition number\n";
		die "Exiting !!!\n";
	    }
	    else{
		$Affected_Mcode_fields{'flag_bit'} = $bin;
		$Affected_Mcode_fields{'int_ext'}=0;
		$Affected_Mcode_fields{'reg_flag'} = 0;
	    } 
	}
### ra_sel ###	
	elsif ($tmp =~ /(R\d)\[(\d+)\]/){
	    $reg=$1; $bit=$2;
	    if (defined $G_BRANCH_Command_Format{'ra_sel'}->{'val_hash'}->{$reg}){
		$reg = $G_BRANCH_Command_Format{'ra_sel'}->{'val_hash'}->{$reg};
		$reg_w = $G_BRANCH_Command_Format{'ra_sel'}->{'wd'};
		($success, $bin) = &parse_const_new1($reg,$reg_w,'non_tc');
		if ($success==0) {
		    print "In Branch command! << $cmd_org >> Fail to parse register number\n";
		    die "Exiting !!!\n";
		}
		else{
		    $Affected_Mcode_fields{'ra_sel'} = $bin;
		    $Affected_Mcode_fields{'int_ext'} = 1;
		    $Affected_Mcode_fields{'reg_flag'} = 1;
		    $bit_w = $G_BRANCH_Command_Format{'flag_bit'}->{'wd'};
		    ($success, $bin)=&parse_const_new1($bit ,$bit_w,'non_tc'); 
		    if ($success==0) {
			print "In Branch command! << $cmd_org >> Fail to parse bit number. \n";
			die "Exiting !!!\n";
		    }
		    else{
			$Affected_Mcode_fields{'flag_bit'} = $bin;
		    }
		}
		
	    }
	    else{
		$die_msg="Register should be one of :\n\n";
		&die_fail_parse('BRANCH',$line_num,$cmd_org,$die_msg,1,'ra_sel');

	    }
	}
### flag_bit ###			
	elsif (defined $G_BRANCH_Command_Format{'flag_bit'}->{'val_hash'}->{$tmp}){
	    $flag = $G_BRANCH_Command_Format{'flag_bit'}->{'val_hash'}->{$tmp};
	    $flag_w = $G_BRANCH_Command_Format{'flag_bit'}->{'wd'};
	    ($success, $bin)=&parse_const_new1($flag ,$flag_w,'non tc'); 
	    if ($success==0) {
		print "In Branch command! << $cmd_org >> Fail to parse flag number . \n";
		die "Exiting !!!\n";
	    }
	    $Affected_Mcode_fields{'flag_bit'} = $bin;
	    $Affected_Mcode_fields{'int_ext'} = 1;
	    $Affected_Mcode_fields{'reg_flag'} = 0;
	}
	else{
	    $die_msg="flag should  be one of :\n";
	    &die_fail_parse('BRANCH',$line_num,$cmd_org,$die_msg,1,'flag_bit');
  	}


### leftovers ###	    
	if ($cmd =~ /[^\s]+/) { # catching leftovers
	    &die_leftovers('BRANCH',$cmd_org,$cmd);
	}
    }
    return ( 1 , \%Affected_Mcode_fields);
}

##################################################################
##################################################################
##################################################################

@G_BRANCH_Command_Format = (
{
    fname => 'regexp',
   # code => '\bbranch\b\s+\S+',$address_w
    code => $G_regexp{ 'commands' }->{ 'BRANCH' },
    example => "branch <!>Rx[bit] xxx  or branch <!>cx xxx or  branch <!>xx_flag xxx \n\tExample:branch !R3[15] 20\n\t\tbranch c2 25\n\t\tbranch eq_flag 100 ", 
},
{
    fname => 'opcode',
    # wd => 5,
    wd => $OPCODE_WIDTH,
    code => 16,
    default => 16,
    comment => "branch command",
},
{
    fname => 'res32',
    wd => 3,
    default => 0,
},
{
    fname => 'Imd1',
    wd => 3,
    comment => "the upper part of unsigned 14 bit pc number",
},

{
    fname => 'ra_sel',
    wd => 3,
    comment => "indicate the register that it's bit will be checked ",
    default => 7,
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
{
    fname => 'reg_flag',
    wd => 1,
    default => 0,
    comment => "indicate register or flags",
    val_hash => {
	flag => 0,
	reg => 1,
    },
},
{
    fname => 'int_ext',
    wd => 1,
    default => 0,
    comment => "indicate if the soures is external (c0,c7) or internal",
    val_hash => {
	ext => 0,
	int => 1,
    },
},
{
    fname => 'polarity',
    wd => 1,
    default => 0,
    comment => "zero means normal polarity",
},
{
    
    fname => 'flag_bit',
    wd => 4,
    comment => "(flag) signal that is used for wait",
    val_hash => { 
	neg_flag      => 15,
	zero_flag     => 14,
	eq_flag       => 13, 
	gr_flag       => 12, 
	ls_flag       => 11,
	ovf_flag      => 10, 
	eq_gr_flag    => 9,
	eq_ls_flag    => 8,

	t0_done    => 4,
	t1_done    => 3,
	in_main_level => 2,
	loop_invoked  => 1,
	search_stop   => 0,
    },
},
   
{
    fname => 'Imd',
    wd => 11,
    comment => "an unsigned number - branch target, 11 bits width",
    default => 0,
    type => "unsigned",
    regexp_hash => { 
	hexadecimal => "11'h([0-9a-f]{3})",
	binary      => "11'b([01]{11})",
	decimal     => '\b(-?\d+)$',  # '
    },
}
);


for $i ( 0..$#G_BRANCH_Command_Format ){
    # print "$i $G_BRANCH_Command_Format[$i]{fname}\n";
    $G_BRANCH_Command_Format{ $G_BRANCH_Command_Format[$i]{fname} } = $G_BRANCH_Command_Format[$i];

if ($i != 0) {
    $G_BRANCH_Command_Format[$i]{ 'cur_val' } = 'z' x $G_BRANCH_Command_Format[$i]{ 'wd' };
}
$r = ref $G_BRANCH_Command_Format[$i];
# print " ref is $r\n";
}


1;
