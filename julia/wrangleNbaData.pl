#!/usr/bin/perl

use strict;
use warnings;

################################################################################

# Get the columns you are interested in from the raw NBA stat data.

(opendir FOL, "nbaTeamData") || die "Failed to open directory.";
my @files = readdir FOL;  close FOL;

my $fgp{'nodes'}   = [];  my $drb{'nodes'}   = [];  my $tov{'nodes'}   = [];
my $fgp{'evalPts'} = [];  my $drb{'evalPts'} = [];  my $tov{'evalPts'} = [];
my @wpc = ();

foreach my $file (@files) {
    next if $file eq '.' || $file eq '..';
    (open NBA, "<nbaTeamData/$file") || die "Failed to open file for reading.";
    my @nba = <NBA>;  close NBA;
    foreach my $line (@nba) {
        if ($line =~ /^\d+\s+/) {
            my @line = split /\s+/, $line;
            my $key = 'nodes';
            $key = 'evalPts' if ($file eq '2022_2023.txt');
            push @{$fgp{$key}}, $line[8];
            push @{$drb{$key}}, $line[16];
            push @{$tov{$key}}, $line[19];
            push @wpc, $line[3];
        }
    }
}

################################################################################

# Print the nodes.txt file, which has the locations of all the nodes.
(open NBA, ">data/nodes.txt") || die "Failed to open file for writing.";
for (my $i = 0; $i < scalar @{$fgp{"nodes"}}; $i++) {
    print NBA @{$fgp{'nodes'}}[$i] . ' ' . @{$drb{'nodes'}}[$i] . ' ' . @{$tov{'nodes'}}[$i] . "\n";
}
close NBA;

# Print the values.txt file, which has all the known function values.
(open NBA, ">data/values.txt") || die "Failed to open file for writing.";
for (my $i = 0; $i < scalar @wpc; $i++) {
    print NBA "$wpc[$i]\n";
}
close NBA;

# Print the evalPts.txt file, which has the locations of all the nodes.
(open NBA, ">data/evalPts.txt") || die "Failed to open file for writing.";
for (my $i = 0; $i < scalar @{$fgp{"evalPts"}}; $i++) {
    print NBA @{$fgp{'evalPts'}}[$i] . ' ' . @{$drb{'evalPts'}}[$i] . ' ' . @{$tov{'evalPts'}}[$i] . "\n";
}
close NBA;

################################################################################


