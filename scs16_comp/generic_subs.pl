
##################################################################
##################################################################
##################################################################
sub  print_assoc {
    
    my(%my_a )= @_;
    my($key, $value);
    # print "@_\n";
    while (( $key, $value) = each %my_a ){
	printf("%-30s=>  %s\n", $key,$value);
    } 
}

#################################################################
#################################################################
#################################################################
sub fchop{
    my($s) = shift(@_);
    my($res,$tmp,$t);
    $tmp = reverse $s;
    $t= chop $tmp;
    $tmp = reverse $tmp;
    return ( $t, $tmp );
}
#################################################################
#################################################################
#################################################################
sub signed2unsigned {
    my($v) = shift @_; # the decimal value signed
    my($w) = shift @_; # the width of representation in bits
    if ($v >= 0) {
	# positive or zero
	if ($v > 2**($w-1)-1){
	    # out of range
	    return (0, 'x');
	}
	else {
	    return (1, $v);
	}
    }
    else {
	# negative
	if ($v < -(2**($w-1))){
	    # out of range
	    return (0, 'x');
	}
	else {
	    return (1, (2**$w)+$v);
	}
    }
}
#################################################################
#################################################################
#################################################################
sub unsigned2unsigned {
    my($v) = shift @_; # the decimal value unsigned
    my($w) = shift @_; # the width of representation in bits
    if ($v >= 0) {
	# positive or zero
	if ($v > 2**($w)-1){
	    # out of range
	    return (0, 'x');
	}
	else {
	    return (1, $v);
	}
    }
    else {
	# negative
	return (0, 'x');
    }
}
#################################################################
#################################################################
#################################################################
sub unsigned2bin {
    my($v) = shift @_; # the decimal value unsigned (positive or zero)
    my($w) = shift @_; # the width of representation in bits
    my ($vv,$res,$bin,$i);
    # positive or zero
    if ($v > (2**$w)-1){
	# out of range
	return (0, 'x');
    }
    else {
	# in range, do the transform
	$vv = $v;

	for ($i=0; $i<$w; $i++){
	    $res = $vv % (1<<($i+1));
	    $bin = ($res > 0)? "1$bin" : "0$bin";
	    $vv = $vv - $res;
	}
	die "error in unsigned2bin v is $v, w is $w, vv is $vv\n" if ($vv > 0);
	return (1, $bin);
    }

}
#################################################################
#################################################################
#################################################################
sub dec2hextc{ # this is the twos compliment vesion of dec2hex
 
    my(@dec) = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f");
    #local($n,$i,$res,$w,$k,$max_size );
    my ($n,$i,$res,$w,$k,$max_size );
    $n = shift(@_); # the number to transform
    $w = shift(@_); # the width
    # print "$n $w\n";
    if ($n =~ /-(\d+)/){
	$max_size =        (1<< (4*$w))-1;
	$n = $max_size - $1 + 1;
    }

    $i=$w-1;
    if ($n ==0) {
        for($k=0; $k<$w; ++$k){
            $res .= "0";
        }
        return $res;
    }
#    print "n is $n @_\n";
    while($n>=0 && $i>=0){
        $res .= $dec[(int($n/(16**$i)))];
#       print "$res ";
        $n -= (int($n/(16**$i))) * (16**$i);
        --$i;
        
    }
    
    return $res;
}

#################################################################
#################################################################
#################################################################
sub bitwise_or{
    my($str1) = shift(@_);
    my($str2) = shift(@_);
    my($d1,$d2,$tmp,$res);

    while (length($str1) >0){
	$str1=~ s/^(\w)//;
	$d1 = $1;
	$str2=~ s/^(\w)//;
	$d2 = $1;
	if ($d1 eq 'z' && $d2 eq 'z'){
	    $tmp ='z';
	}
	elsif ($d1 eq 'z'){
	    $tmp = $d2;
	}
	elsif ($d2 eq 'z'){
	    $tmp = $d1;
	}
	else{
	    $tmp = $d1 || $d2;
	}
	$res .= "$tmp";
    }
    return $res;
}

#################################################################
#################################################################
#################################################################
sub hex2bin{
 
    my($s) = shift(@_);
    my($w) = shift(@_);
    my($q);
    my($res) = "";
    # print "$h2b{3} there $s koko\n";
    while(length($s)>0){
        $s =~ s/^(\w)//;
        $res .= $h2b{$1};
	$q = length($s);
        # print "$res h $s $q \n";
    }
    while(length($res)>$w ){
	$res =~ s/^\w//;
    }
    return $res;
}

#################################################################
#################################################################
#################################################################
sub bin2hex{
 
    my($s) = shift(@_);
    # print "$s\n";

    my($res) = "";
    while(length($s)>=4){
        $s =~ s/([01]{4,4})$//;
        $res = "$b2h{$1}$res";
    }
    if (length($s) !=0){
	
	while(4 - length($s)>0 ){
	    $s = "0$s";
	}
	$res = "$b2h{$s}$res";
    }

    #print "$res\n";
    return $res;
}
#################################################################
#################################################################
#################################################################
sub bin2dec{
 
    my($s) = shift(@_);
    my($i)=0;
    my($bit,$res);
    # print "$s\n";

    $res = 0;
    while($s=~ s/([01])$//){
	$bit = $1;
	$res = $res+ $bit*(2**$i);
	$i++;
    }
    return ($res);
}

