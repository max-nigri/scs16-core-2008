
#  $a = 0x312;
#  $b = 2;
#  $c = $a<<$b;
#  printf("%x %x %x\n", $a, $b, $c);

$label_seed = "L_branch_aaa";
$label2pc{'L_intr_routine'} = 2047;	# label2pc: associtive array  
$label2pc{'L_debug_routine'} = 2046;

$debug=0;

if ($#ARGV < 0){
    &print_command_help;
    print "\n\tPlease provide a statement for translation ...\n";
    exit -1;
}
else {
    $codes[0] = "@ARGV";
    $codes[0] =~ s|//(.*)$||; # 
    $comments[0] = $1;
}

print "\nCompiling lines ......\n\n";



$j=0;



while ($j<=$#codes){
    if ($codes[$j] eq ""){
	$for_print = sprintf("// %-s  \n",$comments[$j] );
	print "$for_print";
	$j++;
	next;
    }

    $comment ="";		# if line is not empty
    $line ="";
    $no_other_fields =0;

    print "\n\nThe whole line is :$codes[$j] \n";
    # @statements            = split(/\s*,\s*/,$codes[$j]);		# here: includes only one element
    # @pre_assign_statements = split(/\s*,\s*/,$codes[$j]);	# code before replacing assign
    # replacing the staement separator from , to ; 
    @statements            = split(/\s*;\s*/,$codes[$j]);		# here: includes only one element
    @pre_assign_statements = split(/\s*;\s*/,$codes[$j]);	# code before replacing assign
    if ($#statements >0){	# has meening only if line includes more than one command
	print "=== New command : found $#statements,  @statements ==== \n";
    }
    $k=0;


    while ($k <= $#statements){
	$cmd = $statements[$k];
	$pre_assign_statements[$k] =~ s/^\s*//;
	$pre_assign_statements[$k] =~ s/\s*$//;
    
	print "\nScanning for best match command .....\n";

	$Command_type = &sort_statment($cmd);		# get the best match command
	++$Command_histogram{$Command_type};		# inc histogram of current command
	$Last_PC = $pc_nums[$j];			# pc of current command			

	if ($k >=1){	# for multy statment line
	    $line .= sprintf(", %s",$pre_assign_statements[$k]);
	}
	else{
	    $line .= sprintf("%s",$pre_assign_statements[$k]);
	}

	$k++;

	undef %Affected_Mcode_fields;			# clear Affected_Mcode_fields


	$Command_Format_array  = "G_$Command_type"."_Command_Format";
	$subroutine_name = "parse_cmd_\L$Command_type";	# build string of sub-routoine name
	# print "$Command_Format_array $subroutine_name\n";
	
	($success , $h_ref) = &$subroutine_name($cmd ,0);	# $h_ref is a pointer to the assoc. array that holds the mcode fields
	%Affected_Mcode_fields = %$h_ref;
	if ($success == 1) {
	    $Command_Format = $Command_Format_array;
	    print "Command is : $Command_Format\n";
	    print_assoc(%Affected_Mcode_fields);
	    last;
	}
	
	
	if ($success == 0){
	die "\07
###############################################################
###############################################################
              Statement Unknown !!!!
###############################################################
###############################################################
";
    }
	
    }  # end of while statements over the line 

#    &output_to_files(\%Affected_Mcode_fields, $Command_Format,$pc_nums[$j],$comments[$j],$line,
#		     MCODE_TXT,MCODE_TXT_HEX,MCODE_DISPLAY,MCODE_FDISPLAY,MCODE_XDISPLAY_HEX,MCODE_TMP);
    &output_to_files(\%Affected_Mcode_fields, $Command_Format,$pc_nums[$j],$comments[$j],$line,
		     STDOUT,
		     MCODE_TXT_HEX,
		     MCODE_DISPLAY,
		     MCODE_FDISPLAY,
		     MCODE_XDISPLAY_HEX,
		     MCODE_TXT_HEX_XILINXS,
		     MCODE_TXT_VHDL_ARRAY,
		     MCODE_TXT_OCP_STIM,
		     MCODE_TXT_16BITS_CLEAN,
		     MCODE_TMP);
		     # STDOUT,MCODE_TXT_HEX,MCODE_DISPLAY,MCODE_FDISPLAY,MCODE_XDISPLAY_HEX,MCODE_TXT_HEX_XILINXS,MCODE_TMP);
    
   

    $j++;
}

	print "
###############################################################
###############################################################
              Go Go Go  => OK !!!!
###############################################################
###############################################################
";
    

# &evaluate_statistics(\%Command_histogram, $Last_PC);


exit -1;

