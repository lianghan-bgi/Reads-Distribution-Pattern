#!/usr/bin/perl

die "perl $0 <FI:data> [FLOAT:percentage ...]\n" if($#ARGV<0);
my ($file)=shift @ARGV;
my @per=@ARGV;
@per=(0.5) unless(scalar(@per));
push @per,1;

my %data=();
my $sum=0;
open IN,$file or die "$0: $file: $!\n";
while(<IN>){
	$data{$sum++}=$_;
}
close IN;

my @turn=(0) x $sum;
for(my $i=1;$i<=$sum;$i++){
	my $o=int(rand($sum));
	while($turn[$o]){
		$o++;
		$o==$sum && ($o=0);
	}
	$turn[$o]=$i;
}

$file=$1 if(/.*\/(.*)/);
my $l=0;
my $t=0;
my $p=$per[0];
my $OUT;
open $OUT,">$file.part0" or die "$0: $file.part0: $!\n";
while($l<$sum){
	if($l>($sum-1)*$p){
		close $OUT;
		$p+=$per[++$t];
		open $OUT,">$file.part$t" or die "$0: $file.part$t: $!\n";
	}
	print $OUT $data{$turn[$l]-1};
	$l++;
}
close $OUT;
