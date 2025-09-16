// ---------------------------------------------
// BBDUK: fastq trimming and cleaning
// ---------------------------------------------

process TRIMMING_BBDUK {
    tag "${sample_id}"

    publishDir "${params.outdir}/${project_name}/trimmed", mode: 'copy'

    input:
    tuple val(sample_id), val(project_name), val(virus_to_detect), path(r1), path(r2)
    path fasta_adapters_file

    output:
    tuple val(sample_id), val(project_name), val(virus_to_detect),
         path("${sample_id}_R1.clean.fastq.gz"),
         path("${sample_id}_R2.clean.fastq.gz"), emit: trimmed_reads

    script:
    """
    echo "Processing sample: ${sample_id}, project: ${project_name}, virus: ${virus_to_detect}" //check per flusso analisi

    /bin/bbmap/bbduk.sh \
        in1=${r1} in2=${r2} \
        out1=${sample_id}_R1.clean.fastq.gz \
        out2=${sample_id}_R2.clean.fastq.gz \
        ref=${fasta_adapters_file} qtrim=rl \
        forcetrimleft=10 \
        ktrim=rl \
        k=20 mink=13 minlength=50 \
        hdist=1 useshortkmers=t \
        tpe tbo \
        stats="${sample_id}_bbduk_stats.txt"
    
    """
}
