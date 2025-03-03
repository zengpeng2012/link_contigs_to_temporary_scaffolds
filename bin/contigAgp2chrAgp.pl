#!/usr/bin/perl

my $chr_agp=shift;
my $sca_agp=shift;

open IN,$sca_agp or die $!;
#HiC_scaffold_00_0002    1       120943  1       W       ctg045213_np5512        1       120943  -
#HiC_scaffold_00_0002    120944  121443  2       N       500     scaffold        yes     paired-ends
#HiC_scaffold_00_0002    121444  393786  3       W       ctg017035_np5512        1       272343  +
#HiC_scaffold_00_0002    393787  394286  4       N       500     scaffold        yes     paired-ends
#HiC_scaffold_00_0002    394287  978446  5       W       ctg021865_np5512        1       584160  +
#HiC_scaffold_00_0002    978447  978946  6       N       500     scaffold        yes     paired-ends
#HiC_scaffold_00_0002    978947  2972318 7       W       ctg012083_np5512        1       1993372 -
#HiC_scaffold_00_0002    2972319 2972818 8       N       500     scaffold        yes     paired-ends
#HiC_scaffold_00_0002    2972819 3165038 9       W       ctg038648_np5512        1       192220  -
#HiC_scaffold_00_0002    3165039 3165538 10      N       500     scaffold        yes     paired-ends
#HiC_scaffold_00_0002    3165539 3292623 11      W       ctg037588_np5512        1       127085  +
#HiC_scaffold_00_0002    3292624 3293123 12      N       500     scaffold        yes     paired-ends
#HiC_scaffold_00_0002    3293124 3641380 13      W       ctg045609_np5512        1       348257  +
#HiC_scaffold_00_0002    3641381 3641880 14      N       500     scaffold        yes     paired-ends
#HiC_scaffold_00_0002    3641881 3822205 15      W       ctg027343_np5512        1       180325  +
#HiC_scaffold_00_0002    3822206 3822705 16      N       500     scaffold        yes     paired-ends
#HiC_scaffold_00_0002    3822706 4280380 17      W       ctg028994_np5512        1       457675  +
#HiC_scaffold_00_0002    4280381 4280880 18      N       500     scaffold        yes     paired-ends

while(<IN>){

	chomp;
	my @f=split;
	if($f[8] eq 'paired-ends' || $f[8] eq 'proximity_ligation'){
		$f[4]="N";
		$f[7]=$f[5];
		$f[5]="hic_gap";
		$f[6]=1;
		$f[8] ='+';
	}
	push @{$sca{$f[0]}},[@f];
}
close IN;

open IB,$chr_agp or die $!;
#Superscaffold_1 1       16869311        1       W       HiC_scaffold_42_0003    269467834       286337144       +       315
#Superscaffold_1 16869312        16869811        2       W       hic_gap_8576    1       500     +       8576
#Superscaffold_1 16869812        18820129        3       W       HiC_scaffold_12_0811    1       1950318 -       1454
#Superscaffold_1 18820130        18820629        4       W       hic_gap_8576    1       500     +       8576
#Superscaffold_1 18820630        19892670        5       W       HiC_scaffold_49_1044    1       1072041 -       1868
#Superscaffold_1 19892671        19893170        6       W       hic_gap_8576    1       500     +       8576
#Superscaffold_1 19893171        44893170        7       W       HiC_scaffold_42_0003    383175123       408175122       +       318
#Superscaffold_1 44893171        44893670        8       W       hic_gap_8576    1       500     +       8576
#Superscaffold_1 44893671        51143670        9       W       HiC_scaffold_18_0280    413796449       420046448       -       529
#Superscaffold_1 51143671        51144170        10      W       hic_gap_8576    1       500     +       8576
#Superscaffold_1 51144171        57394170        11      W       HiC_scaffold_24_0004    618750001       625000000       +       483
#Superscaffold_1 57394171        57394670        12      W       hic_gap_8576    1       500     +       8576
#Superscaffold_1 57394671        82394670        13      W       HiC_scaffold_36_0002    146692945       171692944       -       393

