#usr/bin/perl

use strict;
use warnings;

die "perl $0 <FI:table.list>\n" unless($#ARGV==0);
my ($list)=@ARGV;

my %data=();
my %type=();
open LST,$list or die "$0: $list: $!\n";
while(my $file=<LST>){
	chomp($file);
	my @header=();
	open IN,$file or die "$0: $file: $!\n";
	while(<IN>){
		chomp;
		my @F=split /\t/;
		if(/^#/){
			@header=@F;
			for(my $a=2;$a<scalar(@header);$a++){
				$type{$header[$a]}=0;
			}
			next;
		}
		for(my $a=2;$a<scalar(@F);$a++){
			$data{$F[0]}{$header[$a]}+=$F[$a];
		}
	}
	close IN;
}
close LST;

my @type=sort keys %type;
print "LABEL\t",(join "\t",@type),"\n";
for my $type (@type){
	print $type;
	print "\t".($data{$type}{$_}||0) for(@type);
	print "\n";
}
