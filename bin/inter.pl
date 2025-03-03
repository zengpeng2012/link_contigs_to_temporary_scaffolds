#!/usr/bin/perl
my $interaction=shift;
open IN,$interaction or die $!;
while(<IN>){
	chomp;
	my @f=split;
	next if($f[1] eq $f[5]);
	$hash{$f[1]}{$f[5]}++;
}

foreach my $ctg1(keys %hash){
	foreach my $ctg2(keys %{$hash{$ctg1}}){
		print "$ctg1\t$ctg2\t$hash{$ctg1}{$ctg2}\n";
	}
}

