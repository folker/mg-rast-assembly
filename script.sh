#!/bin/sh
# A simple shell script for serial assembly
# this is to be turned in to a CWL workflow once proof of principle is achieved

# environment stuff
WORKDIR=/var/tmp/assembly

# MEGAHIT options
MEGAHIT_OPTS=meta ## default
# MEGAHIT_OPTS=meta-sensitive   ## uncomment for more sensitive assembly, much slower
# MEGAHIT_OPTS=meta-large   ## uncomment if data is large and complex e.g. soil

# INPUT
# our input is static for now
r1s=forward.fastq
# use only R1 if there are no R2s
r2s=reverse.fastq
files="$r1s $r2s"


#  remove Illumina adapters using cutadapt (http://cutadapt.readthedocs.io/en/stable/guide.html): 
for i in ${files}
do
	cutadapt -a AGATCGGAAGAGC -A AGATCGGAAGAGC -e 0.1 -O 5 -m 125 -o $i.trim $i
done


# quality filtering by maximum expected errors using usearch/vsearch: 
for i in ${files}
do
	vsearch -fastq_filter ${i}.trim -fastqout ${i}.maxee1.fastq -fastq_maxee 1 -fastq_maxns 0
done

# Removal of ADRs (wie?)


# talk to martin about this
# synchronise fastq and get orphans with custom script (https://github.com/enormandeau/Scripts/blob/master/fastqCombinePairedEnd.py). Ist eher langsam und würde sicherlich schneller gehen.


# Assembly using megahit (we do not accept interleaved files)

# if there either mate pairs present for all or no mate pairs (support mixed case later)
if [ -z ${r2s} ]
then
	megahit ${MEGAHIT_OPTS} -r $files -o ${WORKDIR}/assembly
elif
	megahit ${MEGAHIT_OPTS} -1 ${r1s} -2 ${r2s} -o ${WORKDIR}/assembly
fi


# Mapping using Bowtie2?

mkdir -p ${WORKDIR} ; cd ${WORKDIR}
bowtie2-build $assembled_file index

# we use all reads here... even duplicates?
# or do we use the derep results?
bowtie2 -x index -U $files -S mapping.sam

# Calculate coverages using samtools?
# see: https://github.com/voutcn/megahit/wiki/An-example-of-real-assembly

#convert sam to BAM (sort, index as well)
samtools view -bS index.sam | samtools sort - index_sorted.bam
samtools index index_sorted.bam


# get coverage info
samtools idxstats index_sorted.bam| head -n 5


# splice coverage info into fasta headers
# to be done

# find all non mapped reads 
samtools view -u -f4 index_sorted.bam | samtools bam2fq -s unmapped.se.fq - > unmapped.pe.fq


echo "Contigs are in ${WORKDIR}/assembly"
