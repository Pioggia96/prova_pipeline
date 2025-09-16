// ---------------------------------------------
// STAR: alignment to host genome
process STAR_ALIGN_HUMAN {

    tag "$sample_id"
    publishDir "${params.outdir}/${project_name}/star", mode: 'copy'

    input:
    tuple val(sample_id), val(project_name), val(virus_to_detect), path(r1_clean), path(r2_clean)
    path star_genome_dir

    output:
    tuple val(sample_id), val(project_name), val(virus_to_detect),
          path("${sample_id}.Aligned.sortedByCoord.out.bam"),
          path("${sample_id}.Unmapped.out.mate1.fastq.gz"),
          path("${sample_id}.Unmapped.out.mate2.fastq.gz"),
          path("${sample_id}.Log.final.out"), emit: star_results

    script:
    """
    echo "Running STAR alignment for sample ${sample_id}..."

    STAR \
        --runThreadN ${task.cpus} \
        --genomeDir ${star_genome_dir} \
        --readFilesCommand zcat \
        --readFilesIn ${r1_clean} ${r2_clean} \
        --outFileNamePrefix "${sample_id}." \
        --outSAMtype BAM SortedByCoordinate \
        --twopassMode Basic \
        --outFilterMultimapNmax 10 \
        --alignSJDBoverhangMin 3 \
        --outFilterMismatchNmax 999 \
        --outFilterMismatchNoverLmax 0.03 \
        --alignIntronMin 20 \
        --alignIntronMax 1000000 \
        --alignMatesGapMax 1000000 \
        --outReadsUnmapped Fastx \
        --outSAMunmapped Within \
        --outSAMattributes NH HI NM MD \
        --outSAMattrRGline ID:NEGEDIA SM:${sample_id} PL:ILLUMINA

    mv "${sample_id}.Unmapped.out.mate1" "${sample_id}.Unmapped.out.mate1.fastq.gz"
    mv "${sample_id}.Unmapped.out.mate2" "${sample_id}.Unmapped.out.mate2.fastq.gz"
    """
}
