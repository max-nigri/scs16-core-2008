sub parse_cmd_jump{
# jump command
# jump \d+ 

    my($cmd) = shift(@_);

    my $cmd_org = $cmd;
    my($line_num) = shift(@_);
    my ($v, $w);
    my %Affected_Mcode_fields;
    my ($i, $key, $goto_type,$jump_add, $jump_add_w, $add_sel, $success, $bin);
    my $success;
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;


    # if you are here so you either die or success, you cant try enother command
    print "\tProbably JUMP command : $cmd\n";

    # expecting jump ....
    if ($cmd =~ s/\b(goto|gosub)\s+(\S+)//) { 
	$goto_type = $1;
	$jump_add = $2;
	$Affected_Mcode_fields{'goto_type'} = $G_JUMP_Command_Format{'goto_type'}->{'val_hash'}->{$goto_type};
	
	$add_sel = 'R5';
	if ($jump_add !~ /^R5$/) {
	    $add_sel = 'imd';
	    $jump_add_w = $G_JUMP_Command_Format{'Imd'}->{'wd'}+$G_JUMP_Command_Format{'Imd1'}->{'wd'};

	    ($success, $bin) = &parse_const_new1($jump_add ,$jump_add_w,'non_tc');
	    if ($success==0) {
		print "In Jump command! << $cmd_org >> Fail to parse address \n";
		die "Exiting !!!\n";
	    }
	    else {
		# $Affected_Mcode_fields{'Imd'} = $bin;
		$Affected_Mcode_fields{'Imd'} = substr($bin,$G_JUMP_Command_Format{'Imd1'}->{'wd'},
						   $G_JUMP_Command_Format{'Imd'}->{'wd'});
		$Affected_Mcode_fields{'Imd1'} = substr($bin,0,$G_JUMP_Command_Format{'Imd1'}->{'wd'});

	    }
	    # $Affected_Mcode_fields{'Imd'} = &parse_const($jump_add, \%{$G_JUMP_Command_Format{'Imd'}});
	}
	$Affected_Mcode_fields{'add_sel'} = $G_JUMP_Command_Format{'add_sel'}->{'val_hash'}->{$add_sel};
    }

    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('JUMP',$cmd_org,$cmd);
    }
    return ( 1 , \%Affected_Mcode_fields);

}

##################################################################
##################################################################
##################################################################
@G_JUMP_Command_Format = (
{
    fname => 'regexp',
    # code => '\b(gosub|goto)\b\s+\S+', 
    code => $G_regexp{ 'commands' }->{ 'JUMP' },
    example => 'gosub Label_x or goto Label_x\n\tExample:gosub L_jojo\n\t\tgoto L_koko', 
},
{
    fname => 'opcode',
    #wd => 5,
    wd => $OPCODE_WIDTH,
    code => 13,
    default => 13,
    comment => "jump command",
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
    default => 0,
},
{
    fname => 'goto_type',
    wd => 1,
    comment => "indicate the type of jump - gosub or goto",
    val_hash => { 
	'goto' => '0',
	'gosub' => '1',
    },
},
{
    fname => 'reserved1',
    wd => 3,
    default => 0,
},
{
    fname => 'add_sel',
    wd => 1,
    default => 0,
    comment => "selects the branch address ",
    val_hash => {
	imd => 0,
	R5 => 1,
    },
},
{
    fname => 'reserved',
    wd => 5,
    default => 0,
},
{
    fname => 'Imd',
    wd => 11,
    comment => "an unsigned number - start code of subroutine, 14 bits width",
    default => 0,
    type => "unsigned",
    regexp_hash => { 
	hexadecimal => "14'h([0-9a-f]{3})",
	binary      => "14'b([01]{11})",
	decimal     => '\b(-?\d+)$',  #'
    },
}
);


for $i ( 0..$#G_JUMP_Command_Format ){
    # print "$i $G_JUMP_Command_Format[$i]{fname}\n";
    $G_JUMP_Command_Format{ $G_JUMP_Command_Format[$i]{fname} } = $G_JUMP_Command_Format[$i];

if ($i != 0) {
    $G_JUMP_Command_Format[$i]{ 'cur_val' } = 'z' x $G_JUMP_Command_Format[$i]{ 'wd' };
}
$r = ref $G_JUMP_Command_Format[$i];
# print " ref is $r\n";
}


1;
