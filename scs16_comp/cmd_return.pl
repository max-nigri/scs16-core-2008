sub parse_cmd_return{
# return command


    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my ($v, $w);
    my %Affected_Mcode_fields;
    my ($i, $key);
    my $die_msg;
    my ($success, $bin);
    
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # if you are here so you either die or success, you cant try enother command
    print "\tProbably RETURN command : $cmd\n";

    # expecting return ....
    if ($cmd =~ s/\b(return|rti|return_debug)\b//) { 
	if (defined $G_RETURN_Command_Format{'from'}->{'val_hash'}->{$1}){
	    $v =$G_RETURN_Command_Format{'from'}->{'val_hash'}->{$1};
	    $w =$G_RETURN_Command_Format{'from'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	    if ($success==0) {
		$die_msg="Fail to parse from field\n";
		&die_fail_parse('RETURN',$line_num,$cmd_org,$die_msg,1,0);
	    }
	    $Affected_Mcode_fields{'from'}=$bin;
	}
	else{
	    $die_msg="Fail to parse return command\n";
	    &die_fail_parse('RETURN',$line_num,$cmd_org,$die_msg,1,0);
	}
    }

    $v = $G_RETURN_Command_Format{'reserved'}->{'default'};
    $w = $G_RETURN_Command_Format{'reserved'}->{'wd'};
    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
    if ($success==0) {
	$die_msg="Fail to parse reserved field\n";
	&die_fail_parse('RETURN',$line_num,$cmd_org,$die_msg,1,0);
    }
    $Affected_Mcode_fields{'reserved'} = $bin;
    
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('RETURN',$cmd_org,$cmd);
    }
    return ( 1 , \%Affected_Mcode_fields);
}


##################################################################
##################################################################
##################################################################
@G_RETURN_Command_Format = (
    {
	fname => regexp,
	#  code => '\b(return|rti|return_debug)\b', 
	code => $G_regexp{ 'commands' }->{ 'RETURN' },
	example => "return or rti or  ,the interrupt routine should be labeled with : L_intr_routine",
    },
    {
	fname => opcode,
#     wd => 5,
	wd => $OPCODE_WIDTH,
	code => 14,
	default => 14,
	comment => "return command",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => from,
	wd => 2,
	default => 0,
	val_hash => { 
	    return => 0,
	    rti => 2,
	    return_debug => 1,
	    
	},
    },
    {
	fname => reserved,
	wd => 19,
	default => 0,
    },
    );


for $i ( 0..$#G_RETURN_Command_Format ){
    # print "$i $G_RETURN_Command_Format[$i]{fname}\n";
    $G_RETURN_Command_Format{ $G_RETURN_Command_Format[$i]{fname} } = $G_RETURN_Command_Format[$i];

$G_RETURN_Command_Format[$i]{ 'cur_val' } = z x $G_RETURN_Command_Format[$i]{ 'wd' };

$r = ref $G_RETURN_Command_Format[$i];
# print " ref is $r\n";
}


1;