#################################################################
#################################################################
#################################################################
sub dec2bintc{
 
    my $n = shift(@_); # the number to transform
    my $w = shift(@_); # the width 
    my($i,$res,$k);

    # &hex2bin(&dec2hextc( 0, 2),6);
    # print "$n $w\n";
    $res = &hex2bin(&dec2hextc($n,int($w/4)+1),$w);
    # $res = &dec2hextc($n,int($w/4)+1);
    # $res = &hex2bin($res ,$w);
    return $res;

}
#################################################################
#################################################################
#################################################################
sub dec2bin{
 
    my $n = shift(@_); # the number to transform
    my $w = shift(@_); # the width 
    my($i,$res,$k);

    # &hex2bin(&dec2hextc( 0, 2),6);
    # print "$n $w\n";
    $res = &hex2bin(&dec2hex($n,int($w/4)+1),$w);
    # $res = &dec2hextc($n,int($w/4)+1);
    # $res = &hex2bin($res ,$w);
    return $res;

}
#################################################################
#################################################################
#################################################################
sub dec2hex{
 
    my(@dec) = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f");
    my($n,$i,$res,$w,$k);
    $n = shift(@_); # the number to transform
    $w = shift(@_); # the width 
    $i=$w-1;
    if ($n ==0) {
        for($k=0; $k<$w; ++$k){
            $res .= "0";
        }
        return $res;
    }
#    print "n is $n @_\n";
    while($n>=0 && $i>=0){
        $res .= $dec[(int($n/(16**$i)))];
#       print "$res ";
        $n -= (int($n/(16**$i))) * (16**$i);
        --$i;
        
    }
    
    return $res;
}

