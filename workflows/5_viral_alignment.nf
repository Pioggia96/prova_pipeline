include { BWA_MEM2_VIRUS } from '../modules/bwa_mem2_virus'

workflow VIRAL_ALIGNMENT {

    take:
    unmapped_reads_channel
    viral_index

    main:
    bwa_out = BWA_MEM2_VIRUS(unmapped_reads_channel, viral_index)

    emit:
    viral_bam = bwa_out.bwa_virus_results
}
