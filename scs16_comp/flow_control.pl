# This sub routine catch stop @() statment and replace it with relevant code lines.
sub preprocess_debug_statement{
    # I touched here 
    my $ref1 = shift @_;
    my $ref2 = shift @_;
    my @codes    = @$ref1;
    my @comments = @$ref2;

    my($i,$j,$cond,$op,$label,$a,$b,$c,@codes1,@comments1);
    
    $j=0;
    for ($i=0; $i<=$#codes; ++$i){
	$codes[$i] =~ s/\s*$//;
	$codes[$i] =~ s/^\s*//;
	if ($codes[$i] =~ /\bstop\b/){
	    $comments1[$j] = "$codes[$i] * $comments[$i]";
	    if ($codes[$i] =~ s/\bstop\s+@\(\s*(\w+)\s*==\s*(\S+)\s*\)//){
		$j++;
		$codes1[$j++] = "R7_l = 16'h8000";
		if (defined $debug_source_reg_hash->{'val_hash'}->{$1}){
		    $codes1[$j++] = "R0_lo = $debug_source_reg_hash->{val_hash}->{$1}";
		}
		else{
		    # &elaborate_field(0,$debug_source_reg_hash->{'val_hash'});
		    die "\n\n\tDebug statement syntax error!!!, <<$codes[$i]>>\n\t\tstop @(pc or Rx == 345)\n\n";
		}
		$codes1[$j++] = "RAM[R7++] = R0 ";
		$codes1[$j++] = "R0_lo = $2";
		$codes1[$j++] = "RAM[R7] = R0";
		$codes1[$j++] = "R7_l = 0";
		$comments1[$j] = "end of debug code ";
		$j++;
	    }
	    else{
		die "\n\n\tDebug statement syntax error!!!, <<$codes[$i]>>\n\t\tstop @(pc or Rx == 345)\n\n";
	    }
	}
	else{
	    $comments1[$j] = $comments[$i];
	    $codes1[$j++] = $codes[$i];
	}
    }



@codes = @codes1;
@comments = @comments1;
# for ($i=0; $i<=$#codes; ++$i){
#     printf(MCODE_TMP "%5d %-50s  // %-s\n",($i),$codes[$i]   ,$comments[$i] );
# print "($i),$codes[$i],$comments[$i]\n";
# }
# close MCODE_TMP;

return (\@codes, \@comments);


}
##################################################################
##################################################################
##################################################################
# This sub routine catch if elsif statments and inserts ALU command before it.
# It also parse the condition, and selects the right flag (with or without negation) to the ALU command
# it also replace wait (condition) by L_gfgdfg branch (condition) L_gfgdfg
sub preprocess_flow_control{
    # I touched here
    my($f1) = shift @_;
    my $ref1 = shift @_;
    my $ref2 = shift @_;
    my $ref3 = shift @_;
    my $debug = shift @_;
    my @codes    = @$ref1;
    my @comments = @$ref2;
    my @codes_for_presentation    = @$ref3;
    
    my($i,$j,$cond,$op,$label,$a,$b,$c,@codes1,@comments1,@codes1_for_presentation,%cln2oln);
    my($m,$n,$l);
    my($m1,$n1,$l1);
    my($delta);
    my($msg);
    open(MCODE_TMP, ">$f1")      || die "Cant open $f1 for writing ... Exiting\n";
    print MCODE_TMP "Pre-Processing flow control ......\n";

    $msg = "\tsearching for if ( Rx (==|!=|>|<>) ) ... expression, inserting alui and translating to branch
\tsearching for if ( cx ) ... expression and translating to branch
\tsearching wait cx ... expression and translating to branch with label\n";
    print $msg;
    print MCODE_TMP $msg;
    print "\tResults may be seen in $f1 file\n";
   
    $j=0;
    for ($i=0; $i<=$#codes; ++$i){
	# print "from flow control $comments[$i]\n";
	$codes[$i] =~ s/\s*$//;
        #                             if (Rx == or != Ry) {
	if (($codes[$i] =~ s/(\w+\s*,\s*)?if\s*\(\s*([^\)]+(==|!=|>=|<=|>|<)[^\)]+)\)\s*\{/"if (eq_flag){"/e) || 
	    #                             if (Rx == or != Ry) L_where_to_go
	    ($codes[$i] =~ s/(\w+\s*,\s*)?if\s*\(\s*([^\)]+(==|!=|>=|<=|>|<)[^\)]+)\)\s*(L_\w+|R\d)/"branch (eq_flag) $4"/e) ){ 
	    # needs to insert additional alu operator before the branch
	    
	    $cond = "$1eq_flag = $2";  # $cond = L_label,eq_flag = Rx op Ry
	    
	    $op = $3;			# save the operator
	    $label = $4;		
	    $cond =~ s/(=|!)=/==/;	
	    print "1$op**************$cond*********\n" if $debug;
	    if ($op eq '>'){		# put the right condition in the ALU command line befor the if () { 
		$cond =~ s/eq_flag/gr_flag/;
	    }
	    elsif ($op eq '>='){
		$cond =~ s/eq_flag/eq_gr_flag/;
	    }
	    elsif ($op eq '<='){
		$cond =~ s/eq_flag/eq_ls_flag/;
	    }
	    elsif ($op eq '<'){
		$cond =~ s/eq_flag/ls_flag/;
	    }
	    print "2$op**************$cond*********\n" if $debug;
	    
	    if ($label =~ /^(L_\w+|R\d)/){ # if ( ) L_label: put the right flag/!flag in the if command line
		if ($op eq '!='){  # max 26/7/05 changed the polarity
		    $codes[$i] =~  s/eq_flag/eq_flag/;
		}
		elsif ($op eq '>'){
		    $codes[$i] =~  s/eq_flag/gr_flag/;
		}
		elsif ($op eq '>='){
		    $codes[$i] =~  s/eq_flag/eq_gr_flag/;
		}
		elsif ($op eq '<'){
		    $codes[$i] =~  s/eq_flag/ls_flag/;
		}
		elsif ($op eq '<='){
		    $codes[$i] =~  s/eq_flag/eq_ls_flag/;
		}
	    }
	    else{ 			   # if ( ) { put the right flag/!flag in the if command line
		if ($op eq '=='){
		    $codes[$i] =~  s/eq_flag/!eq_flag/;
		}
		elsif ($op eq '!='){
		    $codes[$i] =~  s/eq_flag/eq_flag/;
		}
		elsif ($op eq '>'){
		    $codes[$i] =~  s/eq_flag/!gr_flag/;
		}
		elsif ($op eq '>='){
		    $codes[$i] =~  s/eq_flag/!eq_gr_flag/;
		}
		elsif ($op eq '<'){
		    $codes[$i] =~  s/eq_flag/!ls_flag/;
		}
		elsif ($op eq '<='){
		    $codes[$i] =~  s/eq_flag/!eq_ls_flag/;
		}
		
	    }
	    
	    $cln2oln{$j}=$i+1;   # the new hash code line number to original line number
	    $codes1[$j++] = $cond; 		# $codes1 contains ALU command lines (before if() )
	}
	
	#catching if (condition_bit) L_gggg
	elsif ($codes[$i] =~ s/(\w+\s*,\s*)?if\s*\(\s*(!?[^)]+)\s*\)\s*(L_\w+|R\d)/"$1 branch ($2) $3"/e){
    }
    
    #catching goto L_gggg
    # elsif ($codes[$i] =~ s/(\w+\s*,\s*)?goto\s+(L_\w+|R\d)/"$1 branch (true_bit) $2"/e){
    elsif ($codes[$i] =~ s/(\w+\s*,\s*)?goto\s+(L_\w+|R\d)/"$1 goto $2"/e){
    }
    #                      |             $1              | $4 |  $5            |
    #                                          if         ( !? condition_bit ) \{
    elsif ($codes[$i] =~ s/((\w+\s*,\s*)?(els)?if\s*\(\s*)(!)?(\s*[^)]+\)\s*\{)/"putmehere"/e){
          $a = $1;		# until if (
          $b = $4;		# negation		
	  $c = $5;		# from condition to "{"
	  if ($b eq ""){
	      $codes[$i] =~ s/putmehere/"$a!$c"/e;
	  }
	  else{
	      $codes[$i] =~ s/putmehere/"$a$c"/e;
	  }
	  # end of catching (els)?if ( cond ) {
    }
    elsif ($codes[$i] =~ s/\bwait\b\s+(!\s*)?(\S+)/"putmehere"/e) {
	$b = $1;  # negation
	$c = $2;  # the condition
	if ($b =~ /!/){
	    $codes[$i] =~ s/putmehere/"$wait_label_seed, branch $c $wait_label_seed"/e;
	} 
	else{
	    $codes[$i] =~ s/putmehere/"$wait_label_seed, branch !$c $wait_label_seed"/e;
	}
	$wait_label_seed = &get_wait_label($wait_label_seed);
    }   
    # copying the original codes and comments
    $comments1[$j]              = $comments[$i];
    $codes1_for_presentation[$j]= $codes_for_presentation[$i];
    $cln2oln{$j}=$i+1;   # the new hash code line number to original line number
    $codes1[$j++]               = $codes[$i];

}  # end of for loop

