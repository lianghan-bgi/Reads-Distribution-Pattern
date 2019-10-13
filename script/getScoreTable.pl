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
my %sc=();
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
		$sc{$num}{$t1}+=$a;
		$sc{$num}{$t2}+=$b;
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
	$data{$i}{$_}||=0 for(@type);
	#my $max=0;
	#($max<$data{$i}{$_}) && ($max=$data{$i}{$_}) for(@type);
	#print STDERR "\t$max vs ",$data{$i}{"ASW"};
	#my @m=();
	#($max==$data{$i}{$_}) && (push @m,$_) for(@type);
	#@m=sort{$sc{$b}<=>$sc{$a}} @m;
	my @m=sort{$data{$i}{$b} <=> $data{$i}{$a} || $sc{$i}{$b}<=>$sc{$i}{$a}} @type;
	if($data{$i}{$m[0]}==$data{$i}{$m[1]} && $sc{$i}{$m[0]}==$sc{$i}{$m[1]}){
		print STDERR "$i\t-\n";
	}else{
		$score{$m[0]}++;
		print STDERR "--- $i ---\nSample\t$i\t$m[0]\n";
		my $n=0;
		my $s="";
		while($n<=$#m){
			$s.=$m[$n]."\t".$sc{$i}{$m[$n]}."\n";
			$n++;
		}
		print STDERR $s."\n";
	}
}

print "#LABEL\tTOTAL\t",(join "\t",@type),"\n";
print "$path\t$num";
print "\t",$score{$_} for(@type);
print "\n";
