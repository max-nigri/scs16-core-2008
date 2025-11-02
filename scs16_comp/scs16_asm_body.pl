
if ($#ARGV == 0){
    $script_file_name = shift(@ARGV);		# $f1 gets input file name

}
else{
    # &print_command_help;
    print "\nShould supply your code file name ...

\tscs16_asm.pl  <<user script file>>\n";
    exit 0;
    # die;
}
#################################################################
#nadav code
my $base;
$base=basename($script_file_name);
$dir=dirname($script_file_name);

if ( -e "out" ) {
    print "directory out exist...\n";
    if ( chdir("out") == 1) {
	print "changed dir to dir out..\n";
    }
    else {
	die "fail to changed dir to dir out..\n";
    }
}
else {
    if ( mkdir("out") == 1) {
	print "directory out created...\n";
	if ( chdir("out") == 1) {
	    print "changed dir to dir out..\n";
	}
	else {
	    die "fail to changed dir to dir out..\n";
	}
    }
    else {
	die "fail to create directory out ...\n";
    }
}
	
	
print "$script_file_name, $base, $dir,\n";

##################################################################
$label_seed      = "L_branch_aaa";
$wait_label_seed = "L_wait_dfhfdaaa";
$label2pc{'L_interupt_routine'} = 2; # 911 ;
$label2pc{'L_debug_routine'}    = 4; # 910;
$label2pc{'L_hard_break_code'}    = 3; # 909;
print "Starting with the following labels :\n\tlabel_seed = $label_seed \n\t$wait_label_seed = $wait_label_seed\n";
# $wait_label_seed = &get_wait_label($wait_label_seed);


######################################################################################
######################################################################################
# zero pass, spliting the input file to two arrays, @codes @comments
######################################################################################
######################################################################################
print "Reading input file ......\n";
$script_file_name_orig = "..$file_delimiter".$script_file_name;
print "Reading input file .....  $script_file_name_orig ....\n";
# exit -1; 

#########################################################################
#nadav code
$script_file_name = $base;
#########################################################################
$script_file_name      =~ s/\.scs$//;
$f0="$script_file_name.0";
($ref1,$ref2,$ref3) = &read_script_file($f0,$script_file_name_orig);
@codes    = @$ref1;
@comments = @$ref2;
@codes_for_presentation    = @$ref3;
$n = @codes;
print "\tResulted $n new code lines\n";
$n = @codes_for_presentation;
print "\tResulted $n new code lines for presentation\n";
$n = @comments;
print "\tResulted $n new comment lines\n";
######################################################################################
######################################################################################
if (0){
    print "Pre-Processing debug statement ......\n";
    ($ref1,$ref2) = &preprocess_debug_statement( \@codes, \@comments);
    @codes    = @$ref1;
    @comments = @$ref2;
    $n = @codes;
    print "\tResulted $n new code lines\n";
    $n = @codes_for_presentation;
    print "\tResulted $n new code lines for presentation\n";
    $n = @comments;
    print "\tResulted $n new comment lines\n";
}
######################################################################################
######################################################################################
# first pass, inserting zero_flag = Rx[y]/cond_bit == \S+ before if ( )
# Supporting if ( condition_bit/Rx[y] ) L_label
# Supporting goto L_label
######################################################################################
######################################################################################

print "Pre-Processing flow control ......\n";
$f1="$script_file_name.1";
($ref1,$ref2,$ref3,$ref4) = &preprocess_flow_control($f1, \@codes, \@comments, \@codes_for_presentation, 0);
@codes    = @$ref1;
@comments = @$ref2;
@codes_for_presentation    = @$ref3;
%cln2oln  = %$ref4;
$n = @codes;
print "\tResulted $n new code lines\n";
$n = @codes_for_presentation;
print "\tResulted $n new code lines for presentation\n";
$n = @comments;
print "\tResulted $n new comment lines\n";

# exit -1;
######################################################################################
# second pass, translating if, else, elsif construct to branch with lables
######################################################################################
print "Processing flow control ......\n";
$f2="$script_file_name.2";
$ref1 = &parse_flow_control($f2,\@codes);
@codes = @$ref1;
$n = @codes;
print "\tResulted $n new code lines\n";

######################################################################################
# third pass, generate string which defined pc_inc
######################################################################################
print "Processing pc labels ......\n";
$f3="$script_file_name.3";
($ref1, $ref2, $ref3) = &process_pc_labels( $f3, \@codes, \%label2pc);
@codes = @$ref1;
@line2pc = @$ref2;
%label2pc = %$ref3;

$n = @codes;
print "\tResulted $n new code lines\n";
$n = @line2pc;
print "\tResulted $n length line2pc array\n";

######################################################################################
# forth pass, defines resolve pass, translating define  i R1
######################################################################################
print "Processing defines ......\n";
$f4="$script_file_name.4";
@pre_assign_codes = @codes;
# @codes = &translate_assigns(@codes);
$ref1 = &translate_defines_new1($f4, \@codes);
@codes = @$ref1;
$n = @codes;
print "\tResulted $n new code lines\n";

