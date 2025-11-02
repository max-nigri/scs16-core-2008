sub parse_cmd_timer{
# count (one of the dest bus bits)
#	    ($success, $bin) = &parse_const_new1($address ,$address_w,'non_tc');
#	    &die_leftovers('BRANCH',$cmd_org,$cmd);
#	    $die_msg="flag should  be one of :\n";
#	    &die_fail_parse('BRANCH',$line_num,$cmd_org,$die_msg,1,'flag_bit');

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w);
    my %Affected_Mcode_fields;
    my $q ='"';
    my $regexp;
    my ($i, $key);
    my ($success, $bin, $v, $w);
    my ($lvalue, $sh, $op);
    my $ok =1;
    my ($event, $negate);
    my ($timer_id, $load_value, $polarity, $derivate, $count_source);
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;
    
    # print "$cmd\n";
    print "Probably TIMER command : $cmd\n";
#       1. timer_0 = R2 dec @(c4)
#       2. timer_0 = R3 dec @(!c1)
#       3. timer_0 = 45 dec @(posedge c4)
#       3. timer_1 = 30 dec @(p2)
   
    if ($cmd =~ s/(timer_\d)=(\w+)\s+dec\s+@\s*\(\s*(posedge)?\s*(!)?(\w+)\s*\)//){
	# $1 = timer_0,1
	# $2 = Rx or Imd
	# $3 = posedge or ""
	# $4 = ! or ""
	# $5 = Cx or Px
	$timer_id    = $1;
	$load_value  = $2;
	$derivate    = $3;
	$polarity    = $4; 
	$count_source= $5;
    }

   
        if (defined $G_TIMER_Command_Format{'timer_sel'}->{'val_hash'}->{$timer_id}){
  	    $Affected_Mcode_fields{'timer_sel'} = $G_TIMER_Command_Format{'timer_sel'}->{'val_hash'}->{$timer_id};
  	}
  	else{
  	    $ok = 0;
  	}
 	if ($load_value =~ /^R/) {
 	    $Affected_Mcode_fields{'load_sel'} = $G_TIMER_Command_Format{'load_sel'}->{'val_hash'}->{rx};
  	    if (defined $G_TIMER_Command_Format{'source_reg'}->{'val_hash'}->{$load_value}){
  		$v = $G_TIMER_Command_Format{'source_reg'}->{'val_hash'}->{$load_value};
  		$w = $G_TIMER_Command_Format{'source_reg'}->{'wd'};
 		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
 		if ($success == 1) {
  		    $Affected_Mcode_fields{'source_reg'} = $bin;
  		}
  		else {
  		    $ok = 0;
  		}
  	    }
  	    else {
  		$ok = 0;
  	    }
  	}
	else{
  	    $Affected_Mcode_fields{'load_sel'} = $G_TIMER_Command_Format{'load_sel'}->{'val_hash'}->{imd};
  	    $v = $load_value;
  	    $w = $G_TIMER_Command_Format{'Imd'}->{'wd'};
  		($success, $bin) = &parse_const_new1($v,$w,'non_tc');
  		if ($success == 1) {
  		    $Affected_Mcode_fields{'Imd'} = $bin;
  		}
  		else {
  		    $ok = 0;
  		}


  	}

  	if ($derivate eq "") {
  	    $Affected_Mcode_fields{'der'} = $G_TIMER_Command_Format{'der'}->{'val_hash'}->{as_is};
  	}
  	else{
  	    $Affected_Mcode_fields{'der'} = $G_TIMER_Command_Format{'der'}->{'val_hash'}->{derivate};
  	}

  	if ($polarity eq "") {
  	    $Affected_Mcode_fields{'polarity'} = $G_TIMER_Command_Format{'polarity'}->{'val_hash'}->{as_is};
  	}
  	else{
  	    $Affected_Mcode_fields{'polarity'} = $G_TIMER_Command_Format{'polarity'}->{'val_hash'}->{invert};
  	}

    if($count_source =~ /^c/){
	$Affected_Mcode_fields{'event_sel'} = $G_TIMER_Command_Format{'event_sel'}->{'val_hash'}->{Cx};
	$count_source =~ s/c//;
	if ( $count_source >= 0 && $count_source <= 15 ){
	    $v = $count_source;
  	    $w = $G_TIMER_Command_Format{'condition_bit'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
  		if ($success == 1) {
  		    $Affected_Mcode_fields{'condition_bit'} = $bin;
  		}
	        else{
	           $ok = 0;
	        }

	}
	else{
	    $ok = 0;
        }
    }
    elsif($count_source =~ /^p/){
	$Affected_Mcode_fields{'event_sel'} = $G_TIMER_Command_Format{'event_sel'}->{'val_hash'}->{Px};
	$count_source =~ s/p//;
	if ( $count_source >= 0 && $count_source <= 15 ){
	    $v = $count_source;
  	    $w = $G_TIMER_Command_Format{'condition_bit'}->{'wd'};
	    ($success, $bin) = &parse_const_new1($v,$w,'non_tc');
  		if ($success == 1) {
  		    $Affected_Mcode_fields{'condition_bit'} = $bin;
  		}
	        else{
	           $ok = 0;
	        }

	}
	else{
	    $ok = 0;
        }
    }



    
    if (($cmd =~ /[^\s]+/) || ($ok == 0)) { # catching leftovers
	if ($ok == 0){
	    print "In TIMER command, << $cmd_org >>, syntax error!!, syntax should look like \n\n";
	}
	else{
	    print "In TIMER command, << $cmd_org >>, catching leftovers!!, syntax should look like \n\n";
        }
	&print_assoc(%Affected_Mcode_fields);
	&print_command_example('G_TIMER_Command_Format');
	die "Exiting!!!\n";
    }
    return ( 1 , \%Affected_Mcode_fields);
    
}

