#!/usr/bin/perl
# search_ldap_logs.pl 
# Wed Aug  7 08:05:29 CDT 2019   jnewman@netgate.com   jnn@synfin.org   John Newman
# - extremely crude & simple script to parse the dirsrv "access" log from a FreeIPA ldap server, looking for connections w/ "Invalid credentials" and print out details 
#   - about the connection, namely the connecting IP and the dn that was used that generated the invalid credentials
# - added "-v[erbose] option, which prints out a little bit more info about the invalid connections
# - Script needs cleanup, proper argument processing, etc.  Right now you just pipe the access log into stdin of the script, e.g. "cat access | search_ldap_logs.pl"
#

use strict;

my %conn;
my ($c, $ip, $dn, $keep, $to, $time);
my $verbose = 0;

if ($ARGV[0] =~ /^-v(erbose)?$/) {
    $verbose =1 ;
    shift @ARGV;
}

while ($_ = <>) {
    if ($_ =~ /^\[(.*)\].*conn=(\d+)\s+fd=\d+.*connection\s+from\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s+to\s+(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/) {
        if (length($c) && $keep != 1) {
            delete( $conn{ $c } );
        }
        ($time, $c, $ip, $to) = ($1, $2, $3, $4);
        $conn{ $c }{ "ip" } = $ip;
        $conn{ $c }{ "to" } = $to;
        $conn{ $c }{ "time" } = $time;
        $keep = 0;
    } elsif ($_ =~ /conn=$c.*BIND\s+dn="(.*)"/) {
        $dn = length($1) ? $1 : '""';
        $conn{ $c }{ "dn" } = $dn;
    } elsif ($_ =~ /conn=$c.*RESULT\s(.*Invalid credentials.*)$/)  {
        $conn{ $c }{ "result" } = $1;
        $keep = 1;
    } 
}

if ($keep == 0) {
    delete( $conn{ $c } );
}

foreach my $c (sort keys %conn) {
    print "Connection $c - \n";
    print "  CONN ID  - " . $c . "\n"                       if $verbose;
    print "  TIME     - " . $conn{ $c } { "time" } . "\n";
    print "  SRC      - " . $conn{ $c } { "ip" } . "\n";  
    print "  DEST     - " . $conn{ $c } { "to" } . "\n"     if $verbose;
    if ($verbose) {
        my ($uid) = $conn{ $c }{ "dn" } =~ /uid=(\w+)/;
        print "  UID      - $uid\n";
    }
    print "  DN       - " . $conn{ $c } { "dn" } . "\n";
    print "  ERR      - " . $conn{ $c } { "result" } . "\n";
}

exit (0);
