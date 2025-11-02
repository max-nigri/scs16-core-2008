sub parse_cmd_extract{
# R1 == R2 = RAM[R7+=R5/1]

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my $die_msg;
    my %Affected_Mcode_fields;
    my ($i);
    my $success;
    my ($dest_reg,$source_reg, $range, $r_offset,$l_offset,$ext_ins);
    my ($dest_reg_w,$source_reg_w, $r_offset_w,$l_offset_w,$ext_ins_w,$res,$res_w);

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # return (0, \%Affected_Mcode_fields);
    print "\tProbably EXTRACT command : $cmd\n";
   

  
 if ($cmd =~ s/\s*(R\d)\s*=\s*(R\d)\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])\s*//){     #extract
	$dest_reg = $1;
	$source_reg = $2;
	$range=$3;
	$l_offset = $4;
	$r_offset = $5;
	
	$res=6;
	$ext_ins=1;
    }

$l_offset=(15 - $l_offset);
    
##############################################################################
#####                  INPUT CHECKS                                     ######
##############################################################################

##############################################################################
#####                   OPCODE   GENRATOR                               ######
##############################################################################

### dest_reg ###   
    if (defined $G_EXTRACT_Command_Format{'dest_reg'}->{'val_hash'}->{$dest_reg}){
	$dest_reg=$G_EXTRACT_Command_Format{'dest_reg'}->{'val_hash'}->{$dest_reg};
	$dest_reg_w=$G_EXTRACT_Command_Format{'dest_reg'}->{'wd'};
	($success, $bin) = &parse_const_new1($dest_reg,$dest_reg_w,'non_tc');
	if ($success==0) {
	    print "In EXTRACT  command! << $cmd_org >> Fail to parse dest_reg\n";
	    die "Exiting !!!\n";
	    }
	$Affected_Mcode_fields{'dest_reg'} = $bin;
    }
    else{
	$die_msg="Dest field should be one of:\n";
	&die_fail_parse('EXTRACT',$line_num,$cmd_org,$die_msg,1,'dest_reg');
    }
### source_reg ### 
    if (defined $G_EXTRACT_Command_Format{'source_reg'}->{'val_hash'}->{$source_reg}){
	$source_reg=$G_EXTRACT_Command_Format{'source_reg'}->{'val_hash'}->{$source_reg};
	$source_reg_w=$G_EXTRACT_Command_Format{'source_reg'}->{'wd'};
	($success, $bin) = &parse_const_new1($source_reg,$source_reg_w,'non_tc');
	if ($success==0) {
	    print "In EXTRACT  command! << $cmd_org >> Fail to parse source_reg\n";
	    die "Exiting !!!\n";
	}
	$Affected_Mcode_fields{'source_reg'} = $bin;
    }
    else{
	$die_msg="source_reg field should be one of:\n";
	&die_fail_parse('EXTRACT',$line_num,$cmd_org,$die_msg,1,'source_reg');
    }
### ### 
    $r_offset_w=$G_EXTRACT_Command_Format{'right_offset'}->{'wd'};
    $l_offset_w=$G_EXTRACT_Command_Format{'left_offset'}->{'wd'};
    $ext_ins_w=$G_EXTRACT_Command_Format{'ext_ins'}->{'wd'};
    $res_w=$G_EXTRACT_Command_Format{'resereved1'}->{'wd'};
    $Affected_Mcode_fields{'resereved2'}= "00";

### resereved1 ### 
    ($success, $bin) = &parse_const_new1($res,$res_w,'non_tc');
	if ($success==0) {
	    print "In EXTRACT command! << $cmd_org >> Fail to parse reserved1\n";
	    die "Exiting !!!\n";
	}
    $Affected_Mcode_fields{'resereved1'}=$bin;

### ext_ins ### 
    ($success, $bin) = &parse_const_new1($ext_ins,$ext_ins_w,'non_tc');
    if ($success==0) {
	print "In EXTRACT command! << $cmd_org >> Fail to parse ext_ins\n";
	die "Exiting !!!\n";
	}
    $Affected_Mcode_fields{'ext_ins'}= $bin;

### right_offset ### 
    ($success, $bin) = &parse_const_new1($r_offset,$r_offset_w,'non_tc');
    if ($success==0) {
	print "In EXTRACT command! << $cmd_org >> Fail to right_offset \n";
	die "Exiting !!!\n";
	}
    $Affected_Mcode_fields{'right_offset'}= $bin;
   
### left_offset ###  
    ($success, $bin) = &parse_const_new1($l_offset,$l_offset_w,'non_tc');
    if ($success==0) {
	print "In EXTRACT command! << $cmd_org >> Fail to left_offset \n";
	die "Exiting !!!\n";
    }
    $Affected_Mcode_fields{'left_offset'}= $bin;
### leftovers  ###   
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('EXTRACT',$cmd_org,$cmd);
    }
    
    return ( 1 , \%Affected_Mcode_fields);
    
}

##################################################################
##################################################################
##################################################################
@G_EXTRACT_Command_Format = (
    {
	fname => 'regexp',
	# code => '\bbreakif\b',
	#code =>'\s*(R\d)\s*=\s*(R\d)\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])\s*',
	code => $G_regexp{ 'commands' }->{ 'EXTRACT' },
	example => "Rx=Ry[j:i]\n\tExample:R2=R5[15:7]\n\t\tR0=R6[3:2]", 
	
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 19,
	default => 19,
	comment => "extins",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => 'source_reg',
	wd => 3,
	comment => "the source register - right value - using Ra mux",
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
	fname => 'resereved2',
	wd => 2,
	default => 0, 
    },
    {
	fname => 'R/I',
	wd => 1,
	default => 0,   #in extract its a dontcare.
    },

    {
	fname => 'dest_reg',
	wd => 3,
	comment => "the register that will get the results",
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
	fname => 'resereved1',
	wd => 3,
	default => 6, # to support alu right shift
    },

    {
	fname => 'ext_ins',  #extract=1 insert=0
	wd => 1,
	default => 1,
    }, 
    {
	fname => 'left_offset',
	wd => 4,
	default => 0,
	comment => "offset from left (for mask)",
	regexp_hash => { 
	    hexadecimal => "16'h([0-9a-f]{4})",
	    binary      => "16'b([01]{16})",
	    decimal     => '\b(-?\d+)$',      #'
	},
    },
    {
	fname => 'right_offset',
	wd => 4,
	default => 0,
	comment => "offset from right (for mask)",
	regexp_hash => { 
	    hexadecimal => "16'h([0-9a-f]{4})",
	    binary      => "16'b([01]{16})",
	    decimal     => '\b(-?\d+)$',      #'
	},
    },
    );

for $i ( 0..$#G_EXTRACT_Command_Format ){
    # print "$i $G_STORE_Command_Format[$i]{fname}\n";
    $G_EXTRACT_Command_Format{ $G_EXTRACT_Command_Format[$i]{fname} } = $G_EXTRACT_Command_Format[$i];

if ($i != 0) {
    $G_EXTRACT_Command_Format[$i]{ 'cur_val' } = 'z' x $G_EXTRACT_Command_Format[$i]{ 'wd' };
}
$r = ref $G_EXTRACT_Command_Format[$i];
# print " ref is $r\n";
}


1;
