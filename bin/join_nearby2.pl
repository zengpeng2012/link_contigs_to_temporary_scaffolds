#!/usr/bin/perl
use Data::Dumper;
my $assembly=shift;
my $inter=shift;

open IN,$assembly or die $!;

my @order_raw;
my @order_raw_left;

while(<IN>){
	chomp;
	if(/>/){
		my $line=$_;
#		print $line,"\n";
		my @f=split(/\s+/,$line);
		$f[0]=~s/>//;
		my $le=sprintf("%.3f",$f[2]/1000000);
		$size{$f[0]}=$le;
		$size{$f[1]}=$le;
		my $k=0-$f[1];
		$size{$k}=$le;
		$index{$f[0]}=$f[1];
		$ctg{$f[1]}=$f[0];
		$ctg{$k}=$f[0];
		$ctg{$f[0]}=$f[0];
	}else{

		my @f=split;
		if($#f>0){
			for(my $i=0;$i<=$#f;$i++){
				push @order_raw,$f[$i];
			}
		}else{
			push @order_raw_left,$f[0];
		}
	}
}
close IN;

open IB,$inter or die $!;
while(<IB>){
	chomp;
	my @f=split;
	$num{$f[0]}{$f[1]}=$f[2];
}
close IB;

my @order_sc;



#


my @num_all_nearby_contigs;
for(my $i=0;$i<=$#order_raw;$i++){ #转换contig互作强度，两个contig长度的平方差为分母。

	for(my $j=0;$j<=$#order_raw;$j++){
		if($i==$j){

			print "$i\t$j\t1\t1000\n";
			next;
		}
		my $idx_pre=$i;
		my $ctg_pre=$ctg{$order_raw[$idx_pre]};
		my $ctg=$ctg{$order_raw[$j]};
		my $num=$num{$ctg_pre}{$ctg}+$num{$ctg}{$ctg_pre};
		my $s=sqrt($size{$ctg_pre}*$size{$ctg});
		my $n=int $num/$s;
		my $t=0; $t=1 if ($n>2800);
		print "$i\t$j\t$t\t$n\t$s\t$size{$ctg_pre}\t$size{$ctg}\n";
	}
}

exit;