#################################################################
#################################################################
#################################################################
sub parse_address_mode{
# &parse_concat_address($str, $imd_wd, $reg_wd);
    my ($str)    = shift (@_);
    my ($imd_wd) = shift (@_);
    my ($reg_wd) = shift (@_);
    my $org_str  =$str;
    my($imd,$r6r7, $high_index,$low_index,$success, $imd_bin,$ok);
    my ($address_mode,$inc_add );
    $inc_add = 0;
    $imd =0;
    $r6r7='R6';
    $address_mode ='null';
    $str =~ s/\s//g;
    $ok = 1;
    if ($str =~ s/^(\S+),(R\d)\[(\d+):(\d+)\]$//){
	# the long type imd12,R6[11:0]
	$imd =$1;
	$r6r7=$2;
	$high_index = $3;
	$low_index  = $4;
	($success, $imd_bin)= &parse_const_new1($imd,$imd_wd,'non_tc');
	$ok = $success;
	if (($high_index-$low_index+1) != $reg_wd){
	print "here1\n";
	    $ok = 0;
	}
	if (($r6r7 ne 'R6') && ($r6r7 ne 'R7')){
	print "here2 $r6r7,\n";
	    $ok =0;
	}
	$address_mode = 'long';
    }
    elsif ($str =~ s/^(\S+)\+(R\d)$//){
	# the imd_offset type imd12+R6
	$imd =$1;
	$r6r7=$2;
	($success, $imd_bin)= &parse_const_new1($imd,$imd_wd,'non_tc');
	$ok = $success;
	if (($r6r7 ne 'R6') && ($r6r7 ne 'R7')){
	print "here2 $r6r7,\n";
	    $ok =0;
	}
	$address_mode = 'imd_offset';	
    }
    elsif ($str =~ s/^(R\d)\+\+$//){
	# the inc type 
	$r6r7    =$1;
	$inc_add = 1;
	if (($r6r7 ne 'R6') && ($r6r7 ne 'R7')){
	print "here2 $r6r7,\n";
	    $ok =0;
	}
	$address_mode = 'inc';	
    }
    elsif ($str =~ s/^(R\d)$//){
	# the r6r7 type 
	$r6r7=$1;
	if (($r6r7 ne 'R6') && ($r6r7 ne 'R7')){
	print "here2 $r6r7,\n";
	    $ok =0;
	}
	$address_mode = 'r6r7';	
    }
    elsif ($str =~ s/^(\d\S*)$//){
	# the imd type 
	$imd =$1;
	($success, $imd_bin)= &parse_const_new1($imd,$imd_wd,'non_tc');
	$ok = $success;
	$address_mode = 'imd';	
    }


    else {
	print "here3 ,$str,\n";
	$ok = 0;
    } 
    print "address_mode $address_mode, imd = $imd, r6r7 = $r6r7, inc = $inc_add\n" if (1);


    if ($ok){
	return ($ok, $address_mode, $r6r7, $inc_add, $imd_bin);
    }
    else {
	print "Error! : parse_address_mode : expecting <imd$imd_wd,R6|R7[$reg_wd-1:0]...\n" if (0);
	return ($ok, $address_mode, $r6r7, $inc_add, $imd_bin);
	
    }


}
#################################################################
#################################################################
#################################################################
sub parse_const_new1{

    my ($str)         = shift(@_);        # the string to be converted
    my ($wd_expected) = shift(@_);        # the width of expected result.
    my ($tc)          = shift(@_);        # indicate whether the number may be two's compliment

    my $org_str=$str;
    my ($v,$w,@tmp,$tmp);
    my ($base, $m, $d, $bin, $fail, $residual, $max_int,  $min_int );
    my ($ok, $unsigned_number );

    if ( $str =~ s/(\d+)\'(h|b)(\w+)//){

	# verilog width value notation
	$w=$1;
	$base=$2;
	$m=$3;
	if ($str =~ /[^\s]+/) {
	    print"Error !,There are leftover [ $str ] the number $org_str not valid\n";
	    return ( 0, $bin);
	}


	if ($w != $wd_expected) {
	    print "Error !,width of const $w is not as expected $wd_expected\n";
	    return ( 0, $bin);
	}
	while($m =~ s/^(\w)//){
	    $d=$1;
	    if ($base eq 'h'){
		if (defined $h2b{$d} ){
		    $bin .= $h2b{$d};
		}
		else {
		    print "Error !,characters in $org_str does not comply to hexadecimal style\n";
		    return ( 0, $bin);
		}
	    }
	    else {
		if ($d =~ /[01]/){
		    $bin .= $d;
		}
		else {
		    print "Error !,characters in $org_str does not comply to binary style\n";
		    return ( 0, $bin);
		}		
	    }
	}
    }
    elsif ($str =~ s/(-?\d+)//){
	
	# normal decimal notation
	# print "normal decimal $1\n";
	$base = 'd';
	if ($str =~ /[^\s]+/) {
	    print"Error !,There are leftover [ $str ] the number $org_str not valid\n";
	    return ( 0, $bin);
	}
	if ($tc eq 'tc'){
	    ($ok, $unsigned_number ) = &signed2unsigned($1,$wd_expected);
	    if ($ok == 0){
		print "Error !,number $org_str is out of range: SIGNED, expected width $wd_expected\n";
		return ( 0, $bin);
	    }
	}
	else {
	    ($ok, $unsigned_number ) = &unsigned2unsigned($1,$wd_expected);
	    if ($ok == 0){
		print "Error !,number $org_str is out of range: UNSIGEND, expected width $wd_expected\n";
		return ( 0, $bin);
	    }
	}
	($ok, $bin ) = &unsigned2bin($unsigned_number,$wd_expected);
	# print"\n\n ok $ok unsigned_number $bin \n";
	if ($ok == 0){
	    die "Error!! should not be here!!!";
	}
    }
    else {
	print "Error !,characters in $org_str does not comply to supported style\n";
	return ( 0, $bin);
    }
    # at this stage we have a binary string $bin
    
    # checking and adjusting the length
    # the idea here is that the residual string is homogenous, all ones or all zeros.
    # print "bin is $bin\n";
    if (length($bin) > $wd_expected){
	$residual = substr ( $bin, 0, length($bin)-$wd_expected);
	
	if ($residual =~ /1/){
	    print "Error !,truncating significant digits $residual, number $org_str does not decent nf\n";
	    return ( 0, $bin);
	}
	#if (!($residual =~ /^1+$/ || $residual =~ /^0+$/) ){
	#    print "Error !,truncating significant digits $residual, number $org_str does not decent\n";
	#    return ( 0, $bin);
	#}
	else {
	    $bin = substr ( $bin, length($bin)-$wd_expected, $wd_expected);
	}		
    }
    elsif (length($bin) < $wd_expected){
	while(length($bin) < $wd_expected){
	    $bin ='0'.$bin;
	}
    }
    return (1,$bin);
}	
#################################################################
#################################################################
#################################################################
sub parse_const_new{

    my ($str)         = shift(@_);        # the string to be converted
    my ($wd_expected) = shift(@_);        # the width of expected result.
    my ($tc)          = shift(@_);        # indicate whether the number may be two's compliment

    my ($v,$w,@tmp,$tmp);
    my ($base, $m, $d, $bin, $fail, $residual, $max_int,  $min_int );
	
    if ( $str =~ /(\d+)\'(h|b)(\w+)/){
	# verilog width value notation
	$w=$1;
	$base=$2;
	$m=$3;
	if ($w != $wd_expected) {
	    print "Error !,width of const $w is not as expected $wd_expected\n";
	    return ( 0, $bin);
	}
	while($m =~ s/^(\w)//){
	    $d=$1;
	    if ($base eq 'h'){
		if (defined $h2b{$d} ){
		    $bin .= $h2b{$d};
		}
		else {
		    print "Error !,characters in $str does not comply to hexadecimal style\n";
		    return ( 0, $bin);
		}
	    }
	    else {
		if ($d =~ /[01]/){
		    $bin .= $d;
		}
		else {
		    print "Error !,characters in $str does not comply to binary style\n";
		    return ( 0, $bin);
		}		
	    }
	}
    }
    elsif ($str =~ /(-?\d+)/){
	# normal decimal notation
	print "normal decimal $1\n";
	$base = 'd';
	if ($tc eq 'tc'){
	    $max_int =   2**($wd_expected-1)-1;
	    $min_int = -(2**($wd_expected-1));
	    if (($str <= $max_int) && ($str >= $min_int)) {  
		$bin = &dec2bintc($1, 32);
	    }
	    else {
		print "Error !,number $str is out of range: { $min_int <= x <= $max_int }\n";
		return ( 0, $bin);
	    }
	}
	else {
	    $max_int =   2**$wd_expected-1;
	    $min_int = 0;
	    if (($str <= $max_int) && ($str >= $min_int)) {  
		$bin = &dec2bin($1, 32);
	    }
	    else {
		print "Error !,number $str is out of range: { $min_int <= x <= $max_int }\n";
		return ( 0, $bin);
	    }
	}
    }
    else {
	print "Error !,characters in $str does not comply to supported style\n";
	return ( 0, $bin);
    }
    # at this stage we have a binary string $bin
    
    # checking and adjusting the length
    # the idea here is that the residual string is homogenous, all ones or all zeros.
    print "bin is $bin\n";
    if (length($bin) > $wd_expected){
	$residual = substr ( $bin, 0, length($bin)-$wd_expected);
	if (!($residual =~ /^1+$/ || $residual =~ /^0+$/) ){
	    print "Error !,truncating significant digits $residual, number $str does not decent\n";
	    return ( 0, $bin);
	}
	else {
	    $bin = substr ( $bin, length($bin)-$wd_expected, $wd_expected);
	}		
    }
    elsif (length($bin) < $wd_expected){
	while(length($bin) < $wd_expected){
	    $bin ='0'.$bin;
	}
    }
    return (1,$bin);
}	
#################################################################
#################################################################
#################################################################
sub parse_const{

    my ($n) = shift(@_);        # the string to be converted
    my ($hash_ref) = shift(@_); # the record that describes the format
    my ($key,$v,$w,@tmp,$tmp);
    my %field_hash = %$hash_ref;
    my $i;
    my $res;
#     {
# 	fname => value,
# 	wd => 16,
# 	comment => "a two's complement number, word width",
# 	regexp_hash => { 
# 	    hexadecimal => "(8|16)'h([0-9a-f])([0-9a-f])",
# 	    binary      => "(8|16)'b([01]{8})",
# 	    decimal     => '\b(-?\d+)$',  
# 	},
#     }
	
    foreach $key (keys  %{$field_hash{'regexp_hash'}}){
	$regexp = $field_hash{'regexp_hash'}->{$key};
	if ($n=~ s/$regexp/"$1"/e){
	    if ($key eq 'hexadecimal'){
		while ($n =~ s/([0-9a-f]*)([0-9a-f])/"$1"/e){
		    $res = $h2b{$2}.$res;
		    
		}
		# Taking only "wd" lsb significant bits from the hexa, ie hex can be longer then required field
		$wd=($field_hash{'wd'});
		$res=substr ($res, length ($res)-$wd);
		####
		return ($res);
	    }
	    if($key eq 'binary'){
		$res = $n;
		return ($res);
	    }
	    if($key eq 'decimal'){
		if ($field_hash{'type'} eq 'signed'){
		    if (($n >= (2**($field_hash{'wd'}-1)) -1) || ($n <= -(2**($field_hash{'wd'}-1)))){ 
			&elaborate_field(0,\%field_hash);
			die "Exiting!!! $n (signed) out of range!!!\n";
		    }
		    $res = &dec2bintc($n, $field_hash{'wd'});
		}
		else{
		    if ($n > (2**($field_hash{'wd'})) -1){
			&elaborate_field(0,\%field_hash);
			die "Exiting!!! $n (unsigned) out of range!!!\n";
		    }
		    $res = &dec2bintc($n, $field_hash{'wd'}+1);
		    $res =~ s/^[01]//;
		}
		#&elaborate_field(0,\%field_hash);
		return ($res);
	    }
	}
    }
    print "Expecting some sort of numeric const $n, field should look like :\n";
    &elaborate_field(0,\%field_hash);
    die "Exiting!!!\n";
}	
#################################################################
#################################################################
#################################################################
	
