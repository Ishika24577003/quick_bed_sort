import sys
import pandas as pd

selection_file = "standard_selection.tsv"
output_dir = "sorted_bed_file_per_sample"
sample_files = ["shuf.a.bed.gz", "shuf.b.bed.gz"]
sample_name = "X"
output_file = f"{sample_name}_{selection_file.split('.')[0]}.bed.gz"
chrom_selection = [line.strip() for line in open(standard_file)]  

rule split_bed_files:
    input:
        bed_files = sample_files
    output:
        expand("split/{sample_name}_{chrom}.bed.gz", sample_name=sample_name, chrom=[line.strip() for line in open(selection_file)])
    shell:
        """
        for file in {input.bed_files}; do
            for chrom in $(cat {selection_file}); do
                zcat $file | awk -v chrom=$chrom '{{if ($1 == chrom) {{print $0}}}}' | gzip > split/{wildcards.sample_name}_$chrom.bed.gz
            done
        done
        """

rule sort_bed_files:
    input:
        "split/{sample}_{chrom}.bed.gz"
    output:
        temp("sorted/{sample}_{chrom}.bed.gz")
    shell:
        """
        zcat {input} | sort -k1,1 -k2,2n | gzip > {output}
        """

rule merge_bed_files:
    input:
        expand("sorted/{sample_name}_{chrom}.bed.gz", sample_name=sample_name, chrom=[line.strip() for line in open(selection_file)])
    output:
        f"{output_dir}/{output_file}"
    shell:
        """
        zcat {input} | gzip > {output}
        """
