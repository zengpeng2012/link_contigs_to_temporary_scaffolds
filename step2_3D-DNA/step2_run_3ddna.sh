export PATH=/public/home/wangwen_lab/zhoubotong/soft/coreutils-8.28/corereal/bin:$PATH;
export PATH=/public/home/wangwen_lab/zhoubotong/soft/parallel-20180422/pareal/bin:$PATH;
export PATH=/public/home/wangwen_lab/zhoubotong/soft/conda3/envs/py2/bin:$PATH;
export LD_LIBRARY_PATH=/public/home/wangwen_lab/zhoubotong/soft/conda3/envs/py2/lib:$LD_LIBRARY_PATH;

ln -s ../step1_run_yahs/yahs.contigs.fa
ln -s ../step1_run_yahs/yahs_contigs_merged_nodups.txt
bash /public/home/caijing_lab/zengpeng/03.Software/HiC_assemble/3d-dna/3d-dna_z/run-asm-pipeline.sh -m haploid -i 10000 -r 0 yahs.contigs.fa yahs_contigs_merged_nodups.txt > log 2> log2
