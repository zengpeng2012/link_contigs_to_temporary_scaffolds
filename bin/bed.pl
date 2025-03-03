#!/usr/bin/perl-w
use strict;
use Data::Dumper;
my $matrix=shift;

my $cutoff=shift;

$cutoff ||=100;
my %length;
my %hash;
open IN,$matrix or die $!;
while(<IN>){
	chomp;
	my @f=split;
	if($f[0] != $f[1]){
                $length{$f[0]}=$f[5];
                $length{$f[1]}=$f[6];
        }
	next if($f[3]<$cutoff);
	$hash{$f[0]}{$f[1]}=1;
	$hash{$f[1]}{$f[0]}=1;
}
close IN;


my @length;

foreach my $k(sort {$a<=>$b} keys %length){
	push @length,[$k,$length{$k}];
}
@length=sort {$b->[1]<=>$a->[1]} @length;
my %bed;
my $b_id=1;
my %b_id;
push @{$bed{$b_id}},$length[0][0]; 
$b_id{$length[0][0]}=$b_id;
my @cluster_ID=sort {$a<=>$b} keys %length;

for(my $i=1;$i<=$#length;$i++){
	my $cluster_ID=$length[$i][0];
	next if($b_id{$cluster_ID});
	my $pre=$cluster_ID-1;
	my $aft=$cluster_ID+1;

	#print "$pre\t$aft\n";

	my $check_pre=0;
	my @aa;
	if($pre>=$cluster_ID[0] && $b_id{$pre}){
		@aa=sort {$a<=>$b} @{$bed{$b_id{$pre}}};
		$check_pre=check_a_to_b($aa[0],$cluster_ID,"r");
	}
	my $check_aft=0;
	my @bb;
	if($aft<=$cluster_ID[-1] && $b_id{$aft}){
		@bb=sort {$a<=>$b} @{$bed{$b_id{$aft}}};
		$check_aft=check_a_to_b($cluster_ID,$bb[-1],"l");
	}
	if($check_pre && $check_aft){
		my $check=check_a_to_b($aa[0],$bb[-1],"n");

		if($check){
			$b_id++;
			for my $aa(@aa){
				push @{$bed{$b_id}},$aa;
				$b_id{$aa}=$b_id;
			}
			push @{$bed{$b_id}},$cluster_ID;
			$b_id{$cluster_ID}=$b_id;
			for my $bb(@bb){
				push @{$bed{$b_id}},$bb;
				$b_id{$bb}=$b_id;
			}

		}else{
			my $length_aa;
			for my $aa(@aa){
				$length_aa+=$length{$aa};
			}		
			my $length_bb;
                        for my $bb(@bb){
                                $length_bb+=$length{$bb};
                        }

			if($length_aa>$length_bb){
				$check_aft=0;
			}else{
				$check_pre=0;
			}

		}
	}

	if($check_pre && !$check_aft){
		$b_id++;
		for my $aa(@aa){
			push @{$bed{$b_id}},$aa;
			$b_id{$aa}=$b_id;
		}
		push @{$bed{$b_id}},$cluster_ID;
		$b_id{$cluster_ID}=$b_id;
		next;
	}

	if(!$check_pre && $check_aft){
		$b_id++;
		
		push @{$bed{$b_id}},$cluster_ID;
                $b_id{$cluster_ID}=$b_id;


                for my $bb(@bb){
                        push @{$bed{$b_id}},$bb;
                        $b_id{$bb}=$b_id;
                }
                next;
	}

	$b_id++;
	push @{$bed{$b_id}},$cluster_ID;
        $b_id{$cluster_ID}=$b_id;
}

foreach my $cluster_ID(sort {$a<=>$b} keys %b_id){
	next unless ($b_id{$cluster_ID});
	my $b_id=$b_id{$cluster_ID};
	my @cluster_ID=@{$bed{$b_id}};

	my $dis=$cluster_ID[-1]-$cluster_ID[0];

	if($dis != $#cluster_ID){
		die "cluster_ID not coiled for $cluster_ID\n";
	}

	my $len=0;
	for my $id(@cluster_ID){
                $b_id{$id}=0;
		$len+=$length{$id};
        }	
	print "$cluster_ID[0]\t$cluster_ID[-1]\t$len\n";
}



sub check_a_to_b{
	my $s=shift;
	my $e=shift;
	my $mark=shift;


	my $check=1;
	my $dis=$e-$s+1;
	my $map=0;


	if($mark eq "r"){
		for(my $k=$s;$k<=$e;$k++){
			$map+=$hash{$k}{$e};
		}
	}elsif($mark eq "l"){
		for(my $k=$s;$k<=$e;$k++){
			$map+=$hash{$k}{$s};
		}
	}elsif($mark eq 'n'){
		$map=$dis;
	}else{
		die "err of mark (l/r/n): $mark\n";
	}


	if($map/$dis<0.5){
		$check=0;
		return $check;
	}

	my $matrix_count=$dis*$dis;
	my $map_2;
	for my $x($s..$e){
		for my $y($s..$e){
			$map_2+=$hash{$x}{$y};
		}
	}
	if($map_2/$matrix_count<0.8){
		$check=0;
		return $check;
	}
	return $check;

}



=pod
exit;

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

=cut
