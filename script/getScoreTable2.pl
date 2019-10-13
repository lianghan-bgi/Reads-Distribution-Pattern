#!/usr/bin/perl

use strict;
use warnings;

die "perl $0 <STR:path>\n" unless($#ARGV==0);
my ($path)=@ARGV;
$path=$1 if($path=~/(.*?)\/+$/);

sub getFileList{
	my $ls=`ls $_[0]`;
	chomp($ls);
	my @F=split /\n/,$ls;
	\@F;
}

my @file=@{&getFileList($path)};

my %data=();
my %type=();
my $num=0;
for my $file (@file){
	next unless($file=~/^(.*?)\.(.*?)\.txt$/);
	my ($t1,$t2)=($1,$2);
	$type{$t1}=0;
	$type{$t2}=0;
	$num=0;
	open IN,"$path/$file" or die "$0: $file: $!\n";
	while(<IN>){
		chomp;
		my ($a,$b)=split /,/;
		if($a>$b){
			$data{$num}{$t1}++;
		}elsif($b>$a){
			$data{$num}{$t2}++;
		}
		$num++;
	}
	close IN;
}

my @type=sort keys %type;
my %score=map{$_=>0} @type;
for(my $i=0;$i<$num;$i++){
	print STDERR $i;
	my $max=0;
	$data{$i}{$_}||=0 for(@type);
	($max<$data{$i}{$_}) && ($max=$data{$i}{$_}) for(@type);
	#print STDERR "\t$max vs ",$data{$i}{"ASW"};
	($max==$data{$i}{$_}) && (++$score{$_}) && (print STDERR "\t$_") for(@type);
	print STDERR "\n";
}

print "#LABEL\tTOTAL\t",(join "\t",@type),"\n";
print "$path\t$num";
print "\t",$score{$_} for(@type);
print "\n";