sub elaborate_field{

    my ($level) = shift(@_);    # the level
    my ($hash_ref) = shift(@_); # the record to be elaborated
    my %field_hash = %$hash_ref;
    my $r;
    my $i;
    $level++;
    foreach $key (sort keys %field_hash){
	$r = ref $field_hash{$key};
	$i=$level-1;
	while($i>0){print "\t"; $i--;}
	if ($r eq ""){
	    printf("%-30s=>  %s\n", $key,$field_hash{$key});
	}
	else{
	    printf("%-30s=>  %s\n", $key,$r);
	    &elaborate_field($level,$field_hash{$key});
	}
    }
}
##################################################################
##################################################################
##################################################################
sub die_fail_parse {
    my($command_name) = shift (@_);
    my($line_num) = shift(@_);
    my($cmd_org) = shift(@_);
    my($die_msg) = shift(@_);
    my($example) = shift(@_);
    my($elaborate_field) = shift(@_);

    my $G;
    $G="G\_$command_name\_Command_Format";
    # print "=== from fail parse\n";
    if($die_msg){ # kkk 
	print"die_fail_parse : ERROR!! In $command_name command << $cmd_org >>:$die_msg\n";
    }
    if($elaborate_field){
	&elaborate_field(1,$$G{ $elaborate_field }->{'val_hash'});
	print"\n"
    }
    if($example){
	&print_command_example($G);
    }
    die "\n\nExiting!!!  line $line_num :$cmd_org\n";

}

##################################################################
##################################################################
##################################################################
sub die_leftovers {
    my($command_name) = shift @_;
    my($cmd_org) = shift @_;
    my($cmd) = shift @_;
    print "die_leftovers : in $command_name cmd << $cmd_org >>, syntax error!! << $cmd >> was left after parsing\n\n";
    &print_command_example("G_${command_name}_Command_Format");
    die "\n\nExiting!!!\n";

}


#################################################################
#################################################################
#################################################################
	
