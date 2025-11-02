sub parse_cmd_pulse{
# dest command
# pulse -> \w+

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
    print "\tProbably PULSE command : $cmd\n";
    
    ($cmd, $Affected_Mcode_fields{'pulse_bus'})  = &parse_pulse1($cmd);
	
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('PULSE',$cmd_org,$cmd);
    }
    return ( 1 , \%Affected_Mcode_fields);
}

##################################################################
##################################################################
##################################################################

@G_PULSE_Command_Format = (
    {
	fname => 'regexp',
	#code => '^\bpulse\s*->\s*(\w+)', 
	example => "pulse -> px\n\tExample:pulse -> p12",
	code => $G_regexp{ 'commands' }->{ 'PULSE' },
	
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 11,
	default => 11,
	comment => "exclusive pulse bus manipulation",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => 'reserved',
	wd => 17,
	default => 0,
    },
    $pulse_bus_hash,
    );


for $i ( 0..$#G_PULSE_Command_Format ){
    # print "$i $G_PULSE_Command_Format[$i]{fname}\n";
    $G_PULSE_Command_Format{ $G_PULSE_Command_Format[$i]{fname} } = $G_PULSE_Command_Format[$i];
    
    if ($i != 0) {
	$G_PULSE_Command_Format[$i]{ 'cur_val' } = 'z' x $G_PULSE_Command_Format[$i]{ 'wd' };
    }
    $r = ref $G_PULSE_Command_Format[$i];
# print " ref is $r\n";
}


1;
