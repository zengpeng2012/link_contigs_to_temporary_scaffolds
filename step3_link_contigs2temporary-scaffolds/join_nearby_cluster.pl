#!/usr/bin/perl
use Data::Dumper;
my $assembly=shift;
my $inter=shift;

open IN,$assembly or die $!;

my @order_raw;
my @order_raw_left;

my %cluster;
my $cluster_ID=0;
while(<IN>){
	chomp;
	if(/>/){
		my $line=$_;
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
		my $len=0;
		for my $idx(@f){
			$len+=$size{$idx};
		}
		

		if($len>0.1){
			push @order_raw,[$cluster_ID,$len];
			$cluster{$cluster_ID}=[@f];
			$cluster_ID++;
		}else{
			push @order_raw_left,[@f];
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

for(my $i=0;$i<=$#order_raw;$i++){ #计算相邻contig cluster互作强度，两个contig cluster长度的平方差为分母。
	
	my @ctg_x_idx=@{$cluster{$order_raw[$i][0]}};
#	print Dumper \@ctg_x_idx;
#	next;
	
	for(my $j=$i;$j<=$#order_raw;$j++){
		my @ctg_y_idx=@{$cluster{$order_raw[$j][0]}};
		if($i==$j){
			print "$i\t$j\t1\t1000\n";
			next;
		}
		my $num=0;
		for my $ctg_x (@ctg_x_idx){
			for my $ctg_y(@ctg_y_idx){
				$num+=$num{$ctg{$ctg_x}}{$ctg{$ctg_y}}+$num{$ctg{$ctg_y}}{$ctg{$ctg_x}};
			}
		}

		my $s=sqrt($order_raw[$i][1]*$order_raw[$j][1]);
		my $n=int $num/$s;
		my $t=0; $t=1 if ($n>2800);
		print "$i\t$j\t$t\t$n\t$s\t$order_raw[$i][1]\t$order_raw[$j][1]\n";
	}
}

