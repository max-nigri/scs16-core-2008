sub parse_cmd_alu{
# R1 = R2 - R3 or R1 = R2 -5 or  eq_flag = R3 == R4....
   
    my($cmd) = shift(@_);
    my($line_num) = shift(@_);
    my $cmd_org = $cmd;
    my $die_msg;
    my ($v, $w);
    my %Affected_Mcode_fields;
  
    my ($i, $key);
    my $success,$bin;
    my ($lvalue, $Ra, $Rb,$op,$temp,$sub_op);

    $sub_op=0;
    $cmd =~ s/^\s*//;
    $cmd =~ s/\s*$//;
    $cmd =~ s/\s*=\s*/=/g;
    $cmd =~ s/\s*->\s*/->/g;

    print "\tProbably ALU command : $cmd\n";
   
    $cmd =~ s/(\S+)\s*=\s*([-]?[a-zA-Z]\w+)\s*(>|<|>>|<<|\||&|==|\+|-|<=|>=|\^)\s*([-]?[a-zA-Z]\S*)//;

    $lvalue = $1;
    $Ra = $2;
    $op = $3;
    $Rb = $4;
          
##############################################################################
#####                  INPUT CHECKS                                     ######
##############################################################################	
   
    if($Ra =~ /\s*-R[0-7]/){      # genral check for the case of R3=-R2-R1 // R3=-R2&-R1
	if(($Rb =~ /\s*-R[0-7]/)||($op eq '-')){
	    $die_msg= "In ALU command, not valid to use [ - ] operator on 2 registers\n";
	    &die_fail_parse('ALU',$line_num,$cmd_org,$die_msg,1,0);
	}
    }
    if(($Rb =~ /\s*R[0-7]\S+\s*/)||($Ra =~ /\s*R[0-7]\S+\s*/)){
	$die_msg="there is a non valid part attached to the registers in Alu command only Rx is valid not Rx_h or Rx_l\n";
	&die_fail_parse('ALU',$line_num,$cmd_org,$die_msg,1,0);
    }
    

    if ($op =~ /(\+|\-)/){ ## + and -
	if ($Ra =~ /-R[0-7]\s*/){  #R4=-R4+R1
	    ($Ra,$Rb)=($Rb,$Ra);
	    $Rb =~ s/-//;
	    $op='-';
	}
    }
    elsif($op =~ /(&|\||\^|<<|>>)/){ ##logi & and | and ^
	if(($Ra =~ /-R[0-7]\s*/) || ($Rb =~ /-R[0-7]\s*/)){ #check r=-r&r r=r&-r
      	    $die_msg="in logical and  >>,<<  operations the register can not be negative.\n";
	    &die_fail_parse('ALU',$line_num,$cmd_org,$die_msg,1,0);
	}
    }
    
    elsif($op =~ /(<|>|==)/){  
	if($Rb =~ /-R[0-7]\s*/){           #r=r2<-r2
	    $sub_op=1;                     #'+'
	    $Rb =~ s/-//;
	}
	elsif($Ra =~ /-R[0-7]\s*/){ #r=-r3<r3
	    $die_msg="in  [ > ==  < ] command register on the left side can not be negative.\n";
	    &die_fail_parse('ALU',$line_num,$cmd_org,$die_msg,1,0);
	}
    }
    else{
	$die_msg="no operator found.\n";
	&die_fail_parse('ALU',$line_num,$cmd_org,$die_msg,1,0);
    }
##############################################################################
#####                   OPCODE   GENRATOR                               ######
##############################################################################    
### sub_op ###
    ($success, $bin) =&parse_const_new1($sub_op,1,'non tc');
    if ($success==0) {
	&die_fail_parse('ALU',$line_num,$cmd_org,"Fail to parse sub_op field\n",1,0);
    }
    $Affected_Mcode_fields{'sub_op'} = $bin;

### operation ###
    if (defined $G_ALU_Command_Format{'operation'}->{'val_hash'}->{$op}){
	$v = $G_ALU_Command_Format{'operation'}->{'val_hash'}->{$op};
	$w = $G_ALU_Command_Format{'operation'}->{'wd'};
	($success, $bin) =&parse_const_new1($v,$w,'non tc');
	if ($success==0) {
	    &die_fail_parse('ALU',$line_num,$cmd_org,"Fail to parse operation field\n",1,0);
	}
	$Affected_Mcode_fields{'operation'} = $bin;
    }
    else{
	&die_fail_parse('ALU',$line_num,$cmd_org,"Fail to parse operation field should be one of:\n",1,'operation');
    }
### ra_sel ###
    if (defined $G_ALU_Command_Format{'ra_sel'}->{'val_hash'}->{$Ra}){
	$v = $G_ALU_Command_Format{'ra_sel'}->{'val_hash'}->{$Ra};
	$w = $G_ALU_Command_Format{'ra_sel'}->{'wd'};
	($success, $bin) =&parse_const_new1($v,$w,'non tc');
	if ($success==0) {
	    &die_fail_parse('ALU',$line_num,$cmd_org,"Fail to parse ra_sel field\n",1,0);
	}
	$Affected_Mcode_fields{'ra_sel'} = $bin;
    }
    else{
	$die_msg="Register is not a valid ,  should be one of :\n";
	&die_fail_parse('ALU',$line_num,$cmd_org,$die_msg,1,'ra_sel');
    }
### rb_sel ###    
    if (defined $G_ALU_Command_Format{'rb_sel'}->{'val_hash'}->{$Rb}){
	$v = $G_ALU_Command_Format{'rb_sel'}->{'val_hash'}->{$Rb};
	$w = $G_ALU_Command_Format{'rb_sel'}->{'wd'};
	($success, $bin) =&parse_const_new1($v,$w,'non tc');
	if ($success==0) {
	    &die_fail_parse('ALU',$line_num,$cmd_org,"Fail to parse rb_sel field\n",1,0);
	}
	$Affected_Mcode_fields{'rb_sel'} = $bin;
    }
    else{
	$die_msg="Register is not a valid ,  should be one of :\n";
	&die_fail_parse('ALU',$line_num,$cmd_org,$die_msg,1,'rb_sel');
    }
### dest_reg ###        
    if (defined $G_ALU_Command_Format{'dest_reg'}->{'val_hash'}->{$lvalue}){
	$v = $G_ALU_Command_Format{'dest_reg'}->{'val_hash'}->{$lvalue};
	$w = $G_ALU_Command_Format{'dest_reg'}->{'wd'};
	($success, $bin) =&parse_const_new1($v,$w,'non tc');
	if ($success==0) {
	    &die_fail_parse('ALU',$line_num,$cmd_org,"Fail to parse rb_sel field\n",1,0);
	}
	$Affected_Mcode_fields{'dest_reg'} = $bin;
    }  
    else{
	$die_msg="Left side not a valid ,  should be one of :\n";
	&die_fail_parse('ALU',$line_num,$cmd_org,$die_msg,1,'dest_reg');
    }

    
    if ($cmd =~ /[^\s]+/) { # catching leftovers
	&die_leftovers('ALU',$cmd_org,$cmd);
    }
      
    return ( 1 , \%Affected_Mcode_fields);
    
}