$m=@codes;
$n=@comments;
$l=@codes_for_presentation;
$m1=@codes1;
$n1=@comments1;
$l1=@codes1_for_presentation;

$delta = $m1-$m;
print "\tAdding $delta code lines\n";
$delta = $n1-$n;
print "\tAdding $delta comments lines\n";
$delta = $l1-$l;
print "\tAdding $delta code for presnetation lines\n";

@codes    = @codes1;
@comments = @comments1;
@codes_for_presentation= @codes1_for_presentation;
for ($i=0; $i<=$#codes; ++$i){
    printf(MCODE_TMP "%5d %5d %-50s  // %-s\n",$i,$cln2oln{$i}, $codes[$i]   ,$comments[$i] );
    # print "($i),$codes[$i],$comments[$i]\n";
}
# check result integrity
for ($i=0; $i<=$#codes; ++$i){
    if ($codes[$i] =~ /\b(els)?if\s*\(/) {
	if ($codes[$i] !~ /\(\s*!?\s*(\w+|\w+\[\s*(\d+|`\w+)\s*\])\s*\)/){ # `
	    die "Error !!!, In original line no $cln2oln{$i},\n\t$codes[$i]\n\tFail to process condition expression\n\tsee also in $f1 file\n";
	}
    }
}


close MCODE_TMP;

return (\@codes, \@comments, \@codes_for_presentation, \%cln2oln);


}
##################################################################
##################################################################
##################################################################
# replace if, elsif,else with branch() and labels

sub parse_flow_control {

    my ($fname) = shift @_;
    my ($ref1)  = shift @_;			# @_ contains sub-routines input parameters
    my (@codes) = @$ref1;			# @_ contains sub-routines input parameters
    my ($j, $level, @levels,  $line);	# local variables
    my $pc=0;
    my ($start_i, $stop_i, $i);
    my (@codes_back, @levels_back,$change,$seq_type,$one_change);
    my (@code_fragment);
    print "\tResults may be seen in $fname file\n";

    open(MCODE_TMP, ">$fname") || die "Cant open $fname for writing ... Exiting\n";
    print MCODE_TMP "Translating if, else, elsif construct to branch with lables\n";

    $j=0;
    $level="0";
    $levels[0]=$level;			

# pc=  9, level=01         if (!eq_flag) {
# pc= 10, level=01         R4_l = 1
# pc= 10, level=0          }
# pc= 10, level=02         else {
# pc= 11, level=02         R4_l = 2
# pc= 11, level=0          }
			
    print MCODE_TMP "here ==============\n";
    while ($j<=$#codes){ 
	$levels[$j]=$levels[$j-1];  # empty line gets the previous line level
	if ($codes[$j] eq ""){
	    printf(MCODE_TMP "pc=%3d, level=%-10s %-s\n",$pc,$levels[$j],$codes[$j]);
	    $j++;
	    next;
	}
	$line = $codes[$j];
	
	if ($line =~ /elsif\s*\(\s*[^\)]+\)\s*\{/){ 	# catch elsif 
	    $level .= "3";
	    $pc++;
	}

	elsif ($line =~ /if\s*\(\s*[^\)]+\)\s*\{/){	 # catch if  
	    $level .= "1";
	    $pc++;
	}
	elsif ($line =~ /else\s*\{/){
	    $level .= "2";
	}
	elsif ($line =~ /\}/){				# catch end of if/elsif block		
	    $level =~ s/(1|2|3)$//;			# "}" must be the code char in the line
	}						# level 021 -> 02 (end of block)
	else {		
	    $pc++;					# simple code line
	}
	printf(MCODE_TMP "pc=%3d, level=%-10s %-s\n",$pc,$level,$line);
	$levels[$j] = $level;
	++$j;
    }
    
    print MCODE_TMP "\nThe levels are array is :\n@levels\n\n";
    
    @codes_back = @codes;		# for backup
    @levels_back = @levels;


    $change = 10;
    while ($change >0){
	
	foreach $seq_type ("if_then_else", "if_then", "if_elsif+_else", "if_elsif+"){

	    ($start_i,  $stop_i)  = (0,2);	# min lines for block
	    $one_change =0;
	    while ($start_i != $stop_i){
		@levels = &find_sequence_in_levels(\@levels, $seq_type, 0, MCODE_TMP);
		print MCODE_TMP "\nThe levels are array is (after find_sequence_in_levels):\n@levels\n";
		$stop_i  = pop @levels;		# stop index of the found sequence
		$start_i = pop @levels;		# start index
	    
		if ($start_i != $stop_i){
		    # translating the if then else construct to branch
		    @code_fragment = @codes[$start_i .. $stop_i];
		    @codes[$start_i .. $stop_i] = &translate_seq_type_2label(\@code_fragment, $seq_type, MCODE_TMP);
		    $change = 10;
		    $i=$start_i;
		    print MCODE_TMP "Successful translation of $seq_type $start_i - $stop_i\n";
		    while($i<=$stop_i){
			printf( MCODE_TMP "\t%-50s%-50s\n", $codes_back[$i],$codes[$i]);
			++$i;
		    }
		}
	    }
	    $change--;
	}
    }
	    
    $i=0;

    print MCODE_TMP  "\n\n\n\nFrom parse flow control\n\tAfter finding and translating .....\n\n";
    while ($i<= $#levels_back){
	printf(MCODE_TMP "level=%-10s %-50s%-50s\n",$levels_back[$i],$codes[$i], $codes_back[$i]);
	++$i;
    }

    # moving a label with an empty line to the next code line

    @codes = &reduce_labels(\@codes, MCODE_TMP);

    $i=0;
    print MCODE_TMP "\n\n\n\nFrom parse flow control\n\tAfter label reduction .....\n\n";
    while ($i<= $#codes){
	printf(MCODE_TMP "level=%-10s %-50s%-50s\n",$levels_back[$i],$codes[$i], $codes_back[$i]);
	++$i;
    }
    close MCODE_TMP;

    return (\@codes);

}


##################################################################
##################################################################
##################################################################
sub reduce_labels{

    my($ref1) = shift @_;
    my(@codes) = @$ref1;
    my($file_ref) = shift @_;
    my($i,$j,$label);
    my($replace_label,$by_label);
    my(@codes_back);

    @codes_back =@codes;
    $i=0;

    while($i<=$#codes){ 	# moving a label with an empty line to the next code line
	if ($codes[$i] ne ""){
	    if ($codes[$i] =~ s/^\s*(L_branch_\w+)\s*$//){	# only label in line 
		$label=$1;
		$j=++$i;
		while($j<=$#codes){
#		    if ($codes[$j] =~ /(goto|return|\bbranch\b|gosub|loop|=)/){
		    if ($codes[$j] =~ /(\breset\b|\bset\b|\bpulse\b|\bnop\b|\bwait\b|\bgoto\b|\breturn\b|\bbranch\b|\bgosub\b|\bloop\b|\bpush\b|\bpop\b|\bcount\b|=|->|\bbreakif\b|\bstop)/){ 	# if code line
			$codes[$j] = "$label,$codes[$j]";
			last;	# go out of internal while
		    }
		    ++$j;
		}
		next;		# go back to begining of while
	    }
	}
	++$i;
    }


    print $file_ref "\n\n\nAFTER moving a label with an empty line to the next code line\n\n\n";
    print $file_ref "\n\n\n      before                                             after\n\n\n";
    $i=0;
    while($i<=$#codes){
	printf ($file_ref "%-50s| |%-50s\n", $codes_back[$i],$codes[$i]);
	++$i;
    }

    @codes_back =@codes;
    $i=0;
    while($i<=$#codes){ 		# reducing two or more lables in the same line to one
	if ($codes[$i] =~ s/(^\s*)(L_branch_\w+)(\s*),\s*(L_branch_\w+)\b/"$1$2$3"/e){
	    $replace_label=$4;
	    $by_label = $2;
	    $j=0;
	    while($j <= $#codes){	# run over the code and replace removed label with $by_label
		$codes[$j] =~ s/\b$replace_label\b/"$by_label"/e;
		
		++$j;
	    }
	    $i=0;
	    next;
	}
	++$i;
    }
    
    print $file_ref "\n\n\nAFTER reducing two or more lables in the same line to one\n\n\n";
    print $file_ref "\n\n\n      before                                             after\n\n\n";

    $i=0;
    while($i<=$#codes){
	printf ($file_ref "%-50s%-50s\n", $codes_back[$i],$codes[$i]);
	++$i;
    }

    return (@codes);

}

##################################################################
##################################################################
##################################################################
sub find_sequence_in_levels{
# this routine gets the @levels array and a flag saying what to search
# it return a manipulated array followed by two numbers that indicates
# the location of the matched pattern


    my($ref1) = shift @_;
    my(@levels) = @$ref1;
    my($seq_type) = shift @_;
    my($debug)    = shift @_;
    my($file_ref)    = shift @_;

    my($sequence,$pad_item,@pre_match,@match ,$pad_string , $deep ,$total);
    my($i,$j);
    my($pre_match ,$match ,$post_match);

    @levels = ("0","0",@levels); 		# adding two elements from the left
    $sequence = join(":",@levels);		# reurns 0:0:element:element:...
    print $file_ref "From find_sequence\n\t$#levels elements in level\n\tSearching for sequence type <<$seq_type>>  \n\t$sequence ===\n" if $debug;
    $deep = 0;

    $cnt = 1;
#    $debug = 1; # remove
    if ($seq_type eq "if_then"){
	$cnt = $sequence =~ s/(:0[1-3]*)(\1[1])+(\1)(?!\1[2-3]):/putmehere/;
	($pre_match ,$match ,$post_match) = ($`,$&,$')  ; # should capture them becase
	$pad_item = $1;
	# they dont last after the first enclosing block
    }
    elsif ($seq_type eq "if_then_else"){
	$cnt = $sequence =~ s/(:0[1-3]*)(\1[1])+(\1)(\1[2])+(\1:)/putmehere/;
	($pre_match ,$match ,$post_match) = ($`,$&,$')  ;
	$pad_item = $1;
    }
    elsif ($seq_type eq "if_elsif+_else"){
	$cnt = $sequence =~ s/(:0[1-3]*)(\1[1])+((\1)(\1[3])+)+(\1)((\1[2])+\1):/putmehere/;
	($pre_match ,$match ,$post_match) = ($`,$&,$')  ;
	$pad_item = $1;
    }
    elsif ($seq_type eq "if_elsif+"){
	$cnt = $sequence =~ s/(:0[1-3]*)(\1[1])+((\1)(\1[3])+)+(\1)(?!\1[2-3]):/putmehere/;
	($pre_match ,$match ,$post_match) = ($`,$&,$')  ;
	$pad_item = $1;
    }
    
    if ($cnt != 0){
	
	#$pad_item = $1;			# the first part of $match 
	print $file_ref "$seq_type construct $pre_match === $match === $post_match\n" if $debug;
	# print "1.sequence = $sequence\n";
	print "pad item =====$pad_item=====\n" if $debug;
	@pre_match  = split(/:/,$pre_match);
	@match      = split(/:/,$match);
	@post_match = split(/:/,$post_match);
	$pad_string = "";
	$j=0;
	# inserting the outer level tag to replace the resolved branch
	while ($j<$#match){
	    $pad_string .= $pad_item;		# produce string of "\1" to replace resolved block
	    ++$j;
	}
	$sequence =~ s/putmehere/"$pad_string:"/e; 	
	# print "2.sequence = $sequence\n";
	$total = $#pre_match + $#match + $#post_match; 	# for debug only
	print $file_ref "$#pre_match  $#match  $#post_match = $total, a= $a\n" if $debug;
	print $file_ref "match = @match\n" if $debug;
	$i = $#pre_match+2;

	print $file_ref "find $seq_type in level sequence \n" if $debug;
	while ($i< $#pre_match + $#match +1){
	    # $codes[$i] = "done$deep $codes[$i]";
	    $levels[$i]= $levels[$#pre_match + $#match ]; # going back one level
	    printf($file_ref "level=%-10s %-s\n",$levels[$i],$codes[$i]) if $debug;
	    ++$i;
	}
	@levels = @levels[2 .. $#levels];
	print $file_ref ">>>>>>>>>>>>>>>>   @levels\n $#pre_match, ",$#pre_match + $#match-2,"\n";
	return ( @levels , $#pre_match , $#pre_match + $#match-2);	# return modified levels array
    }									# with start and stop index founds
    else {
	@levels = @levels[2 .. $#levels];
	return (@levels , 0,0);
    }
}

##################################################################
##################################################################
##################################################################
sub translate_seq_type_2label{
# this routine gets a piece of codes arrays and a flag indicating the type of construct 
# that was found there. the routine translate this code to branch's and goto's and return 
# the translated array.
 
    my($ref1) = shift @_;
    my(@codes) = @$ref1;

    my($seq_type) = shift @_;
    my($file_ref) = shift @_;

    my($state,$i,$j,$label);
    my($label_else_start,$label_else_end );
    my($label_next_elseif_start,$label_prev_elseif_start);
    my($label_last_elsif_end)="";
    my($label_last_else_elsif_end)="";
    my($elsif_cnt);
    # my($goto_string) = "branch true_bit";
    my($goto_string) = "goto";
    $i=0;
    $j=0;
    print $file_ref "########### from translate_seq_type_2label  : $seq_type\n";
    while($j<=$#codes){
	print  $file_ref "# $codes[$j]\n";
	++$j
    }
   
########### from translate_if_else
#       if (hhh){
#               R6 = fram1
#       }       
#       else {
#               R1 = fpint1
#       }

#       if (hhh){              ->   branch $1 $label_else_start
#               R6 = fram1     ->   R6 = fram1
#       }                      ->   $goto_string $label_else_end"
#       else {		       ->   
#               R1 = fpint1    ->   $label_else_start,R1 = fpint1
#       }		       ->   $label_else_end

# state machine to prpocess piece of code
    if ($seq_type eq "if_then_else"){
	while($i<=$#codes){
	    if ($state ==0 && $codes[$i] =~ /if\s+(\([^\)]+\))\s*\{/){
		$state=1;
		$label_else_start = &get_label;
		$codes[$i] =~ s/if\s+(\([^\)]+\))\s*\{/"branch $1 $label_else_start"/e; 
	    }
	    elsif ($state ==1 && $codes[$i] =~ /\}/){
		$state=2;
		$label_else_end = &get_label;
		$codes[$i] =~ s/\}/"$goto_string $label_else_end"/e; 
	    }
	    elsif ($state ==2 && $codes[$i] =~ /else\s*\{/){
		$state=3;
		$codes[$i] = ""; # else line return empty line
	    }
	    elsif ($state ==3 && !($codes[$i] =~ /(\{|\})/)){ # first line in else block
		$state=4;
		$codes[$i] =~ s/(\s*)(.+)/"$1$label_else_start,$2"/e;
	    }
	    elsif ($state ==4 && ($codes[$i] =~ /\}/)){ # closing bracket in else block
		$state=5;
		$codes[$i] =~ s/(\})/"$label_else_end"/e;
	    }
	    elsif ( !($codes[$i] =~ /(\{|\})/)){ 	# simple code lines
		$codes[$i] = $codes[$i] ;
	    }
	    ++$i;
	}
    }
    elsif ($seq_type eq "if_then"){
	while($i<=$#codes){
	    if ($state ==0 && $codes[$i] =~ /if\s+(\([^\)]+\))\s*\{/){
		$state=1;
		$label_else_start = &get_label;
		$codes[$i] =~ s/if\s+(\([^\)]+\))\s*\{/"branch $1 $label_else_start"/e; 
	    }
	    elsif ($state ==1 && $codes[$i] =~ /\}/){ # end of then block
		$state=2;
		$label_else_end = &get_label;
		$codes[$i] =~ s/\}/"$label_else_start"/e; 
	    }
	    elsif ( !($codes[$i] =~ /(\{|\})/)){ # body lines
		$codes[$i] = $codes[$i] ;
	    }
	    ++$i;
	}	    
    }

    elsif ($seq_type eq "if_elsif+_else"){
	while($i<=$#codes){
	    if ($state ==0 && $codes[$i] =~ /if\s+(\([^\)]+\))\s*\{/){
		$state=1;
		$label_next_elseif_start = &get_label;  # at least one elsif 
		$codes[$i] =~ s/if\s+(\([^\)]+\))\s*\{/"branch $1 $label_next_elseif_start"/e; 
	    }
	    elsif ($state ==1 && $codes[$i] =~ /\}/){  # end of then block
		$state=2;
		if ($label_last_else_elsif_end eq "") {
		    $label_last_else_elsif_end = &get_label;
		}
		$codes[$i] =~ s/\}/"$goto_string $label_last_else_elsif_end"/e; 
	    }
	    elsif ($state ==2 && $codes[$i] =~ /elsif\s+(\([^\)]+\))\s*\{/){
		$state=1;
		$label_prev_elseif_start  = $label_next_elseif_start;
		$label_next_elseif_start = &get_label;  # at least one elsif 
		$codes[$i] =~ s/elsif\s+(\([^\)]+\))\s*\{/"$label_prev_elseif_start, branch $1 $label_next_elseif_start"/e; 
	    }
	    elsif ($state ==2 && $codes[$i] =~ /else\s*\{/){
		$state=3;
		$codes[$i] = "";
	    }
	    elsif ($state ==3 && !($codes[$i] =~ /(\{|\})/)){ # first code line in else block
		$state=4;
		$codes[$i] =~ s/(\s*)(.+)/"$label_next_elseif_start,$2"/e
	    }
	    elsif ($state ==4 && ($codes[$i] =~ /\}/)){ # closing bracket in else block
		$state=5;
		$codes[$i] =~ s/(\})/"$label_last_else_elsif_end"/e;
	    }
	    elsif ( !($codes[$i] =~ /(\{|\})/)){ # body lines
		$codes[$i] = $codes[$i] ;
	    }
	    ++$i;
	}
    }
    elsif ($seq_type eq "if_elsif+"){ # I know that there is no else
	while($i<=$#codes){
	    if ($codes[$i] =~ /\belsif\b/){
		++$elsif_cnt;
	    }
	    ++$i;
	}
	# now I know the number of elsif in the block
	$i=0;
	while($i<=$#codes){
	    if ($state ==0 && $codes[$i] =~ /if\s+(\([^\)]+\))\s*\{/){
		$state=1;
		$label_next_elseif_start = &get_label;  # at least one elsif 
		$codes[$i] =~ s/if\s+(\([^\)]+\))\s*\{/"branch $1 $label_next_elseif_start"/e; 
	    }
	    elsif ($state ==1 && $codes[$i] =~ /\}/){  # end of then block
		$state=2;
		if ($label_last_elsif_end eq "") {
		    $label_last_elsif_end = &get_label;
		}
		if ($i == $#codes){  # closing bracket of the last elsif
		    $codes[$i] =~ s/(\})/"$label_last_elsif_end"/e;
		}
		else{
		    $codes[$i] =~ s/\}/"$goto_string $label_last_elsif_end"/e; 
		}
	    }
	    elsif ($state ==2 && $codes[$i] =~ /elsif\s+(\([^\)]+\))\s*\{/){
		--$elsif_cnt;
		$state=1;
		$label_prev_elseif_start  = $label_next_elseif_start;
		if ($elsif_cnt != 0){
		    $label_next_elseif_start = &get_label;  # at least one elsif 
		    $codes[$i] =~ s/elsif\s+(\([^\)]+\))\s*\{/"$label_prev_elseif_start, branch $1 $label_next_elseif_start"/e; 
		}
		else{
		    $codes[$i] =~ s/elsif\s+(\([^\)]+\))\s*\{/"$label_prev_elseif_start, branch $1 $label_last_elsif_end"/e;
		}
	    }
	    elsif ( !($codes[$i] =~ /(\{|\})/)){ # body lines
		$codes[$i] = $codes[$i] ;
	    }
	    ++$i;
	}
    }
    
   
    return (@codes);
########### end from translate_if_else
#       branch hhh L_branch_aab
#               R6 = fram1
#       goto L_branch_aac       
# 
#               L_branch_aab,R1 = fpint1
#       L_branch_aac

}

1;
