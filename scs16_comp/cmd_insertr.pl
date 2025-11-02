sub parse_cmd_insertr{
    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my %Affected_Mcode_fields;
    my($dest_reg,$source_reg, $range, $r_offset,$l_offset,$ext_ins,$res,$left_offset,$right_offset);
    my($dest_reg_w,$source_reg_w, $range_w, $r_offset_w,$l_offset_w,$ext_ins_w,$res_w,$right_offset_w,$left_offset_w);
    my $success = 1;

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    print "\tProbably INSERTR command : $cmd\n";

    if ($cmd =~ s/\s*(R\d)\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])\s*=\s*(R\d)\s*//){   #insert r
	$dest_reg = $1;
	$range = $2;
	$l_offset = $3;
	$r_offset = $4;
	$source_reg = $5;
	$ext_ins = 0;
	$res = 7;
    }
    else {
	# &elaborate_field(1,$G_LOAD_Command_Format{'Dest_reg'}->{'val_hash'});
	print "in INSERTR cpmmand << $cmd_org >>, fail to parse : << $cmd >> expression\n\n";
	&print_command_example('G_INSERTR_Command_Format');
	die "Exiting !!! \n";
	
    }
    
    $dest_reg_w   =$G_INSERTR_Command_Format{'dest_reg'}->{'wd'};
    $source_reg_w =$G_INSERTR_Command_Format{'source_reg'}->{'wd'};
    $r_offset_w   =$G_INSERTR_Command_Format{'right_offset'}->{'wd'};
    $l_offset_w   =$G_INSERTR_Command_Format{'left_offset'}->{'wd'};
    $ext_ins_w    =$G_INSERTR_Command_Format{'ext_ins'}->{'wd'};
    $res_w        =$G_INSERTR_Command_Format{'reserved1'}->{'wd'};


##############################################################################
#####                  INPUT CHECKS                                     ######
##############################################################################
    
    if(($l_offset>15)|| ($r_offset<0)){
$die_msg="bit offset out of range!!!\n";
	&die_fail_parse('INSERTR',$line_num,$cmd_org,$die_msg,1,0);

	
    }
    elsif($l_offset<$r_offset){
	$die_msg=", left offset $l_offset < right offset $r_offset\n";
	&die_fail_parse('INSERTR',$line_num,$cmd_org,$die_msg,1,0);
	
    }
    $l_offset=15-$l_offset;
##############################################################################
#####                   OPCODE   GENRATOR                               ######
##############################################################################
#source_reg         
    if (defined $G_INSERTR_Command_Format{'source_reg'}->{'val_hash'}->{$source_reg}){
	$source_reg=$G_INSERTR_Command_Format{'source_reg'}->{'val_hash'}->{$source_reg};
	($success, $source_reg)= &parse_const_new1($source_reg,$source_reg_w,'non tc');
	if ($success==0) {
	    $die_msg="Fail to parse source_reg field\n";
	    &die_fail_parse('INSERTR',$line_num,$cmd_org,$die_msg,1,0);
	}
    }
    else{
	$die_msg="source register should be one of :\n";
	&die_fail_parse('INSERTR',$line_num,$cmd_org,$die_msg,1,'source_reg');
    }

#dest_reg
    if (defined $G_INSERTR_Command_Format{'dest_reg'}->{'val_hash'}->{$dest_reg}){
	$dest_reg=$G_INSERTR_Command_Format{'dest_reg'}->{'val_hash'}->{$dest_reg};
	($success, $dest_reg)= &parse_const_new1($dest_reg,$dest_reg_w,'non tc');
	if ($success==0) {
	    $die_msg="Fail to parse dest_reg field\n";
	    &die_fail_parse('INSERTR',$line_num,$cmd_org,$die_msg,1,0);
	}
    }
    else{
	$die_msg="Dest register should be one of :\n";
	&die_fail_parse('INSERTR',$line_num,$cmd_org,$die_msg,1,'dest_reg');
    }
#right_offset
    ($success, $right_offset)=&parse_const_new1($r_offset,$r_offset_w,'non tc');
    if ($success==0) {
	$die_msg="Fail to parse right_offset field\n";
	&die_fail_parse('INSERTR',$line_num,$cmd_org,$die_msg,1,0);
    }
#left_offset
    ($success, $left_offset)=&parse_const_new1($l_offset,$l_offset_w,'non tc');
    if ($success==0) {
	$die_msg="Fail to parse left_offset field\n";
	&die_fail_parse('INSERTR',$line_num,$cmd_org,$die_msg,1,0);
    }
#reserved1
    ($success, $res)=&parse_const_new1($res,$res_w,'non tc');
    if ($success==0) {
	$die_msg="Fail to parse res field\n";
	&die_fail_parse('INSERTR',$line_num,$cmd_org,$die_msg,1,0);
    }
#Affected_Mcode_fields    
    $Affected_Mcode_fields{'reserved1'}= $res;
    $Affected_Mcode_fields{'dest_reg'}=  $dest_reg;
    $Affected_Mcode_fields{'source_reg'}= $source_reg;
    $Affected_Mcode_fields{'ext_ins'}= $ext_ins;
    $Affected_Mcode_fields{'right_offset'}= $right_offset;
    $Affected_Mcode_fields{'left_offset'}=$left_offset;
    $Affected_Mcode_fields{'reserved2'}="00";
    $Affected_Mcode_fields{'R/I'}=0;
    
#leftovers    
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('INSERTR',$cmd_org,$cmd);
    }
    
    
    return ( 1 , \%Affected_Mcode_fields);
}
##################################################################
##################################################################
##################################################################
@G_INSERTR_Command_Format = (
    {
	fname => 'regexp',
	# code => '\bbreakif\b',
	#code => '\s*(R\d)\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])\s*=\s*(R\d)\s*',
	code => $G_regexp{ 'commands' }->{ 'INSERTR' },
	example => "R5[i:j]=Rx\n\tExample:R5[12:4]=R7 ", 
	
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
	fname => 'reserved2',
	wd => 2,
	default => 0, 
    },
    {
	fname => 'R/I',
	wd => 1,
	default => 0,   
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
	fname => 'reserved1',
	wd => 3,
	default => 7, # to support alu right shift
    },
    
    {
	fname => 'ext_ins',  #etract=1 insert=0
	wd => 1,
	default => 0,
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

for $i ( 0..$#G_INSERTR_Command_Format ){
    # print "$i $G_STORE_Command_Format[$i]{fname}\n";
    $G_INSERTR_Command_Format{ $G_INSERTR_Command_Format[$i]{fname} } = $G_INSERTR_Command_Format[$i];

if ($i != 0) {
    $G_INSERTR_Command_Format[$i]{ 'cur_val' } = 'z' x $G_INSERTR_Command_Format[$i]{ 'wd' };
}
$r = ref $G_INSERTR_Command_Format[$i];
# print " ref is $r\n";
}


1;
