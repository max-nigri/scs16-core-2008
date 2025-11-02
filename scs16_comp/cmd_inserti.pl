sub parse_cmd_inserti{
    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my $die_msg;
    my %Affected_Mcode_fields;
    my($dest_reg,$range,$right_offset,$left_offset,$imd);
    my($dest_reg_w,$range_w,$right_offset_w,$left_offset_w,$imd_w,$w);
    my($num);
    my $success = 1;

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    print "\tProbably INSERTI command : $cmd\n";

    if ($cmd =~ s/\s*(R\d)\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])\s*=\s*(\d\S*)\s*//){
	$dest_reg = $1;
	$range = $2;
	$left_offset = $3;
	$right_offset = $4;
	$imd = $5;

	$res=7;
	$ext_ins=0;
    }
    else {
	$die_msg="fail to parse this line\n";
	&die_fail_parse('INSERTI',$line_num,$cmd_org,$die_msg,1,0);
	
    }
    $dest_reg_w     =$G_INSERTI_Command_Format{'dest_reg'}->{'wd'};
    $right_offset_w =$G_INSERTI_Command_Format{'right_offset'}->{'wd'};
    $left_offset_w  =$G_INSERTI_Command_Format{'left_offset'}->{'wd'};
    $ext_ins_w      =$G_INSERTRI_Command_Format{'ext_ins'}->{'wd'};
    $res_w          =$G_INSERTI_Command_Format{'reserved'}->{'wd'};
    $imd_w          =$G_INSERTI_Command_Format{'imd'}->{'wd'};
    
    $range=$left_offset-$right_offset;
    $range=$range+1;
    $left_offset=15-$left_offset;
    
    
##############################################################################
#####                  INPUT CHECKS                                     ######
##############################################################################
    
    if ($imd =~ /-/){     #opt
	die "should not be here Exiting !!!\n";
    }
    elsif ($imd =~ /^\d+$/){
	if ($imd > 31){
	    $die_msg="the immediate value is out of range. the command supports up to 5 bits unsingn value.\n";
	    &die_fail_parse('INSERTI',$line_num,$cmd_org,$die_msg,1,0);
	}
	elsif($imd > ((2 ** $range)-1)){
	    $die_msg="the immediate value is out of $range bits range.\n";
	    &die_fail_parse('INSERTI',$line_num,$cmd_org,$die_msg,1,0);
	}
    }
    elsif ($imd =~ /(\d+)\'\w*/){
	$imd_w=$1;
	if($imd_w > 5){
	    $die_msg="the immediate value is out of range, the command supports up to 5 bits unsingn value.\n";
	    &die_fail_parse('INSERTI',$line_num,$cmd_org,$die_msg,1,0);
	}
	elsif ($imd_w != ($range)){
	    $die_msg="the range of bits in dest_reg is not equal to imd bits range.\n";
	    &die_fail_parse('INSERTI',$line_num,$cmd_org,$die_msg,1,0);
	}
    }
    if($range > 5){
	$die_msg="range is too large for bit range. command support up to 5 bits in imd field\n";
	&die_fail_parse('INSERTI',$line_num,$cmd_org,$die_msg,1,0);
    }
    
##############################################################################
#####                   OPCODE   GENRATOR                               ######
##############################################################################


#imd
    $w=5 - $imd_w;
    ($success,$imd)= &parse_const_new1($imd,$imd_w,'non tc');
    if ($success==0) {
	print "The value $imd is not valid\n";
	die"Exiting !!!\n";
    }
    $imd_w=5;
    while($w != "0"){
	$imd="0".$imd;
	$w=$w-1;
    }
#dest_reg
    if (defined $G_INSERTI_Command_Format{'dest_reg'}->{'val_hash'}->{$dest_reg}){
	$dest_reg=$G_INSERTI_Command_Format{'dest_reg'}->{'val_hash'}->{$dest_reg};
	($success, $dest_reg)= &parse_const_new1($dest_reg,$dest_reg_w,'non tc');
	if ($success==0) {
	    print"In INSERTI Fail to parse dest_reg\n";
	    die"Exiting !!!\n";
	}
	$Affected_Mcode_fields{'dest_reg'} = $dest_reg;
    }
    else{
	$die_msg="dest_reg field should be one of:\n";
	&die_fail_parse('INSERTI',$line_num,$cmd_org,$die_msg,1,'dest_reg');
    }
    
        
#right_offset
    ($success, $right_offset)=&parse_const_new1($right_offset,$right_offset_w,'non tc');
    if ($success==0) {
	print "should not be here";
	die"Exiting !!!\n";
    }
#left_offset
    ($success, $left_offset)=&parse_const_new1($left_offset,$left_offset_w,'non tc');
    if ($success==0) {
	print "should not be here";
	die"Exiting !!!\n";
    }

    $Affected_Mcode_fields{'imd'}          = $imd;
    $Affected_Mcode_fields{'right_offset'} = $right_offset;
    $Affected_Mcode_fields{'left_offset'}  = $left_offset;
    $Affected_Mcode_fields{'R/I'}          = 1;
    $Affected_Mcode_fields{'ext_ins'}      = $ext_ins;

    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('INSERTI',$cmd_org,$cmd);
    }    
  
    return ( 1 , \%Affected_Mcode_fields);
}
##################################################################
##################################################################
##################################################################
@G_INSERTI_Command_Format = (
    {
	fname => 'regexp',
	
	# code => '\s*(R\d)\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])\s*=\s*(\d\S*)\s*',
	code => $G_regexp{ 'commands' }->{ 'INSERTI' },
	example => "  R5[15:12]=3 or R5[15:11]=5'h1a", 
	
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
	fname => 'imd',
	wd => 5,
	default => 0, 
    },
    {
	fname => 'R/I',
	wd => 1,
	default => 1,   #in extract its a dontcare.
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
	fname => 'reserved',
	wd => 3,
	default => 7, # to support alu right shift
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


for $i ( 0..$#G_INSERTI_Command_Format ){
    # print "$i $G_STORE_Command_Format[$i]{fname}\n";
    $G_INSERTI_Command_Format{ $G_INSERTI_Command_Format[$i]{fname} } = $G_INSERTI_Command_Format[$i];

if ($i != 0) {
    $G_INSERTI_Command_Format[$i]{ 'cur_val' } = 'z' x $G_INSERTI_Command_Format[$i]{ 'wd' };
}
$r = ref $G_INSERTI_Command_Format[$i];
# print " ref is $r\n";
}



1;
