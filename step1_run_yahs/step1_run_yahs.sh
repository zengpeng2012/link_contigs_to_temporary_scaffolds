#Convert the output of juicer (hi-C mapping result) to the input of YaHS
perl ../bin/merged_nodups2bed.pl ../input/contigs_merged_nodups.txt ../input/contig.size > step1_for_yahs.bed

#
ln -s ../input/contig.fa
samtools faidx contig.fa

#Run yaHS to correct contigs
/public/home/caijing_lab/zengpeng/03.Software/Yahs/c-zhou-yahs-6537efb/yahs contig.fa  step1_for_yahs.bed

#rename broken contigs.
perl ../bin/rename_yahs_agp.pl yahs.out_scaffolds_final.agp > yahs.agp 
perl ../bin/contig2chr.pl contig.fa yahs.agp > yahs.contigs.fa

#convert the output of juicer (hi-C mapping result) to the coordinates of YaHS agp.
perl ../bin/change_pos.6.pl yahs.agp ../input/contigs_merged_nodups.txt > yahs_contigs_merged_nodups.txt 