##################################################################
##################################################################
##################################################################
@G_ALU_Command_Format = (
{
    fname => 'regexp',
   
    
    code => $G_regexp{ 'commands' }->{ 'ALU' },
    example => "Rw|flag = Rx op Ry\n\tExample:R1 = R2 - R1 \n\t\tR1 = R2 >> R1\n\t\tR4 = -R4 + R1\n\t\tR5 = R4 | R1\n\t\teq_flag = R3 == R4\n",  
},
{
    fname => 'opcode',
    # wd => 5,
    wd => $OPCODE_WIDTH,
    code => 10,
    default => 10,
    comment => "alu command ",
},
{
    fname => 'res32',
    wd => 6,
    default => 0,

},
{
    fname => 'ra_sel',
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
	eq_gr_flag => 7,  # dont care
    },
},

{
    fname => 'rb_sel',
    wd => 3,
    comment => "selects the second operand register",
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
    fname => 'sub_op',
    wd => 1,
    default => 0,
    comment => "indicate  the sub oprator in  the case of > < == opratores",
    val_hash => { 
   	'-'  => 0, 
 	'+'  => 1, 
       	
    },
},

{
    fname => 'reserved',
    wd => 8,
    default => 0,

},
);


for $i ( 0..$#G_ALU_Command_Format ){
    # print "$i $G_ALU_Command_Format[$i]{fname}\n";
    $G_ALU_Command_Format{ $G_ALU_Command_Format[$i]{fname} } = $G_ALU_Command_Format[$i];
if ($i != 0) {
    $G_ALU_Command_Format[$i]{ 'cur_val' } = 'z' x $G_ALU_Command_Format[$i]{ 'wd' };
}
$r = ref $G_ALU_Command_Format[$i];
# print " ref is $r\n";
}
##################################################################


1;
