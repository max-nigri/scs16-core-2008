#!/usr/local/bin/perl 

BEGIN {
#      $zorba=1;
#      if ($zorba){
#  	$base_dir     = 'C:\Designs\Products\new_mcm\MCM_ASM\\';  # gsdgdsg
#      }
#      else{
#  	$base_dir     = '/home/x00xmaxn/mcm_eval/MCM_ASM/';
#      }

    #define BASE_DIR 'C:\Designs\Products\new_mcm\MCM_ASM\\'
    $all_requires = #BASE_DIR."all_requires.pl";
    require 'C:\Designs\Products\new_mcm\MCM_ASM\all_requires_zorba.pl'; # $all_requires;

    # $base_dir     = 'C:\Designs\Products\new_mcm\MCM_ASM\\';  # gsdgdsg
    # $all_requires = $base_dir."all_requires.pl";
    
    # require $all_requires;
    # $jj= "generic_subs.pl";
    # require 'generic_subs.pl';
}
# foreach $v (10, 0, -1, -10, -8, "5'h4"){
for ($v=0; $v<20; $v++ ){
    for ($w=5; $w<20; $w++ ){
	($success,   $bin) = &parse_const_new1($v,$w,'tc');
	printf("%-20s,  %d, %20s %20s\n", $v, $success,$bin, &bin2hex($bin));
    }
}

foreach $c (a, b, c, d){
    # $ch = chr($c);
    printf("%s %d %02x\n", $c,ord($c), 65);
}
$str = "hello world";
@a =unpack('C*', $str);
$str = "hello world   ";
@b =unpack('H40@', $str);
print "$str @a\n";
print "$str @b\n";

print "bin2dec\n";
foreach $v ( '01', '0', '111' , '1', '10101010101'){
    $a=&bin2dec($v);
    print "$v $a\n";
}
exit -1;
