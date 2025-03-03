#!/usr/bin/perl

my $matrix=shift;

my $cutoff=shift;

$cutoff ||=100;

open IN,$matrix or die $!;
while(<IN>){
	chomp;
	my @f=split;
	next if($f[3]<$cutoff);
	$hash{$f[0]}{$f[1]}=1;
	$num{$f[0]}++;
}
close IN;


my @num;
foreach my $k(keys %num){
	push @num,[$k,$num{$k}];
}

@num=sort {$b->[0]<=>$a->[0]}@num;

my $max=$num[0][0]; #最大index；


my $start=0;
my $end=0;


for (my $i=$start+1;$i<=$max;$i++){

	my $dis=$i-$start+1;
	my $map=0;
	for(my $k=$start;$k<=$i;$k++){
		$map+=$hash{$k}{$i};
	}



	if($map/$dis<=0.5){
		print "$start\t$end\n";
		$start=$i-1;
		$end=$i-1;
	}else{
		
		my $matrix_count=$dis*$dis;
		my $map_2;
		for my $x($start..$i){
			for my $y($start..$i){
				$map_2+=$hash{$x}{$y};
			}
		}

		if($map_2/$matrix_count>0.6){
			$end=$i;
		}else{
			print "$start\t$end\n";
	        $start=$i-1;
		    $end=$i-1;
		}
	}
}
print "$start\t$end\n";


