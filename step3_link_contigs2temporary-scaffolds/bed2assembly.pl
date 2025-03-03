#!/usr/bin/perl
use Data::Dumper;
my $bed=shift;
my $assembly=shift;


open IA,$bed or die $!;
while(<IA>){
	chomp;
	my @f=split;
	push @bed,[@f];
}
close IA;

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
		print $line,"\n";
		$f[0]=~s/>//;
		my $le=sprintf("%.3f",$f[2]/1000000);
		$size{$f[0]}=$le;
		$size{$f[1]}=$le;
		my $k=0-$f[1];
		$size{$k}=$le;
	}else{

		my @f=split;
		my $len=0;
		for my $idx(@f){
			$len+=$size{$idx};
		}
		
		if($len>0.1){
			$cluster{$cluster_ID}=[@f];
			$cluster_ID++;
		}else{
			push @order_raw_left,join(" ",@f);
		}
	}
}
close IN;

#my $n=0;
for(my $i=0;$i<=$#bed;$i++){
	my $s=$bed[$i][0];
	my $e=$bed[$i][1];
	my @ctg_total;
	for(my $k=$s;$k<=$e;$k++){
		my @ctg=@{$cluster{$k}};
		push @ctg_total,join(" ",@ctg);
#		print STDERR "$n\t$k\n";	
#		$n++;
	}
	print join(" ",@ctg_total),"\n";


}

print join("\n",@order_raw_left),"\n";