my %order;
while(<IB>){
	chomp;
#	print $_,"\n";
	my @f=split;
	my ($sca,$start_1,$end_1,$strand_1)=($f[5],$f[6],$f[7],$f[8]);	
	unless($sca{$sca}){
		$f[4]="N" if($f[5]=~/hic_gap/ || $f[8]=~/proximity_ligation/);
		$order{$f[0]}++;
		$f[3]=$order{$f[0]};
		print join("\t",@f),"\n";
		next;
	}
#	print $_,"\n";
	my @sca_arr=sort {$a->[1]<=>$b->[1]} @{$sca{$sca}};
	my @out;
	for(my $i=0;$i<=$#sca_arr;$i++){
		
		my ($start_2,$end_2)=($sca_arr[$i][1],$sca_arr[$i][2]);

		next if($start_2>$end_1 || $end_2<$start_1);
		
		my $start_3=($start_1>$start_2)?$start_1:$start_2;
		my $end_3=($end_1<$end_2)?$end_1:$end_2;
		
		#print "\t$sca\t$start_3\t$end_3\n";
		my ($start_chr_new,$end_chr_new)=pos_chr($f[1],$f[2],$start_1,$end_1,$strand_1,$start_3,$end_3);
		my ($start_ctg_new,$end_ctg_new)=pos_ctg($start_2,$end_2,$sca_arr[$i][6],$sca_arr[$i][7],$sca_arr[$i][8],$start_3,$end_3);

#		print "\t$start_chr_new\t$end_chr_new\t$start_ctg_new\t$end_ctg_new\t$sca\t$start_3\t$end_3\n";
#		print "\t",join("\t",@{$sca_arr[$i]}),"\n";

		push @out,[$start_chr_new,$end_chr_new,$start_ctg_new,$end_ctg_new,$sca_arr[$i][5],$sca_arr[$i][8]];
	}
	@out=sort {$a->[0]<=>$b->[0]}@out;
	for(my $i=0;$i<=$#out;$i++){
		#print "\t",join("\t",@{$out[$i]}),"\n";
		my $strand="+";
		if($strand_1 ne $out[$i][5]){
			$strand="-";
		}
		$order{$f[0]}++;
		my $w_n="W";
		$w_n='N' if($out[$i][4]=~/hic_gap/ || $out[$i][8]=~/proximity_ligation/);
		print "$f[0]\t$out[$i][0]\t$out[$i][1]\t$order{$f[0]}\t$w_n\t$out[$i][4]\t$out[$i][2]\t$out[$i][3]\t$strand\n";
	}

}

sub pos_ctg{

	my ($st1,$en1,$st2,$en2,$forward,$st,$en)=@_;
        my ($st_new,$en_new)=(0,0);
        if($forward eq '+'){
                my $dis_st=$st-$st1;
                my $dis_en=$en1-$en;
                $st_new=$st2+$dis_st;
                $en_new=$en2-$dis_en;
        }elsif($forward eq '-'){
                my $dis_st=$st-$st1;
                my $dis_en=$en1-$en;
                $st_new=$st2+$dis_en;
                $en_new=$en2-$dis_st;
        }

        return ($st_new,$en_new);

}


sub pos_chr{
	my ($st1,$en1,$st2,$en2,$forward,$st,$en)=@_;
	my ($st_new,$en_new)=(0,0);
	if($forward eq '+'){
		my $dis_st=$st-$st2;
		my $dis_en=$en2-$en;
		$st_new=$st1+$dis_st;
		$en_new=$en1-$dis_en;
	}elsif($forward eq '-'){
		my $dis_st=$st-$st2;
                my $dis_en=$en2-$en;
                $st_new=$st1+$dis_en;
                $en_new=$en1-$dis_st;
	}
	return ($st_new,$en_new);
}