##################################################################
##################################################################
##################################################################

@G_TIMER_Command_Format = (
    {
	fname => 'regexp',
	code => '\btimer.+',  
	example => "Formal : timer_<0|1> = <Rx|35> dec @([posedge] [!] <Cx|Px>)
Examples
     1. timer_0 = R2 dec @(c4)
     2. timer_0 = R3 dec @(!c1)
     3. timer_0 = 45 dec @(posedge c4)
     3. timer_1 = 30 dec @(p2)
"
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 12,
	default => 12,
	comment => "Load counter_0/1 with value of Rx and select the event to count",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    {
	fname => 'source_reg',
	wd => 3,
	comment => "selects the register to be copied to the timer",
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
	fname => 'load_sel',
	wd => 1,
	default => 0,
	val_hash => {
	    rx      => 0,
	    imd => 1,
	}
    },
    {
	fname => 'der',
	wd => 1,
	default => 0,
	comment => "controls whether to derivate the count event or not",
	val_hash => {
	    as_is      => 0,
	    derivate => 1,
	}
    },
    {
	fname => 'polarity',
	wd => 1,
	default => 0,
	comment => "controls whether to invert the count event or not",
	val_hash => {
	    as_is      => 0,
	    invert => 1,
	}
    },
    $condition_bit_hash, 
    {
	fname => 'event_sel',
	wd => 1,
	default => 0,
	comment => "controls whether to count Cx or Px",
	val_hash => {
	    Cx      => 0,
	    Px => 1,
	}
    },
    {
	fname => 'timer_sel',
	wd => 1,
	default => 0,
	comment => "selects the timer to activate",
	val_hash => {
	    timer_0 => 0,
	    timer_1 => 1,
	}
    },
    {
	fname => 'Imd',
	wd => 9,
	comment => "an unsigned number 9 bits width",
	default => 0,
	type => "unsigned",
	regexp_hash => { 
	    hexadecimal => "9'h([0-9a-f]{3})",
	    binary      => "9'b([01]{11})",
	    decimal     => '\b(-?\d+)$',  # '
	},
    },
    
    );


for $i ( 0..$#G_TIMER_Command_Format ){
    # print "$i $G_TIMER_Command_Format[$i]{fname}\n";
    $G_TIMER_Command_Format{ $G_TIMER_Command_Format[$i]{fname} } = $G_TIMER_Command_Format[$i];

if ($i != 0) {
    $G_TIMER_Command_Format[$i]{ 'cur_val' } = 'z' x $G_TIMER_Command_Format[$i]{ 'wd' };
}
$r = ref $G_TIMER_Command_Format[$i];
# print " ref is $r\n";
}


1;
