
sub parse_cmd_move{
# move command
#  dest_regi = source_regi [ pulse-> <signal> ]

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my ($dest,$source,$dest_w,$source_w);
    my %Affected_Mcode_fields ;
    my $die_msg;

    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # print "$cmd\n";

    # if you are here so you either die or success, you cant try enother command
    print "\tProbably MOVE command : $cmd\n";

    # expecting (\w+)=(\w+) 
    if ($cmd =~ s/\b(\w+)=(\w+)\b//) { # catching "Acc=source0" anywhare in $cmd
	$dest=$1;
	$source=$2;

### Dest_reg ###
	if (defined $G_MOVE_Command_Format{'Dest_reg'}->{'val_hash'}->{$dest}){
	    $dest = $G_MOVE_Command_Format{'Dest_reg'}->{'val_hash'}->{$dest};
	    $dest_w = $G_MOVE_Command_Format{'Dest_reg'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($dest,$dest_w,'non_tc');
	    if ($success==0) {
		print "In MOVE command! << $cmd_org >> Fail to parse Dest_reg\n";
		die "Exiting !!!\n";
	    }
	    $Affected_Mcode_fields{'Dest_reg'} = $bin;
	}
	else{
	    $die_msg="Dest field should be one of :\n\n";
	    &die_fail_parse('MOVE',$line_num,$cmd_org,$die_msg,1,'Dest_reg');
	}
### source_reg ###
	if (defined $G_MOVE_Command_Format{'source_reg'}->{'val_hash'}->{$source}){
	    $source = $G_MOVE_Command_Format{'source_reg'}->{'val_hash'}->{$source};
	    $source_w = $G_MOVE_Command_Format{'source_reg'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($source,$source_w,'non_tc');
	    if ($success==0) {
		print "In MOVE command! << $cmd_org >> Fail to parse source_reg\n";
		die "Exiting !!!\n";
	    }
	    $Affected_Mcode_fields{'source_reg'} = $bin;
	}
### ext_source ###
	elsif (defined $G_MOVE_Command_Format{'ext_source'}->{'val_hash'}->{$source}){
	    $source = $G_MOVE_Command_Format{'ext_source'}->{'val_hash'}->{$source};
	    $source_w = $G_MOVE_Command_Format{'ext_source'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($source,$source_w,'non_tc');
	    if ($success==0) {
		print "In MOVE command! << $cmd_org >> Fail to parse source_reg\n";
		die "Exiting !!!\n";
	    }
	    $Affected_Mcode_fields{'ext_source'} = $bin;
	    
	}
### crc_sel ###
	# catching the crc0 and crc1 
	elsif (defined $G_MOVE_Command_Format{'crc_sel'}->{'val_hash'}->{$source}){
	    $source = $G_MOVE_Command_Format{'crc_sel'}->{'val_hash'}->{$source};
	    $source_w = $G_MOVE_Command_Format{'crc_sel'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($source,$source_w,'non_tc');
	    if ($success==0) {
		print "In MOVE command! << $cmd_org >> Fail to parse source_reg\n";
		die "Exiting !!!\n";
	    }
	    $Affected_Mcode_fields{'crc_sel'} = $bin;
	    $Affected_Mcode_fields{'crc_en'} = '1';
	}
	   
	else{
	    $die_msg="source field should be one of :\n\tcrc1/0\n\ts0,s1";
	    &die_fail_parse('MOVE',$line_num,$cmd_org,$die_msg,1,'source_reg');
	}
    }
###  ###
    ($cmd, $Affected_Mcode_fields{'pulse_bus'})  = &parse_pulse1($cmd);
    
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('MOVE',$cmd_org,$cmd);
    }
    return (1, \%Affected_Mcode_fields);
}
##################################################################
##################################################################
##################################################################
@G_MOVE_Command_Format = (
    {
	fname => 'regexp',
	#code => '(\w+\s*=\s*[a-zA-Z]\w+)?(\s+pulse\s*->\s*\w+)?',
	code => $G_regexp{ 'commands' }->{ 'MOVE' },
	example => "Rx=s0|1 or Rx=Ry or Rx=reg or device=R2  <pulse -> p3>  \n\tExample:R3=R4 pulse -> p3 \n\t\tdevice=R3 \n\t\tR4=s0  pulse -> p3\n",  
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 6,
	default => 6,
	comment => "copy R0-R7 CR, PC, Loop, etc. to R0-R7 and CR",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => 'ext_source',
	wd => 2,
	comment => "selects what external source will be used for assignment",
	default => 3,   # 2'b1x means the source will come from the source reg table
	val_hash => { 
	    s0  => 0,
	    s1 => 1,
	    swap_R5 => 2,
	},
    },
    {
	fname => 'Dest_reg',
	wd => 4,
	comment => "indicate the register that will get the data ",
	default => 15,
	val_hash => { 
	    R0 => 0,
	    R1 => 1,
	    R2 => 2,
	    R3 => 3,
	    R4 => 4,
	    R5 => 5,
	    R6 => 6,
	    R7 => 7,
	    device => 13, # This is the device (control register) it is here for context switch purposes
	    pc => 15, 
	},
    },
    $Source_reg_hash,
    {
	fname => 'crc_en',
	comment => "Indicate if we are moving the crc regisiters into the regular registers",
	wd => 1,
	default => 0,	
	
    },
    {
	fname => 'crc_sel',
	comment => "Indicate which part of the crc register we are moving",
	wd => 1,
	default => 0,	
	val_hash => { 
	    crc0 => 0,
	    crc1 => 1,
	},		
	
    },
    
    {
	fname => 'reserved',
	wd => 5,
	default => 0,
    },
    
    $pulse_bus_hash,
    );


for $i ( 0..$#G_MOVE_Command_Format ){
    # print "$i $G_MOVE_Command_Format[$i]{fname}\n";
    $G_MOVE_Command_Format{ $G_MOVE_Command_Format[$i]{fname} } = $G_MOVE_Command_Format[$i];

if ($i != 0) {
    $G_MOVE_Command_Format[$i]{ 'cur_val' } = 'z' x $G_MOVE_Command_Format[$i]{ 'wd' };
}
$r = ref $G_MOVE_Command_Format[$i];
# print " ref is $r\n";
}

1;
