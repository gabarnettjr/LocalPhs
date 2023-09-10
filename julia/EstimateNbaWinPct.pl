#!/usr/bin/perl

use strict;
use warnings;

# Get the needed data from the raw NBA text files.
system "perl wrangleNbaData.pl";

# Interpolate the known data to estimate the win pct of the current teams.
system "julia Interpolate.jl data/nodes.txt data/values.txt data/evalPts.txt data/estimates.txt";

# Get an array of the team names for the current season, and the currente WPC for each team.
(open NBA, "<nbaTeamData/2022_2023.txt") || die "Failed to open file for reading.";
my @nba = <NBA>;  close NBA;
my @teams = ();
my @trueWpc = ();
foreach my $line (@nba) {
    chomp $line;
    if ($line =~ /\S+/ && $line !~ /\./ && $line !~ /Logo\s*$/) {
        push @teams, $line;
    } elsif ($line =~ /^\d+\s+/) {
        my @line = split /\s+/, $line;
        push @trueWpc, $line[3];
    }
}

# Get the array of estimated win percentages for each team.
(open EST, "data/estimates.txt") || die "Faile to open file for reading.";
my @est = <EST>;  close EST;
my @wpc = ();
foreach my $line (@est) {
    chomp $line;
    if ($line =~ /\S+/) {
        push @wpc, $line;
    }
}

if (scalar @teams != scalar @wpc || scalar @teams != scalar @trueWpc) {
    print "numTeams = " . (scalar @teams) . "\n";
    print "numWpc   = " . (scalar @wpc) . "\n";
    print "numTrWpc = " . (scalar @trueWpc) . "\n";
    die "Number of teams does not match number of win percentages.";
}

# Save a new text file that shows both, and print it to standard output.
(open SUM, ">data/nbaWpcEstimates.txt") || die "Failed to open file for writing.";
printf SUM "%-25s %9s %6s    %4s\n", "Team Name", "Estimated", "Actual", "Diff";
printf     "%-25s %9s %6s    %4s\n", "Team Name", "Estimated", "Actual", "Diff";
for (my $i = 0; $i < scalar @teams; $i++) {
    my $diff = $wpc[$i] - $trueWpc[$i];
    printf SUM "%-25s %-9.3f %-6.3f   %6.3f\n", $teams[$i], $wpc[$i], $trueWpc[$i], $diff;
    printf     "%-25s %-9.3f %-6.3f   %6.3f\n", $teams[$i], $wpc[$i], $trueWpc[$i], $diff;
}
close SUM;