######################################################################################
######################################################################################
$f5="$script_file_name.5";
open(MCODE_TMP,     ">$f5")                     || die "Cant open $f5 for writing  ... Exiting\n";

$o_fname = $script_file_name."_mcode_b.v";
open(MCODE_TXT,     ">$o_fname")                || die "Cant open $o_fname for writing  ... Exiting\n";
$o_fname = $script_file_name."_mcode_hex.v";
open(MCODE_TXT_HEX,  ">$o_fname")               || die "Cant open $o_fname for writing  ... Exiting\n";
$o_fname = $script_file_name."_mcode_display.v";
open(MCODE_DISPLAY,  ">$o_fname")               || die "Cant open $o_fname for writing  ... Exiting\n";
$o_fname = $script_file_name."_mcode_fdisplay.v";
open(MCODE_FDISPLAY,  ">$o_fname")              || die "Cant open $o_fname for writing  ... Exiting\n";
$o_fname = $script_file_name."_mcode_xdisplay_hex.v";
open(MCODE_XDISPLAY_HEX,   ">$o_fname")         || die "Cant open $o_fname for writing  ... Exiting\n";
$o_fname = $script_file_name."_mcode_hex.mem";
open(MCODE_TXT_HEX_XILINXS, ">$o_fname")        || die "Cant open $o_fname for writing  ... Exiting\n";

$o_fname = $script_file_name."_mcode_array.vhdl";
open(MCODE_TXT_VHDL_ARRAY, ">$o_fname")        || die "Cant open $o_fname for writing  ... Exiting\n";
$o_fname = $script_file_name."_ocp_mcode_fill.v";
open(MCODE_TXT_OCP_STIM, ">$o_fname")        || die "Cant open $o_fname for writing  ... Exiting\n";
$o_fname = $script_file_name."_mcode_16bits_clean.dbg";
open(MCODE_TXT_16BITS_CLEAN, ">$o_fname")        || die "Cant open $o_fname for writing  ... Exiting\n";
print MCODE_TXT_16BITS_CLEAN "// plain code, two lines for instruction : first [15:0] second [31:16] where [28:16] are valid\n";
#######################################################################################
#Nadav code
$o_fname = $script_file_name."_pc_line";
open(LINE_2_PC, ">$o_fname")        || die "Cant open $o_fname for writing  ... Exiting\n";
print LINE_2_PC "// two colums : pc vs source code line number\n"; 
#######################################################################################

print "Compiling lines ......\n";
print "\tResults may be seen in $f5 file\n";
print MCODE_TMP "Compiling lines .... Statement clasification and translation\n";

print MCODE_TXT_HEX_XILINXS "\@0000\n";


$j=0;
$Last_PC = 0;
$total_code_lines = @codes;
$current_threshold = 10;
while ($j<=$#codes){
    $original_line_number = $cln2oln{$j};
    if ($j*100/$total_code_lines > $current_threshold){
	printf("\tProgress : %3d\%\n", int($j*100/$total_code_lines));
	$current_threshold = $current_threshold +10;
    }
    if ($codes[$j] eq ""){
	$for_print = sprintf("// %-s  \n",$comments[$j] );
	print MCODE_TXT "$for_print";
	print MCODE_TXT_HEX "$for_print";
	print MCODE_TXT_HEX_XILINXS "$for_print";
	$j++;
	next;
    }
    $comment ="";		# if line is not empty
    $line ="";

    printf( MCODE_TMP "\n###### Line no: %4d #### line is : %s\n",$original_line_number, $codes[$j]);
    # replacing the staement separator from , to ;
    @statements            = split(/\s*;\s*/,$codes[$j]);		# here: includes only one element
    @pre_assign_statements = split(/\s*;\s*/,$pre_assign_codes[$j]);	# code before replacing assign
    if ($#statements >0){	# has meening only if line includes more than one command
	print "=== New command : found $#statements,  @statements ==== \n";
    }
    $k=0;


    while ($k <= $#statements){
	$cmd = $statements[$k];
	$pre_assign_statements[$k] =~ s/^\s*//;
	$pre_assign_statements[$k] =~ s/\s*$//;

	print MCODE_TMP "\tScanning for best match command .....\n";

	$Command_type = &sort_statment($cmd);		# get the best match command
	print MCODE_TMP "\tMatching command is : $Command_type\n";

	++$Command_histogram{$Command_type};		# inc histogram of current command
	$Last_PC  = $line2pc[$j];			# pc of current command

	if ($k >=1){	# for multi statment line
	    $line .= sprintf(", %s",$pre_assign_statements[$k]);
	}
	else{
	    $line .= sprintf("%s",$pre_assign_statements[$k]);
	}

	$k++;

	undef %Affected_Mcode_fields;			# clear Affected_Mcode_fields


	$Command_Format_array  = "G_$Command_type"."_Command_Format";
	$subroutine_name = "parse_cmd_\L$Command_type";	# build string of sub-routoine name

	$old_fh = select(MCODE_TMP);
	($success , $h_ref) = &$subroutine_name($cmd, $original_line_number);	# $h_ref is a pointer to the assoc
	$old_fh = select(STDOUT);

	%Affected_Mcode_fields = %$h_ref;
	if ($success == 1) {
	    $Command_Format = $Command_Format_array;
	    print MCODE_TMP "\tSuccessfull command parsing.....\n";
	    foreach $field (keys %Affected_Mcode_fields){
		printf(MCODE_TMP "\t%-20s => %s\n",$field, $Affected_Mcode_fields{$field});
	    }
	    last;
	}
	elsif ($success == 0){
	    die "\07
###############################################################
###############################################################
  Fail to parse Statement at line : $original_line_number << $cmd >> !!!!
###############################################################
###############################################################
";
	}

    }  # end of while statements over the line
    # print "these are the comments :$comments[$j]\n";
############################################################################
#Nadav code
    print LINE_2_PC " $line2pc[$j] \t $original_line_number \n";
############################################################################
    &output_to_files(\%Affected_Mcode_fields, $Command_Format,$line2pc[$j],$comments[$j],$line,
		     MCODE_TXT,
		     MCODE_TXT_HEX,
		     MCODE_DISPLAY,
		     MCODE_FDISPLAY,
		     MCODE_XDISPLAY_HEX,
		     MCODE_TXT_HEX_XILINXS,
		     MCODE_TXT_VHDL_ARRAY,
		     MCODE_TXT_OCP_STIM,
		     MCODE_TXT_16BITS_CLEAN,
		     MCODE_TMP);

    $j++;
}

