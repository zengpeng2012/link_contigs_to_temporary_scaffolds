#!/usr/bin/perl
my $assembly=shift;
my $prefix=shift;
my $N_size=shift;
 $N_size ||=500;
 $prefix ||="HiC_scaffold_";


#>ptg000169l 1 18611606
#>ptg000107l 2 17906788
#>ptg000231l 3 16435525
#>ptg001588l 4 16043152
#>ptg000262l 5 15284731
#>ptg000780l 6 14451695
#>ptg000185l 7 14429285
#>ptg000489l 8 14261310
#>ptg000372l 9 13192822
#>ptg000077l 10 12635817
#>ptg000403l 11 12329561
#>ptg000105l 12 12328945
#>ptg000076l:::fragment_1 13 826888
#>ptg000076l:::fragment_2:::debris 14 500000
#>ptg000076l:::fragment_3 15 8316419
#>ptg000076l:::fragment_4:::debris 16 500000
#>ptg000076l:::fragment_5 17 1947665
#

open IN,$assembly or die $!;
while(<IN>){
	chomp;
	if(/>/){
		my @f=split;
		$f[0]=~s/>//;
		my @e=split(/\:/,$f[0]);
		push @{$size{$e[0]}},[$f[1],$f[2]];
	}else{
		push @scaffold,$_;
	}
}
close IN;

foreach my $ctg(keys %size){
	my @aa=@{$size{$ctg}};
	my $pos=1;
	for(my $i=0;$i<=$#aa;$i++){
		my $end=$pos+$aa[$i][1]-1;
		$index{$aa[$i][0]}=[$ctg,$pos,$end,$aa[$i][1]];
		$pos=$end+1;
	}
}

for(my $n=0;$n<=$#scaffold;$n++){
	my $id=$n+1;
	$id=sprintf("%04d",$id);
	my @bb=split(/\s+/,$scaffold[$n]);
	my $start=1;
	my $end=0;
	my $num=0;
	for(my $i=0;$i<=$#bb;$i++){
		if($i>0){
			$end+=$N_size;	
			$num++;
			print $prefix,"",$id,"\t",$start,"\t",$end,"\t",$num,"\tN\t$N_size\tscaffold\tyes\tpaired-ends\n";
			$start=$end+1;
		}
		$num++;

		my $index=$bb[$i];
		my $strand="+";
		if($index<0){
			$strand="-";
			$index=abs($index);
		}
		my @cc=@{$index{$index}}; #[$ctgID,$st,$en,$len];
		$end+=$cc[3];
		print $prefix,"",$id,"\t",$start,"\t",$end,"\t",$num,"\tW\t",$cc[0],"\t",$cc[1],"\t",$cc[2],"\t",$strand,"\n";
		$start=$end+1;
	}
	print STDERR $prefix,"",$id,"\t",$end,"\n";
}

=pod
1. 大片段的序列名(object)
2. 大片段起始(object_begin)
3. 大片段结束(object_end)
4. 该段序列在大片段上的编号(part_number)
    一般一个大片段由多个小片段和gap组成。此处则为这些小片段和gap在大片段上的编号。
5. 该段序列的类型(component_type)
    常用的是W、N和U。W表示WGS contig；N表示指定大小的gap；U表示不明确长度的gap，一般用100bp长度。
6. 小片段的ID或gap长度(component_id or gap_length)
    如果第5列不为N或U，则此列为小片段的ID。
    如果第5列是N或U，则此列为gap的长度。如果第5列为U，则此列值必须为100。
7. 小片段起始或gap类型(component_begin or gap_type)
    如果第5列是N或U，则此列表示gap的类型。常用的值是scaffold，表示是scaffold内2个contigs之间的gap。其它值有：contig，2个contig序列之间的unspanned gap，这样的gap由于没有证据表明有gap，应该要打断大片段序列；centromere，表示中心粒的gap；short_arm，a gap inserted at the start of an acrocentric chromosome；heterochromatin，a gap inserted for an especially large region of heterochromatic sequence；telomere，a gap inserted for the telomere；repeat，an unresolvable repeat。
8. 小片段结束或gap是否被连接(component_end or linkage)
    如果第5列是N或U，则此列一般的值为yes，表示有证据表明临近的2个小片段是相连的。
9. 小片段方向或gap的连接方法(orientation or linkage_evidence)
    如果第5列不为N或U，则此列为小片段的方向。其常见的值为 +、-或？。
    如果第5列是N或U，则此列表明临近的2个小片段能连接的证据类型。其用的值是paired-ends，表明成对的reads将小片段连接起来。其它值有：na，第8列值为no的时候使用；align_genus，比对到同属的参考基因组而连接；align_xgenus，比对到其它属的参考基因组而连接；align_trnscpt，比对到同样物种的转录子序列上；within_clone，gap两边的序列来自与同一个clone，但是gap没有paired-ends跨越，因此这种连接两边小片段无法确定方向和顺序；clone_contig，linkage is provided by a clone contig in the tiling path (TPF)；map，根据连锁图，光学图等方法确定的连接；strobe，根据PacBio序列得到的连接；unspecified。如果有多中证据，则可以写上多种证据，之间用分号分割。
=cut
