sub parse_cmd_nop{
# nop command

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my %Affected_Mcode_fields;
    my ($i, $key);

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # if you are here so you either die or success, you cant try enother command
    print "\tProbably NOP command : $cmd\n";

    if ($cmd =~ s/\bnop\b//) { 	
    }
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('NOP',$cmd_org,$cmd);
    }
    return ( 1 , \%Affected_Mcode_fields);

}
##################################################################
##################################################################
##################################################################

@G_NOP_Command_Format = (
    {
	fname => 'regexp',
	# code => '\b(nop)\b',        #'
	code => $G_regexp{ 'commands' }->{ 'NOP' },
	example => 'nop <<with no other things!!!>>',
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 0,
	default => 0,
	num_of_lines => 1,  
	comment => "nop command ",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => 'reserved',
	wd => 21,
	default => 0,
    },
    );


for $i ( 0..$#G_NOP_Command_Format ){
    # print "$i $G_NOP_Command_Format[$i]{fname}\n";
    $G_NOP_Command_Format{ $G_NOP_Command_Format[$i]{fname} } = $G_NOP_Command_Format[$i];

if ($i != 0) {
    $G_NOP_Command_Format[$i]{ 'cur_val' } = 'z' x $G_NOP_Command_Format[$i]{ 'wd' };
}
$r = ref $G_NOP_Command_Format[$i];
# print " ref is $r\n";
}

1;
