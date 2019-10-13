#!/usr/bin/perl

use strict;
use warnings;
use drawSVG;

die "perl $0 <FI:score.table>\n" unless($#ARGV==0);
my ($file)=@ARGV;

my $MARGIN=32;
my $BAR_WIDTH=32;
my $BAR_HEIGHT=$BAR_WIDTH;
my $BAR_MARGIN=2;
my @color=@{&drawSVG::listColor("#EEEEEE","#FF1100",11)};
my @_color=@{&drawSVG::listColor("#EEEEEE","#0011FF",11)};

my $neg=0;
my $svg="";
my @HEAD=();
my $Y=$MARGIN;
my $X=0;
open IN,$file or die "$0: $file: $!\n";
while(<IN>){
	chomp;
	my @F=split /\t/;
	unless(scalar(@HEAD)){
		@HEAD=@F;
		next;
	}
	for(my $i=1;$i<=$#F;$i++){
		$F[$i]=($F[$i]>0?1:($F[$i]<0?-1:0)) if(abs($F[$i])>1);
		if($F[$i]>=0){
			$svg.=&drawSVG::drawRect(x=>$MARGIN+($i-1)*($BAR_WIDTH+$BAR_MARGIN),y=>$Y,width=>$BAR_WIDTH,height=>$BAR_HEIGHT,fill=>$color[int($F[$i]*10)]);
		}else{
			$neg=1;
			$svg.=&drawSVG::drawRect(x=>$MARGIN+($i-1)*($BAR_WIDTH+$BAR_MARGIN),y=>$Y,width=>$BAR_WIDTH,height=>$BAR_HEIGHT,fill=>$_color[int($F[$i]*-10)]);
		}
		my $vd=int($F[$i]*100+0.5);
		$svg.=&drawSVG::drawText(x=>$MARGIN+($i-1)*($BAR_WIDTH+$BAR_MARGIN)+$BAR_WIDTH/2,y=>$Y+$BAR_WIDTH/2,text=>$vd,"align-mode"=>"vm") if($vd);
	}
	my $len=scalar(@F)*($BAR_WIDTH+$BAR_MARGIN)-$BAR_MARGIN;
	$svg.=&drawSVG::drawText(x=>$len+20,y=>$Y+$BAR_HEIGHT/2+4,text=>$F[0]);
	$X=$len if($X<$len);
	$Y+=$BAR_HEIGHT+$BAR_MARGIN;
}
close IN;

if(scalar(@HEAD)){
	for(my $i=1;$i<=$#HEAD;$i++){
		$svg.=&drawSVG::drawText(x=>$MARGIN+($i-1)*($BAR_WIDTH+$BAR_MARGIN)+$BAR_WIDTH/2-4,y=>$Y+18,text=>$HEAD[$i],"align-mode"=>"l",rotate=>90);
	}
	$Y+=$MARGIN*8;
}
#unless($neg){
#	$svg.=&drawSVG::drawRects(x=>$MARGIN+100,y=>$Y,width=>16,height=>16,margin=>0,color=>\@color);
#	$svg.=&drawSVG::drawText(x=>$MARGIN+18,y=>$Y+12,text=>"Percentage: 0");
#	$svg.=&drawSVG::drawText(x=>$MARGIN+114+scalar(@color)*16,y=>$Y+12,text=>"100");
#}else{
#	shift @_color;
#	@color=(reverse(@_color),@color);
#	$svg.=&drawSVG::drawRects(x=>$MARGIN+100,y=>$Y,width=>8,height=>16,margin=>0,color=>\@color);
#	$svg.=&drawSVG::drawText(x=>$MARGIN+6,y=>$Y+12,text=>"Percentage: -100");
#	$svg.=&drawSVG::drawText(x=>$MARGIN+114+scalar(@color)*8,y=>$Y+12,text=>"100");
#}
#$Y+=$MARGIN*2-$BAR_MARGIN;
$X+=$MARGIN*10;
$X=600 if($X<600);
$Y=400 if($Y<400);
print &drawSVG::drawHeader(width=>$X,height=>$Y);
print $svg;
print &drawSVG::drawTail();
