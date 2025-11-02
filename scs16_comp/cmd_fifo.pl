
sub parse_cmd_fifo{
    
    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my %Affected_Mcode_fields ;
    my($rd_wr,$re_wr_w);
    my ($success, $bin);
    my $die_msg;
    
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

##############################################################################
#####                  INPUT CHECKS                                     ######
##############################################################################

    if ($cmd =~ s/\s*(\(\s*R0\s*,\s*R1\s*\))\s*=\s*(fifo_rd)\s*(\(\s*R0\s*,\s*R1\s*\))//){
	$rd_wr="read";
    }
    elsif($cmd =~ s/\s*(\(\s*R0\s*,\s*R1\s*\))\s*=\s*(fifo_wr)\s*(\(\s*R0\s*,\s*R1\s*\))//){
	$rd_wr="write";
    }

   else{
       &die_fail_parse('FIFO',$line_num,$cmd_org,$die_msg,1,0);
   }

#############################################################################
#####                   OPCODE   GENRATOR                              ######
#############################################################################

	

    $rd_wr=$G_FIFO_Command_Format{'rd_wr'}->{'val_hash'}->{$rd_wr};
    $rd_wr_w=$G_FIFO_Command_Format{'rd_wr'}->{'wd'};
    ($success, $bin)=&parse_const_new1($rd_wr,$rd_wr_w,'non_tc'); 
    if ($success==0) {
	print "Fail to parse  read or write. \n";
	die "Exiting !!!\n";
    }
    else{
	$Affected_Mcode_fields{'rd_wr'} = $bin;
    }
    
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('FIFO',$cmd_org,$cmd);
    }
    return (1, \%Affected_Mcode_fields);
   


}
##################################################################
##################################################################
##################################################################
@G_FIFO_Command_Format = (
    {
	fname => regexp,
	#code => '\s*\(\s*R\d\s*,\s*R\d\s*\)\s*=\s*fifo_\S+',
	code => $G_regexp{ 'commands' }->{ 'FIFO' },
	example => "\nExample:(R0,R1)=fifo_rd(R0,R1)\n\t(R0,R1)=fifo_wr(R0,R1)\n",
    },
    {
	fname => opcode,
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 21,
	default => 21,
	comment => "fifo command",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => rd_wr,
	wd => 1,
	default => 0,
	val_hash => { 
	    read => 0,
	    write => 1,
	},
    },
    {
	fname => reserved,
	wd => 20,
	default => 0,
    },
    );


for $i ( 0..$#G_FIFO_Command_Format ){
    $G_FIFO_Command_Format{ $G_FIFO_Command_Format[$i]{fname} } = $G_FIFO_Command_Format[$i];
$G_FIFO_Command_Format[$i]{ 'cur_val' } = z x $G_FIFO_Command_Format[$i]{ 'wd' };

$r = ref $G_FIFO_Command_Format[$i];

}


1;
