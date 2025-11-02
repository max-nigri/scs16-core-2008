sub parse_cmd_alui{
# R1 = R2 - R3 or R1 = R2 -5 or  eq_flag = R3 == R4....

    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my (@tmp,$tmp);
    my ($v, $w);
    my %Affected_Mcode_fields;
    my $q ='"';
    my $regexp;
    my ($i, $key);
    my $success, $bin;
    my ($lvalue, $Ra, $Rb,$op);
    my ($dig,$reg,$case,$imd,$swap,$neg);  #if dig or reg eq 1 its negativ else pos
    my ($reg_w,$imd_w,$swap_w,$neg_w,$op_w,$lvalue_w);
    my $modi612=0;
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    # return (0, \%Affected_Mcode_fields);
    print "\tProbably ALUI command : $cmd\n";
   
    $neg=$G_ALUI_Command_Format{'is_neg'}->{'default'};
    $swap=$G_ALUI_Command_Format{'is_neg'}->{'default'};

    # if ($cmd =~ s/$G_ALUI_Command_Format{'regexp'}->{'code'}//){
    #              R
    if($cmd =~ s/(\S+)\s*=\s*([\+-]?[a-zA-Z]\w+)\s*(>|<|>>|<<|\||&|==|\+|-|<=|>=|\^)\s*([-]?\d\S*)//){
	$lvalue = $1;
	$Ra = $2;
	$op = $3;
	$Rb = $4;
	$Affected_Mcode_fields{'swap'}= &dec2bintc(1,1);
	#print"\n a  $1 , $2 , $3 , $4 \n";
    }
    elsif ($cmd =~ s/(\S+)\s*=\s*([-\+]?\s*\d\S*?)\s*(>|<|>>|<<|\||&|==|\+|-|<=|>=|\^)\s*([-]?R\d)//) {


	$lvalue = $1;
	$Ra = $2;
	$op = $3;
	$Rb = $4;
	$Affected_Mcode_fields{'swap'}= &dec2bintc(0,1);
	#print"\n b  $1 , $2 ,$3, $4 \n";
    }
    else {
	print "In ALUI command, << $cmd_org >>, syntax error!!, syntax should look like \n\n";
	&print_command_example('G_ALUI_Command_Format');
	print"can not parse this Alui command  ";
	die "Exiting!!!\n";
    }
###########################################################################################
####### Modified by nadav to seporet the hexa and bin val of 8 bit in the lest or rhit side but not neg
####### 06.12.03
######################################################################################### 

    if ($Ra =~ /([-]?\d+\'(h|b)\w+)/ ){
	if($Ra =~ s/-//){
	    $modi612=1;
	}
	($success, $bin) = &parse_const_new1($Ra ,8,'tc');
	if ($success==0) {
	    print "In Alui command! << $cmd_org >> Fail to parse the val of Ra $Ra\n";
	    die "Exiting !!!\n";
	}
	$Ra=&bin2dec($bin);
	if($modi612){
	    $Ra=$Ra-(2 * $Ra);
	}
    }

    elsif ($Rb =~ /(\d+\'(h|b)\w+)/ ){
	if($Rb =~ s/-//){
	    $modi612=1;
	}
	($success, $bin) = &parse_const_new1($Rb ,8,'tc');
	if ($success==0) {
	    print "In Alui command! << $cmd_org >> Fail to parse  the val of Rb $Rb\n";
	    die "Exiting !!!\n";
	}
	$Rb=&bin2dec($bin);
    }
    #else the imd is a dec to start with

#########################################################################################
#######06.12.03
#############################################################################################
    if ($op eq '-'){  #to avoid R5=4--R2 
	if($Rb =~ /^-\S+/){
	    print "In ALUI command, << $cmd_org >>, syntax error!!, syntax should look like \n\n";
	    &print_command_example('G_ALUI_Command_Format');
	    print"can not use --, <R5=4--R2> is not legal\n";
	    die "Exiting!!!\n";
	}
    }
    

#the next part check is the register in pos or neg 
  
    $reg="5";
    $dig="5";
    $case=0;  #used for + - > < ==

    if($op =~ /^(\+|-)$/ ){ #this if is for + -  when we can have neg and swap
	if ($Ra =~ /[\+-]?R[0-7]\s*/){
	    if ($Ra =~ /-R[0-7]\s*/){
		#print"\nra $Ra is a neg register";
		$reg=1;
	    }
	    else{
		#print"\nra $Ra is a pos register";
		$reg=0;
	    }
	}
	
	if ($Rb =~ /[\+-]?R[0-7]\s*/){
	    if ($op eq "-"){
		#print"\nrb $Rb is a neg register";
		$reg=1;
	    }
	    elsif ($Rb =~ /-R[0-7]\s*/){   # for < > op
		#print"\nra $Rb is a neg register";
		$reg=1;
	    }
	    elsif ($Rb =~ /R[0-7]\s*/){
		#print"\nrb $Rb is a pos register";
		$reg=0;
	    }
	}
	#the next part check is the digit in pos or neg    
	if ($Ra =~ /^[\+\-]?\d\s*/){
	    if ($Ra =~ /-\d+\s*/){
		#print"\nra $Ra is a neg digit";
		$dig=1;
	    }
	    else{
		#print"\nra $Ra is a pos digit";
		$dig=0;
	    }
	}
	if ($Rb =~ /^[\+-]?\d\S*/){
	    if ($op eq "-"){
		#print"\nra $Rb is a neg digit";
		$dig=1;
	    }
	    elsif ($op eq "+"){
		#print"\nrb $Rb is a pos digit";
		$dig=0
		}
	    elsif($Rb =~ /^[-]\d\S*/){     # for < > op old 
		#print"\nra $Rb is a neg digit";
		$dig=1;
	    }
	    else{
		$dig=0;
	    }
	}
	
    }

    elsif($op =~ /^(<|>|==|<=|>=)$/){
	if ($Ra =~ /[\+-]?R[0-7]\s*/){
	    if ($Ra =~ /-R[0-7]\s*/){
		if ($Rb =~ /^[-]\d\S*/){
		    $case=11; #R=-R>-4
		}
		else{
		    $case=9;  #R=-R>4
		}
	    }
	    elsif ($Rb =~ /^[-]\d\S*/){
		$case=7;
	    }
	    else{
		$case=5;
	    }
	}
	elsif ($Ra =~ /[\+-]?\d\S*/){
	    if ($Ra =~ /^[-]\d\S*/){
		if ($Rb =~ /-R[0-7]\s*/){
		    $case=12;
		}
		else{
		    $case=8;
		}
	    }
	    elsif($Rb =~ /-R[0-7]\s*/){
		$case=10;
	    }
	    else{
		$case=6;
	    } 
	}
    }

    
    elsif ($op =~ /^(<<|>>)$/){
	if ($Rb =~ /-\S*/){
	    print "In ALUI command, << $cmd_org >>, syntax error!!, syntax should look like \n\n";
	    &print_command_example('G_ALUI_Command_Format');
	    print"right side can not be negative in << or >>.\n";
	    die "Exiting!!!\n";
	    
	}
	if ($Ra =~ /-R[0-7]/){
	    print "In ALUI command, << $cmd_org >>, syntax error!!, syntax should look like \n\n";
	    &print_command_example('G_ALUI_Command_Format');
	    print"a register on the left side in operation << or >> can not be negative.\n";
	    die "Exiting!!!\n";
	}
    }

    else{
	#print"the oprator must be logi &^|";
	if($Ra =~ /^[-]?R[0-7]$/){
	    $reg=$Ra;
	    $imd=$Rb;
	}
	elsif($Rb =~ /^[-]?R[0-7]$/){
	    $reg=$Rb;
	    $imd=$Ra;
	    
	}
	if($reg =~ /-/){
	    print "In ALUI command, << $cmd_org >>, syntax error!!, syntax should look like \n\n";
	    &print_command_example('G_ALUI_Command_Format');
	    print"in logical operations the register can not be negative.\n";
	    die "Exiting!!!\n";
	}

    }


    #print"\n dig  $dig // reg $reg";
    if ( $op =~ /^(\+|-)$/ ){
	if($dig==1){
	    if($reg==0){
		$case=2;
	    }  
	    elsif($reg==1){
		$case=4;
	    }
	}
	elsif($dig==0){
	    if($reg==0){
		$case=1;
	    }
	    elsif($reg==1){
		$case=3;
	    }
	}
    }
   
    ##the next lines are to put the register in $reg
    if($Ra =~ /^[-]?R[0-7]$/){
	$reg=$Ra;
	$imd=$Rb;
	
    }
    elsif($Rb =~ /^[-]?R[0-7]$/){
	$reg=$Rb;
	$imd=$Ra;
    }
    if ($case==4){ #this is the only case that we have neg = 1
	$imd=-$imd;
    }
#after the case is  determined we clean the - from the reg in the logi opretions - is not valid
    if($op =~ /^(\+|-|<|>|==|<=|>=)$/ ){
	$reg =~ s/-//;
    }
# a check for the immediate value
    if ($imd< -128 || $imd >128){  
	print "In ALUI command, << $cmd_org >>, syntax error!!, syntax should look like \n\n";
	&print_command_example('G_ALUI_Command_Format');
	print"the immediate value must be -128 - 128.\n";
	die "Exiting!!!\n";
    }
    #print"\n---------------\ncase $case";
    if ($case != 0){
	if ($case == 1 ){     # R=R+2 , R=2+R
	    $swap=0;
	    $neg=0;
	    $op=$op;
	}
	if ($case == 2 ){    #R=R-2  , R=-2+R
	    $swap=0;
	    $neg=0;
	    $op='-';
	    if($imd =~ /^[-]\d\S*/){
		$imd=-$imd;
	    }
	}
	if ($case == 3 ){   #R=-R+2 R=2-R
	    $swap=1;
	    $neg=0;
	    $op='-';
	}
	if ($case == 4 ){   #R=-R-2 R=-2-R
	    $swap=1;
	    $neg=1;
	    $op='-';
	    if ( $reg eq $Rb ){ 
		$imd = -$imd;
	    }  
	    
	}
	if ($case == 5){   #F=R>4
	    $swap=0;
	    $neg=0;
	    $op=$op;
	}
	if ($case == 6 ){  #F=4<R
	    $swap=1;
	    $neg=0;
	    $op=$op;
	}
	if ($case == 7 ){   #F=R>-4
	    $swap=0;
	    $neg=1;
	    $op=$op;
	    # $imd=-$imd; 
	}
	if ($case == 8 ){   #F=4<-R
	    $swap=1;
	    $neg=1;
	    $op=$op;
	    #  $imd=-$imd; 
	}
	if ($case == 9 ){   #F=-R>4
	    $swap=1;
	    $neg=1;
	    $op=$op;
	    $imd=-$imd; 
	}
	if ($case == 10 ){  #F=-4<R
	    $swap=0;
	    $neg=1;
	    $op=$op;
	    $imd=-$imd; 
	}
	if ($case == 11 ){   #F=-R>-4
	    $swap=1;
	    $neg=0;
	    $op=$op;
	    $imd=-$imd;

	}
	if ($case == 12 ){   #F=-4<-R
	    $swap=0;
	    $neg=0;
	    $op=$op;
	    $imd=-$imd;
	}
    }
    else{
	#print"the operator is & ^ | >> <<\n";
    }
    if ($reg==5){                     #check R9 R8 ext'  mod 8/12/03
	print "In ALUI command, << $cmd_org >>, syntax error!!, syntax should look like \n\n";
	&print_command_example('G_ALUI_Command_Format');
	print"the register is not a valid one.\n";
	die "Exiting!!!\n";
}

#       ($success, $bin) = &parse_const_new1($b,8,'tc');
#  		    if ($success==0) {
#  			print "In LOADIA command! << $cmd_org >> Fail to parse address offset $b\n";
#  			die "Exiting !!!\n";
#  		    }

   
    $lvalue=$G_ALUI_Command_Format{'dest_reg'}->{'val_hash'}->{$lvalue};
    $reg=$G_ALUI_Command_Format{'rb_sel'}->{'val_hash'}->{$reg};  
    $op=$G_ALUI_Command_Format{'operation'}->{'val_hash'}->{$op};
        
    $neg_w    =$G_ALUI_Command_Format{'is_neg'}->{'wd'};
    $lvalue_w =$G_ALUI_Command_Format{'dest_reg'}->{'wd'};
    $reg_w    =$G_ALUI_Command_Format{'rb_sel'}->{'wd'};
    $op_w     =$G_ALUI_Command_Format{'operation'}->{'wd'};
    $swap_w   =$G_ALUI_Command_Format{'swap'}->{'wd'};
    $imd_w    =$G_ALUI_Command_Format{'Imd'}->{'wd'};



    $Affected_Mcode_fields{'is_neg'}= &dec2bintc($neg,$neg_w);
    $Affected_Mcode_fields{'dest_reg'}= &dec2bintc($lvalue,$lvalue_w);
    $Affected_Mcode_fields{'rb_sel'}= &dec2bintc($reg,$reg_w);
    $Affected_Mcode_fields{'operation'}= &dec2bintc($op,$op_w);
    $Affected_Mcode_fields{'swap'}= &dec2bintc($swap,$swap_w);
    $Affected_Mcode_fields{'Imd'}= &dec2bintc($imd,$imd_w);

    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('ALUI',$cmd_org,$cmd);
    }
 
	
    return ( 1 , \%Affected_Mcode_fields);

}
##################################################################
##################################################################
##################################################################

@G_ALUI_Command_Format = (
    {
	fname => 'regexp',
	code => $G_regexp{ 'commands' }->{ 'ALUI' },
	example => " R5 = 85 - R1 or  eq_flag = R3 == 4, Shifting only on right operand (imd) only byte, Imd signed",
    },
    {
	fname => 'opcode',
	# wd => 5,
	wd => $OPCODE_WIDTH,
	code => 17,
	default => 17,
	comment => "alu immediate command ",
    },
    {
	fname => 'res32',
	wd => 6,
	default => 0,
	
    },
    
    {
	fname => 'reserved',
	wd => 2,
	default => 0,
	
    },
    {
	fname =>'is_neg',
	wd => 1,
	default => 0,
	comment => "is neg",
    },	  
    {
	fname => 'dest_reg',
	wd => 3,
	comment => "selects the register that will get the result",
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
	    eq_flag => 7,  # dont care
	    gr_flag => 7,  # dont care
	    ls_flag => 7,  # dont care
	    eq_ls_flag => 7,  # dont care
	    eq_ls_flag => 7,  # dont care
	},
    },
    {
	fname => 'rb_sel',
	wd => 3,
	comment => "selects the first operand register",
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
	fname => 'operation',
	wd => 3,
	comment => "indicate the operator ",
	val_hash => { 
	    '&'  => 0, 
	    '|'  => 1, 
	    '^'  => 2, 
	    '==' => 3,
	    '>'  => 3,
	    '<'  => 3, 
	    '+'  => 4, 
	    '-'  => 5, 
	    '>>' => 6, 
	    '<<' => 7, 
	    '<=' => 3, 
	    '>=' => 3, 
	    
	},
    },
    {
	fname => 'swap',
	wd => 1,
	comment => "swaps Ra with Imd for asymetric operations, always swaps when imd in the left",
	default => 0,
    },
    {
	fname => 'Imd',
	wd => 8,
	comment => "an signed number -  8 bits width",
	default => 0,
	type => "signed",
	regexp_hash => { 
	    hexadecimal => "8'h([0-9a-f]{2})",
	    binary      => "8'b([01]{8})",
	    decimal     => '\b(-?\d+)$',  # '
	},
    }
    
    );


for $i ( 0..$#G_ALUI_Command_Format ){
    # print "$i $G_ALUI_Command_Format[$i]{fname}\n";
    $G_ALUI_Command_Format{ $G_ALUI_Command_Format[$i]{fname} } = $G_ALUI_Command_Format[$i];
    if ($i != 0) {
	$G_ALUI_Command_Format[$i]{ 'cur_val' } = 'z' x $G_ALUI_Command_Format[$i]{ 'wd' };
    }
    $r = ref $G_ALUI_Command_Format[$i];
    # print " ref is $r\n";
}




1;
