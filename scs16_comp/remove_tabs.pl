#!/usr/local/bin/perl
 
use Text::Tabs;
open(IN_FILE , $ARGV[0]) || die "can not open $ARGV[0] for reading! existing\n"; 
while(<IN_FILE>){
# while(<STDIN>){
    $expanded_line = expand($_);
    print "$expanded_line";
}

 
