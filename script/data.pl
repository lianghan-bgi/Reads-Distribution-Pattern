#!/usr/bin/perl

use strict;
use warnings;

die "perl $0 <FI:table> [fuse=1]\n" if($#ARGV<0 || $#ARGV>1);
my ($list,$fuse)=@ARGV;
$fuse||=1;

open LST,$list or die "$0: $list: $!\n";
while(my $file=<LST>){
	chomp($file);
	$file=$1 if($file=~/.*\t(.*)/);
	print STDERR $file,"\n";
	my $num=0;
	my $sum=0;
	my $first=1;
	open IN,"gzip -dc $file |" or die "$0: $file: $!\n";
	while(<IN>){
		next unless(/^\d/);
		chomp;
		if($num++>$fuse){
			if($first){
				$first=0;
			}else{
				print ",";
			}
			print $sum;
			$num=0;
			$sum=0;
		}
		$sum+=$_;
	}
	close IN;
	print "\n";
}
close LST;
