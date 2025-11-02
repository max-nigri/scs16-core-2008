##################################################################
##################################################################
##################################################################

sub process_pc_labels{

    my $file_name = shift @_;
    my $ref1 = shift @_;
    my @codes = @$ref1;
    my $ref2 = shift @_;
    my %label2pc = %$ref2;

    my ($ok,$i,$j,$put_back, $cmd,$v,$pc_inc,@pc_inc,$key);
    print "\tResults may be seen in $file_name file\n";
    open(MCODE_TMP, ">$file_name") || die "Cant open $file_name for writing ... Exiting\n";

    my($pc, %pc2pcinc, @pc_nums, @line2pc) ; # %label2pc);
    my($start_offset,$stop_offset);
    $j=0;
    $pc =0;

    print MCODE_TMP "First pass: assigning pc to non empty code lines (line2pc array)\n";
    print "\tFirst pass: assigning pc to non empty code lines (line2pc array)\n";
    while ($j<=$#codes){
	if (($codes[$j] eq "") | ($codes[$j] =~ /\`include\b/) | ($codes[$j] =~ /\`define\b/)){
	    $pc_inc[$j] = 0;
	    #next;
	}
	else {
	    $pc_inc[$j] = 1;
	}

	$codes[$j] =~ s/^\s*//;		# remove spaces from start
	$codes[$j] =~ s/\s*$//;		# remove spaces from end
	# filling the pc2pcinc hash
	# filling the pc_nums array
	$pc2pcinc{$pc} = $pc_inc[$j];
	$pc_nums[$j] = $pc; 
	$line2pc[$j] = $pc; 

	printf(MCODE_TMP "%5d %1d %5d %s\n",$j, $pc_inc[$j], $pc ,$codes[$j]);
	# printf(MCODE_TMP "%5d %s\n",$pc_inc[$j],$codes[$j]);
	$pc = $pc + $pc_inc[$j];
	$j++;

    }
    
    print MCODE_TMP "Second pass: eliminating start of line labels and filling label2pc hash\n";
    print "\tSecond pass: eliminating start of line labels and filling label2pc hash\n";

    # extracting the label2pc hash and eliminating start of line labels
    $j=0;
    while ($j<=$#codes){ 
	while ($codes[$j] =~ s/^(L_\w+)\s*,\s*//) { # deleting the L_20, at the begining of the code line
	    $label2pc{$1} = $line2pc[$j];		# define entry with label name
	    # print "$1 $pc_nums[$j]\n";
	}
	++$j;
    }

    # supporting differential labels in loop statements
    print MCODE_TMP "Third pass: evaluating labels of loop statements\n";
    print "\tThird pass: evaluating labels of loop statements\n";
    
    $j=0;
    while ($j<=$#codes){ 
	if ($codes[$j] =~ /^\s*loop\s+(L_\w+)\s+(L_\w+)\s+/) { # catching loop statemnts
	    if ((!defined $label2pc{$1}) ||(!defined $label2pc{$2})) {
		die "Error !!!, while parsing <<$codes[$j]>>, at least one of the labels is not declared !!!\n";
	    }
	    $start_offset = $label2pc{$1} - $line2pc[$j]  ;
	    $stop_offset  = $label2pc{$2} - $line2pc[$j];
	    $codes[$j] =~ s/^\s*loop\s+(L_\w+)\s+(L_\w+)\s+/"loop $start_offset $stop_offset "/e;
	    # print "$1 $pc_nums[$j]\n";
	}
	print MCODE_TMP "$pc_inc[$j] - $codes[$j]\n";
	++$j;
    }
    
    
    print MCODE_TMP "Forth pass: evaluating command arguments labels\n";
    print "\tForth pass: evaluating command arguments labels\n";
    
    $j=0;
    my($I_should_die) = 0;
    while ($j<=$#codes){ # structures of type ... loop L_koko L_toto  256
	if ($codes[$j] ne ""){
	    # print  "$codes[$j]\n";
	    while ($codes[$j] =~ s/\b(L_\w+)\b/"$label2pc{$1}"/e){
		if (! defined ($label2pc{$1})){
		    $I_should_die = 1;
		    print MCODE_TMP "***** Label $1 is referenced but not declared in the code\n";
		    print "***** Label $1 is referenced but not declared in the code\n";
		}
		else{
		    print MCODE_TMP "===== found label $1 at pc  $label2pc{$1}\n";
		}
	    }
	}
	$j++;
    }
    if ($I_should_die == 1){
	die "\nLabels declarations are missing in code, Exiting!!\n\n";
    }
    
    $j=0;
    while ($j<=$#codes){
	if ($codes[$j] ne ""){
	    printf(MCODE_TMP "%-50s  // %5d %-50s\n",$codes[$j] ,$line2pc[$j]  ,$comments[$j] );
	}
	else{
	    printf(MCODE_TMP "// %-s  \n",$comments[$j] );
	}
	$j++;
    }
    
    
    

    close MCODE_TMP;

    return (\@codes, \@line2pc, \%label2pc);
}

##################################################################
##################################################################
##################################################################

sub calculate_pc_increament{

    my $ref1 = shift @_;
    my @codes = @$ref1;
    my $file_name = shift @_;

    my ($ok,$i,$j,$put_back, $cmd,$v,$pc_inc,@pc_inc,$key);
    print "Results may be seen in $file_name file\n";
    open(MCODE_TMP, ">$file_name") || die "Cant open $file_name for writing ... Exiting\n";
    print MCODE_TMP "Third pass : Allocating pc to non empty code lines, based on data from calculate_pc_increament routine\n";

    $j=0;
    while ($j<=$#codes){
	if (($codes[$j] eq "") | ($codes[$j] =~ /\bassign\b/) | ($codes[$j] =~ /\`define\b/)){
	    $pc_inc[$j] = 0;
	    #next;
	}
	else {
	    $pc_inc[$j] = 1;
	}
	printf(MCODE_TMP "%5d %s\n",$pc_inc[$j],$codes[$j]);
	$j++;

    }
    close MCODE_TMP;

    return (@pc_inc);
}

##################################################################
##################################################################
##################################################################

sub print_command_help{

    # my $cmd = shift @_;
    my ($command_name,$command_array_name,$regexp, $current_command_name );
    my ($pre_match ,$match ,$post_match) ;
    my ($max_match_len) =0;
    my ($code_field)='code';
    my $text;
    $current_command_name = 'NOTHING MATCH';

    print "\n\n";
    foreach $command_name (@Commands_List) {
	$command_array_name = "G_$command_name"."_Command_Format";

	for $code_field ('example') { #, 'code'){
	    if (defined $$command_array_name{'regexp'}->{$code_field}){
		$text =$$command_array_name{'regexp'}->{$code_field};
		printf ("%-15s:\n\t%-s\n\n", $command_name,$$command_array_name{'regexp'}->{$code_field});
	    }
	}
    }

}

##################################################################
##################################################################
##################################################################

sub sort_statment{

    my $cmd = shift @_;
    my ($command_name,$command_array_name,$regexp, $current_command_name );
    my ($pre_match ,$match ,$post_match) ;
    my ($max_match_len) =0;
    my ($code_field);
    my ($SCORE);
    $current_command_name = 'NOTHING MATCH';

    # print "--$cmd\--\n";
    foreach $command_name (keys %{$G_regexp{commands}}) {			# run over all commands
    #    foreach $command_name (@Commands_List) {			# run over all commands
	$command_array_name = "G_$command_name"."_Command_Format";
	# print "$command_array_name\n";

	for $code_field ('code', 'code1', 'code2'){
	    # print "koko\n";
	    if (defined $$command_array_name{'regexp'}->{$code_field}){
		$regexp =$$command_array_name{'regexp'}->{$code_field};
	    }
	    else{
		last;
	    }
	    # $regexp = $$command_array_name{'regexp'}->{'code'};
	    
	    $cmd =~ m/$regexp/;				      	# check if current command matched to regular exp.
	    ($pre_match ,$match ,$post_match) = ($`,$&,$')  ; 	# 'should capture them because
	    $SCORE->{$command_name}->{$code_field}->{match} = length($match);
	    $SCORE->{$command_name}->{$code_field}->{pre_match} = length($pre_match);
	    $SCORE->{$command_name}->{$code_field}->{post_match} = length($post_match);
	    $score{$command_name} = length($match);		# to decide what is the best match 
								# (number of match for this command)
	    # printf ("command_name %-15s, match %3d chars %s\n", $command_name, length($match),$regexp);
	    if (length($match) > $max_match_len){		# search the max match length
		$max_match_len =length($match);
		$current_command_name = $command_name ;
	    }
	}

    }

    #####################################################################################
    my($score_table,$i, $fail_to_match);
    $max_match_len = 0;
    $score_table ="";
    $current_command_name = 'NOTHING MATCH';
    $i=0;$fail_to_match = 0;
    foreach $command_name (sort {$SCORE->{$b}->{code}->{match} <=> $SCORE->{$a}->{code}->{match} } (keys %$SCORE)) {
	if ($i==0 ){
	    if ($SCORE->{$command_name}->{code}->{match} ==0){
		$fail_to_match = 1; # non of the commands found
	    }
	    $current_command_name = $command_name;
	    $max_match_len = $SCORE->{$command_name}->{code}->{match};
	}
	if (($i==1) && ($fail_to_match == 0)){
	    if ($SCORE->{$command_name}->{code}->{match} == $max_match_len) {
		$fail_to_match = 2; # the top two scores are equal
	    }
	}
	$score_table = sprintf("%s\t%-15s  : %3d | %3d | %3d |\n", $score_table, $command_name, $SCORE->{$command_name}->{code}->{pre_match}, 
		   $SCORE->{$command_name}->{code}->{match},$SCORE->{$command_name}->{code}->{post_match}); 
	$i++;
    }
    if ($fail_to_match > 0){
	print "while trying to analyze statment << $cmd >> \n";
	print "Score table is: \n$score_table\n";    
	if ($fail_to_match == 1){
	    print "Statment does not match non of the command set\n\n\n";
	    die "Statment does not match non of the command set\n\n\n";
	}
	else{
	    print "Statment match more then one command type\n\n\n";
	    die "Statment match more then one command type\n\n\n";
	}
    }
    else {
	return ($current_command_name);
    }
    #####################################################################################
   


    if ($current_command_name eq 'NOTHING MATCH'){
	die "Statment does not match non of the command set\n\n\n";
    }
    else{
	print "\n";
	# print "Probably $current_command_name\n\n";
	return ($current_command_name);
    }
}

##################################################################
##################################################################
##################################################################

sub parse_device{

    my($cmd) = shift @_;
    my($v,$w,%Affected_Mcode_fields,$nibble_value,$bits2set,$bits2reset,$i,$tmp);
    my $lval;
    # catching "device6 = 4'b01xx" anywhare in $cmd
    if ($cmd =~ s/\b(device_\d)\b->(\S+)//) {
	$lval=$2; 
	$nibble_value =$2;
	if (defined $CR_part_hash->{'val_hash'}->{$1}){
	    $w = $CR_part_hash->{'wd'};
	    $v = $CR_part_hash->{'val_hash'}->{$1};
	    $Affected_Mcode_fields{'CR_part'} = &dec2bintc($v,$w);
	    
	}
	else{ # CR= unknown token 
	    #print "in WAIT cmd << $cmd_org >>, syntax error !!";
	    #&print_command_example('G_WAIT_LOAD_Command_Format');
	    die "In parse_device, wrong l_value <<$1>>, can be device_0-3,Exiting!!!\n";
	}
	if ( $lval !~ /^\d+/){
	    die"\nERROR :In device_x command the right value size must be 4 bits.\nit is possible to use 2 formats:\n\t\t\t 1. 4\'b1x01\n\t\t\t 2. Decimal 0-15 max.\n";
	}
	# bitset and bitreset part
	$bits2set =0;
	$bits2reset =0;
	if ($nibble_value =~ /^(4\'b[01x]{4}|\d+)$/){  #' 
	    if ($nibble_value =~ /(4\'b[01x]{4})/){
		$nibble_value =~ s/4\'b//;
		for ($i=3;$i>=0;--$i){
		    $nibble_value =~ s/^([01x])//;
		    print "$1 ";
		    if ($1 == 1){
			$bits2set += 2**$i;
		    }
		    elsif ($1 eq 'x'){
			# bit not change
		    }
		    elsif ($1 == 0){
			$bits2reset += 2**$i;
		    }
		    print "=============$i $nibble_value bits2set  = $bits2set, bits2reset = $bits2reset \n";
		}
	    }
	    else{
		print "==== begin ========= $nibble_value bits2set  = $bits2set, bits2reset = $bits2reset \n";
		for ($i=3;$i>=0;--$i){
		    if ($nibble_value >= 2**$i){
			$bits2set +=  (2**$i);
                        $nibble_value -= 2**$i;
		    } 
		    else{
			$bits2reset += (2**$i);
                    }

		    print "=============$i $nibble_value bits2set  = $bits2set, bits2reset = $bits2reset \n";

		}
	    }
	    print "=============bits2set  = $bits2set, bits2reset = $bits2reset \n";
	    $v = $bits2reset ;
	    $w = $bits2reset_hash->{'wd'};
	    $Affected_Mcode_fields{'bits2reset'} = &dec2bintc($v,$w);
	    $v = $bits2set ;
	    $w = $bits2set_hash->{'wd'};
	    $Affected_Mcode_fields{'bits2set'} = &dec2bintc($v,$w);
	    
	}
	return ($cmd, $Affected_Mcode_fields{'CR_part'} ,$Affected_Mcode_fields{'bits2reset'},$Affected_Mcode_fields{'bits2set'});
    }
    else{
	#return ($cmd, "", "", "");
	return ($cmd, undef, undef, undef);
    }


}

##################################################################
##################################################################
##################################################################
# Added to take care of the division in Count
sub parse_div{

    my($cmd) = shift @_;
    my($v,$w,%Affected_Mcode_fields,$i,$tmp);
    
    # expecting  div (^)number
    if ($cmd =~ s/\bdiv\b\s+(\^?)(\S+)//) { # catching "div ^6'h23" anywhare in $cmd
	if ($1 eq "^")
	{ print "== The division is by power of 2, amount of division is 2\^$2\n";}
	else 
	{ print "== The division is by number, amount of division is $2\n";}
	# Writes the type of division
	$div_amount = &parse_const($2, ($G_COUNT_Command_Format{'div_amount'}));
	# Writes the amount of division
	$Affected_Mcode_fields{'div_amount'} = $div_amount;
	if ($1 eq "^"){
	    $power =1;
	}
	else{
	    $power =0;
	}

	return ($cmd, $power, $Affected_Mcode_fields{'div_amount'});
    }
    else {
	return ($cmd, undef, undef);
    }
}

##################################################################
##################################################################
##################################################################

sub parse_pulse{

    my($cmd) = shift @_;
    my($v,$w,%Affected_Mcode_fields,$i,$tmp);
    
    # expecting  pulse-> signal
    if ($cmd =~ s/\bpulse\b->(\w+)//) { # catching "pulse->blp_ready" anywhare in $cmd
	if (defined $Dest_bus_hash->{'val_hash'}->{$1}){
	    $w = $Dest_bus_hash->{'wd'};
	    $v = $Dest_bus_hash->{'val_hash'}->{$1};
	    $Affected_Mcode_fields{'Dest_bus'} = &dec2bintc($v,$w);
	}
	else{
	    @tmp = keys  %{$Dest_bus_hash->{'val_hash'}};
	    $tmp = "@tmp"; $tmp =~ s/\s/\n\t/g;
	    die "In command! << $cmd_org >> Dest_bus field should be one of :\n\n\t$tmp\n\n";
	}
    }
    return ($cmd, $Affected_Mcode_fields{'Dest_bus'});
}
##################################################################
##################################################################
##################################################################

sub parse_pulse1{

    my($cmd) = shift @_;
    my($v,$w,%Affected_Mcode_fields,$i,$tmp);
    
    # expecting  pulse-> signal
    if ($cmd =~ s/\bpulse\b->(\w+)//) { # catching "pulse->blp_ready" anywhare in $cmd
	if (defined $pulse_bus_hash->{'val_hash'}->{$1}){
	    $w = $pulse_bus_hash->{'wd'};
	    $v = $pulse_bus_hash->{'val_hash'}->{$1};
	    $Affected_Mcode_fields{'pulse_bus'} = &dec2bintc($v,$w);
	}
	else{
	    @tmp = keys  %{$pulse_bus_hash->{'val_hash'}};
	    $tmp = "@tmp"; $tmp =~ s/\s/\n\t/g;
	    die "In command! << $cmd_org >> pulse_bus field should be one of :\n\n\t$tmp\n\n";
	}
    }
    return ($cmd, $Affected_Mcode_fields{'pulse_bus'});
}
##################################################################
##################################################################
##################################################################

sub parse_condition{

    my($cmd) = shift @_;
    my($v,$w,%Affected_Mcode_fields,$i,$tmp,$negate);
    
    $cmd =~ s/!\s*/!/;

    # expecting  wait or branch (!)? condition bit
    if ($cmd =~ s/\b(wait|branch|wait_store|wait_load)\s+(!)?(\w+)//) { # 
	if (defined $condition_bit_hash->{'val_hash'}->{$3}){
	    $w = $condition_bit_hash->{'wd'};
	    $v = $condition_bit_hash->{'val_hash'}->{$3};
	    $Affected_Mcode_fields{'condition_bit'} = &dec2bintc($v,$w);
	}
	else{
	    
	    @tmp = keys  %{$condition_bit_hash->{'val_hash'}};
	    $tmp = "@tmp"; $tmp =~ s/\s/\n\t/g;
	    die "In command! << $cmd>> condition_bit field should be one of :\n\n\t$tmp\n\n";
	}
	if ($2 eq "!"){
	    $negate =1;
	}
	else{
	    $negate =0;
	}

	return ($cmd, $negate, $Affected_Mcode_fields{'condition_bit'});
    }
    else {
	return ($cmd, undef, undef);
    }
    
}


##################################################################
##################################################################
##################################################################
# Accpected only for wait_store after breakif
sub parse_condition2{

    my($cmd) = shift @_;
    my($v,$w,%Affected_Mcode_fields,$i,$tmp,$negate);
    
    $cmd =~ s/!\s*/!/;
    print "In parse condition2 the cmd is <<$cmd>>\n";	
    # expecting  wait_store (!)? condition bit
    if ($cmd =~ s/\bbreakif\s+(!)?(\w+)//) { # 
	if (defined $condition_bit_hash2->{'val_hash'}->{$2}){
	    $w = $condition_bit_hash2->{'wd'};
	    $v = $condition_bit_hash2->{'val_hash'}->{$2};
	    $Affected_Mcode_fields{'condition_bit2'} = &dec2bintc($v,$w);
	}
	else{
	    
	    @tmp = keys  %{$condition_bit_hash->{'val_hash'}};
	    $tmp = "@tmp"; $tmp =~ s/\s/\n\t/g;
	    die "In command! << $cmd>> condition_bit field should be one of :\n\n\t$tmp\n\n";
	}
	if ($1 eq "!"){
	    $negate =1;
	}
	else{
	    $negate =0;
	}

	return ($cmd, $negate, $Affected_Mcode_fields{'condition_bit2'});
    }
    else {
	return ($cmd, undef, undef);
    }
    
}



1;

