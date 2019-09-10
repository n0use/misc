#!/usr/local/bin/perl
#
use MIME::Parser;
use MIME::Head;

use Date::Manip;

use Cwd;
#my $base_dir = getcwd;
my $base_dir = "/tmp/usps.decode/";

umask("0022");

my %FILES_BY_DAY = ();

# die "Usage: $0 mail-file1 [mail-file2 [mail-fileX]]\n" if (!length($ARGV[0]));

sub handle_msg($$)
{
    my ($base_dir, $fname) = @_; # = $_[0];
    my $FH;
    
    if (length($fname)) {
        open($FH, "<$fname") || die "Error opening '$fname': $!\n";
        print STDERR "Parsing message for USPS attachments from file $fname, sav [";
    } else {
        $FH = \*STDIN;
        print STDERR "Parsing message for USPS attachments from stdin, saving to $base_dir - [";
    }
        
    
    my $parser = MIME::Parser->new();
    #$parser->output_to_core(1);
    #don't write attachments to disk
    #
    
    my $message = $parser->parse($FH);
    my $filer = $parser->filer;
    #die( )s if can't parse
    
    my $head = $message->head();
    my $date_str = $head->get('Date');
    chomp($date_str);
    my $date = new Date::Manip::Date;
    $date->parse($date_str);
    my $output_date = $date->printf("%m.%d.%Y");

    if (! -d "$base_dir/$output_date") {
        mkdir("$base_dir/$output_date") || die "Error creating directory '$base_dir/$output_date': $!\n";
    }
#    $parser->output_under(".");
#    $parser->output_under("$base_dir/$output_date") || die "Error: $!\n";

    #object--see docs
    $preamble = $message->preamble;
    #ref to array of lines
    $epilogue = $message->epilogue;
    #ref to array of lines
    
    $num_parts = $message->parts;
    for (my $i = 0; $i < $num_parts; $i++) {
        print STDERR "$i ";
        my $part = $message->parts($i);

#        print $part . "\n";
#        my $bh = $part->{'ME_Bodyhandle'};
#        my $bh = $part->bodyhandle;
        my $path = $part->bodyhandle->path;

        #    print "bh = [$bh]\n";
        #print "path = [$path]\n";
        #foreach my $p (keys %$part) {
        #        print "  key [$p]\n";
        #    }
        #print "filename = [" . $part->{'Filename'} . "]\n";
        #
        push @{ $FILES_BY_DAY{ $output_date } }, $path;
        my $content_type = $part->mime_type;
        my $body = $part->as_string;
    }
    print STDERR "]\n";
}


if ($#ARGV != -1) {
    foreach my $f (@ARGV) {
        handle_msg($base_dir, $f);
    }
}
else {
    handle_msg($base_dir, "");
}

foreach my $d (keys %FILES_BY_DAY) {
    my @files = @{ $FILES_BY_DAY{ $d } };
    foreach my $f (@files) {
        rename $f, "$d/$f";
    }
#    print "Files for [$d] are: @files\n\n";
}
