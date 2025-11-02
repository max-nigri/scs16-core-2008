sub parse_cmd_data{
#  DATA 29'h12345 

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w, $r_side,$l_side);
    my ($success, $bin);
    my ($success1, $bin1);
    my %Affected_Mcode_fields;
    my $die_msg;
    my ($i, $key);
    my($bin_tmp);
    
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;
   


    print "\tProbably DATA command : $cmd\n";

    $cmd =~ s/DATA\s+//;   
  
    while ($cmd =~ s/(\S+)//) { 
	$v = $1;
	$w = $G_DATA_Command_Format{'opcode'}->{'wd'} + 27;
	($success, $bin) = &parse_const_new1($v,$w,'non_tc');
	if ($success==0){
	    $die_msg="Fail to parse element $v in data command\n";
	    &die_fail_parse('DATA',$line_num,$cmd_org,$die_msg,1,0);
	}
	$bin_tmp .= $bin;
    }


    $Affected_Mcode_fields{'opcode'} = substr($bin_tmp,0,$G_DATA_Command_Format{'opcode'}->{'wd'});
    $Affected_Mcode_fields{'imd'}    = substr($bin_tmp,$G_DATA_Command_Format{'opcode'}->{'wd'},
					      $G_DATA_Command_Format{'imd'}->{'wd'});
    
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('DATA',$cmd_org,$cmd);
    }
    return ( 1 , \%Affected_Mcode_fields);

}



##################################################################
##################################################################
##################################################################

@G_DATA_Command_Format = (
    {
	fname => 'regexp',				
	code => $G_regexp{ 'commands' }->{ 'DATA' },
	example => "insert full line of data\n\tExample: DATA 29'h12345 = dig\n",
    },
    {
	fname => 'opcode',
	wd => $OPCODE_WIDTH,
	code => 7,
	default => 7,
	comment => "opcode here is not relevant",
    },
    {
	fname => 'imd',
	wd => 32-$OPCODE_WIDTH,
	default => 0,
	comment => "the lower part of the data line",
    },
    );


for $i ( 0..$#G_DATA_Command_Format ){
    # print "$i $G_LOADW_Command_Format[$i]{fname}\n";
    $G_DATA_Command_Format{ $G_DATA_Command_Format[$i]{fname} } = $G_DATA_Command_Format[$i];
if ($i != 0) {
    $G_DATA_Command_Format[$i]{ 'cur_val' } = 'z' x $G_DATA_Command_Format[$i]{ 'wd' };
}
$r = ref $G_DATA_Command_Format[$i];
}



1;
