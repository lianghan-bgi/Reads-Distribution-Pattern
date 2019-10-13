#!/usr/bin/perl

use strict;
use warnings;

die "perl $0 <FI:score>\n" unless($#ARGV==0);
my ($file)=@ARGV;

my $head=1;
open IN,$file or die "$0: $file: $!\n";
while(<IN>){
	chomp;
	my @F=split /\t/;
	if($head){
		shift @F;
		shift @F;
		print "SCORE\t",(join "\t",@F),"\n";
		$head=0;
		next;
	}elsif(/^#/){
		next;
	}
	print shift(@F);
	my $total=shift @F;
	print "\t",$_/$total for(@F);
	print "\n";
}
close IN;
