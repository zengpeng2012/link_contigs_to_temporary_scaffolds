#!/usr/bin/perl
my $ctg=shift;
my $agp=shift;

open IN,$ctg or die $!;
$/=">";<IN>;
while(<IN>){
	chomp;
	my($ctgid,$seq)=split(/\n/,$_,2);
	$ctgid=(split(/\s+/,$ctgid))[0];
	$seq=~s/\s+//g;
	$seq{$ctgid}=$seq;
}
close IN;

open IB,$agp or die $!;
my $chr;
my $seq;
$/="\n";
while(<IB>){
	chomp;
	my @f=split;
	if($chr ne $f[0]){
		seq_out() if($chr);
		$seq="";
		$chr=$f[0];
	}

#chr1    1       2726803 1       W       ptg000325l      3635153 6361955 -
#chr1    2726804 2727303 2       N       500     scaffold        yes     paired-ends
#

	if($f[4] eq 'W'){
		my $cut_seq=substr($seq{$f[5]},$f[6]-1,$f[7]-$f[6]+1);
		if($f[8] eq '-'){
			$cut_seq=Complement_Reverse($cut_seq);
		}
		$seq.=$cut_seq;
	}elsif($f[4] eq 'N'){
		$seq.='N' x ($f[2]-$f[1]+1);
	}else{
		print STDERR "error in ",join("\t",@f),"\n";
		exit;
	}
}
seq_out() if($chr);


sub seq_out{
	Display_seq(\$seq);
	print ">$chr\n";
	print $seq,"\n";
}

sub Display_seq{
	my $seq_p=shift;
	my $num_line=(@_) ? shift : 50; ##set the number of charcters in each line
		my $disp;

	$$seq_p =~ s/\s//g;
	for (my $i=0; $i<length($$seq_p); $i+=$num_line) {
		$disp .= substr($$seq_p,$i,$num_line)."\n";
	}
	$$seq_p = ($disp) ?  $disp : "\n";
}
#############################################
#
#
##############################################
sub Complement_Reverse{
	my $seq=shift;
	$seq=~tr/AGCTagct/TCGAtcga/;
	$seq=reverse($seq);
	return $seq;

}

