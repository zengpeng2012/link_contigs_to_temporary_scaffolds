my $file=shift;
open IN,$file or die $!;
my $num=1;
#scaffold_7      1       158000  1       W       ptg003510l      206001  364000  -
#scaffold_7      158001  158200  2       N       200     scaffold        yes     proximity_ligation
#scaffold_7      158201  364200  3       W       ptg003510l      1       206000  -

while(<IN>){
        chomp;
	my @f=split;
	if($f[4] =~/W/){
		my $len=$f[2]-$f[1]+1;
		print "yahs_$num\t1\t$len\t$num\tW\t$f[5]\t$f[6]\t$f[7]\t$f[8]\n";
		$num++;
	}
}
close IN;
