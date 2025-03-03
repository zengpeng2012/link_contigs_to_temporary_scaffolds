#!/usr/bin/perl-w
use strict;
use Data::Dumper;

my $agp=shift; #"/public/home/wangwen_lab/zonghang/project/Pp/05.3ddna/01.fish_ctg/FINAL_cut.agp";
my $merged_nodups=shift;
my $p=shift;
$p ||=int rand (1000);

#chr1    1       2726803 1       W       ptg000325l      3635153 6361955 -
#chr1    2726804 2727303 2       N       500     scaffold        yes     paired-ends
#chr1    2727304 3989956 3       W       ptg001097l      1       1262653 +
#chr1    3989957 3990456 4       N       500     scaffold        yes     paired-ends
#chr1    3990457 4468126 5       W       ptg000882l      1       477670  -


open IB,$agp or die $!;
my %index;
my %pos;
my %new_sca;
my %strand;
while(<IB>){
	chomp;
	my @f=split;
	next if($#f<8);
	

	my $st=1+int ($f[6]/1000);
	my $en=-1+int ($f[7]/1000);
	for(my $i=$st;$i<=$en;$i++){
		$new_sca{$f[5]}{$i}=$f[0];
		$strand{$f[5]}{$i}=$f[8];
		if($f[8] eq '+'){
			$pos{$f[5]}{$i}=$f[1]-$f[6]+1;
#			print "$f[5]\t$f[5]\t$i\t$f[1]\n";
		}else{
			$pos{$f[5]}{$i}=$f[2]+$f[6]-1;
			
		}
	}
}
close IB;

#0 ptg000001l 20311 96 0 ptg000001l 141141 614 0 121M29S
#0 ptg000001l 20500 99 0 ptg000001l 167996 691 0 63M87S
#0 ptg000001l 21430 103 0 ptg000001l 33965 162 0 92H58M
#0 ptg000001l 22024 104 0 ptg000001l 218924 896 0 48M102S
#0 ptg000001l 24050 112 0 ptg000001l 30527 146 0 148M2S
#0 ptg000001l 25168 117 0 ptg000001l 55184 249 27 87M63S
#0 ptg000001l 25399 119 0 ptg000001l 25761 121 23 131M19S
#0 ptg000001l 26785 125 0 ptg000001l 52291 232 56 137M13S
#0 ptg000001l 27715 130 0 ptg000001l 31045 149 8 150M
#0 ptg000001l 28494 134 0 ptg000001l 141141 614 0 121M29S

open IC,$merged_nodups or die $!;
while(<IC>){
	chomp;
	my @f=split;
	next if($f[1] eq $f[5]);
	next unless (exists $pos{$f[1]});
	next unless (exists $pos{$f[5]});
	my $p1=int ($f[2]/1000);
	my $p2=int ($f[6]/1000);
		
	next unless ($pos{$f[1]}{$p1});
	next unless ($pos{$f[5]}{$p2});

	my $st1=$pos{$f[1]}{$p1};
	my $st2=$pos{$f[5]}{$p2};
#	if($strand{$f[1]}{$p1}){
		my $strand1=$strand{$f[1]}{$p1};
		if($strand1 eq '+'){
			$f[2]+=$pos{$f[1]}{$p1};			
			$f[1]=$new_sca{$f[1]}{$p1};
		}else{
			$f[2]=$pos{$f[1]}{$p1}-$f[2];
			$f[1]=$new_sca{$f[1]}{$p1};
		}
#	}

#	if($strand{$f[5]}{$p2}){
		my $strand1=$strand{$f[5]}{$p2};
		if($strand1 eq '+'){
			$f[6]+=$pos{$f[5]}{$p2};
			$f[5]=$new_sca{$f[5]}{$p2};
		}else{
			$f[6]=$pos{$f[5]}{$p2}-$f[6];
			$f[5]=$new_sca{$f[5]}{$p2};
		}
#	}

		print join " ",@f;
		print "\n";
	}


