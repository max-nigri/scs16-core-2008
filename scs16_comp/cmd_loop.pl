sub parse_cmd_loop{
# loop command
# loop \d+ \d+ (Acc|\d+)

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my ($v, $w);
    my %Affected_Mcode_fields;
    my ($i, $key);
    my $success,$bin,$die_msg;

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

   

    # if you are here so you either die or success, you cant try enother command
    print "\tProbably LOOP command : $cmd\n";

    # expecting loop ....
    if ($cmd =~ s/\bloop\s+(\S+)\s+(\S+)\s+(\S+)//) { 
	if (defined $G_LOOP_Command_Format{'ra_sel'}->{'val_hash'}->{$3}){
	    $v = $G_LOOP_Command_Format{'ra_sel'}->{'val_hash'}->{$3};
	    $w = $G_LOOP_Command_Format{'ra_sel'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0){
		$die_msg="Fail to parse ra_sel\n";
		&die_fail_parse('LOOP',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'ra_sel'} = $bin;
	    $Affected_Mcode_fields{'Imd'} = &parse_const($G_LOOP_Command_Format{'Imd'}->{'default'}, \%{$G_LOOP_Command_Format{'Imd'}});
	    }
	else{ # check if match regexp of Imd field
	    $Affected_Mcode_fields{'Imd'} = &parse_const($3, \%{$G_LOOP_Command_Format{'Imd'}});
	    $v = $G_LOOP_Command_Format{'ra_sel'}->{'val_hash'}->{'Imd'};
	    $w = $G_LOOP_Command_Format{'ra_sel'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0){
		$die_msg="Fail to parse ra_sel\n";
		&die_fail_parse('LOOP',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'ra_sel'} = $bin;
	}
	
	$Affected_Mcode_fields{'start_offset'} = &parse_const($1, \%{$G_LOOP_Command_Format{'start_offset'}});
	$Affected_Mcode_fields{'end_offset'} = &parse_const($2, \%{$G_LOOP_Command_Format{'end_offset'}});
	
	
    }

    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('LOOP',$cmd_org,$cmd);
    }
    return ( 1 , \%Affected_Mcode_fields);
}

##################################################################
##################################################################
##################################################################

@G_LOOP_Command_Format = (
    {
	fname => 'regexp',
	#code => '\bloop\b\s+\S+',
	code => $G_regexp{ 'commands' }->{ 'LOOP' },
	example => "loop Label_x Label_y dig|Rx\n\texample:loop L_a L_b 50\n\t\tloop L_a L_a R6",
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 9,
	default => 9,
	comment => "loop command ",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => 'ra_sel',
	wd => 3,
	comment => "indicate the N source, Rx or imd ",
	val_hash => { 
	    R0 => 0,
	    R1 => 1,
	    R2 => 2,
	    R3 => 3,
	    R4 => 4,
	    R5 => 5,
	    R6 => 6,
	    Imd => 7,
	},
    },
    {
	fname => 'start_offset',
	wd => 3,
	comment => "positive number n pc_start = pc + start_offset",
	type => "unsigned",
	regexp_hash => { 
	    hexadecimal => "3'h([0-9a-f])",
	    binary      => "3'b([01]{3})",
	    decimal     => '\b(-?\d+)$',   #'
	},
    },
    {
	fname => 'end_offset',
	wd => 5,
	comment => "positive number n pc_stop = pc + start_offset + stop_offset",
	type => "unsigned",
	regexp_hash => { 
	    hexadecimal => "5'h([0-9a-f]{2})",
	    binary      => "5'b([01]{5})",
	    decimal     => '\b(-?\d+)$',  #'
	},
    },
    {
	fname => 'Imd',
	wd => 10,
	comment => "an unsigned number, 10 bits width",
	default => 0,
	type => "unsigned",
	regexp_hash => { 
	    hexadecimal => "10'h([0-9a-f]{3})",
	    binary      => "10'b([01]{10})",
	    decimal     => '\b(-?\d+)$',   #'
	},
    }
    );


for $i ( 0..$#G_LOOP_Command_Format ){
    # print "$i $G_LOOP_Command_Format[$i]{fname}\n";
    $G_LOOP_Command_Format{ $G_LOOP_Command_Format[$i]{fname} } = $G_LOOP_Command_Format[$i];

if ($i != 0) {
    $G_LOOP_Command_Format[$i]{ 'cur_val' } = 'z' x $G_LOOP_Command_Format[$i]{ 'wd' };
}
$r = ref $G_LOOP_Command_Format[$i];
# print " ref is $r\n";
}

1;
