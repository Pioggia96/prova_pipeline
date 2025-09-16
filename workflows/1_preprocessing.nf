/* include { FASTQC as FASTQC_RAW } from '../modules/fastqc'
include { FASTQC as FASTQC_TRIMMED } from '../modules/fastqc'
include { TRIMMING_BBDUK } from '../modules/trimming_bbduk'

workflow PREPROCESSING {
    take: samples

    main:
    raw_fastqc      = FASTQC_RAW(samples)
    
    def adapter_channel = Channel.fromPath(params.fasta_adapters)

    // Pass the two channels separately, not combined.
    trimmed_reads   = TRIMMING_BBDUK(samples, adapter_channel)

    trimmed_for_qc  = trimmed_reads.map { sid, proj, virus, r1, r2 -> tuple(sid, proj, virus, [r1, r2]) }
    trimmed_fastqc  = FASTQC_TRIMMED(trimmed_for_qc)

    emit:
    trimmed    = trimmed_reads
    raw_qc     = raw_fastqc.fastqc_results
    trimmed_qc = trimmed_fastqc.fastqc_results
} */

// workflows/1_preprocessing.nf

include { FASTQC as FASTQC_TRIMMED } from '../modules/fastqc'
include { TRIMMING_BBDUK } from '../modules/trimming_bbduk'

workflow PREPROCESSING {
    take: samples

    main:
    // Adapter fasta per trimming
    def adapter_channel = Channel.fromPath(params.fasta_adapters)

    // Trimming con BBDUK
    trimmed_reads_out = TRIMMING_BBDUK(samples, adapter_channel)

    // Prepara input per FastQC sulle reads trimmate
    trimmed_for_qc = trimmed_reads_out.map { sample_id, project_name, virus_to_detect, r1_clean, r2_clean ->
        tuple(sample_id, project_name, virus_to_detect, r1_clean, r2_clean)
    }

    // FastQC trimmate
    trimmed_fastqc_out = FASTQC_TRIMMED(trimmed_for_qc)

    emit:
    trimmed = trimmed_reads_out
    trimmed_qc_html = trimmed_fastqc_out.fastqc_html
    trimmed_qc_zip  = trimmed_fastqc_out.fastqc_zip
}