@compiler_additional_code = (
			     {
				 address => '0004', # '038d',
				 command => "goto  $label2pc{'L_debug_routine'}",
				 comment => 'Debug pointer',
			     },
			     {
				 address => '0003', # '038e',
				 command => "goto  $label2pc{'L_hard_break_code'}",
				 comment => 'Hard Break pointer',
			     },
			     {
				 address => '0002', # '038f',
				 command => "goto  $label2pc{'L_interupt_routine'}",
				 comment => 'Interrupt pointer',
			     },
			     );
undef @compiler_additional_code; # to eliminate compiler insertion of additional commands
foreach $ref1 (@compiler_additional_code){
    %statement_hash = %$ref1;
    $address_hex= $statement_hash{address};
    $cmd        = $statement_hash{command};
    $comment    = $statement_hash{comment};
    $address_dec = hex $address_hex;
    print MCODE_TMP "\n###### Compiler added #### line is :$cmd\n";
	$old_fh = select(MCODE_TMP);
    ($success , $h_ref) = &parse_cmd_jump($cmd);
    $old_fh = select(STDOUT);

    %Affected_Mcode_fields = %$h_ref;
    if ($success == 1) {
	print MCODE_TMP "\tSuccessfull command parsing.....\n";
	foreach $field (keys %Affected_Mcode_fields){
	    printf(MCODE_TMP "\t%-20s => %s\n",$field, $Affected_Mcode_fields{$field});
	}
	$Command_Format = G_JUMP_Command_Format;
    }

    print MCODE_TXT     "\@$address_hex\n";
    print MCODE_TXT_HEX "\@$address_hex\n";
    print MCODE_TXT_HEX_XILINXS "\@$address_hex\n";
    print MCODE_XDISPLAY_HEX "\@$address_hex\n";

    &output_to_files(\%Affected_Mcode_fields, $Command_Format,$address_dec,$comment,$cmd,
		     MCODE_TXT,
		     MCODE_TXT_HEX,
		     MCODE_DISPLAY,
		     MCODE_FDISPLAY,
		     MCODE_XDISPLAY_HEX,
		     MCODE_TXT_HEX_XILINXS,
		     MCODE_TXT_VHDL_ARRAY,
		     MCODE_TXT_OCP_STIM,
		     MCODE_TMP);

    # print "gggg $address_hex, $address_dec, $cmd\n";
}
###########################################################
#nadav code 
close LINE_2_PC;
###########################################################
close MCODE_TXT;
close MCODE_TXT_HEX;
close MCODE_DISPLAY;
close MCODE_FDISPLAY;
close MCODE_XDISPLAY_HEX;
close MCODE_TMP;
close MCODE_TXT_HEX_XILINXS;
close MCODE_TXT_VHDL_ARRAY;
close MCODE_TXT_OCP_STIM;

printf("\tProgress : %3d\%\n", 100);

	print "
###############################################################
###############################################################
              Go Go Go  => OK !!!!
###############################################################
###############################################################
";


&evaluate_statistics(\%Command_histogram, $Last_PC);


exit -1;



##################################################################
##################################################################
##################################################################
