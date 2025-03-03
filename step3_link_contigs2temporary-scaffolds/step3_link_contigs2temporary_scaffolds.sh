# Calculate the interaction strength between contigs
perl inter.pl ../step2_3D-DNA/yahs_contigs_merged_nodups.txt > yahs-contigs.inter.txt 

# Calculate the normalized interaction intensity between contigs
ln -s ../step2_3D-DNA/yahs.contigs.0.assembly yahs-contigs.assembly
perl ../bin/join_nearby2.pl yahs-contigs.assembly yahs-contigs.inter.txt > yahs-contigs.assembly.inter

#Ordered contigs were linked into temporary scaffolds where adjacent contigs have a normalized interaction intensity >=100
perl ../bin/cluster.pl yahs-contigs.assembly.inter > yahs-contigs.assembly.inter.cluster
perl ../bin/cluster_step2.pl yahs-contigs.assembly yahs-contigs.assembly.inter.cluster > yahs-contigs.assembly.inter.cluster.assembly
perl ../bin/join_nearby_cluster.pl  yahs-contigs.assembly.inter.cluster.assembly yahs-contigs.inter.txt > yahs-contigs.assembly.inter.cluster.assembly.matrix
perl ../bin/bed.pl yahs-contigs.assembly.inter.cluster.assembly.matrix > yahs-contigs.assembly.inter.cluster.assembly.matrix.bed
perl ../bin/bed2assembly.pl yahs-contigs.assembly.inter.cluster.assembly.matrix.bed yahs-contigs.assembly.inter.cluster.assembly > yahs-contigs.assembly.inter.cluster.new.assembly

#assembly convert to agp
perl ../bin/assembly2agp.pl  yahs-contigs.assembly.inter.cluster.new.assembly tempsca_ > yahs-contigs2tempscaffolds.agp
perl ../bin/contigAgp2chrAgp.pl  yahs-contigs2tempscaffolds.agp ../step1_run_yahs/yahs.agp  > contigs2tempscaffolds.agp
