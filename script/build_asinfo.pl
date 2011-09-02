#! /usr/bin/env perl

use strict;
use warnings;

my $workdir = "/home/sora/work/asinfo";

my( %lat, %as_name, %as );
my @rir_name = ("iana", "arin", "apnic", "afrinic", "lacnic", "ripencc");

my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst )
    = localtime();
my $fmt0 = "%04d%02d%02d%02d";
my $now  = sprintf( $fmt0, $year + 1900, $mon + 1, $mday, $hour );

open LAT, "<$workdir/data/capitallatlong.txt" or die "Can't open file: $!";
while (<LAT>) {
    chomp;
    my( $cc, $capital, $conti, $lat, $long ) = split(/\|/);
    $lat{$cc} = { capi => $capital, conti => $conti, lat => $lat, long => $long };
}
close(LAT);

open NAME, "<$workdir/tmp/autnums.html" or die "Can't open file: $!";
while (<NAME>) {
    chomp;
    if(/^\<a .*?\>AS([\d\.]+)\s*\<\/a\>(.*?)$/) {
        my( $a, $b ) = ( $1, $2 );
        $b =~ s/^\s*(.*?)\s*$/$1/;

        # convert 'asdot' to 'asplain' for four-byte as
        if($a =~ /(\d+)\.(\d+)/) {
            $a = (1 << 16) * $1 + $2;
        }

        # convert into short asname
        my @n = split(/\s/, $b);
        if($#n > 0) {
            $b = $n[0];
        }

        $as_name{$a} = $b;
    }
}
close(NAME);

foreach my $rir (@rir_name) {
    open RIR, "<$workdir/tmp/delegated-${rir}-latest"  or die "Can't open file: $!";
    while (<RIR>) {
        chomp;
        if(/^([a-z]+)\|([A-Z]{2})\|asn\|(\d+)\|\d+\|(\d+)\|allocated$/) {
            my( $r, $cc, $asn, $date ) = ( $1, $2, $3, $4 );
            if(!defined( $as{$asn} )) {
                $as{$asn} = { cc => $cc, rir => $r, date => $date };
            } else {
                print "Duplicate asn: $asn\n";
                exit 1;
            }
        }
    }
    close(RIR);
}

open JP, "<$workdir/tmp/as-numbers.txt" or die "Can't open file: $!";
while (<JP>) {
    chomp;
    if(/^(\d+)\s+(.*?)\s+(.*?)$/) {
        my( $asn, $name, $contact ) = ( $1, $2, $3 );
        if(!defined( $as{$asn} )) {
            $as{$asn} = { cc => 'JP', rir => 'jpnic' }
        }
        if(!defined( $as_name{$asn} )) {
            $as_name{$asn} = $name;
        }
    }
}
close(JP);

my $out = "$workdir/asinfo/asinfo-$now";
open OUT, ">$out" or die "Can't open file: $!";

foreach my $asn ( sort { $a <=> $b } keys %as) {
    my( $name, $capi, $conti, $lat, $long, $cc, $rir, $date );

    $name  = $as_name{$asn} || "unknown";

    $cc    = $as{$asn}->{cc} || "";
    $rir   = $as{$asn}->{rir} || "";
    $date  = $as{$asn}->{date} || "";

    $capi  = $lat{$cc}->{capi} || "";
    $conti = $lat{$cc}->{conti} || "";
   	$lat   = $lat{$cc}->{lat} || "";
   	$long  = $lat{$cc}->{long} || "";

    # see http://www.maxmind.com/app/faq#EUAPcodes
    if($cc eq 'EU') {
        $conti = 'Europe';
    } elsif($cc eq 'AP') {
        $conti = 'Asia';
    }

    printf(OUT "%s|%s|%s|%s|%s|%s|%s|%s|%s\n",
	   $asn, $name, $cc, $conti, $rir, $date, $capi, $lat, $long);
}
close(OUT);

exit 0;
