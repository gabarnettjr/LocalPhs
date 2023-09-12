#!/usr/bin/perl

use strict;
use warnings;

################################################################################

# case 1: field goal pct, defensive rebounds, turnovers.
# case 2: points, defensive rebounds, opponent points.
# case 3: points, opponent points.
my $case = 2;

# Get the columns you are interested in from the raw NBA stat data.

(opendir FOL, "nbaTeamData") || die "Failed to open directory.";
my @files = readdir FOL;  closedir FOL;

(opendir FOL, "nbaTeamDataOpp") || die "Failed to open directory.";
my @filesOpp = readdir FOL;  closedir FOL;

my @wpc = ();

################################################################################

# Traditional Stat Sheet

my (%fgp, %drb, %tov, %pts);

if ($case == 1) {
    $fgp{'nodes'} = [];
    $fgp{'evalPts'} = [];
    
    $drb{'nodes'} = [];
    $drb{'evalPts'} = [];
    
    $tov{'nodes'} = [];
    $tov{'evalPts'} = [];

} elsif ($case == 2) {
    $pts{'nodes'} = [];
    $pts{'evalPts'} = [];

    $drb{'nodes'} = [];
    $drb{'evalPts'} = [];

} elsif ($case == 3) {
    $pts{'nodes'} = [];
    $pts{'evalPts'} = [];
}

foreach my $file (@files) {
    next if $file eq '.' || $file eq '..';
    (open NBA, "<nbaTeamData/$file") || die "Failed to open file for reading.";
    my @nba = <NBA>;  close NBA;
    foreach my $line (@nba) {
        if ($line =~ /^\d+\s+/) {
            my @line = split /\s+/, $line;
            my $key = 'nodes';
            $key = 'evalPts' if $file eq '2022_2023.txt';
            if ($case == 1) {
                push @{$fgp{$key}}, $line[8];
                push @{$drb{$key}}, $line[16];
                push @{$tov{$key}}, $line[19];
            } elsif ($case == 2) {
                push @{$pts{$key}}, $line[5];
                push @{$drb{$key}}, $line[16];
            } elsif ($case == 3) {
                push @{$pts{$key}}, $line[5];
            }
            push @wpc, $line[3] if $key eq 'nodes';
        }
    }
}

################################################################################

# Opponent Stat Sheet

my %pto;

if ($case == 2 || $case == 3) {
    $pto{'nodes'} = [];
    $pto{'evalPts'} = [];
}

my $numTeams = 0;

foreach my $file (@filesOpp) {
    next if $file eq '.' || $file eq '..';
    (open NBA, "<nbaTeamDataOpp/$file") || die "Failed to open file for reading.";
    my @nba = <NBA>;  close NBA;
    foreach my $line (@nba) {
        if ($line =~ /\S+/) {
            my @line = split /\s+/, $line;
            shift @line while $line[0] =~ /\D+/;
            my $key = 'nodes';
            $key = 'evalPts' if $file eq '2022_2023.txt';
            push @{$pto{$key}}, $line[23] if $case == 2 || $case == 3;
            $numTeams++ if $key eq 'evalPts';
        }
    }
}

################################################################################

# Print the nodes.txt file, which has the locations of all the nodes.
(open NBA, ">data/nodes.txt") || die "Failed to open file for writing.";
for (my $i = 0; $i < scalar @wpc; $i++) {
    print NBA @{$fgp{'nodes'}}[$i] . ' ' . @{$drb{'nodes'}}[$i] . ' ' . @{$tov{'nodes'}}[$i] . "\n" if $case == 1;
    print NBA @{$pts{'nodes'}}[$i] . ' ' . @{$drb{'nodes'}}[$i] . ' ' . @{$pto{'nodes'}}[$i] . "\n" if $case == 2;
    print NBA @{$pts{'nodes'}}[$i] . ' ' . @{$pto{'nodes'}}[$i] . "\n" if $case == 3;
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
for (my $i = 0; $i < $numTeams; $i++) {
    print NBA @{$fgp{'evalPts'}}[$i] . ' ' . @{$drb{'evalPts'}}[$i] . ' ' . @{$tov{'evalPts'}}[$i] . "\n" if $case == 1;
    print NBA @{$pts{'evalPts'}}[$i] . ' ' . @{$drb{'evalPts'}}[$i] . ' ' . @{$pto{'evalPts'}}[$i] . "\n" if $case == 2;
    print NBA @{$pts{'evalPts'}}[$i] . ' ' . @{$pto{'evalPts'}}[$i] . "\n" if $case == 3;
}
close NBA;

################################################################################


