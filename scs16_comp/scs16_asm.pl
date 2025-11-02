#!/usr/local/bin/perl

BEGIN {
    use File::Basename;
    $zorba=1;
    if (defined $ENV{OS}) {
	if ($ENV{OS} eq 'Windows_NT'){
	    $file_delimiter = '\\'; # for window system
	}
	else {
	    $file_delimiter = '/'; # for unix system
	}
	if (defined $ENV{SCS_BASE_DIR}) {
	    $base_dir     = $ENV{SCS_BASE_DIR}.$file_delimiter.'scs16_comp'.$file_delimiter;
	}
	else {
	    die "\nError : Environmet variable SCS_BASE_DIR is not defined... Exit\n\n";	    
	}
    }
    else {
	die "Error : Can not infere the operating system type... Exit\n";
    }

    $all_requires = $base_dir."all_requires.pl";
    print "all_requires location is\n\t$all_requires\n";
    # exit;
    $SCS16_LINE = 0;
    require $all_requires;

}

exit -1;

