#!/usr/bin/perl -w
#bind_synt_wait.pl
# creating a synthetic bind "WAIT" for otherwise UFBCs 
use strict;

my $prev_cursor     = 0 ;
my $cursor          = 0 ;
my $prev_timestamp  = 0 ;
my $timestamp       = 0 ;
my $calc_timestamp  = 0 ;
my $ela             = 0 ;
my $calc_ela        = 0 ;
my $to_be_processed = 0 ; 
# 0 => nothing to do, 
# 1 => BIND seen, but no WAIT, 
# 2 => BIND & WAIT seen ==> process!

#my $tablespace;
#my $block;
#my $object_id;

while (<>) {
  my $line = $_;
  if ($line =~ m/.*#(\d+)[: ].*/) {
    ($cursor = $line) =~ s/.*#(\d+)[: ].*/$1/ ;
  }
  $cursor =~ tr/\n//d;

  if ($line =~ m/.*tim=(\d+).*/) {
    ($timestamp = $line) =~ s/.*tim=(\d+).*/$1/ ;
	if ($to_be_processed == 1) {
	  $to_be_processed = 2;	
	}
  }
  $timestamp =~ tr/\n//d;
#  print " ---- timestamp = $timestamp \n";

  if ($line =~ m/.*ela= (\d+) .*/) {
    ($ela = $line) =~ s/.*ela= (\d+) .*/$1/ ;
  }
  $ela =~ tr/\n//d;
  
  if ($line =~ m/.*,e=(\d+),.*/) {
    ($ela = $line) =~ s/.*,e=(\d+),.*/$1/ ;
  }
  $ela =~ tr/\n//d;
#  print " ---- ela = $ela \n";
  
  if ($line =~ m/^BINDS/) {
    $to_be_processed = 1;
  }
  
  if ($to_be_processed == 2) {
# WAIT #391723720: nam='db file scattered read' ela= 2876 file#=5 block#=129 blocks=127 obj#=71123 tim=90982740602
    $calc_ela = ($timestamp - $ela) - $prev_timestamp;
	if ( $calc_ela < 0) {
		$calc_ela = 0 ; #$timestamp - $prev_timestamp;
	}
	$calc_timestamp = $timestamp-$ela;
    print "WAIT #"; # as the hash is somethign special ...
    print "$cursor: nam='BIND to tracefile write' ela= $calc_ela tim=$calc_timestamp\n";
    $to_be_processed = 0;
  }
  print $line;
  
  # will need these when generating tim & ela for BIND
  $prev_cursor = $cursor;
  $prev_timestamp = $timestamp;
}