sub print_command_example{

    my ($hash_ref) = shift(@_); # the record to be elaborated
    my %field_hash = %$hash_ref;
    my ($example);
    print "Command syntax should be like that :\n";
    foreach $example (example, example1, example2, example3, example4, example5){ 
	if (defined $field_hash{regexp}{$example}) {
	    print "\t$field_hash{regexp}{$example}\n";
	}
	else {
	    last;
	}
    }
}
##################################################################
##################################################################
##################################################################
sub read_script_file{
    my $file_name = shift @_;
    my $script_file_name = shift @_;
    my (@codes, @codes_for_presentation, @comments);

    my ($i,$comment);
    print "\tResults may be seen in $file_name file\n";
    open(MCODE_TXT, $script_file_name)           || die "Cant open $script_file_name for reading ... Exiting\n";
    open(MCODE_TMP, ">$file_name")               || die "Cant open $file_name for writing ... Exiting\n";
    
    print  "\tzero pass, spliting the input file into three arrays, \@codes \@codes_for_presentation \@comments\n";
    print MCODE_TMP "zero pass, spliting the input file into three arrays, \@codes \@codes_for_presentation \@comments\n";


    $i=0;
    while(<MCODE_TXT>){			
	$codes[$.-1]         = "";			# create new entry
	$codes_for_presentation[$.-1]         = $codes[$.-1];
	$comments[$.-1]      = "";
#    print ;
	$comment = "";
	chop($_);
	if (/^\s*(\`define|\`include)\b/){ 	# just copy the whole line to comments array
	    $comment = $_;
	}
	elsif (s/\/\/\s*(.*)//){
	    # grab the comment and clean it from $_
	    $comment = $1;
	}
	$comments[$.-1] = $comment;
	
	if ($_ =~ /(\w+|\{|\})/){ 			# a code lines including curly brakets {}
	    $codes[$.-1]         = $_;
	    $codes[$.-1]         =~ s/\t/  /g; 	# should reconsider this 
	    $codes_for_presentation[$.-1]         = $codes[$.-1];
	    $i++;
	}
	if ($codes[$.-1] =~ /\S+/){
	    printf(MCODE_TMP "%5d %-50s  // %-s\n",($.-1),$codes[$.-1]   ,$comments[$.-1] );
	}
	else {
	    printf(MCODE_TMP "%5d // %-s\n",($.-1),$comments[$.-1] );
	}
	# print "($.-1),$codes[$.-1],$comments[$.-1]\n";
    }
    close MCODE_TXT;
    close MCODE_TMP;
    
    return (\@codes,\@comments,\@codes_for_presentation);

}
##################################################################
##################################################################
##################################################################
sub translate_defines{

# `define i r2

    my $file_name = shift @_;
    my $ref1      = shift @_;
    my @codes = @$ref1;
    my($i,$j);
    my($var_name, $reg_name, %var2reg);
    my(@codes_back);

    @codes_back =@codes;
    print "\tResults may be seen in $file_name file\n";
    open(MCODE_TMP, ">$file_name") || die "Cant open $file_name for writing ... Exiting\n";
    
    print MCODE_TMP "First pass: evaluating defines\n";
    print "\tFirst pass: evaluating defines\n";

    for($i=0; $i<=$#codes; ++$i){ # 
	if ($codes[$i] ne ""){
	    if ($codes[$i] =~ /\`define\b/){
		while($codes[$i] =~ s/\`define\s+(\S+)\s+(\S+)//){
		    # print "here --\n";
		    $var_name = $1;
		    $reg_name = $2;
		    $var2reg{$var_name} = $reg_name ;
		}
		$codes[$i] ="";
		next;
	    }
	    elsif  ($codes[$i] =~ /\bassign_clear\b/){
		undef %var2reg;
		$codes[$i] ="";
		next;
	    }
	    else{
		# with the current %var2reg do the replacements
		foreach $var_name (keys %var2reg){
		    # print "trying to replace $var_name by $reg_name\n";
		    $reg_name  = $var2reg{$var_name}; 
		    $codes[$i] =~ s/\`$var_name\b/$reg_name/eg; # to stop coloring `
		}
	    }
	}
    }		
    
    print MCODE_TMP "\n\n\nAFTER translating assigns\n\n\n";
    print MCODE_TMP "\n\n\n      before                                             after\n\n\n";

    for($i=0; $i<=$#codes; ++$i){ # 
	printf (MCODE_TMP "%-50s%-50s\n", $codes_back[$i],$codes[$i]);
    }
    
    close MCODE_TMP;
    return (\@codes);

}

##################################################################
##################################################################
##################################################################
sub translate_defines_new{

# `define i r2

    my $file_name = shift @_;
    my $ref1      = shift @_;
    my @codes = @$ref1;
    my($i,$j);
    my($var_name, $reg_name, %var2reg);
    my(@codes_back);
    my($include_f_name);

    @codes_back =@codes;
    print "\tResults may be seen in $file_name file\n";
    open(MCODE_TMP, ">$file_name") || die "Cant open $file_name for writing ... Exiting\n";
    
    print MCODE_TMP "First pass: evaluating defines\n";
    print "\tFirst pass: evaluating defines\n";

    for($i=0; $i<=$#codes; ++$i){ # 
	if ($codes[$i] ne ""){
	    if ($codes[$i] =~ /\`define\b/){
		while($codes[$i] =~ s/\`define\s+(\S+)\s+(\S+)//){
		    # print "here --\n";
		    $var_name = $1;
		    $reg_name = $2;
		    $var2reg{$var_name} = $reg_name ;
		}
		$codes[$i] ="";
		next;
	    }
	    elsif  ($codes[$i] =~ /\`include\b/){   # to resync indentation
		# print "hhhhhhhhhh $codes[$i]\n";
		if ($codes[$i] =~ s/\`include\b\s+(\S+)//){
		    $include_f_name = $1;
		    $include_f_name =~ s/\"//g; 
		    open(INCLUDE_FILE, "$include_f_name") || 
			die "Cant open include file <$include_f_name> for reading ... Exiting\n";
		    while(<INCLUDE_FILE>){
			if ( s/\`define\s+(\S+)\s+(\S+)//){
			    $var_name = $1;
			    $reg_name = $2;
			    $var2reg{$var_name} = $reg_name ;
			}
		    }
		    $codes[$i] ="";
		    next;		    
		}
	    }
	}
    }
    # seconf pass, performing the reference translation

    print MCODE_TMP "Second pass: translating all defines\n";
    print "\tSecond pass: translating all defines\n";
    
    for($i=0; $i<=$#codes; ++$i){ # 
	if ($codes[$i] ne ""){
	    $j=0;
	    while ($codes[$i] =~ /\`(\w+)\b/) {
		$var_name = $1;
		if (defined $var2reg{$var_name}) {
		    $reg_name  = $var2reg{$var_name}; 
		    $codes[$i] =~ s/\`$var_name\b/$reg_name/eg;
		}
		else {
		    if ($j++ > 10){
			last;
		    }
		    print MCODE_TMP "Error!!, no definition for <$var_name> ...\n";
		    print           "Error!!, no definition for <$var_name> ...\n";
		}
	    }
	}
    }
    
    print MCODE_TMP "\n\n\nAFTER translating defines\n\n\n";
    print MCODE_TMP "\n\n\n      before                                             after\n\n\n";

    for($i=0; $i<=$#codes; ++$i){ # 
	printf (MCODE_TMP "%-50s%-50s\n", $codes_back[$i],$codes[$i]);
    }
    
    close MCODE_TMP;
    return (\@codes);

}



#######################################################
#######################################################
#######################################################
sub translate_defines_new1{

# `define i r2
    # print "-------------- translate defines entered\n";
    my $file_name = shift @_;
    my $ref1      = shift @_;
    my @codes = @$ref1;
    my($i,$j);
    my($var_name, $reg_name, %var2reg);
    my(@codes_back);
    my($include_f_name);
    my ($def_tag);

    @codes_back =@codes;
    print "\tResults may be seen in $file_name file\n";
    open(MCODE_TMP, ">$file_name") || die "Cant open $file_name for writing ... Exiting\n";
    
    print MCODE_TMP "First pass: evaluating defines\n";
    print "\tFirst pass: evaluating defines\n";

    for($i=0; $i<=$#codes; ++$i){ # 
	if ($codes[$i] ne ""){
	    if ($codes[$i] =~ /\`define\b/){
		while($codes[$i] =~ s/\`define\s+(\S+)\s+(.+)//){
		    # print "here --\n";
		    $var_name = $1;
		    $reg_name = $2;
		    
		    #checks if the define is nested and if is checks if it 
		    #has already been declared
		    while($reg_name =~ /.*\`(\w+).*/){
			$def_tag = $1;
			if(defined $var2reg{$def_tag}){
			    $reg_name =~ s/(.*)(\`\w+)(.*)/$1$var2reg{$def_tag}$3/;
			}
			else{
			    die "Error: no definition for <$def_tag>\n"; 
			}
			#print "loop\n";
		    }
		    $reg_name = &eval_reg_name($reg_name);
		    $var2reg{$var_name} = $reg_name;
		}
		$codes[$i] ="";
		next;
	    }
	    elsif  ($codes[$i] =~ /\`include\b/){   # to resync indentation
		# print "hhhhhhhhhh $codes[$i]\n";
		if ($codes[$i] =~ s/\`include\b\s+(\S+)//){
		    $include_f_name = $1;
		    $include_f_name =~ s/\"//g; 
		    open(INCLUDE_FILE, "$include_f_name") || 
			die "Cant open include file <$include_f_name> for reading ... Exiting\n";
		    while(<INCLUDE_FILE>){
			if ( s/\`define\s+(\S+)\s+(.+)//){ # max 25/7/05 was \S+ for reg_name
			    $var_name = $1;
			    $reg_name = $2;
			    
			    #checks if the define is nested and if is checks if it 
			    #has already been declared
			    while($reg_name =~ /.*\`(\w+).*/){
				$def_tag = $1;
				if(defined $var2reg{$def_tag}){
				    $reg_name =~ s/(.*)(\`\w+)(.*)/$1$var2reg{$def_tag}$3/;
				}
				else{
				    die "Error: no definition for <$def_tag>\n"; 
				}
			    }
			    $reg_name = &eval_reg_name($reg_name);
			    $var2reg{$var_name} = $reg_name;
			}
		    }
		    $codes[$i] ="";
		    next;		    
		}
	    }
	}
    }
    # seconf pass, performing the reference translation
    
    print MCODE_TMP "Second pass: translating all defines\n";
    print "\tSecond pass: translating all defines\n";
    
    for($i=0; $i<=$#codes; ++$i){ # 
	if ($codes[$i] ne ""){
	    $j=0;
	    while ($codes[$i] =~ /\`(\w+)\b/) {
		$var_name = $1;
		if (defined $var2reg{$var_name}) {
		    $reg_name  = $var2reg{$var_name}; 
		    $codes[$i] =~ s/\`$var_name\b/$reg_name/eg;
		}
		else {
		    if ($j++ > 10){
			last;
		    }
		    print MCODE_TMP "Error!!, no definition for <$var_name> ...\n";
		    print           "Error!!, no definition for <$var_name> ...\n";
		}
	    }
	}
    }
    
    print MCODE_TMP "\n\n\nAFTER translating defines\n\n\n";
    print MCODE_TMP "\n\n\n      before                                             after\n\n\n";
    
    for($i=0; $i<=$#codes; ++$i){ # 
	printf (MCODE_TMP "%-50s%-50s\n", $codes_back[$i],$codes[$i]);
    }
    
    close MCODE_TMP;
    return (\@codes);
    
}

#######################################################
#######################################################
#######################################################
sub eval_reg_name{
    
    my $org_line = shift @_;
    my @line;
    my ($i,$end);
    my $expr;
    my $tmp;
    # print "bkkkkkk $org_line\n";
    $org_line =~ s/\s*//g; # to fix space problems in rside of defines construct
    $i = 0;
    while($org_line =~ s/\s*(\S+?)\s*([\+\-*\/])//){
	$line[$i] = $1;
	$i++;
	$line[$i] = $2;
	$i++;
    }
    $line[$i] = $org_line;

    # print "akkkkkk @line $org_line\n";
    for($i=0; $i<=$#line; ){
	# print "i= $i\n";
	if($line[$i] =~ /^\d+$/ & $line[$i+2] =~ /^\d+$/){
	    $expr = eval($line[$i].$line[$i+1].$line[$i+2]);
	    $end = @line-1;
	    
	    if($i==0){
		@line = ($expr,@line[$i+3..$end]);
	    }else{
		@line = (@line[0..$i],$expr,@line[$i+3..$end]);
		 $i += 2;
	    }
	   
	}
	else{
	    $i += 2;
	}	
    }
    $tmp = join('',@line);
    return $tmp;
}



##################################################################
##################################################################
##################################################################
sub translate_assigns{

# assign i=r2 j=r3

    my(@codes) = @_;
    my($i,$j);
    my($var_name, $reg_name, %var2reg);
    my(@codes_back);

    @codes_back =@codes;

    for($i=0; $i<=$#codes; ++$i){ # 
	if ($codes[$i] ne ""){
	    if ($codes[$i] =~ /\bassign\b/){
		
#		while($codes[$i] =~ s/(\w+)\s*=\s*((r|R)\d+)//){
		while($codes[$i] =~ s/(\w+)\s*=\s*(\S+)//){
		    $var_name = $1;
		    $reg_name = $2;
		    $var2reg{$var_name} = $reg_name ;
		}
		$codes[$i] ="";
		next;
	    }
	    elsif  ($codes[$i] =~ /\bassign_clear\b/){
		undef %var2reg;
		$codes[$i] ="";
		next;
	    }
	    else{
		foreach $var_name (keys %var2reg){
		    $reg_name  = $var2reg{$var_name}; 
		    $codes[$i] =~ s/\b$var_name\b/$reg_name/eg;
		}
	    }
	}
    }		
    
    print "\n\n\nAFTER translating assigns\n\n\n";
    print "\n\n\n      before                                             after\n\n\n";

    for($i=0; $i<=$#codes; ++$i){ # 
	printf ("%-50s%-50s\n", $codes_back[$i],$codes[$i]);
    }

    return (@codes);

}

##################################################################
##################################################################
##################################################################

sub output_to_files{
    
    my($h_ref) = shift(@_);          # this is the %Affected_Mcode_fields
    my($Command_Format) = shift(@_); # this is the name of the command array
    my($pc_num) = shift(@_);         # this is the pc_num for this command
    my($comment) = shift(@_);        # this is the comment for this command
    my($line) = shift(@_);           # this is the source code for this command
    my($bin_file) = shift(@_);       # handle to bin mcode file
    my($hex_file) = shift(@_);       # handle to hex mcode file
    my($display_file) = shift(@_);   # handle to verilog display file
    my($fdisplay_file) = shift(@_);   # handle to verilog fdisplay file
    my($display_file_hex) = shift(@_);   # handle to verilog display file in hex format
    my($hex_file_xilinxs) = shift(@_);   
    my($bin_file_vhdl)    = shift(@_);   
    my($hex_file_ocp_stim) = shift(@_);   
    my($hex_file_16bits_clean) = shift(@_);   
    my($tmp_file) = shift(@_);   
  
    
    $Command_Format =~ m/G_(\w+)_Command_Format/;
    my($command_name) = $1;
    my ($hex_mcode_line_xilinxs);
    my $bin_mcode_line="";
    my $bin_mcode_line_ref="";
    my $hex_mcode_line="";
    my $hex_mcode_line_ref="";
    my ($i,$bin_second_line ,$hex_second_line, $pc_string,$verilog_second_display_cmd,$verilog_display_cmd);

    my %Affected_Mcode_fields = %$h_ref;
    my ($v,$w, $line_comment);

    $array_name = $Command_Format ;
    print $tmp_file "\tArray name is $Command_Format, num of fields $#$Command_Format\n";
    for ($i=1; $i<=$#$Command_Format; ++$i){
	if (defined $Affected_Mcode_fields{ $$Command_Format[$i]{'fname'} }){
	    $bin_mcode_line .= sprintf ("%s",$Affected_Mcode_fields{ $$Command_Format[$i]{'fname'} });
	}
	else{

	    # print "$$Command_Format[$i]{'fname'} field is not in affected mcode fields array!!!!\n";
	    # print "the default value for this field is $$Command_Format[$i]{'default'}   !!!!\n";
	    # print "the width of this field is $$Command_Format[$i]{'wd'}   !!!!\n";
	    if (!defined $$Command_Format[$i]{'default'}){
		die "In output to files, no default for field <<$$Command_Format[$i]{'fname'}>> in command $Command_Format\nExiting!!!\n";
	    }
	    $v = $$Command_Format[$i]{'default'};
	    $w = $$Command_Format[$i]{'wd'} ;
	    $bin_mcode_line .= sprintf ("%s",&dec2bintc($v,$w));
	}
    }


    $bin_mcode_line =~ s/_+$//;   # chop trailer ___
    $bin_mcode_line_ref = $bin_mcode_line;
    $hex_mcode_line =  $bin_mcode_line;
    $hex_mcode_line =~ s/_+//g;
    $hex_mcode_line =~ s/z/0/g;
    $hex_mcode_line_xilinxs = &bin2hex("000000".$hex_mcode_line);
    $hex_mcode_line         = &bin2hex($hex_mcode_line);
    $hex_mcode_line_ref     = $hex_mcode_line;

    $bin_mcode_line  = sprintf( "%-28s// (%5d) %6s %-12s %-35s // %-s\n",
				$bin_mcode_line,$pc_num, $hex_mcode_line, $command_name,$line, $comment);
    $hex_mcode_line  = sprintf( "%-10s// (%5d) %-12s %-35s // %-s\n",
				$hex_mcode_line,$pc_num, $command_name,$line, $comment);
    $hex_mcode_line_xilinxs  = sprintf( "%-10s// (%5d) %-12s %-35s // %-s\n",
				$hex_mcode_line_xilinxs,$pc_num, $command_name,$line, $comment);


    print $hex_file_xilinxs "$hex_mcode_line_xilinxs";
    print $bin_file     "$bin_mcode_line";

    print $hex_file     "$hex_mcode_line";

    printf($bin_file_vhdl "%5d => \"%s\", \n", $pc_num, $bin_mcode_line_ref);

    printf($hex_file_ocp_stim "ocp_write(`SCS_GPR0, 16'h%4s); // %s",  substr($hex_mcode_line_ref,4,4), $bin_mcode_line);
    printf($hex_file_ocp_stim "ocp_write(`SCS_GPR0, 16'h%4s); // %s\n", substr($hex_mcode_line_ref,0,4), $hex_mcode_line_ref);

    printf($hex_file_16bits_clean "%4s\n",  substr($hex_mcode_line_ref,4,4));
    printf($hex_file_16bits_clean "%4s\n",  substr($hex_mcode_line_ref,0,4));


    print $tmp_file "\t$pc_num $bin_mcode_line";
    print $tmp_file "\t$pc_num $hex_mcode_line";

    $pc_string = sprintf("%5d",$pc_num);
    # trying to put the comments in the display line
    if ($comment =~ /\S+/){
	$comment = "// $comment";
    } 
    # $line_comment = "$line $comment";
    $line_comment = sprintf("%-30s %s", $line, $comment);
    # $line_comment =~ /^(.{0,50})(.*)$/;
    $line_comment =~ /^(.{0,80})(.*)$/; # trying to widen the xdisplay line  28/07/05
    if (length($2) > 0){
	$line_comment = "$1 ...";
    }
    # the display that goes in include 
    $verilog_display_cmd = "\t$pc_string\t:\$display(\"pc = $pc_string :\\t $line_comment\");";
    print  $display_file "$verilog_display_cmd\n"; 
    $verilog_display_cmd = "\t$pc_string\t:\$fdisplay( mcm_log_file, \"pc = $pc_string :\\t $line_comment\");";
    print  $fdisplay_file "$verilog_display_cmd\n"; 

    # generating memory view for display file, to avoid compilation after microcode change
    # $verilog_display_cmd =  "$pc_string : $line_comment";
    $verilog_display_cmd =  "$line_comment";
    # $verilog_display_cmd = sprintf("%-60s", $verilog_display_cmd);
    $verilog_display_cmd = sprintf("%-90s", $verilog_display_cmd); # trying to widen the xdisplay line  28/07/05
    my($hex_display, $len);
    $len = length($verilog_display_cmd);
    # $hex_display = unpack('H120',$verilog_display_cmd);
    $hex_display = unpack('H180',$verilog_display_cmd); # trying to widen the xdisplay line  28/07/05
    # print $display_file_hex "$hex_display\n";
    print $display_file_hex "$hex_display //$len $pc_string : $verilog_display_cmd\n";
    

}
##################################################################
##################################################################
##################################################################

sub evaluate_statistics{

    my($ref) = shift @_;
    my (%Command_histogram) = %$ref;
    my($Last_PC) = shift @_;
    my $Command_type ;

    
    # foreach $Command_type (@Commands_List){
    foreach $Command_type (keys %{$G_regexp{commands}}){
	if (! defined $Command_histogram{$Command_type}){
	    $Command_histogram{$Command_type}=0;
	}
	$Command_histogram_1{ sprintf("%04d_%-s",$Command_histogram{$Command_type},$Command_type)} = $Command_type;
	# printf("%-20s%4d\n",$Command_type,$Command_histogram{$Command_type});
    }
    print "\n\nCode contains $Last_PC micro-code lines\n\n";

    foreach $key (reverse sort (keys %Command_histogram_1)){
	$tmp = $key;
	$Command_type = $Command_histogram_1{$key };
	$tmp =~ m/^(\d+)/;
	$count = $1;
	printf("%-20s%4d  ",$Command_type,$count );
	for ($i=0; $i< int(50*$count/$Last_PC); $i++){
	    print "*";
	}
	print "\n";
    }	
    
    print "\n\n";
#    @tmp = reverse sort (keys %Command_histogram_1);
#    print "@tmp\n";

}


##################################################################
##################################################################
##################################################################
sub get_label{

    $label_seed =~ s/_//g;
    ++$label_seed;
    $label_seed =~ s/Lbranch(\w+)/"L_branch_$1"/e;

    return ( $label_seed);
}
##################################################################
##################################################################
##################################################################
sub get_wait_label{
    my($wait_label_seed) = shift @_;
    $wait_label_seed =~ s/_//g;
    ++$wait_label_seed;
    $wait_label_seed =~ s/Lwait(\w+)/"L_wait_$1"/e;

    return ( $wait_label_seed);
}


##################################################################
##################################################################
##################################################################
sub gen_header{

    my($array_name) = @_;
    my($i,$header,$j,$space,$label,$var_name,$format,$legend,$bar,$total_wd);

    $i=0;
    $header ="";  
    for ($i=0; $i<=$#$array_name; ++$i){
	# $header .= sprintf( "// ");
	for ($j=0; $j<=$i; ++$j){
	    #print "$labels[$j] ====";
	    $space    = $$array_name[$j]{wd};
	    $label    = $$array_name[$j]{comment};
	    $var_name = $$array_name[$j]{name};
	    # print "\n$space, $label, $var_name\n";
	    if ($j<$i){
#	    $format = "%$space"."s |";
		$format = "|%$space"."s ";
		$header .= sprintf( $format, "");
	    }
	    else{
		#$format = "%$space"."s|";
		$header =~ s/\|$//;
		$header .= sprintf("%-s\n",$label);
	    }
	}
    }

    #  print "$header\n";
    $legend = "";
    $bar = "";
    $total_wd =0;
    for ($i=$#$array_name; $i>=0; $i--){
	$space    = $$array_name[$i]{wd};
	$label    = $$array_name[$i]{comment};
	$var_name = $$array_name[$i]{name};
	$total_wd += $space;
	$space +=2;
	$format = "%-$space"."s";

	$legend = sprintf( $format, $total_wd-1). $legend;
	$bar    = sprintf( $format, "|"). $bar;
    }
    
    
    $header = $header.$bar."\n".$legend."\n$bar\n";
    
    return $header;
    
}
##################################################################
##################################################################
##################################################################
sub gen_width_array{

    my(@labels) = @_;
    my($i,$space,$label,$var_name,%widths);

    for ($i=0; $i<=$#labels; ++$i){
	($space, $label, $var_name) = split(/\s*\/\/\s*/, $labels[$i]);
	$widths{$var_name} = $space;

    }

    return (%widths);
    
}
##################################################################
##################################################################
##################################################################
sub gen_field_names_array{

    my(@labels) = @_;
    my($i,$space,$label,$var_name,@field_names);

    for ($i=0; $i<=$#labels; ++$i){
	($space, $label, $var_name) = split(/\s*\/\/\s*/, $labels[$i]);
	$field_names[$i] = $var_name;

    }
    return (@field_names);
}



1;
