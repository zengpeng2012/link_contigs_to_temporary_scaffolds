#!/usr/bin/perl
use Data::Dumper;
my $assembly=shift;
my $cluster=shift;

open IN,$assembly or die $!;

my @order_raw;
my @order_raw_left;

while(<IN>){
	chomp;
	if(/>/){
		my $line=$_;
		print $line,"\n";
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

open IB,$cluster or die $!;

my @aa;
while(<IB>){
	chomp;
	my @f=split;
	if($f[0] < $f[1]){
		push @aa,[@f];
	}		
}
close IB;

my %len_k;

for(my $k=0;$k<=$#aa;$k++){
	for(my $i=$aa[$k][0];$i<=$aa[$k][1];$i++){
		$len_k{$k}+=$size{$order_raw[$i]};
	}
}

for(my $k=1;$k<=$#aa;$k++){
	if($aa[$k][0] == $aa[$k-1][1]){
		if($len_k{$k}<$len_k{$k-1}){
			$aa[$k][0]++;
		}else{
			$aa[$k-1][1]--;
		}
	}
}

my %order_sc_idx;

my %region;

for(my $k=0;$k<=$#aa;$k++){
	my $idx=$aa[$k][0];
	$order_sc_idx{$idx}=$aa[$k];
	for(my $i=$aa[$k][0];$i<=$aa[$k][1];$i++){
		$region{$i}=1;
	}

}


for(my $i=0;$i<=$#order_raw;$i++){
	unless($region{$i}){
		$order_sc_idx{$i}=[$i,$i];
	}
}


foreach my $idx( sort {$a<=>$b} keys %order_sc_idx){
	#print STDERR $idx,"\n";
	my @idx=@{$order_sc_idx{$idx}};
	#print STDERR Dumper \@idx;
	my @order_sc;
	
	for (my $i=$idx[0];$i<=$idx[1];$i++){
		push @order_sc,$order_raw[$i];
	}
	print join(" ",@order_sc),"\n";
}


print join("\n",@order_raw_left),"\n";

